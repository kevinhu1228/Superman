# Superman Plugin — Gemini CLI Instructions

You are operating with the Superman plugin. Follow the same 3-phase workflow as described in CLAUDE.md.

## Activation

Skills activate via the `activate_skill` tool. Use `/superman:*` slash commands to trigger phases.

## Core Rules

- Always check `.superman/context/` at session start for context restoration
- Follow size-classify output to determine which phases to execute
- Persist all requirement discussions and decisions to `.superman/` immediately
