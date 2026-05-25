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

3. n rounds of review, fix after confirmation
   User specifies n. After each review, wait for user confirmation before
   fixing; then start the next round. Stop after n rounds.

4. n rounds of review, auto-fix
   User specifies n. After each review, apply fixes automatically; then start
   the next round. Stop after n rounds.

5. Unlimited reviews, fix after confirmation (until 0 defects)
   After each review, wait for user confirmation before fixing; then start the
   next round automatically. Stop when no defects remain.

6. Unlimited reviews, auto-fix (until 0 defects)
   After each review, apply fixes automatically; then start the next round
   automatically. Stop when no defects remain.

Enter the rule number (for rules 3 or 4, also specify the value of n):
```

**Input validation**: If the user enters an invalid rule number or non-numeric input, re-prompt once with an error message; if still invalid after the re-prompt, default to Rule 1 and inform the user. For rules 3/4, if n is not provided, zero, or negative, re-prompt up to 2 times for a valid positive integer; if still invalid after 2 re-prompts, default to n=3 and inform the user.

### Rule Execution Logic

After the user selects a rule, follow the corresponding execution flow:

| Rule | Fix trigger | Loop condition | End condition |
|------|-------------|----------------|---------------|
| 1 | Wait for user confirmation | No loop | After 1 review + fix verification pass |
| 2 | Auto-fix immediately | No loop | After 1 review + fix verification pass |
| 3 | Wait for user confirmation | Loop n times | After n rounds complete; see **Exit note (Rules 3/4)** in Loop behavior §3 |
| 4 | Auto-fix immediately | Loop n times | After n rounds complete; see **Exit note (Rules 3/4)** in Loop behavior §3 |
| 5 | Wait for user confirmation | Loop until 0 defects | 0 Critical/Important issues |
| 6 | Auto-fix immediately | Loop until 0 defects | 0 Critical/Important issues |

**"Fix after confirmation" (Rules 1, 3, 5)**: present ALL findings from the current round first, then wait for a single user confirmation (e.g., "proceed") to fix all findings as a batch. Do not prompt separately for each finding. If the user declines or sends a non-confirmation response, interpret as follows:
  - **"skip" or "skip fixes, continue"** (Rules 3 and 5 only — not applicable to Rule 1 which has no loop): skip the fix step for this round only and proceed to the next round (no fixes applied this round; the loop continues normally through step 3 exit conditions). For Rule 1, treat "skip" the same as "stop" — declare ⚠️ REVIEW PAUSED and stop.
  - **"stop", "no", "cancel"** or any other non-confirmation:
    - For Rule 3 on the final allowed round (round N = n): declare ⚠️ ROUND LIMIT REACHED — [N] unresolved issue(s) remain (user declined fixes on final round), and stop.
    - Otherwise: declare ⚠️ REVIEW PAUSED — user declined fixes for this round; [N] unresolved issue(s) remain; no new changes applied this round (prior-round fixes, if any, remain in place), and stop.

**Rules 1 and 2 — fix verification pass**: if the initial review finds zero defects, declare ✅ APPROVED immediately and stop. Otherwise:
- **Rule 1**: only if the user confirmed fixes — run one final check on the full branch diff from the base branch to confirm no Critical/Important issues remain. If the user declined, the REVIEW PAUSED state already applies; do not proceed to the final check.
- **Rule 2**: fixes are applied automatically — always run the final check on the full branch diff from the base branch.
- If the final check finds new issues introduced by the fixes: report them, declare ⚠️ FIX INTRODUCED NEW DEFECTS — manual review required before approval, and stop. For automated invocations (Rule 2), this is a FAILED review; the orchestrator must escalate to the user before retrying.
- If the final check is clean: declare ✅ APPROVED and stop.

**Loop behavior (Rules 3–6)** — execute every step in order each iteration; steps marked [Rules X] apply only to those rules:

- **[Rules 3/4] Step 0**: Announce "Round X / N" (X = current round, 1-indexed; N = user-specified limit)
- **Step 1**: Run the full code-review checklist from scratch on the full branch diff from the base branch
- **Step 2**: Apply fixes:
  - No defects found: skip directly to Step 3
  - Defects found + Rule 3/5, confirmed: fix all as a batch; mark any new Critical/Important defect introduced by a fix as **[Fix-Induced]** in the next round's report
  - Defects found + Rule 3/5, "skip fixes, continue": skip fix step this round; no fixes applied
  - Defects found + Rule 3/5, "stop/no/cancel": apply declination handling (see "Fix after confirmation" above) — declination handling declares a terminal state and stops; do not proceed to Steps 3–5
  - Defects found + Rule 4/6: auto-fix all; **[Fix-Induced]** note applies
- **Step 3 — Exit conditions** (**Exit note**):
  - If no defects found → declare ✅ APPROVED and **STOP** (see APPROVED note below)
  - **[Rules 3/4]** If round X = N (limit reached) and defects still remain → declare ⚠️ ROUND LIMIT REACHED — [N] unresolved issue(s) remain; review ended per user-specified limit (whether user confirmed, skipped, or declined fixes this round); **STOP**
  - Otherwise → **[Rules 3/4]** proceed to Step 4; **[Rules 5/6]** proceed to Step 5
- **[Rules 3/4] Step 4**: Increment round counter (X → X+1), then loop back to Step 0 for the next round
- **[Rules 5/6] Step 5 — Safety cap**: declare ⚠️ SAFETY CAP REACHED and **STOP** if either condition is true; otherwise loop back to Step 1 for the next round:
  - Once at least 4 rounds have elapsed, the defect count at the end of this round is not strictly less than the count 3 rounds ago (no net progress in last 3 rounds)
  - A defect with the same file and summary (line number ignored) recurs in 3 consecutive rounds **where a fix was attempted** — recurrence caused solely by skipped fixes does not count

**APPROVED note**: For all invocations (all rules), ✅ APPROVED covers the code-quality scan only. The re-commit verification and explicit human sign-off required by the Review Completion Criteria must still be completed before the change is considered fully approved.

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
