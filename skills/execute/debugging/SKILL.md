# superman:debugging

**Goal**: Locate and resolve bugs quickly through a systematic 5-step debugging process and error recovery patterns, avoiding random guessing.

**Trigger**: Triggered when tests fail, code errors, behavior is unexpected, or the user explicitly requests debugging.

---

## 5-Step Debugging Process (Superpowers core)

### Step 1: Reproduce

**Achieve stable reproduction before debugging.**

- Find the minimum reproduction steps: the fewest operations that trigger the bug
- If unable to reproduce → record the conditions and wait for the next occurrence
- Confirm reproduction succeeds before continuing

### Step 2: Isolate

**Narrow the problem to the smallest possible code unit.**

- Binary search: comment out half the code, confirm which half contains the bug
- Gradually narrow scope: system level → module level → function level → line level
- Use `git bisect` to locate the commit that introduced the bug (when git history is available)

### Step 3: Form a Hypothesis

**Write down what you believe the root cause is before looking at code.**

```
Hypothesis: {I think X caused Y because Z}
Verification method: {add a log/breakpoint at line L, check the value of variable V}
```

Do not start randomly modifying code without a hypothesis.

### Step 4: Verify the Hypothesis

- Add logs / breakpoints / temporary prints to verify the hypothesis
- If the hypothesis is correct → proceed to Step 5
- If the hypothesis is wrong → return to Step 3, form a new hypothesis

**Hypothesis tracking:**

```
[Hypothesis 1] X causes Y — verified: ❌ wrong (variable Z was 0, not null)
[Hypothesis 2] A causes B — verified: ✅ correct
```

### Step 5: Fix and Verify

- Fix the minimum scope (do not expand the change)
- Run tests, confirm the bug is gone and there are no regressions
- Remove all temporary logs / prints
- Commit the fix

## Error Recovery Patterns (Agent Skills contribution)

Choose a recovery strategy based on error type:

| Error Type | Recovery Strategy |
|------------|------------------|
| Test failure (expected vs. actual mismatch) | Check whether the test itself is correct; check whether the implementation matches the spec |
| Runtime crash / exception | Read the full stack trace; start from the innermost frame |
| Performance issue | Profile first, find the hot path, do not optimize blindly |
| State inconsistency | Find the single write point for the state, check write order |
| Third-party library error | Read the docs first, then GitHub Issues, only then change code |
| CI fails but passes locally | Check environment differences (env vars, versions, file path casing) |

## Browser DevTools Integration (Agent Skills contribution)

When debugging frontend bugs, use Chrome DevTools MCP:

```
1. navigate_page → open the target page
2. take_snapshot → confirm DOM state
3. list_console_messages → check JS errors
4. list_network_requests → check API calls
5. evaluate_script → run validation code in page context
```

## When to Stop Debugging (Escalation)

If no progress after 45 minutes:
1. Write down what is known and what hypotheses have been ruled out
2. Ask a person / AI to review the current hypothesis log
3. Consider a temporary workaround and file an issue (do not dig indefinitely)
