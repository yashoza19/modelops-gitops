# CLAUDE.md — GitOps-Driven LLM Deployment on OpenShift: Patterns and Pitfalls

## Project Overview

This repository contains two coupled deliverables:

1. **A research paper** (target: KubeCon industry track / IEEE Software practitioner track / Red Hat Summit) titled *"GitOps-Driven LLM Deployment on OpenShift: Patterns and Pitfalls"*
2. **A companion reference implementation** — a working set of ArgoCD/Kustomize manifests that deploy an LLM serving stack on OpenShift, demonstrating every pattern described in the paper

The paper's credibility depends on the repo. Every pattern in the paper MUST have a corresponding, working manifest in this repo. Every pitfall MUST have a reproducible demonstration or documented mitigation config.

## Author Context

- Author: Yash Oza — Senior DevOps & Software Engineer at Red Hat
- GitHub: `yashoza19` | Email for commits: `Yash Oza <yashdoza19@gmail.com>`
- **NEVER add AI co-authorship trailers to commits** (no `Co-Authored-By: Claude`, no "Generated with Claude Code" lines). All commits are authored solely by Yash Oza.
- Background: 5+ years Kubernetes/OpenShift, ArgoCD/GitOps, CI/CD automation, AWS, AI/ML platform engineering
- Prior relevant work to draw from (do not copy verbatim; reference patterns):
  - `labargocd` — native SSL cert setup via ArgoCD sync waves
  - `opl-argocd` — GitOps/ArgoCD project
  - Spending Transaction Monitor — agentic AI quickstart (LangGraph, LlamaStack, pgvector, Kubeflow on OpenShift), published on Red Hat Developer blog

## Repository Structure

```
.
├── CLAUDE.md                  # This file
├── .claude/
│   └── skills/                # Project skills — see "Project Skills" section below
│       ├── kustomize-validate/
│       ├── paper-style/
│       ├── pattern-scaffold/
│       └── paper-export/
├── README.md                  # Repo landing page: what this is, quickstart, paper link
├── paper/
│   ├── outline.md             # Locked outline (see Paper Outline section below)
│   ├── 00-abstract.md
│   ├── 01-introduction.md
│   ├── 02-background.md
│   ├── 03-reference-architecture.md
│   ├── 04-patterns.md
│   ├── 05-pitfalls.md
│   ├── 06-case-studies.md
│   ├── 07-discussion.md
│   ├── 08-conclusion.md
│   ├── appendices.md
│   ├── references.bib         # BibTeX, IEEE style
│   └── figures/               # Architecture diagrams (draw.io / mermaid sources + exported SVG/PNG)
├── infra/
│   ├── base/                  # Platform layer: ArgoCD config, cert-manager, sealed-secrets, Tekton
│   ├── ai-platform/           # vLLM / KServe, model registry, vector DB, observability
│   ├── models/                # ModelVersion CRs — pointers to weights, never weights themselves
│   └── apps/                  # Downstream consumers: RAG service, agent orchestration
├── overlays/
│   ├── dev/                   # CRC / SNO-friendly sizing (single GPU or CPU-only fallback)
│   ├── staging/
│   └── prod/
├── patterns/                  # One directory per paper pattern, each self-contained
│   ├── 01-sync-waves/
│   ├── 02-init-container-hydration/
│   ├── 03-modelversion-crd/
│   ├── 04-app-of-apps-fleet/
│   └── 05-progressive-delivery/
├── pitfalls/                  # One directory per pitfall: reproduction + mitigation
│   ├── 01-self-healing-gpu/
│   ├── 02-hf-revision-drift/
│   ├── 03-sealed-secrets-mounts/
│   ├── 04-sync-timeouts/
│   ├── 05-quantization-sprawl/
│   ├── 06-observability-blindspots/
│   └── 07-disaster-recovery/
├── scripts/                   # Validation, smoke tests, kustomize build checks
└── .github/workflows/         # CI: kustomize build validation, yamllint, markdown lint
```

## Tech Stack & Conventions

