# GitOps-Driven LLM Deployment on OpenShift: Patterns and Pitfalls

This repository contains a research paper and companion reference implementation demonstrating GitOps patterns and pitfalls for deploying LLM workloads on OpenShift.

## Overview

**Paper Target:** KubeCon industry track / IEEE Software practitioner track / Red Hat Summit

**Author:** Yash Oza, Senior DevOps & Software Engineer at Red Hat

This repository provides:

1. **Research Paper** - "GitOps-Driven LLM Deployment on OpenShift: Patterns and Pitfalls"
2. **Reference Implementation** - Working ArgoCD/Kustomize manifests demonstrating every pattern

## Quick Start

### Prerequisites

- OpenShift 4.16+ cluster (or CRC/SNO for development)
- ArgoCD installed
- NVIDIA GPU Operator (for GPU-enabled overlays)

### Deploy Development Environment

```bash
# Clone repository
git clone https://github.com/yashoza19/modelops-gitops.git
cd modelops-gitops

# Build and validate manifests
./scripts/validate.sh

# Deploy to development overlay (CRC/SNO compatible)
kubectl apply -k overlays/dev
```

## Repository Structure

- `paper/` - Research paper source (Markdown + BibTeX)
- `infra/` - Infrastructure layer manifests (ArgoCD, cert-manager, etc.)
- `overlays/` - Environment-specific configurations (dev/staging/prod)
- `patterns/` - GitOps patterns implementation (1-5)
- `pitfalls/` - Common pitfalls and mitigations (1-7)
- `scripts/` - Validation and testing utilities

## Patterns Implemented

1. **Sync Waves** - Ordered LLM component bring-up
2. **Init Container Hydration** - Model weight management
3. **ModelVersion CRD** - Declarative model references
4. **App-of-Apps Fleet** - Multi-model deployment
5. **Progressive Delivery** - Argo Rollouts for LLM warm-up

## Pitfalls Addressed

1. Self-healing vs GPU scheduling conflicts
2. HuggingFace revision drift
3. Sealed secrets mount issues
4. Sync timeouts on large models
5. Quantization variant sprawl
6. Observability blind spots
7. Disaster recovery for model artifacts

## Paper

The full paper is available in the `paper/` directory. To build the submission PDF:

```bash
# Install pandoc and dependencies
# Then build paper
./scripts/build-paper.sh
```

## Contributing

This repository demonstrates production GitOps patterns for LLM workloads. All manifests are validated against OpenShift schemas and tested on CRC/SNO.

## License

[Add appropriate license]