# superman:spec-satisfied

**Goal**: Verify line by line against the spec.md generated in the DEFINE phase that the code changes from the EXECUTE phase fully implement all spec requirements.

**Trigger**: At the start of the VERIFY phase, before code-review (required for L level, Lite version for M level, skipped for S level).

---

## Execution Steps

### Step 1: Read the Spec

Read `.superman/phases/define/spec.md` and extract all functional requirement items.

If spec.md does not exist:
- L level: error, VERIFY cannot continue — spec.md must be written first
- M level: use `.superman/phases/define/tasks.md` as the verification basis instead

### Step 2: Compare Against Code

For each spec requirement, verify the implementation by:
- Reading relevant code files
- Running relevant tests (`npm test` / `pytest` / `go test`)
- If there are API endpoints: verify via curl or Chrome DevTools MCP

### Step 3: Generate Verification Report

Write the results to `.superman/phases/verify/spec-check.md`:

```
# Spec Satisfaction Verification Report

**Verified at:** {ISO timestamp}
**Requirement level:** {L/M/S}
**Spec source:** .superman/phases/define/spec.md

## Verification Results

| # | Spec Requirement | Status | Verification Method | Notes |
|---|-----------------|--------|---------------------|-------|
| 1 | User registration supports email + password | ✅ Satisfied | test: test_user_registration | - |
| 2 | Password strength check (8 chars + digit + uppercase) | ✅ Satisfied | test: test_password_strength | - |
| 3 | Send welcome email after registration | ❌ Not implemented | No related tests; code search found no email sending logic | Blocking |

## Summary

- ✅ Satisfied: {N} items
- ❌ Not satisfied: {M} items
- ⚠️ Partially satisfied: {K} items

**Conclusion: PASS / FAIL**
```

### Step 4: Handle Unsatisfied Items

If there are ❌ unsatisfied items:
1. Report to the user, explain what implementation is missing
2. User confirms → return to the EXECUTE phase to add the implementation
3. After implementation is complete, re-run spec-satisfied

If all items are satisfied (✅):
1. Append `*Spec Satisfied: PASSED [{ISO timestamp}]*` to the end of the report
2. Continue to `superman:verification`

## Lite Mode (M level)

Use tasks.md instead of spec.md:
- Only verify that each task in tasks.md has a corresponding implementation and test
- No deep spec comparison
- Generate a simplified report to spec-check.md