### Manifests
- **Kustomize-first.** Base + overlays. Helm only where an upstream chart is unavoidable (wrap with Kustomize `helmCharts` or ArgoCD multi-source).
- Target platform: **OpenShift 4.16+**. Use OpenShift-native resources where they exist (`Route` over `Ingress`, `SecurityContextConstraints` awareness). Note vanilla-Kubernetes deltas in comments only when they matter for the paper.
- ArgoCD: use **ApplicationSets** for the fleet pattern, sync waves via `argocd.argoproj.io/sync-wave` annotations, health checks via `resource.customizations`.
- LLM serving: **vLLM** as the primary runtime (with KServe `ServingRuntime` as the deployment vehicle where appropriate). Document TGI/Ollama deltas in Appendix C only.
- Model artifacts: demonstrate **both** OCI-registry (KitOps/ModelKit) and S3 + init-container hydration approaches in pattern 02.
- Secrets: **External Secrets Operator** as primary, sealed-secrets as the documented alternative.
- GPU: assume NVIDIA GPU Operator. Dev overlay must work on CRC/SNO **without a GPU** (CPU-only small model, e.g., a quantized 1–3B model) so anyone can run the quickstart.

### YAML style
- 2-space indent, no tabs
- Every resource gets `app.kubernetes.io/part-of: gitops-llm-paper` label
- Pin ALL image tags and model revisions by digest/SHA — this is literally Pitfall 2, so the repo must practice what the paper preaches
- No `latest` tags anywhere, ever

### Commits
- Conventional commits: `feat:`, `fix:`, `docs:`, `chore:`
- Scope by area: `feat(patterns/03): add ModelVersion CRD and controller stub`
- Paper writing commits: `docs(paper): draft pitfalls section 5.1-5.3`
- Author: `Yash Oza <yashdoza19@gmail.com>` — no AI attribution

### CI (GitHub Actions)
- `kustomize build` must succeed for every overlay on every PR
- `yamllint` with relaxed line-length
- `markdownlint` on paper/ (allow long lines — prose)
- Optional: `kubeconform` validation against OpenShift schemas

## Paper Outline (LOCKED — do not restructure without explicit instruction)

Target length: 7,000–9,000 words, ~8 pages IEEE double-column.

1. **Abstract** (~200 words) — gap, mismatch of LLM workloads with naive GitOps, contribution: 5 patterns + 7 pitfalls + reference repo
2. **Introduction** — practitioner observation; three research questions; explicit contribution list
3. **Background** — 2.1 GitOps on OpenShift; 2.2 LLM serving taxonomy; 2.3 why LLMs strain GitOps (artifact size, GPU statefulness, warm-up time); 2.4 related work & positioning
4. **Reference Architecture** — 3-layer model (platform / AI platform / apps), repo structure, artifact handling comparison, secrets strategy
5. **Patterns** — the catalog. Each pattern: name, problem, solution, manifest snippet, when to use, tradeoffs
   - P1: Sync waves for ordered LLM bring-up
   - P2: Init containers for model weight hydration
   - P3: ModelVersion as a CRD
   - P4: App-of-Apps for multi-model fleets
   - P5: Progressive delivery with Argo Rollouts (warm-up problem)
6. **Pitfalls** — each: symptom, root cause, mitigation
   - PF1: Self-healing fights GPU scheduling
   - PF2: HuggingFace revision drift (tag vs SHA)
   - PF3: Sealed secrets and file-mounted tokens
   - PF4: Sync timeouts on large model first deploy
   - PF5: Manifest sprawl from quantization variants
   - PF6: Observability blind spots (pod-ready ≠ inference-healthy)
   - PF7: Disaster recovery for model artifacts
7. **Case Studies** — 6.1 Spending Transaction Monitor (operational lessons only, anonymize internal details, flag anything needing Red Hat legal review); 6.2 OpenClaw deployment decision matrix (ROSA/ARO vs on-prem OCP vs CRC/SNO; in-cluster vLLM vs external API)
8. **Discussion** — what GitOps gets right; where it strains; threats to validity; future work
9. **Conclusion**
10. **Appendices** — A: full manifests (point to repo); B: ArgoCD timeout/health reference config; C: vLLM vs TGI vs KServe comparison table

## Writing Style Guide (paper/)

- **Voice:** first-person plural ("we observed"), practitioner-direct, no academic hedging beyond the threats-to-validity section
- **Evidence over assertion:** every pitfall claim needs either a reproduction in `pitfalls/` or a citation
- **Honest failure reporting:** the pitfalls section is the paper's value. Do not soften failures into vague "challenges." Name the symptom, show the error, explain the root cause.
- Sentence case headings. No marketing language ("revolutionary," "game-changing" — banned).
- Code/manifest snippets in the paper: maximum 15 lines each; full versions live in the repo with a footnote link
- Citations: IEEE numeric style, maintained in `references.bib`. Key anchors to include: GitOps Working Group reference architecture, KServe, Seldon Core, vLLM paper (Kwon et al., SOSP '23), Sculley et al. "Hidden Technical Debt in ML Systems" (NeurIPS '15), the Gamma et al. patterns framing, Nygard's *Release It!* stability patterns
- All performance numbers must be reproducible by `scripts/` or clearly marked as illustrative

