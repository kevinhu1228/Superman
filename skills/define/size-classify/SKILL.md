# superman:size-classify

**Goal**: Score an incoming requirement across three dimensions and output an S/M/L classification, writing the result to `.superman/context/size-classification.md`.

**Trigger**: When the user raises a new requirement, invoke this skill before any other skill.

---

## Scoring Method

Score the requirement on three independent dimensions (1–3 each):

| Score | Dimension A: Change Scope | Dimension B: Time Estimate | Dimension C: Impact |
|-------|--------------------------|---------------------------|---------------------|
| 1 | Single file / single function | < 30 minutes | Private code only |
| 2 | Cross-module / multiple files | 30 minutes – 2 hours | Touches API / public interface |
| 3 | New system / architectural refactor | > 2 hours | Multi-team / production impact |

**Overall score = max(A, B, C)** — any dimension reaching the threshold upgrades the whole requirement.

## Classification Rules

| Level | Condition | DEFINE | EXECUTE | VERIFY |
|-------|-----------|--------|---------|--------|
| S Small | max ≤ 1 | Skip | Full | Skip |
| M Medium | max = 2 | Lite | Full | Lite |
| L Large | max = 3 | Full (required) | Full (required) | Full (required) |

## Execution Steps

1. Show the three-dimension scoring table to the user; ask for scores or self-score based on the requirement description
2. Compute `max(A, B, C)` to determine the level
3. **WRITE FIRST — before announcing the result:** Call Write to create `.superman/context/size-classification.md`. This write MUST happen before any other response content (announcement, next steps, etc.). Do not defer or skip.

```markdown
# Requirement Classification

**Requirement:** {original user requirement}
**Classified at:** {ISO timestamp}

| Dimension | Score | Rationale |
|-----------|-------|-----------|
| A Change Scope | {1/2/3} | {explanation} |
| B Time Estimate | {1/2/3} | {explanation} |
| C Impact       | {1/2/3} | {explanation} |

**Overall Level: {S/M/L}**
**Routing:** {DEFINE→EXECUTE→VERIFY or skip explanation}

---
*Note: AI must not self-downgrade. User-initiated downgrades must be recorded with a reason in requirements.md.*
```

4. Announce the classification result to the user and explain which phases will be executed
5. Invoke the next skill (M/L: `superman:brainstorming`; S: jump to the appropriate EXECUTE skill)

## Downgrade Rules

AI must not self-downgrade. If the user requests a downgrade:
1. Append to the end of `requirements.md`: `[Downgrade Record] {timestamp} User downgraded {original level} to {new level}, reason: {user explanation}`
2. Update the level field in `size-classification.md` and note "manually downgraded"
