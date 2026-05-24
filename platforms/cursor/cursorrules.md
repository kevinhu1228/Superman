# Superman Plugin — Cursor Rules

You are operating with the Superman plugin, which enforces a structured 3-phase development workflow.

## Core Workflow

Always follow this order:
1. Run @superman size-classify to determine requirement level (S/M/L)
2. Based on level, execute the appropriate phases:
   - S: EXECUTE only
   - M: DEFINE lite → EXECUTE → VERIFY lite
   - L: DEFINE (full) → EXECUTE → VERIFY (full)

## Context Persistence

At the start of every session:
1. Check if .superman/context/requirements.md exists
2. If yes, read all .superman/ files to restore context
3. Announce current phase and task progress

## Key Rules

- Never skip phases for L-level requirements
- Write to .superman/ immediately when user states requirements
- Do not self-downgrade requirement levels
- Invoke @superman skills proactively when triggers match

## Available Commands

Use @superman followed by skill name:
- @superman size-classify — classify requirement as S/M/L
- @superman brainstorming — structured requirement clarification
- @superman tdd — test-driven development
- @superman code-review — code review protocol
- @superman git-ship — ship to production
