# superman:verification

**Goal**: Verify that code changes produce the expected user-visible behavior by operating the application in an actual running environment, without relying on assumptions about the correctness of test code.

**Trigger**: VERIFY phase; invoked after `superman:spec-satisfied` passes (applies to L/M/S levels).

---

## Notes

This skill is the direct port of Superpowers verification into the Superman system, with identical core behavior.

## Core Principle

**Tests passing ≠ feature correct.**

Tests only verify the expected behavior of code. Verification confirms the actual behavior of the application in a real environment.

## Verification Flow

### Step 1: Start the Application

Use the development/staging environment, not production.

```bash
npm run dev   # or python manage.py runserver, or go run main.go
```

Confirm the application starts successfully (no startup errors).

### Step 2: Golden Path Verification

Follow the success path described in spec.md and operate step by step:

1. Open the application (local URL)
2. Follow the steps described in the user story
3. Confirm each step produces the expected UI / response / data change

Using Chrome DevTools MCP (web applications):

1. `navigate_page` → open the application
2. `take_snapshot` → confirm initial state
3. Perform operations (`fill`, `click`, etc.)
4. `take_snapshot` → confirm state after operations
5. `take_screenshot` → preserve visual evidence

### Step 3: Boundary Condition Verification

Manually verify the following scenarios:
- Empty input / invalid input → confirm error messages match expectations
- Existing data (duplicate creation) → confirm conflict handling
- Permission boundaries → confirm unauthorized operations are correctly rejected

### Step 4: Confirm No Regressions

Quickly operate previously working features to confirm nothing was unintentionally broken.

### Step 5: Generate Verification Report

Record observations to `.superman/phases/verify/review.md`:

```
## Verification Report

**Verified at:** {ISO timestamp}
**Environment:** localhost:3000 / staging

### Golden Path
- [x] User registration → success, redirected to /dashboard
- [x] Welcome message displayed → "Welcome, {name}" shown correctly
- [x] Email verification link → received email, clicking marks as verified

### Boundary Conditions
- [x] Duplicate email registration → shows "Email already in use" error
- [x] Weak password → shows password strength requirements

### Regressions
- [x] Login function → working
- [x] User settings → working

**Conclusion: PASS**
```

## When Issues Are Found

If actual behavior does not match expectations:
1. Take a screenshot (`take_screenshot` + save file)
2. Record reproduction steps
3. Return to the EXECUTE phase to fix
4. Re-run verification after the fix
