---
name: paper-export
description: "Use when the user asks to 'export the paper', 'build the PDF', 'generate the submission', 'create the docx', 'compile the paper', or prepare any submission/review artifact from the markdown sources under paper/. Assembles the numbered section files in outline order, resolves BibTeX citations, and produces an IEEE-formatted PDF plus a docx for collaborator review. Do NOT use for drafting or editing prose — that is the paper-style skill."
---

# Paper export — markdown sources to submission artifacts

Sources: `paper/00-abstract.md` through `paper/08-conclusion.md`, plus
`paper/appendices.md` and `paper/references.bib`. Output goes to `paper/build/`
(gitignored — never commit build artifacts).

## Pre-flight checks (run BEFORE building)

1. Grep all `paper/*.md` for `TODO(yash)` and `<!-- LEGAL-REVIEW -->`.
   If any exist, list them and ask whether to proceed — a submission build
   with unresolved legal-review flags must never be sent out.
2. Verify every `[@citekey]` in the markdown resolves to an entry in
   `references.bib`. List unresolved keys as FAIL.
3. Report total word count against the 7,000–9,000 budget (exclude code
   blocks and references).

## Build commands

Assemble in outline order and convert with pandoc:

```bash
mkdir -p paper/build

# Section order is the locked outline order — do not reorder
SECTIONS="paper/00-abstract.md paper/01-introduction.md paper/02-background.md \
paper/03-reference-architecture.md paper/04-patterns.md paper/05-pitfalls.md \
paper/06-case-studies.md paper/07-discussion.md paper/08-conclusion.md \
paper/appendices.md"

# PDF — IEEE-style two-column via LaTeX
pandoc $SECTIONS \
  --citeproc --bibliography=paper/references.bib --csl=paper/ieee.csl \
  -V documentclass=IEEEtran -V classoption=conference \
  --pdf-engine=xelatex \
  -o paper/build/gitops-llm-paper.pdf

# docx — for collaborator review with tracked changes
pandoc $SECTIONS \
  --citeproc --bibliography=paper/references.bib --csl=paper/ieee.csl \
  -o paper/build/gitops-llm-paper.docx
```

Notes:
- `paper/ieee.csl` is the IEEE citation style file. If missing, download it
  once from the official CSL repository
  (https://github.com/citation-style-language/styles — `ieee.csl`) and commit
  it to `paper/`.
- If `IEEEtran.cls` is unavailable in the TeX installation, fall back to
  `-V documentclass=article -V classoption=twocolumn` and note the fallback
  in the build report — fine for drafts, not for final submission.
- If xelatex is missing, try `--pdf-engine=pdflatex`; if no LaTeX engine
  exists, produce only the docx and tell the user PDF needs a TeX install.

## Post-build report

After a successful build, report:
- Output file paths and sizes
- Total word count vs. budget, and per-section counts vs. the budgets in the
  paper-style skill
- Page count of the PDF (target: ~8 pages double-column)
- Any pre-flight WARNs that were waived

## Figures

Figures referenced as `paper/figures/*.svg` should be converted to PDF or PNG
for the LaTeX path (`rsvg-convert` or `inkscape`); pandoc cannot embed SVG in
PDF output directly. Keep the SVG sources — they are the editable originals.
