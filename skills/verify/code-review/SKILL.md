# superman:code-review

**Goal**: Ensure code meets correctness, security, and maintainability standards before merging through a two-way code review protocol (requester + reviewer) combined with a structured checklist.

**Trigger**: After each task completes in the EXECUTE phase (in the two-stage review within subagent-dev) and at the start of the VERIFY phase.

---

## Pre-Execution: Rule Selection (REQUIRED)

Before performing any code review, you MUST ask the user to choose an execution rule. Present the following options and wait for the user's response:

```
请选择 code-review 执行规则：

1. 单次 review，确认后修复
   发现缺陷后汇总，等待用户确认后再修复

2. 单次 review，自动修复
   发现缺陷后汇总并自动执行修复

3. 无限次 review，确认后修复（直到缺陷为 0）
   每次发现缺陷后等待用户确认再修复，修复完自动进入下一轮，直到缺陷为 0

4. 无限次 review，自动修复（直到缺陷为 0）
   每次发现缺陷后自动修复，修复完自动进入下一轮，直到缺陷为 0

5. 指定 n 次 review，确认后修复
   由用户指定轮数 n，每次发现缺陷后等待用户确认再修复，完成 n 轮后结束

6. 指定 n 次 review，自动修复
   由用户指定轮数 n，每次发现缺陷后自动修复，完成 n 轮后结束

请输入规则编号（选择 5 或 6 时请同时告知 n 的值）：
```

### Rule Execution Logic

After the user selects a rule, follow the corresponding execution flow:

| Rule | Fix trigger | Loop condition | End condition |
|------|-------------|----------------|---------------|
| 1 | Wait for user confirmation | No loop | After 1 review |
| 2 | Auto-fix immediately | No loop | After 1 review |
| 3 | Wait for user confirmation | Loop until 0 defects | 0 Critical/Important issues |
| 4 | Auto-fix immediately | Loop until 0 defects | 0 Critical/Important issues |
| 5 | Wait for user confirmation | Loop n times | After n rounds complete |
| 6 | Auto-fix immediately | Loop n times | After n rounds complete |

**Loop behavior (Rules 3–6)**:
1. Run code review using checklist below
2. If defects found:
   - Rule 3/5: Present findings → wait for user confirmation → fix → proceed to next round
   - Rule 4/6: Present findings → auto-fix → proceed to next round
3. If no defects found (or round limit reached): declare ✅ APPROVED and stop
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
