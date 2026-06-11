---
name: pattern-scaffold
description: "Use whenever creating a NEW directory under patterns/ or pitfalls/, or when the user says 'scaffold', 'add pattern', 'add pitfall', 'start pattern N', or 'create the directory for pitfall N'. Generates the self-contained, consistent structure every pattern and pitfall directory must follow (README skeleton, kustomization.yaml, labels, naming). All 12 directories must be structurally identical — never hand-roll one from scratch."
---

# Pattern and pitfall directory scaffolding

Every `patterns/NN-name/` and `pitfalls/NN-name/` directory is a self-contained,
applyable unit. Consistency across all 12 is a deliverable — reviewers and
readers will diff them.

## Naming

- Two-digit zero-padded number + kebab-case slug: `01-sync-waves`,
  `06-observability-blindspots`.
- Numbers match the paper outline exactly. Never renumber without updating
  `paper/outline.md` and CLAUDE.md in the same commit.

## Pattern directory structure

```
patterns/NN-slug/
├── README.md            # from templates/pattern-readme.md
├── kustomization.yaml   # standalone — `kustomize build patterns/NN-slug` must work
└── *.yaml               # the manifests demonstrating the pattern
```

README sections (use `templates/pattern-readme.md`):
1. **Problem** — 2–4 sentences, what breaks without this pattern
2. **Solution** — how the pattern works, referencing the manifests by filename
3. **Apply** — exact commands to deploy against the dev overlay
4. **When to use / tradeoffs** — honest, includes when NOT to use it
5. **Paper reference** — link to the subsection in `paper/04-patterns.md`

## Pitfall directory structure

```
pitfalls/NN-slug/
├── README.md            # from templates/pitfall-readme.md
├── reproduce/           # optional — manifests/steps that trigger the failure
│   └── kustomization.yaml
└── mitigation/          # required — corrected configuration
    └── kustomization.yaml
```

README sections (use `templates/pitfall-readme.md`):
1. **Symptom** — what the operator sees (error text, ArgoCD status, behavior)
2. **Root cause** — why it happens, mechanism-level
3. **Reproduce** — steps, or "not safely reproducible because X"
4. **Mitigation** — the fix, referencing `mitigation/` files
5. **Paper reference** — link to the subsection in `paper/05-pitfalls.md`

## Rules

- Every resource carries `app.kubernetes.io/part-of: gitops-llm-paper` — add
  via `labels:` in the directory's `kustomization.yaml`, not per-manifest.
- All images and model revisions pinned by digest/SHA. The ONLY exception is
  inside `pitfalls/02-hf-revision-drift/reproduce/`, which demonstrates the
  violation on purpose (and is allowlisted in the validate script).
- After scaffolding, run the kustomize-validate skill before committing.
- Commit message format: `feat(patterns/NN): scaffold <slug>` or
  `feat(pitfalls/NN): scaffold <slug>`.

## Templates

Copy from `templates/` in this skill directory:
- `templates/pattern-readme.md`
- `templates/pitfall-readme.md`
- `templates/kustomization.yaml`
