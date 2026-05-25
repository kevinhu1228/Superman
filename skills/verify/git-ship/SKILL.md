# superman:git-ship

**Goal**: Ensure code is safely merged to the main branch and correctly released through a structured branch decision flow and a pre-release checklist.

**Trigger**: After all VERIFY phase checks pass (spec-satisfied ✅ + verification ✅ + code-review ✅ + production-ready ✅), invoke as the final step.

---

## Branch Decision (Superpowers contribution)

### Assess Branch Status

```bash
git log main..HEAD --oneline    # number of commits this branch is ahead of main
git diff main..HEAD --stat      # change size
git log --oneline -5            # recent commit history
```

### Branch Strategy

| Situation | Strategy |
|-----------|---------|
| Single logical change | squash merge (keeps main branch history clean) |
| Multiple independent changes | merge commit (preserves branch structure) |
| Working in a worktree | create PR from the worktree branch |
| Quick fix | cherry-pick to main + tag |

### PR Creation (when GitHub is available)

```bash
gh pr create \
  --title "feat: {change description}" \
  --body "## Summary
- {main change 1}
- {main change 2}

## Test plan
- [x] Unit tests passing
- [x] Manual verification complete
- [x] spec-satisfied check passed"
```

## Pre-Release Checklist (Agent Skills contribution)

Confirm each item before submitting PR / merging:

### Code Level

- [ ] All tests pass (`npm test` / `pytest` / `go test`)
- [ ] Linting passes (no error-level warnings)
- [ ] No `console.log`, `debugger`, or temporary comments left in code
- [ ] No `TODO: fix before merge` type markers

### Documentation Level

- [ ] If public API was modified → update API docs
- [ ] If new environment variables were added → update `.env.example`
- [ ] If schema was modified → confirm migration is included

### Version Level

- [ ] Version number updated (if required)
- [ ] CHANGELOG updated (if applicable)
- [ ] All CI checks pass (GitHub Actions / CircleCI)

### After Merge

- [ ] Verify merged code on staging
- [ ] Monitor error rate for 30 minutes (if production release)
- [ ] If major release: notify relevant teams

## Smoke Test (post-merge verification)

```bash
# Switch back to main branch
git checkout main
git pull

# Quickly verify key functionality (2–3 most important operations)
curl http://localhost:3000/health   # API health check
# or manually open the application and verify one core flow
```

## Invoke superman:archive

After git-ship completes, invoke `superman:archive` to archive all .superman/ artifacts from this change.
