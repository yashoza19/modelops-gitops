# 5. Pitfalls

<!-- Target: ~2,000 words -->
<!-- Write SECOND after patterns - this is the paper's key value -->

Each pitfall follows the structure: symptom, root cause, mitigation.

## 5.1 Pitfall 1: Self-Healing Fights GPU Scheduling

### Symptom
[ArgoCD continuously recreates pods that Kubernetes can't schedule due to GPU constraints]

### Root Cause
[Resource requests vs cluster capacity mismatch, ArgoCD unaware of scheduling constraints]

### Mitigation
[Reference to pitfalls/01-self-healing-gpu/ mitigation config]

---

## 5.2 Pitfall 2: HuggingFace Revision Drift

### Symptom
[Model behavior changes between deployments despite "same" model reference]

### Root Cause
[HuggingFace tags point to different revisions over time, no SHA pinning]

### Mitigation
[Reference to pitfalls/02-hf-revision-drift/ mitigation config]

---

## 5.3 Pitfall 3: Sealed Secrets and File-Mounted Tokens

### Symptom
[API tokens in sealed secrets don't work when mounted as files for model downloads]

### Root Cause
[File permission and newline handling in sealed secret mounts]

### Mitigation
[Reference to pitfalls/03-sealed-secrets-mounts/ mitigation config]

---

## 5.4 Pitfall 4: Sync Timeouts on Large Model First Deploy

### Symptom
[ArgoCD sync fails with timeout during initial large model deployment]

### Root Cause
[Model download time exceeds default ArgoCD sync timeout limits]

### Mitigation
[Reference to pitfalls/04-sync-timeouts/ mitigation config]

---

## 5.5 Pitfall 5: Quantization Variant Manifest Sprawl

### Symptom
[Dozens of nearly-identical manifests for different quantization levels]

### Root Cause
[Lack of parameterization for model variant deployment]

### Mitigation
[Reference to pitfalls/05-quantization-sprawl/ mitigation config]

---

## 5.6 Pitfall 6: Observability Blind Spots

### Symptom
[Pod shows Ready but model inference fails or returns errors]

### Root Cause
[Kubernetes readiness != model loaded and inference-healthy]

### Mitigation
[Reference to pitfalls/06-observability-blindspots/ mitigation config]

---

## 5.7 Pitfall 7: Disaster Recovery for Model Artifacts

### Symptom
[Model registry failure blocks all deployments, no backup strategy]

### Root Cause
[Single point of failure in model artifact storage, no DR planning]

### Mitigation
[Reference to pitfalls/07-disaster-recovery/ mitigation config]