# superman:archive

**Goal**: Move completed changes into the archive directory, update spec documents, and clean up the current phases/ working directory.

**Trigger**: After all VERIFY phase checks pass and `superman:git-ship` completes.

---

## Execution Steps

1. Confirm all VERIFY phase checks have passed (verify/review.md and spec-check.md exist with no unresolved items)

2. Create the archive directory:

```
mkdir -p .superman/archive/$(date +%Y-%m-%d)-{feature-name}
```

3. Copy artifacts from phases/ to the archive directory:

```
cp -r .superman/phases/ .superman/archive/$(date +%Y-%m-%d)-{feature-name}/
cp .superman/context/requirements.md .superman/archive/$(date +%Y-%m-%d)-{feature-name}/
cp .superman/context/decisions.md .superman/archive/$(date +%Y-%m-%d)-{feature-name}/
```

4. Clean up the current working directory:

```
rm -rf .superman/phases/
rm -f .superman/context/size-classification.md
```

Note: Preserve the cumulative history of `requirements.md` and `decisions.md` (do not delete; archived content remains in the archive)

5. Confirm archive completion to the user and report the archive path

## Notes

- VERIFY must be confirmed as passed before archiving; do not invoke without completed verification
- Archive path format: `.superman/archive/YYYY-MM-DD-{feature-name}/`
- If `decisions.md` does not exist (not generated for S-level requirements), skip the copy without error
