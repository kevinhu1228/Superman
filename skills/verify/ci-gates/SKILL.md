# superman:ci-gates

**Goal**: Read `.superman/ci/gates.json`, execute all configured CI gate checks, and ensure L-level requirements pass all automated validations before merging.

**Trigger**: VERIFY phase; invoke after `superman:spec-satisfied` for L-level requirements. Skip for M and S levels.

---

## Execution Flow

### Step 1: Read Gates Configuration

```bash
cat .superman/ci/gates.json
```

If the file does not exist:
- L level: error and stop; prompt the user to configure CI gates (reference `ci/gates-default.json` in the project root)
- Empty gates array: skip and log, continue to the next step

### Step 2: Execute Each Gate

For each gate object (`{ id, name, command, expected_exit_code }`), execute:

```bash
echo "Running gate: {gate.name}"
{gate.command}
EXIT_CODE=$?

if [ $EXIT_CODE -eq {gate.expected_exit_code} ]; then
  echo "✅ PASS: {gate.name}"
else
  echo "❌ FAIL: {gate.name} (exit code: $EXIT_CODE, expected: {gate.expected_exit_code})"
fi
```

### Step 3: Summarize Results

Append results to `.superman/phases/verify/review.md`:

```
## CI Gates Results

**Executed at:** {ISO timestamp}
**Requirement level:** L

| Gate ID | Gate Name | Result | Exit Code |
|---------|-----------|--------|-----------|
| validate-skills | Validate all skill files | ✅ PASS | 0 |
| spec-exists | Spec file must exist | ✅ PASS | 0 |

**Total:** {N} gates, ✅ {P} passed, ❌ {F} failed

**Conclusion: PASS / FAIL**
```

### Step 4: Handle Failures

If any gate fails:
1. Show the gate's full output (for diagnosis)
2. Stop the VERIFY phase; do not proceed to git-ship
3. Return to the EXECUTE phase to fix the failing check
4. Re-run ci-gates after the fix

If all pass: continue to `superman:git-ship`

## Adding Custom Gates

Add project-specific checks to `.superman/ci/gates.json`:

```json
{
  "gates": [
    {
      "id": "unit-tests",
      "name": "All unit tests must pass",
      "command": "npm test",
      "expected_exit_code": 0,
      "phase": "verify",
      "required_level": "L"
    },
    {
      "id": "type-check",
      "name": "TypeScript type check",
      "command": "npx tsc --noEmit",
      "expected_exit_code": 0,
      "phase": "verify",
      "required_level": "L"
    }
  ]
}
```

## Relationship with superman:production-ready

`superman:production-ready` is a manual checklist; `superman:ci-gates` is automated enforcement. Automatable production readiness checks (e.g., `npm audit`, tests, type checking) should be configured as ci-gates to provide double assurance.
