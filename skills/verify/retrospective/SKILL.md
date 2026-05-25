# superman:retrospective

**Goal**: Conduct a structured retrospective on completed tasks, distill reusable best practices, output a retrospective document for this session, and append it to the project's cumulative knowledge base.

**Trigger**: Triggered manually after any task completes, or at the end of the VERIFY phase.

---

## Execution Steps

### 1. Collect Context

Read in order (only if they exist):

- `.superman/context/requirements.md` — original requirements
- `.superman/context/size-classification.md` — complexity classification
- `.superman/context/decisions.md` — key decisions from this session
- Recent git log (`git log --oneline -20`)

If none of these files exist, inform the user and ask what they want to review.

### 2. Structured Questions (optional)

If the user has not provided feedback proactively, ask one at a time:

1. **What went most smoothly in this task?** (tools, process, methodology)
2. **What friction or surprises did you encounter? How were they resolved?**
3. **If you did it again, what would you do differently?**
4. **Any patterns or techniques worth recording?**

Ask one question at a time; wait for the user's answer before continuing.

### 3. Generate This Retrospective

Write to `.superman/context/retrospective.md` (overwrite each time):

```markdown
# Retrospective: [one-sentence requirement summary]

**Date**: YYYY-MM-DD
**Size**: S / M / L
**Phase reached**: DEFINE / EXECUTE / VERIFY

## What Was Built
[2–4 sentences describing what was delivered]

## Key Decisions
[List key decisions from decisions.md, or decision points mentioned during this retrospective]

## What Worked Well
- [specific practice or tool, with explanation of why it worked]

## What Could Be Improved
- [specific issue, with improvement suggestion]

## Best Practices Extracted
- [patterns reusable in future tasks; each entry stands alone]
```

### 4. Append Best Practices

First ensure the directory exists: `mkdir -p .superman/learnings/`

Read `.superman/learnings/best-practices.md` (create if it does not exist).

Append each practice from "Best Practices Extracted" under the following categories:

| Category | Applicable content |
|----------|-------------------|
| **Workflow** | Process order, phase transitions, task decomposition |
| **Testing** | Test strategy, coverage, TDD rhythm |
| **Architecture** | Design decisions, pattern selection, interface boundaries |
| **Tooling** | Tool usage tips, scripts, automation |
| **Communication** | Requirements clarification, decision recording, documentation habits |

Each entry format:
```
- **YYYY-MM-DD** [practice content, one readable sentence] — [source: requirement summary]
```

If a practice is highly redundant with an existing entry (same meaning), skip appending to avoid noise.

### 5. Output Summary

Show the user:

```
✅ Retrospective complete

This retrospective has been written to: .superman/context/retrospective.md
Best practices appended to: .superman/learnings/best-practices.md (N new entries)

--- Best practices extracted this session ---
• [practice 1]
• [practice 2]
...
```

---

## Output File Reference

| File | Description | Git status |
|------|-------------|-----------|
| `.superman/context/retrospective.md` | This session's retrospective, overwritten each time | gitignored |
| `.superman/learnings/best-practices.md` | Cumulative best practices, continuously appended | **committed** |

`.superman/learnings/` should be committed to the repository for team sharing. Confirm this directory is not in `.gitignore` before first use.

---

## Quality Standards

- Each best practice is **independently readable**: understandable without context
- Describe **behavior rather than outcomes**: "Write spec before designing interfaces in the DEFINE phase", not "interface design was good"
- Avoid **vague generalities**: "keep code clean" is not a best practice; "split functions into independent units of responsibility when they exceed 40 lines" is
