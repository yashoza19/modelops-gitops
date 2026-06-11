# Pattern NN — <Pattern name>

## Problem

<!-- 2–4 sentences: what breaks or degrades without this pattern. -->

## Solution

<!-- How the pattern works. Reference manifests by filename, e.g. `model-server.yaml`. -->

## Apply

```bash
kustomize build patterns/NN-slug | oc apply -f -
```

<!-- Note any prerequisites (operators, namespaces, GPU). Dev overlay must work on CRC/SNO. -->

## When to use / tradeoffs

<!-- Honest assessment, including when NOT to use this pattern. -->

## Paper reference

Section 4.N of [the paper](../../paper/04-patterns.md).
