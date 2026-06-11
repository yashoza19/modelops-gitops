# Appendices

## Appendix A: Full Manifests

All complete manifest implementations are available in the companion repository at:
[Repository URL]

- `patterns/` - Complete implementations of patterns 1-5
- `pitfalls/` - Reproduction cases and mitigations for pitfalls 1-7  
- `infra/` - Infrastructure layer manifests
- `overlays/` - Environment-specific configurations

## Appendix B: ArgoCD Timeout and Health Reference Configuration

[Complete ArgoCD Application configurations for LLM workloads]

### Recommended Timeout Settings
```yaml
# ArgoCD Application timeouts for LLM workloads
spec:
  syncPolicy:
    syncOptions:
      - ServerSideApply=true
    automated:
      prune: false  # Dangerous for stateful LLM workloads
      selfHeal: false  # Can fight GPU scheduling
  operation:
    sync:
      timeout: "600s"  # Large model downloads need time
```

### Health Check Customizations
[Resource-specific health checks for vLLM, model registries, etc.]

## Appendix C: LLM Serving Runtime Comparison

### Feature Comparison Matrix

| Feature | vLLM | TGI | KServe | Ollama |
|---------|------|-----|--------|--------|
| GPU Memory Efficiency | Excellent | Good | Varies | Good |
| Model Format Support | HF Transformers | HF Transformers | Multiple | GGUF, HF |
| Quantization Support | AWQ, GPTQ | AWQ, GPTQ, GGML | Runtime-dependent | Built-in |
| Kubernetes Integration | Manual/KServe | Manual/KServe | Native | Manual |
| Production Readiness | High | High | High | Medium |

### When to Choose Each Runtime

#### vLLM
- High-throughput inference requirements
- GPU memory optimization critical
- HuggingFace model ecosystem

#### TGI (Text Generation Inference)  
- HuggingFace Hub integration
- Docker-first deployment
- Comparable to vLLM performance needs

#### KServe
- Multi-framework serving requirements
- Advanced features (explainability, monitoring)
- Kubernetes-native patterns preferred

#### Ollama
- Edge deployment scenarios
- CPU-first or mixed GPU/CPU
- Simplified model management