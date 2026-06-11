#!/usr/bin/env bash
# validate.sh — repo validation for the gitops-llm-paper companion repo.
# Run from the repo root: bash .claude/skills/kustomize-validate/scripts/validate.sh

set -uo pipefail

FAIL=0
WARN=0

# Directories intentionally allowed to contain unpinned references because
# they ARE the reproduction of Pitfall 2. Keep this list short and explicit.
PINNING_ALLOWLIST=(
  "pitfalls/02-hf-revision-drift/reproduce"
)

red()    { printf '\033[31m%s\033[0m\n' "$*"; }
yellow() { printf '\033[33m%s\033[0m\n' "$*"; }
green()  { printf '\033[32m%s\033[0m\n' "$*"; }

is_allowlisted() {
  local dir="$1"
  for allowed in "${PINNING_ALLOWLIST[@]}"; do
    [[ "$dir" == *"$allowed"* ]] && return 0
  done
  return 1
}

command -v kustomize >/dev/null 2>&1 || { red "FAIL: kustomize not installed"; exit 1; }
command -v yamllint  >/dev/null 2>&1 || yellow "WARN: yamllint not installed — skipping lint"

# ---------------------------------------------------------------------------
# 1. Collect all buildable kustomization roots
# ---------------------------------------------------------------------------
BUILD_DIRS=()
for d in overlays/dev overlays/staging overlays/prod; do
  [[ -f "$d/kustomization.yaml" ]] && BUILD_DIRS+=("$d")
done
while IFS= read -r kfile; do
  BUILD_DIRS+=("$(dirname "$kfile")")
done < <(find patterns pitfalls -name kustomization.yaml 2>/dev/null)

if [[ ${#BUILD_DIRS[@]} -eq 0 ]]; then
  yellow "WARN: no kustomization.yaml files found — nothing to validate yet"
  exit 0
fi

# ---------------------------------------------------------------------------
# 2. Build + pinning + label checks on rendered output
# ---------------------------------------------------------------------------
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

for dir in "${BUILD_DIRS[@]}"; do
  out="$TMP/$(echo "$dir" | tr '/' '_').yaml"
  if ! kustomize build "$dir" > "$out" 2> "$TMP/err.log"; then
    red "FAIL: kustomize build $dir"
    sed 's/^/    /' "$TMP/err.log"
    FAIL=1
    continue
  fi
  green "OK:   kustomize build $dir"

  # --- pinning enforcement on rendered output ---
  if ! is_allowlisted "$dir"; then
    if grep -nE 'image:\s*\S+:latest(\s|$)' "$out" >/dev/null; then
      red "FAIL: :latest image tag in rendered output of $dir"
      grep -nE 'image:\s*\S+:latest(\s|$)' "$out" | sed 's/^/    /'
      FAIL=1
    fi
    if grep -nE 'image:\s*[^:@"]+\s*$' "$out" >/dev/null; then
      red "FAIL: untagged image in rendered output of $dir"
      grep -nE 'image:\s*[^:@"]+\s*$' "$out" | sed 's/^/    /'
      FAIL=1
    fi
    if grep -nE 'revision:\s*(main|master)\s*$' "$out" >/dev/null; then
      red "FAIL: unpinned revision (main/master) in rendered output of $dir"
      grep -nE 'revision:\s*(main|master)\s*$' "$out" | sed 's/^/    /'
      FAIL=1
    fi
  fi

  # --- label check (WARN) ---
  missing=$(python3 - "$out" <<'PY'
import sys, yaml
count = 0
with open(sys.argv[1]) as f:
    for doc in yaml.safe_load_all(f):
        if not isinstance(doc, dict):
            continue
        labels = (doc.get("metadata") or {}).get("labels") or {}
        if labels.get("app.kubernetes.io/part-of") != "gitops-llm-paper":
            kind = doc.get("kind", "?")
            name = (doc.get("metadata") or {}).get("name", "?")
            print(f"{kind}/{name}")
            count += 1
print(f"__COUNT__{count}", file=sys.stderr)
PY
)
  if [[ -n "$missing" ]]; then
    yellow "WARN: resources missing part-of label in $dir:"
    echo "$missing" | sed 's/^/    /'
    WARN=1
  fi
done

# ---------------------------------------------------------------------------
# 3. yamllint on source files
# ---------------------------------------------------------------------------
if command -v yamllint >/dev/null 2>&1; then
  LINT_CONF=".yamllint.yaml"
  if [[ -f "$LINT_CONF" ]]; then
    yamllint -c "$LINT_CONF" infra overlays patterns pitfalls 2>/dev/null || { yellow "WARN: yamllint findings (see above)"; WARN=1; }
  else
    yamllint -d "{extends: relaxed, rules: {line-length: disable}}" infra overlays patterns pitfalls 2>/dev/null || { yellow "WARN: yamllint findings (see above)"; WARN=1; }
  fi
fi

# ---------------------------------------------------------------------------
# 4. Dev overlay memory budget (CRC/SNO constraint: < 8Gi requested)
# ---------------------------------------------------------------------------
DEV_OUT="$TMP/overlays_dev.yaml"
if [[ -f "$DEV_OUT" ]]; then
  python3 - "$DEV_OUT" <<'PY'
import sys, yaml, re

def to_mi(v):
    v = str(v)
    m = re.match(r"^(\d+(?:\.\d+)?)(Ki|Mi|Gi|Ti|m)?$", v)
    if not m:
        return 0
    n, unit = float(m.group(1)), m.group(2)
    return {"Ki": n/1024, "Mi": n, "Gi": n*1024, "Ti": n*1024*1024, "m": 0, None: n/(1024*1024)}[unit]

total = 0.0
with open(sys.argv[1]) as f:
    for doc in yaml.safe_load_all(f):
        if not isinstance(doc, dict):
            continue
        spec = doc.get("spec") or {}
        tpl = (spec.get("template") or {}).get("spec") or {}
        for c in (tpl.get("containers") or []) + (tpl.get("initContainers") or []):
            req = ((c.get("resources") or {}).get("requests") or {}).get("memory")
            if req:
                total += to_mi(req)

gi = total / 1024
budget = 8.0
status = "OK" if gi < budget else "OVER BUDGET"
print(f"Dev overlay total memory requests: {gi:.2f}Gi / {budget:.0f}Gi budget — {status}")
sys.exit(0 if gi < budget else 2)
PY
  [[ $? -eq 2 ]] && { red "FAIL: dev overlay exceeds 8Gi memory request budget (CRC/SNO constraint)"; FAIL=1; }
fi

echo ""
if [[ $FAIL -ne 0 ]]; then
  red "VALIDATION FAILED — fix FAIL items before committing."
  exit 1
elif [[ $WARN -ne 0 ]]; then
  yellow "Validation passed with warnings."
  exit 0
else
  green "All validation checks passed."
  exit 0
fi
