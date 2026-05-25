# superman:worktrees

**Goal**: Create an isolated workspace in a git worktree so that EXECUTE phase changes do not affect the main branch, enabling parallel development and safe rollback.

**Trigger**: Before entering the EXECUTE phase, or when the user requests an isolated development environment.

---

## Notes

This skill is the direct port of Superpowers using-git-worktrees into the Superman system, with identical core behavior.

## When to Use

- EXECUTE phase for L-level requirements (strongly recommended)
- When parallel work on multiple features is needed
- When the main branch must remain clean and deployable

## Creating a Worktree

Run from the main repository root:

```bash
git worktree add .worktrees/{feature-name} -b {feature-branch}
```

Example:

```bash
git worktree add .worktrees/auth-refactor -b feat/auth-refactor
```

## Switching to the Worktree

```bash
cd .worktrees/{feature-name}
```

After switching, continue with EXECUTE phase tasks. All changes are on the worktree's branch and do not affect the main branch.

## Worktree Rules

- **One requirement per worktree**: Do not mix multiple features in the same worktree
- **Rebase regularly**: If the main branch has updates, run `git rebase main` from inside the worktree
- **Merge when done**: After the VERIFY phase passes, merge to the main branch via `superman:git-ship`

## Cleanup

```bash
# From the main repository root
git worktree remove .worktrees/{feature-name}
```

If the worktree has uncommitted changes:

```bash
git worktree remove --force .worktrees/{feature-name}
```

## Working with subagent-dev

When using `superman:subagent-dev`, subagents execute tasks in the worktree directory:
- Each subagent's commits are on the worktree branch
- The controller (current session) coordinates from the main repository directory
