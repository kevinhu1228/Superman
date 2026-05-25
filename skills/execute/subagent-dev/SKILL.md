# superman:subagent-dev

**Goal**: Dispatch tasks from `.superman/phases/define/tasks.md` to independent subagents for execution. Each subagent holds precise task descriptions and context; after completion, results pass through a two-stage review (spec compliance + code quality) before moving to the next task.

**Trigger**: After the DEFINE phase completes (tasks.md is ready), invoke when entering the EXECUTE phase.

---

## Notes

This skill is the direct port of Superpowers subagent-driven-development into the Superman system, with identical core behavior.

## Core Principles

- **Fresh subagent per task**: Each task dispatches a brand-new subagent that does not inherit current session context
- **Two-stage review**: After each task completes, first perform a spec compliance review, then a code quality review
- **Continuous execution**: Do not pause to ask the user between tasks unless a BLOCKED state or genuine ambiguity is encountered

## Execution Flow

### Preparation Phase

1. Read `.superman/phases/define/tasks.md` and extract the full text and context for all tasks
2. Read `.superman/phases/execute/plan.md` (if it exists) to obtain the implementation plan
3. Create progress tracking in `.superman/phases/execute/progress.md` listing all tasks
4. Create a TaskCreate entry for every task group or phase (e.g. "Phase 1: 后端脚手架 (T01-T05)"); call TaskUpdate to set the **first** group as `in_progress` before dispatching its first task. All other groups start as `pending`.

### For Each Task

**1. Dispatch implementation subagent**

Provide the subagent with:
- Full task text (extracted from tasks.md)
- Project context (stack, directory structure, relevant file paths)
- Relevant sections of spec.md (L level)
- Commit SHAs of completed tasks (for code review comparison)

Require the subagent to execute the task using the `superman:tdd` skill.

**2. Handle subagent status**

| Status | Action |
|--------|--------|
| DONE | Proceed to spec compliance review |
| DONE_WITH_CONCERNS | Read concerns; if they affect correctness, address before review |
| NEEDS_CONTEXT | Provide missing context, re-dispatch |
| BLOCKED | Evaluate blocker; provide more context / split task / escalate to user |

**3. Spec compliance review**

Dispatch a spec reviewer subagent to verify the code matches requirements in spec.md / tasks.md:
- ✅ No missing features
- ✅ No out-of-scope implementation
- ❌ Issues found → original implementer fixes → re-review

**4. Code quality review**

Dispatch a code quality reviewer subagent to check correctness, maintainability, and security:
- ❌ Important or higher issues found → fix → re-review

**5. Mark complete**

Mark the task as `[x]` in `.superman/phases/execute/progress.md`. When all tasks in the current group are done:
- Call TaskUpdate to set the current group's task entry to `completed`
- Call TaskUpdate to set the next group's task entry to `in_progress` before dispatching its first task

### Completion Phase

After all tasks are complete:
1. Call TaskUpdate to mark the last group's task entry as `completed` (if not already done in step 5)
2. Dispatch a final code review subagent (overall implementation quality)
3. Invoke `superman:git-ship`
