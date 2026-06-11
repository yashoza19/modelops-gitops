#!/bin/bash
set -e

# GitOps LLM Paper - Manifest Validation Script
# Validates kustomize builds, YAML lint, and repo conventions

echo "🔍 Validating GitOps LLM Paper repository..."

# Check required tools
command -v kustomize >/dev/null 2>&1 || { echo "❌ kustomize required but not installed"; exit 1; }
command -v yamllint >/dev/null 2>&1 || { echo "❌ yamllint required but not installed"; exit 1; }

# Kustomize build validation for all overlays
echo "📦 Validating kustomize builds..."
for overlay in overlays/*/; do
  if [[ -f "$overlay/kustomization.yaml" ]]; then
    echo "  Building $overlay..."
    kustomize build "$overlay" > /dev/null || {
      echo "❌ Kustomize build failed for $overlay"
      exit 1
    }
  fi
done

# Pattern directory validation
echo "🔧 Validating patterns..."
for pattern in patterns/*/; do
  if [[ -f "$pattern/kustomization.yaml" ]]; then
    echo "  Building $pattern..."
    kustomize build "$pattern" > /dev/null || {
      echo "❌ Pattern build failed for $pattern"
      exit 1
    }
  fi
done

# Pitfall directory validation
echo "🚨 Validating pitfalls..."
for pitfall in pitfalls/*/; do
  if [[ -f "$pitfall/mitigation/kustomization.yaml" ]]; then
    echo "  Building $pitfall/mitigation..."
    kustomize build "$pitfall/mitigation" > /dev/null || {
      echo "❌ Pitfall mitigation build failed for $pitfall"
      exit 1
    }
  fi
done

# YAML linting
echo "📝 Running yamllint..."
yamllint -c .yamllint.yml . || {
  echo "❌ YAML lint failed"
  exit 1
}

# Check for forbidden patterns
echo "🔒 Checking pinning enforcement..."

# No :latest tags allowed
if find . -name "*.yaml" -exec grep -l ":latest" {} \; 2>/dev/null | grep -v ".git"; then
  echo "❌ Found :latest image tags - all images must be pinned"
  exit 1
fi

# No unpinned HuggingFace model references (this is Pitfall 2!)
if find . -name "*.yaml" -exec grep -l "huggingface.co.*model.*revision" {} \; 2>/dev/null | \
   xargs grep -L "revision.*[a-f0-9]{40}" 2>/dev/null; then
  echo "❌ Found unpinned HuggingFace model references - must use SHA commits"
  exit 1
fi

# Check app.kubernetes.io/part-of labels
echo "🏷️  Checking part-of labels..."
if find . -name "*.yaml" -exec grep -l "kind:" {} \; 2>/dev/null | \
   xargs grep -L "app.kubernetes.io/part-of.*gitops-llm-paper" 2>/dev/null | \
   grep -v -E "(kustomization\.yaml|.git)" | head -1; then
  echo "❌ Found resources missing app.kubernetes.io/part-of: gitops-llm-paper label"
  exit 1
fi

# Dev overlay memory budget check (8Gi limit for CRC/SNO compatibility)
echo "💾 Checking dev overlay memory budget..."
if [[ -f "overlays/dev/kustomization.yaml" ]]; then
  total_memory=$(kustomize build overlays/dev | \
    grep -E "memory:.*[0-9]" | \
    sed -E 's/.*memory: *([0-9]+)Gi.*/\1/' | \
    awk '{sum += $1} END {print sum}')

  if [[ ${total_memory:-0} -gt 8 ]]; then
    echo "❌ Dev overlay exceeds 8Gi memory budget (found: ${total_memory}Gi)"
    echo "   Dev must work on CRC/SNO with limited resources"
    exit 1
  fi
fi

echo "✅ All validations passed!"
echo ""
echo "🎯 Summary:"
echo "   - Kustomize builds: ✅"
echo "   - YAML lint: ✅"
echo "   - Image pinning: ✅"
echo "   - HF model pinning: ✅"
echo "   - Part-of labels: ✅"
echo "   - Dev memory budget: ✅"
echo ""
echo "Ready for commit! 🚀"