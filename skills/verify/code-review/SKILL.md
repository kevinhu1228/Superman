# superman:code-review

**Goal**: Ensure code meets correctness, security, and maintainability standards before merging through a two-way code review protocol (requester + reviewer) combined with a structured checklist.

**Trigger**: After each task completes in the EXECUTE phase (in the two-stage review within subagent-dev) and at the start of the VERIFY phase.

---

## Pre-Execution: Rule Selection

> **Invocation context — check this first:**
> - **Interactive** (user directly invokes `/code-review` or equivalent): present the rule-selection prompt below and wait for the user's choice before proceeding.
> - **Automated** (dispatched by `superman:subagent-dev` or any non-interactive orchestrator): skip rule selection and default to **Rule 2** (single review, auto-fix).

For interactive invocations, present the following and wait for the user's response:

```
Please select a code-review execution rule:

1. Single review, fix after confirmation
   Summarize all findings and wait for user confirmation before fixing.

2. Single review, auto-fix
   Summarize all findings and apply fixes automatically.

3. Unlimited reviews, fix after confirmation (until 0 defects)
   After each review, wait for user confirmation before fixing; then start the
   next round automatically. Stop when no defects remain.

4. Unlimited reviews, auto-fix (until 0 defects)
   After each review, apply fixes automatically; then start the next round
   automatically. Stop when no defects remain.

5. n rounds of review, fix after confirmation
   User specifies n. After each review, wait for user confirmation before
   fixing; then start the next round. Stop after n rounds.

6. n rounds of review, auto-fix
   User specifies n. After each review, apply fixes automatically; then start
   the next round. Stop after n rounds.

Enter the rule number (for rules 5 or 6, also specify the value of n):
```

**Input validation**: If the user enters an invalid rule number or non-numeric input, re-prompt once with an error message. For rules 5/6, if n is not provided, zero, or negative, re-prompt for a valid positive integer before proceeding.

### Rule Execution Logic

After the user selects a rule, follow the corresponding execution flow:

| Rule | Fix trigger | Loop condition | End condition |
|------|-------------|----------------|---------------|
| 1 | Wait for user confirmation | No loop | After 1 review + fix verification pass |
| 2 | Auto-fix immediately | No loop | After 1 review + fix verification pass |
| 3 | Wait for user confirmation | Loop until 0 defects | 0 Critical/Important issues |
| 4 | Auto-fix immediately | Loop until 0 defects | 0 Critical/Important issues |
| 5 | Wait for user confirmation | Loop n times | After n rounds complete (see exit note) |
| 6 | Auto-fix immediately | Loop n times | After n rounds complete (see exit note) |

**"Fix after confirmation" (Rules 1, 3, 5)**: present ALL findings from the current round first, then wait for a single user confirmation (e.g., "proceed") to fix all findings as a batch. Do not prompt separately for each finding.

**Rules 1 and 2 — fix verification pass**: after fixes are applied, run one final check to confirm no Critical/Important issues remain. If new issues are introduced by the fixes, report them but do not start another round.

**Loop behavior (Rules 3–6)**:
1. Run the full code-review checklist (below) from scratch on the complete diff
2. If defects found:
   - Rule 3/5: Present findings → wait for single user confirmation → fix all as a batch → proceed to next round (return to step 1)
   - Rule 4/6: Present findings → auto-fix all → proceed to next round (return to step 1)
3. Exit conditions:
   - If no defects found at the end of any round: declare ✅ APPROVED and stop
   - If round limit reached (Rules 5/6) but defects still remain: declare ⚠️ ROUND LIMIT REACHED — [N] unresolved issue(s) remain; review ended per the user-specified round limit without full approval
4. For Rule 5/6: track current round number; announce "Round X / N" at each iteration

---

## Two-Way Protocol (Superpowers contribution)

### Requester (implementer) responsibilities

When submitting for review, must provide:

1. **Change summary**: What does this PR/commit do (1–3 sentences)
2. **Test status**: Which tests were run and what were the results
3. **Focus areas**: Where the reviewer should pay special attention
4. **Out of scope**: Explicitly state what is not addressed in this change

Requester template:

```
## Code Review Request

**Change**: Add email validation logic to the User model with regex and MX record check
**Tests**: unit tests 5/5 passing; integration tests cover the happy path and three error paths
**Focus**: Timeout handling for the MX record query — not sure if 5 seconds is appropriate
**Out of scope**: Phone number validation will be handled in the next PR
```

### Reviewer responsibilities

Check against the following checklist, marking each item ✅/❌/⚠️:

#### Correctness

- [ ] Does the logic implement the spec requirements (verify against spec.md line by line)
- [ ] Are boundary conditions handled completely (null, zero, max value, concurrency)
- [ ] Are error paths covered by tests
- [ ] Error handling in async code (unhandled Promise rejections)

#### Security (baseline checks)

- [ ] Is user input validated (refer to `superman:security`)
- [ ] No hardcoded keys or credentials
- [ ] SQL/Shell/template injection risks

#### Maintainability

- [ ] Do function names describe behavior
- [ ] Single functions do not exceed 50 lines (consider splitting if exceeded)
- [ ] Duplicate code (DRY principle; extract if repeated more than 3 times)
- [ ] Do comments explain "why" (not "what")

#### Performance (only when relevant)

- [ ] Are there unnecessary I/O or computations in loops
- [ ] Are large data sets paginated or streamed

## Feedback Severity Levels

| Level | Meaning | Blocks merge |
|-------|---------|-------------|
| **Critical** | Correctness/security issue, must fix | ✅ Blocks |
| **Important** | Significantly impacts maintainability, strongly recommended to fix | ✅ Blocks |
| **Minor** | Code style / preference, optional fix | ❌ Does not block |
| **Note** | Observation and suggestion, for reference | ❌ Does not block |

## Feedback Format

```
[Critical] UserService.validate(): regex does not escape the dot,
  `user@company.com` would match `user@companyXcom`
  Suggestion: change `.` to `\.` and add a test case to verify

[Minor] Variable name `d` → suggest renaming to `userData` for readability
```

## Review Completion Criteria

- All Critical and Important issues have been fixed
- Fixes have been re-committed and the reviewer has verified them
- Reviewer explicitly declares ✅ APPROVED

## Relationship with superman:subagent-dev

`superman:subagent-dev` automatically dispatches a code reviewer subagent after each task using this skill's checklist. There is one final global code review before the last merge.
