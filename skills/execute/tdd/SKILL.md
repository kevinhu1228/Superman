# superman:tdd

**Goal**: Ensure every implementation step has test coverage by enforcing a strict "write tests first" execution order backed by an anti-rationalization firewall. No reason to skip tests is accepted.

**Trigger**: Automatically invoked at the start of the EXECUTE phase, or before each task begins in subagent-dev.

---

## Core Rules (hard gates)

**The following order is non-negotiable:**

Write failing test → Confirm test fails (RED) → Write minimal implementation → Confirm test passes (GREEN) → Commit

Any reason to bypass this order is invalid.

## Anti-Rationalization Firewall (Agent Skills contribution)

When the following excuses appear, reject immediately and continue TDD:

| Excuse | Response |
|--------|----------|
| "This logic is too simple to need a test" | Simple logic is exactly where bugs hide most easily — write the test first |
| "I'll implement the feature first and add tests later" | Tests added later never happen — write them now |
| "I tested this in my head" | Mental tests cannot catch future regressions — write the test first |
| "We're short on time, tests can wait" | Code without tests is technical debt — write the test first |
| "This is just temporary code" | Temporary code has a high probability of becoming permanent — write the test first |
| "This is too hard to test" | Hard-to-test code means the design has a problem — fix the design first, then write the test |

## Execution Steps

### Step 1: Confirm Task Boundary

Read the current task from `.superman/phases/execute/progress.md` and clarify:
- What functionality to implement (input / output / behavior)
- Test file path
- Implementation file path

### Step 2: Write the Failing Test

Write the minimal test for the task requirements:
- Test only the behavior of the current task, not unimplemented functionality
- Test names describe the expected behavior (e.g., `test_returns_error_when_input_empty`)
- Run the test, confirm **RED** (failing)

If the test unexpectedly passes → check whether the test itself is correct (the test logic may be wrong).

### Step 3: Write Minimal Implementation

Write the minimal code to make the test pass:
- Do not write code beyond what the test covers
- Do not optimize prematurely
- Run the test, confirm **GREEN** (passing)

### Step 4: Refactor (optional)

If the implementation has obvious duplication or hard-to-understand code:
- Refactor while keeping the test passing
- Do not add new functionality

### Step 5: Commit

```
git add {test_file} {impl_file}
git commit -m "feat: {specific description of the behavior implemented}"
```

### Step 6: Update Progress

Mark the current task as `[x]` in `.superman/phases/execute/progress.md` and continue to the next task.

## Task Tracking Format

`.superman/phases/execute/progress.md` is maintained as follows:

```
## Execution Progress

- [x] Task 1: description
- [ ] Task 2: description (in progress)
- [ ] Task 3: description
```
