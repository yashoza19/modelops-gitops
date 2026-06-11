---
name: paper-style
description: "ALWAYS load before writing, editing, or reviewing ANY prose under paper/ — including the abstract, any numbered section, appendices, figure captions, or references.bib. Also use when the user asks to 'draft a section', 'write the paper', 'revise the abstract', 'tighten the prose', 'check word counts', or 'add citations'. Contains the locked voice, formatting, citation, and evidence rules for the GitOps LLM paper. Writing paper prose WITHOUT this skill loaded risks violating the venue style and the author's evidence standards."
---

# Paper writing style — GitOps-Driven LLM Deployment on OpenShift

Target: KubeCon industry track / IEEE Software practitioner track.
Total budget: 7,000–9,000 words. The outline in `paper/outline.md` is LOCKED —
never restructure sections without explicit instruction from Yash.

## Voice

- First-person plural: "we observed", "we recommend". Never "I" or "the author".
- Practitioner-direct. State findings plainly. Academic hedging belongs ONLY in
  the threats-to-validity subsection (7.3).
- Honest failure reporting. The pitfalls section is the paper's value. Never
  soften a failure into a vague "challenge". Name the symptom, show the error
  message or behavior, explain the root cause.
- Banned words and phrases: "revolutionary", "game-changing", "cutting-edge",
  "seamless", "leverage" (as a verb — use "use"), "delve", "it's worth noting",
  "in today's fast-paced world". Strike on sight.

## Formatting

- Sentence case for ALL headings, including subsections.
- Code and manifest snippets: 15 lines MAXIMUM in the paper body. The full
  version lives in the repo; add a footnote linking to the exact path.
- Prose-first. No bullet lists longer than 5 items; convert long lists to
  prose or a table.
- Figures: every figure referenced in text before it appears; captions are
  full sentences ending in a period.

## Evidence standard

- Every pitfall claim needs either (a) a reproduction in `pitfalls/NN-*/` or
  (b) a citation. No exceptions.
- Never fabricate benchmark numbers, incident details, or citations. Leave a
  `TODO(yash):` marker instead and add the claim to `paper/TODO.md`.
- Performance numbers must be reproducible by a script in `scripts/` or be
  explicitly marked "illustrative" in the text.
- Anything referencing Red Hat internal systems, incidents, or unreleased
  products gets a `<!-- LEGAL-REVIEW -->` HTML comment on the same line.

## Citations

- IEEE numeric style. All entries live in `paper/references.bib` (BibTeX).
- Anchor citations the paper must include: GitOps Working Group reference
  architecture; KServe; Seldon Core; vLLM (Kwon et al., SOSP '23); Sculley et
  al., "Hidden Technical Debt in Machine Learning Systems" (NeurIPS '15);
  Gamma et al. design patterns (for the catalog framing); Nygard, *Release
  It!* (stability patterns framing).
- When citing a tool's documentation, cite a versioned/permalink URL where
  possible and include an access date.

## Section word budgets

After drafting or substantially editing a section, report its word count
against budget:

| Section | Budget |
|---|---|
| 1 Introduction | 800 |
| 2 Background | 1,200 |
| 3 Reference architecture | 1,500 |
| 4 Patterns | 2,500 |
| 5 Pitfalls | 2,000 |
| 6 Case studies | 1,000 |
| 7 Discussion | 800 |

Abstract: ~200 words, written LAST, only after sections 1–8 are stable.

## Writing order

Patterns (4) → Pitfalls (5) → Architecture (3) → Case studies (6) →
Background (2) → Introduction (1) → Discussion/Conclusion (7/8) → Abstract.

Before drafting any pattern subsection, READ the corresponding
`patterns/NN-*/README.md` and its manifests. The paper describes the repo —
never the other way around. If the manifest doesn't exist yet, build it first
or leave a `TODO(yash):` placeholder rather than describing imaginary code.
