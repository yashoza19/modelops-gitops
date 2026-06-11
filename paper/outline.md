# Paper Outline - GitOps-Driven LLM Deployment on OpenShift: Patterns and Pitfalls

**Target Length:** 7,000–9,000 words (~8 pages IEEE double-column)

**Target Venues:** KubeCon industry track / IEEE Software practitioner track / Red Hat Summit

## Structure (LOCKED)

### 1. Abstract (~200 words)
- Gap: mismatch of LLM workloads with naive GitOps
- Contribution: 5 patterns + 7 pitfalls + reference repository

### 2. Introduction (~800 words)
- Practitioner observation
- Three research questions
- Explicit contribution list

### 3. Background (~1,200 words)
- 2.1 GitOps on OpenShift
- 2.2 LLM serving taxonomy
- 2.3 Why LLMs strain GitOps (artifact size, GPU statefulness, warm-up time)
- 2.4 Related work & positioning

### 4. Reference Architecture (~1,500 words)
- 3-layer model (platform / AI platform / apps)
- Repository structure
- Artifact handling comparison
- Secrets strategy

### 5. Patterns (~2,500 words)
The catalog. Each pattern: name, problem, solution, manifest snippet, when to use, tradeoffs

- **P1:** Sync waves for ordered LLM bring-up
- **P2:** Init containers for model weight hydration
- **P3:** ModelVersion as a CRD
- **P4:** App-of-Apps for multi-model fleets
- **P5:** Progressive delivery with Argo Rollouts (warm-up problem)

### 6. Pitfalls (~2,000 words)
Each: symptom, root cause, mitigation

- **PF1:** Self-healing fights GPU scheduling
- **PF2:** HuggingFace revision drift (tag vs SHA)
- **PF3:** Sealed secrets and file-mounted tokens
- **PF4:** Sync timeouts on large model first deploy
- **PF5:** Manifest sprawl from quantization variants
- **PF6:** Observability blind spots (pod-ready ≠ inference-healthy)
- **PF7:** Disaster recovery for model artifacts

### 7. Case Studies (~1,000 words)
- 6.1 Spending Transaction Monitor (operational lessons, anonymized)
- 6.2 OpenClaw deployment decision matrix (ROSA/ARO vs on-prem OCP vs CRC/SNO)

### 8. Discussion (~800 words)
- What GitOps gets right
- Where it strains
- Threats to validity
- Future work

### 9. Conclusion
- Summary and implications

### 10. Appendices
- **A:** Full manifests (point to repository)
- **B:** ArgoCD timeout/health reference config
- **C:** vLLM vs TGI vs KServe comparison table

## Key Citations to Include

- GitOps Working Group reference architecture
- KServe, Seldon Core
- vLLM paper (Kwon et al., SOSP '23)
- Sculley et al. "Hidden Technical Debt in ML Systems" (NeurIPS '15)
- Gamma et al. patterns framing
- Nygard's *Release It!* stability patterns

## Writing Order

1. Section 4 (patterns) → 5 (pitfalls)
2. Section 3 (architecture) → 6 (case studies)
3. Section 2 (background) → 1 (intro)
4. Sections 8/9 (discussion/conclusion)
5. Abstract LAST