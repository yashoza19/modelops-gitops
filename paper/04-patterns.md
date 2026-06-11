# 4. Patterns

<!-- Target: ~2,500 words -->
<!-- Write FIRST - this drives the implementation -->

Each pattern follows the structure: name, problem, solution, manifest snippet, when to use, tradeoffs.

## 4.1 Pattern 1: Sync Waves for Ordered LLM Bring-up

### Problem
[GPU operator → model registry → vLLM → application dependency chain]

### Solution
[ArgoCD sync wave annotations for deterministic startup order]

### Implementation
[Reference to patterns/01-sync-waves/ manifests]

### When to Use
[Multi-component LLM stacks with strict dependencies]

### Tradeoffs
[Deployment time vs reliability]

---

## 4.2 Pattern 2: Init Container Model Weight Hydration

### Problem
[Large model artifacts don't belong in container images or Git]

### Solution
[Init containers + S3/OCI registry for model artifact hydration]

### Implementation
[Reference to patterns/02-init-container-hydration/ manifests]

### When to Use
[Multi-GB model weights, air-gapped environments]

### Tradeoffs
[Storage strategy complexity vs GitOps purity]

---

## 4.3 Pattern 3: ModelVersion as a Custom Resource

### Problem
[Model references scattered across deployments, no versioning consistency]

### Solution
[ModelVersion CRD for declarative model lifecycle management]

### Implementation
[Reference to patterns/03-modelversion-crd/ manifests]

### When to Use
[Multiple models, versioning requirements, compliance tracking]

### Tradeoffs
[CRD complexity vs declarative model management]

---

## 4.4 Pattern 4: App-of-Apps for Multi-Model Fleets

### Problem
[Deploying dozens of model variants across environments]

### Solution
[ArgoCD ApplicationSets for fleet management]

### Implementation
[Reference to patterns/04-app-of-apps-fleet/ manifests]

### When to Use
[Model variant matrices, multi-tenant model serving]

### Tradeoffs
[ApplicationSet complexity vs manual application management]

---

## 4.5 Pattern 5: Progressive Delivery for LLM Warm-up

### Problem
[Model loading takes minutes, naive deployments cause downtime]

### Solution
[Argo Rollouts with readiness gates for warm-up completion]

### Implementation
[Reference to patterns/05-progressive-delivery/ manifests]

### When to Use
[Production deployments, large models with long warm-up]

### Tradeoffs
[Deployment complexity vs zero-downtime updates]