# Superman Plugin — Claude Code Instructions

You are operating with the Superman plugin, which enforces a structured 3-phase development workflow.

## Core Workflow

**Always follow this order:**
1. Run `superman:size-classify` to determine requirement level (S/M/L)
2. Based on level, execute the appropriate phases:
   - S: EXECUTE only
   - M: DEFINE lite → EXECUTE → VERIFY lite
   - L: DEFINE (full) → EXECUTE → VERIFY (full)

## Context Persistence

At the start of every session:
1. Check if `.superman/context/requirements.md` exists
2. If yes, read all `.superman/` files to restore context
3. Announce: "Context restored from .superman/ — currently at [phase], task [N/M]"

## CLI Enforcement

| Command | When to use |
|---------|-------------|
| `node scripts/validate-spec.js` | After writing `.superman/phases/define/spec.md` — programmatic spec check (no TBD, required sections) |
| `node scripts/validate-spec.js --strict` | Requires "Spec Review: PASSED" marker before planning begins |
| `superman` | Installs plugin into a target project |

## Key Rules

- **Never skip phases for L-level requirements** — enforced at two levels: (1) CI gates block merge at VERIFY time; (2) the PreToolUse hook in `.claude/hooks.json` is advisory-only (prints a reminder, does not block individual tool calls)
- **Write to .superman/ immediately** when user states requirements or makes decisions
- **Do not self-downgrade** requirement levels — user must explicitly approve with reason
- **Invoke skills proactively** — if the situation matches a skill's trigger, invoke it before acting
- **Run `openspec validate` after DEFINE phase** for M/L requirements — spec must pass before EXECUTE

## Available Skills

Skills are in `skills/{define,execute,verify}/*/SKILL.md`. Load them via the Skill tool.

| Phase | Skills |
|-------|--------|
| DEFINE | size-classify, brainstorming, propose, spec-review, writing-plans, archive |
| EXECUTE | tdd, subagent-dev, incremental-impl, security, api-design, frontend-ui, debugging, worktrees |
| VERIFY | code-review, production-ready, spec-satisfied, verification, git-ship, ci-gates, retrospective |
