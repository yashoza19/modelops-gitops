# Paper Development TODO

Track claims that need citations, reproduction, or legal review.

## Citations Needed

- [ ] GitOps Working Group reference architecture (section 2.1) - DONE in references.bib
- [ ] KServe official documentation (section 2.2) - DONE in references.bib  
- [ ] vLLM PagedAttention paper (section 2.2) - DONE in references.bib
- [ ] Sculley ML technical debt paper (background) - DONE in references.bib
- [ ] External Secrets Operator documentation
- [ ] NVIDIA GPU Operator documentation  
- [ ] Container registry security papers
- [ ] LLM serving performance benchmarks
- [ ] GitOps security analysis papers

## Pitfalls Needing Reproduction

- [ ] PF1: Self-healing vs GPU scheduling (create reproduce/ case)
- [ ] PF2: HuggingFace revision drift (demonstrate with examples)
- [ ] PF3: Sealed secrets mount issues (reproduce file permission problem)
- [ ] PF4: Sync timeouts (demonstrate with large model)
- [ ] PF5: Quantization sprawl (show manifest explosion)
- [ ] PF6: Observability blind spots (pod ready != inference healthy)
- [ ] PF7: DR planning (show registry failure impact)

## Patterns Needing Implementation

- [ ] P1: Sync waves manifests in patterns/01-sync-waves/
- [ ] P2: Init container hydration in patterns/02-init-container-hydration/
- [ ] P3: ModelVersion CRD in patterns/03-modelversion-crd/
- [ ] P4: App-of-apps fleet in patterns/04-app-of-apps-fleet/
- [ ] P5: Progressive delivery in patterns/05-progressive-delivery/

## Performance Numbers to Collect

- [ ] vLLM vs TGI throughput comparison (mark as illustrative if not reproducible)
- [ ] Model loading times by size category
- [ ] ArgoCD sync duration for different model sizes
- [ ] GPU utilization patterns during deployment

## Legal Review Flags

Mark any sentences with `<!-- LEGAL-REVIEW -->` if they reference:
- [ ] Red Hat internal systems
- [ ] Unreleased products  
- [ ] Customer incidents
- [ ] Internal performance numbers
- [ ] Spending Transaction Monitor details (anonymize)

## Section Status

| Section | Status | Word Count | Target |
|---------|--------|------------|---------|
| Abstract | Placeholder | 0 | 200 |
| 1. Introduction | Placeholder | 0 | 800 |
| 2. Background | Placeholder | 0 | 1200 |
| 3. Reference Architecture | Placeholder | 0 | 1500 |
| 4. Patterns | Template | 0 | 2500 |
| 5. Pitfalls | Template | 0 | 2000 |
| 6. Case Studies | Placeholder | 0 | 1000 |
| 7. Discussion | Placeholder | 0 | 800 |
| 8. Conclusion | Placeholder | 0 | - |
| Appendices | Template | 0 | - |
| References | Started | - | - |

## Repository Status

- [x] Directory structure scaffolded
- [x] Paper section placeholders created
- [x] Validation script created
- [x] CI workflow created  
- [ ] Pattern directories implemented (use pattern-scaffold skill)
- [ ] Pitfall directories implemented (use pattern-scaffold skill)
- [ ] Infrastructure manifests created
- [ ] Overlay configurations created
- [ ] All kustomize builds passing