---
name: kustomize-validate
description: "MANDATORY after ANY change to YAML manifests, kustomization.yaml files, or anything under infra/, overlays/, patterns/, or pitfalls/. Validates kustomize builds for all overlays, lints YAML, and enforces the repo's image/model pinning rules (no :latest tags, no unpinned HuggingFace revisions). Run this BEFORE committing manifest changes — a commit with a broken overlay or unpinned reference violates the paper's own Pitfall 2. Also use when the user asks to 'validate', 'check manifests', 'run CI locally', or before opening any PR."
---

# Kustomize validation workflow

This repo is the companion artifact for a paper whose Pitfall 2 is literally
"unpinned revisions cause silent drift." The repo must practice what the paper
preaches. Validation is non-negotiable after manifest changes.

## When to run

- After creating, editing, or deleting ANY `.yaml`/`.yml` file
- After modifying any `kustomization.yaml`
- Before every commit touching `infra/`, `overlays/`, `patterns/`, or `pitfalls/`
- When the user asks to validate, lint, or check the repo

## How to run

Execute the bundled script from the repo root:

```bash
bash .claude/skills/kustomize-validate/scripts/validate.sh
```

The script performs, in order:

1. **Kustomize build check** — `kustomize build` for `overlays/dev`,
   `overlays/staging`, `overlays/prod`, and every self-contained directory in
   `patterns/` and `pitfalls/*/mitigation/` that contains a `kustomization.yaml`.
   Any non-zero exit fails validation.
2. **YAML lint** — `yamllint` with relaxed line-length (the repo ships
   `.yamllint.yaml`; if missing, use `-d "{extends: relaxed, rules: {line-length: disable}}"`).
3. **Pinning enforcement** — greps rendered output (not source, so overlays
   can't hide violations) for:
   - `image:` values using `:latest` or missing a tag/digest → FAIL
   - `revision: main`, `revision: master`, or HuggingFace model refs without a
     commit SHA → FAIL
   - Helm chart references without a pinned `version:` → FAIL
4. **Label check** — every rendered resource must carry
   `app.kubernetes.io/part-of: gitops-llm-paper` → WARN (list offenders).

## Interpreting results

- **FAIL items**: fix before committing. Never commit over a failing build or a
  pinning violation. If a pinning violation is intentional (e.g., it IS the
  reproduction case inside `pitfalls/02-hf-revision-drift/reproduce/`), the
  directory must be listed in `PINNING_ALLOWLIST` inside the script — never
  bypass by editing grep patterns.
- **WARN items**: fix in the same commit when trivial; otherwise add a
  `TODO(yash):` marker in the offending file.

## If tools are missing

If `kustomize` or `yamllint` are not installed, install them first
(`yamllint` via pip, `kustomize` via the official install script or package
manager). Do not skip validation because tooling is absent.

## Dev overlay resource budget

While validating `overlays/dev`, also verify total memory requests for the AI
platform layer stay under 8Gi (CRC/SNO constraint from CLAUDE.md). The script
prints a summed total — flag if exceeded.
