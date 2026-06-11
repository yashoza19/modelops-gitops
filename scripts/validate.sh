#!/bin/bash
set -euo pipefail

# GitOps LLM Paper - Manifest Validation Script
# Validates kustomize builds, YAML lint, and repo conventions

echo "Validating GitOps LLM Paper repository..."

# Check required tools
command -v kustomize >/dev/null 2>&1 || { echo "FAIL: kustomize required but not installed"; exit 1; }
command -v yamllint >/dev/null 2>&1 || { echo "FAIL: yamllint required but not installed"; exit 1; }

FAIL=0

# ---------------------------------------------------------------------------
# 1. Kustomize build validation
# ---------------------------------------------------------------------------
echo "Validating kustomize builds..."
for overlay in overlays/*/; do
  if [[ -f "$overlay/kustomization.yaml" ]]; then
    echo "  Building $overlay..."
    if ! kustomize build "$overlay" > /dev/null 2>&1; then
      echo "FAIL: Kustomize build failed for $overlay"
      kustomize build "$overlay" 2>&1 | tail -5
      FAIL=1
    fi
  fi
done

for pattern in patterns/*/; do
  if [[ -f "$pattern/kustomization.yaml" ]]; then
    echo "  Building $pattern..."
    if ! kustomize build "$pattern" > /dev/null 2>&1; then
      echo "FAIL: Pattern build failed for $pattern"
      FAIL=1
    fi
  fi
done

for pitfall in pitfalls/*/; do
  if [[ -f "$pitfall/mitigation/kustomization.yaml" ]]; then
    echo "  Building $pitfall/mitigation..."
    if ! kustomize build "$pitfall/mitigation" > /dev/null 2>&1; then
      echo "FAIL: Pitfall mitigation build failed for $pitfall"
      FAIL=1
    fi
  fi
done

# ---------------------------------------------------------------------------
# 2. YAML linting (warnings are OK, errors are not)
# ---------------------------------------------------------------------------
echo "Running yamllint..."
if ! yamllint -c .yamllint.yml . 2>&1; then
  echo "FAIL: YAML lint found errors"
  FAIL=1
fi

# ---------------------------------------------------------------------------
# 3. Pinning enforcement
# ---------------------------------------------------------------------------
echo "Checking pinning enforcement..."

# No :latest tags allowed
latest_files=$(find . -name "*.yaml" -not -path "./.git/*" -exec grep -l ":latest" {} \; 2>/dev/null || true)
if [[ -n "$latest_files" ]]; then
  echo "FAIL: Found :latest image tags - all images must be pinned"
  echo "$latest_files" | sed 's/^/    /'
  FAIL=1
fi

# No unpinned HuggingFace model references (this is Pitfall 2!)
hf_files=$(find . -name "*.yaml" -not -path "./.git/*" \
  -exec grep -l "huggingface.co.*model.*revision" {} \; 2>/dev/null || true)
if [[ -n "$hf_files" ]]; then
  unpinned=$(echo "$hf_files" | xargs grep -L "revision.*[a-f0-9]\{40\}" 2>/dev/null || true)
  if [[ -n "$unpinned" ]]; then
    echo "FAIL: Found unpinned HuggingFace model references - must use SHA commits"
    echo "$unpinned" | sed 's/^/    /'
    FAIL=1
  fi
fi

# ---------------------------------------------------------------------------
# 4. Label check
# ---------------------------------------------------------------------------
echo "Checking part-of labels..."
label_offenders=$(find . -name "*.yaml" -not -path "./.git/*" \
  -not -name "kustomization.yaml" \
  -exec grep -l "kind:" {} \; 2>/dev/null | \
  xargs grep -L "app.kubernetes.io/part-of.*gitops-llm-paper" 2>/dev/null | \
  grep -v -E "(\.git|\.claude)" || true)
if [[ -n "$label_offenders" ]]; then
  echo "WARN: Resources missing app.kubernetes.io/part-of label:"
  echo "$label_offenders" | sed 's/^/    /'
fi

# ---------------------------------------------------------------------------
# 5. Dev overlay memory budget (8Gi for CRC/SNO)
# ---------------------------------------------------------------------------
echo "Checking dev overlay memory budget..."
if [[ -f "overlays/dev/kustomization.yaml" ]]; then
  total_mi=$(kustomize build overlays/dev 2>/dev/null | \
    python3 -c "
import sys, yaml, re

def to_mi(v):
    v = str(v)
    m = re.match(r'^(\d+(?:\.\d+)?)(Ki|Mi|Gi|Ti|m)?$', v)
    if not m: return 0
    n, unit = float(m.group(1)), m.group(2)
    return {'Ki': n/1024, 'Mi': n, 'Gi': n*1024, 'Ti': n*1024*1024, 'm': 0, None: n/(1024*1024)}[unit]

total = 0.0
for doc in yaml.safe_load_all(sys.stdin):
    if not isinstance(doc, dict): continue
    spec = doc.get('spec') or {}
    tpl = (spec.get('template') or {}).get('spec') or {}
    for c in (tpl.get('containers') or []) + (tpl.get('initContainers') or []):
        req = ((c.get('resources') or {}).get('requests') or {}).get('memory')
        if req: total += to_mi(req)
print(f'{total:.0f}')
" 2>/dev/null || echo "0")

  gi=$(python3 -c "print(f'{${total_mi:-0}/1024:.2f}')")
  echo "  Dev overlay total memory requests: ${gi}Gi / 8Gi budget"
  if python3 -c "exit(0 if ${total_mi:-0}/1024 < 8 else 1)"; then
    echo "  OK: within budget"
  else
    echo "FAIL: Dev overlay exceeds 8Gi memory request budget"
    FAIL=1
  fi
fi

# ---------------------------------------------------------------------------
# Result
# ---------------------------------------------------------------------------
echo ""
if [[ $FAIL -ne 0 ]]; then
  echo "VALIDATION FAILED - fix issues before committing."
  exit 1
fi

echo "All validations passed."
