# superman:spec-review

**Goal**: Self-review `.superman/phases/define/spec.md` to ensure no TBDs, no contradictions, and no ambiguities; only allow entry into the EXECUTE phase after passing.

**Trigger**: Automatically invoked after `superman:propose` generates spec.md (required for L level, skipped for M level).

---

## Checklist

Execute in order; fix issues immediately without waiting for the user:

### 1. TBD Scan

Search spec.md for `TBD`, `TODO`, `FIXME`, or any unresolved placeholder.
- Found: replace with specific content or remove the item
- Cannot determine: mark as needing user clarification, pause and ask

### 2. Internal Consistency Check

- Is the architecture description consistent with the feature description?
- When interface definitions appear in multiple places, are they the same?
- Are there any circular dependencies or contradictions?

### 3. Scope Check

- Is it focused? Does all content belong to the current change scope?
- Can it be decomposed into smaller independent units?

### 4. Ambiguity Check

- Can the same requirement be implemented in two different ways?
- If so, choose one and write it explicitly into spec.md

## Pass Criteria

All checks complete with no unresolved issues → append to the end of spec.md:

```
---
*Spec Review: PASSED [{ISO timestamp}]*
```

Then continue to `superman:writing-plans`.
