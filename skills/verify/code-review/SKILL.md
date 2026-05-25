# superman:code-review

**Goal**: Ensure code meets correctness, security, and maintainability standards before merging through a two-way code review protocol (requester + reviewer) combined with a structured checklist.

**Trigger**: After each task completes in the EXECUTE phase (in the two-stage review within subagent-dev) and at the start of the VERIFY phase.

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
