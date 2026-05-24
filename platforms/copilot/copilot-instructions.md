# Superman Plugin — GitHub Copilot Instructions

You are operating with the Superman plugin, which enforces a structured 3-phase development workflow.

## Core Workflow

Always follow this order when a user brings a new requirement:
1. Run `/superman size-classify` to determine requirement level (S/M/L)
2. Based on level, execute the appropriate phases:
   - S: EXECUTE only (direct implementation)
   - M: DEFINE lite → EXECUTE → VERIFY lite
   - L: DEFINE (full) → EXECUTE → VERIFY (full)

## Context Persistence

At the start of every chat session:
1. Check if `.superman/context/requirements.md` exists in the workspace
2. If yes, read all `.superman/` files to restore context
3. Announce: "Context restored — currently at [phase], task [N/M]"

## Available Commands

Use `/superman` followed by skill name in GitHub Copilot Chat:

**DEFINE Phase:**
- `/superman size-classify` — classify requirement as S/M/L
- `/superman brainstorming` — structured requirement clarification (5 questions)
- `/superman propose` — create structured change proposal
- `/superman spec-review` — spec self-check (TBD scan, consistency, ambiguity)
- `/superman writing-plans` — generate detailed implementation plan
- `/superman archive` — archive completed changes

**EXECUTE Phase:**
- `/superman tdd` — test-driven development
- `/superman subagent-dev` — parallel task execution
- `/superman incremental-impl` — incremental implementation strategy
- `/superman security` — security hardening checklist
- `/superman api-design` — API design principles
- `/superman frontend-ui` — frontend engineering discipline
- `/superman debugging` — systematic debugging flow
- `/superman worktrees` — git worktree isolation

**VERIFY Phase:**
- `/superman code-review` — two-way code review protocol
- `/superman production-ready` — production readiness gate (L-level)
- `/superman spec-satisfied` — verify code matches spec
- `/superman verification` — run app and observe real behavior
- `/superman git-ship` — branch decision + pre-release checklist
- `/superman ci-gates` — CI enforcement gates (L-level)

## Key Rules

- Never skip phases for L-level requirements — CI gates enforce this
- Write to `.superman/` immediately when user states requirements
- Do not self-downgrade requirement levels without user approval and documented reason
- Invoke superman skills proactively when the situation matches a skill's trigger
