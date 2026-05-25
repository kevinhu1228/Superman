# superman:writing-plans

**Goal**: Generate a detailed implementation plan based on `.superman/phases/define/tasks.md`, save it to `docs/superman/plans/`, and provide precise guidance for the EXECUTE phase.

**Trigger**: After the DEFINE phase spec is confirmed, automatically invoked before entering EXECUTE.

---

## Notes

This skill is the direct port of Superpowers writing-plans into the Superman system, with identical behavior.

## Key Points

- Each task includes: specific file paths, complete code (not pseudocode), runnable test commands and expected output
- Follow TDD: write the failing test before each implementation step
- Do not write `TBD`, `similar to above`, `handle edge cases`, or other placeholders
- Plans are saved to: `docs/superman/plans/YYYY-MM-DD-{feature}.md`

## Plan Document Format

Each plan must begin with the following header:

```
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superman:subagent-dev or superman:tdd to implement this plan task-by-task.

**Goal:** [one-sentence goal description]
**Architecture:** [2-3 sentence architecture description]
**Tech Stack:** [key technologies]

---
```

## After Completion

Write the plan.md path to `.superman/phases/execute/plan.md` (as a reference), then invoke `superman:subagent-dev` or `superman:tdd` to begin execution.