## Project Skills (USE THESE — do not improvise these workflows)

This repo ships four project skills in `.claude/skills/`. They are the source of
truth for their workflows; this file only summarizes when to invoke them.

| Skill | When to use |
|---|---|
| `kustomize-validate` | MANDATORY after ANY change to YAML manifests or kustomizations, and before every commit touching `infra/`, `overlays/`, `patterns/`, or `pitfalls/`. Runs `scripts/validate.sh`: kustomize builds, yamllint, pinning enforcement (rendered output), part-of label check, dev overlay 8Gi memory budget. |
| `paper-style` | ALWAYS load before writing, editing, or reviewing any prose under `paper/`. Holds voice, formatting, citation, evidence rules, and section word budgets. |
| `pattern-scaffold` | Whenever creating a new `patterns/NN-*/` or `pitfalls/NN-*/` directory. Copies the bundled templates so all 12 directories stay structurally identical. Never hand-roll one. |
| `paper-export` | When producing a submission artifact: converts `paper/*.md` + `references.bib` into IEEE-formatted PDF (and docx for collaborator review) via pandoc. Use only when the user asks for an export or a submission build. |

Rules of engagement:
- If a skill covers the task, the skill's instructions win over improvisation.
- Skill edits take effect live within a session; if a skill seems wrong, propose
  an edit to its SKILL.md rather than silently deviating.
- The pinning allowlist lives in `kustomize-validate/scripts/validate.sh` —
  never bypass validation by editing grep patterns or skipping the script.

## Workflow Instructions for Claude Code

### When building manifests
1. Start with `infra/base/`, then `ai-platform/`, then `patterns/` in numbered order
2. New `patterns/NN-*/` or `pitfalls/NN-*/` directory → use the **pattern-scaffold** skill
3. After ANY manifest change, run the **kustomize-validate** skill before committing
4. Each `patterns/NN-name/` directory is self-contained: its own `README.md` (problem → solution → apply instructions), manifests, and a `kustomization.yaml`
5. Each `pitfalls/NN-name/` directory contains: `README.md` (symptom/root-cause/mitigation), a `reproduce/` dir if feasible, and a `mitigation/` dir with corrected config
6. Dev overlay must remain runnable on CRC/SNO with no GPU — the validate script enforces the 8Gi memory request budget

### When writing paper sections
1. Load the **paper-style** skill FIRST — it holds the voice, citation, and evidence rules
2. Write sections in this order: 4 (patterns) → 5 (pitfalls) → 3 (architecture) → 6 (case studies) → 2 (background) → 1 (intro) → 8/9 (discussion/conclusion) → abstract LAST
2. Before drafting a pattern section, read the corresponding `patterns/NN-*/README.md` and manifests — the paper describes the repo, not the other way around
3. Keep a running `paper/TODO.md` of claims that need citations or reproduction
4. Flag any sentence referencing Red Hat internal systems, incidents, or unreleased products with `<!-- LEGAL-REVIEW -->` comments
5. Word count check per section after drafting; target budget: intro 800, background 1200, architecture 1500, patterns 2500, pitfalls 2000, case studies 1000, discussion 800

### When unsure
- Prefer OpenShift-native and Red Hat-ecosystem tooling when two options are equivalent
- Ask before adding new top-level directories or restructuring the outline
- Never fabricate benchmark numbers, incident details, or citations — leave `TODO(yash):` markers instead

## Definition of Done

- [ ] `kustomize build overlays/dev` succeeds and deploys cleanly on CRC/SNO
- [ ] All 5 patterns have working, documented manifests
- [ ] All 7 pitfalls have README + mitigation config (reproduction where feasible)
- [ ] CI green: kustomize validation, yamllint, markdownlint
- [ ] Paper complete at 7,000–9,000 words with all citations resolved
- [ ] Zero `TODO(yash)` markers and zero `<!-- LEGAL-REVIEW -->` flags remaining unresolved
- [ ] Submission PDF builds cleanly via the **paper-export** skill (IEEE format, all citations resolved by the bibliography pass)
- [ ] README.md quickstart tested end-to-end from a fresh clone
