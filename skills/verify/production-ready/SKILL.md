# superman:production-ready

**Goal**: Pass the production readiness gate before entering the release process to ensure code behavior in production is predictable, monitorable, and recoverable.

**Trigger**: VERIFY phase; required for L-level requirements, skipped for M Lite, skipped for S level.

---

## Production Readiness Checklist

### 1. Observability

- [ ] Key operations have structured logging (not `console.log`)
  - Format: `{ timestamp, level, service, operation, duration_ms, result }`
- [ ] Errors have full stack traces (server side) and user-friendly messages (client side)
- [ ] Key business metrics are instrumented (registrations, payment success rate, API latency)
- [ ] Health check endpoint `/health` returns application status

### 2. Error Handling and Recovery

- [ ] All I/O operations have timeout settings (database queries, external APIs, file operations)
- [ ] Network requests have retry logic (exponential backoff, max 3 retries)
- [ ] Database operations are wrapped in transactions (avoid partial commits)
- [ ] No unhandled Promise rejections / uncaught exceptions

### 3. Configuration and Secrets

- [ ] All environment configuration is injected via environment variables
- [ ] No hardcoded production secrets, IP addresses, or port numbers
- [ ] A `.env.example` file exists listing all required environment variables
- [ ] Secrets do not appear in git history (verify with `git log -S "secret"`)

### 4. Database

- [ ] All schema changes have reversible migrations (`up` and `down`)
- [ ] New indexes have been added (verified in query plans)
- [ ] Large table operations use batch processing rather than full table scans

### 5. Dependencies

- [ ] All dependency versions are locked (`package-lock.json` / `poetry.lock` committed)
- [ ] No `latest`, `*`, or other floating versions
- [ ] `npm audit` / `safety check` passes (no high-severity vulnerabilities)

### 6. Deployment

- [ ] Code has run completely in the staging environment
- [ ] A rollback plan exists (old version container / feature flag off)
- [ ] There is a verification step after deployment (smoke test)

## When Checks Fail

When an item fails:
1. Skipping to the next step is not allowed
2. Fix the item
3. Re-check the entire checklist (a fix may affect other items)

## Relationship with superman:ci-gates

Automatable production readiness checks (e.g., `npm audit`, health check) should be configured as `superman:ci-gates` gate items for automated enforcement.
