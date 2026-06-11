# 3. Reference Architecture

<!-- Target: ~1,500 words -->
<!-- Write after patterns and pitfalls sections -->

## 3.1 Three-Layer Model

### Platform Layer
[ArgoCD, cert-manager, sealed-secrets, Tekton]

### AI Platform Layer  
[vLLM, KServe, model registry, vector DB, observability]

### Applications Layer
[RAG services, agent orchestration, downstream consumers]

## 3.2 Repository Structure

[Mapping to infra/, overlays/, patterns/, pitfalls/]

## 3.3 Artifact Handling Strategies

[OCI registry vs S3 + init containers, tradeoffs]

## 3.4 Secrets Management Strategy

[External Secrets Operator vs sealed-secrets, model-specific considerations]