# superman:security

**Goal**: Perform a security self-check for each implementation step in the EXECUTE phase to prevent common vulnerabilities and ensure code meets baseline security requirements before release.

**Trigger**: After each task completes in the EXECUTE phase, run the security self-check before committing. Applies to both L and M levels.

---

## Security Self-Check Checklist

After completing each task, check the following items:

### 1. Input Validation

- [ ] All user input (forms, URL parameters, API request bodies) is validated before use
- [ ] File path operations use allowlists rather than blocklists
- [ ] Numeric type checks (integer overflow, negative numbers, NaN)
- [ ] String length limits (to prevent denial of service)

### 2. Injection Prevention

- [ ] SQL queries use parameterized queries, not string concatenation
- [ ] Shell commands use argument arrays, not string concatenation
- [ ] Template rendering escapes user data
- [ ] XML/JSON parsing protects against entity injection

### 3. Authentication and Authorization

- [ ] Every API endpoint has an explicit permission check
- [ ] Sensitive operations require a second confirmation (e.g., delete, payment)
- [ ] Session tokens have an expiry time
- [ ] Passwords use strong hashing (bcrypt/argon2), never stored in plaintext

### 4. Data Protection

- [ ] Keys and credentials are not hardcoded; use environment variables
- [ ] Sensitive data is not written to logs
- [ ] Sensitive data is transmitted over HTTPS
- [ ] Sensitive fields in the database are encrypted at rest

### 5. Dependency Security

- [ ] New dependencies come from trusted sources (official npm / PyPI / Maven)
- [ ] No dependency versions with known critical vulnerabilities

### 6. Error Handling

- [ ] Error messages do not expose internal implementation details (stack traces, paths, versions)
- [ ] Expected errors return user-friendly messages; internal errors are logged

## When a Security Issue Is Found

1. **Do not skip**: Security issues must not be marked TODO and deferred
2. Assess severity:
   - **Critical** (injection, authentication bypass) → fix immediately; do not commit code with this issue
   - **High** (missing permissions, sensitive data leak) → fix in the current task
   - **Medium/Low** (best practice violations) → fix in the current task or create a tracking issue

## Relationship with superman:ci-gates

Automatable security checks (e.g., `npm audit`) should be configured as ci-gates gate items:

```json
{
  "id": "security-audit",
  "name": "npm audit for high+ vulnerabilities",
  "command": "npm audit --audit-level=high",
  "expected_exit_code": 0,
  "phase": "verify",
  "required_level": "L"
}
```
