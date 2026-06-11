# Pitfall NN — <Pitfall name>

## Symptom

<!-- What the operator sees: exact error text, ArgoCD sync status, pod behavior. -->

## Root cause

<!-- Mechanism-level explanation of why this happens. -->

## Reproduce

<!-- Steps to trigger, or: "Not safely reproducible because <reason>." -->

```bash
kustomize build pitfalls/NN-slug/reproduce | oc apply -f -
```

## Mitigation

<!-- The fix. Reference files under mitigation/. -->

```bash
kustomize build pitfalls/NN-slug/mitigation | oc apply -f -
```

## Paper reference

Section 5.N of [the paper](../../paper/05-pitfalls.md).
