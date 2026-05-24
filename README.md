# 🦸 Superman Plugin

> **The OpenSpec + Superpowers + Agent Skills unified AI development workflow plugin**
>
> Requirements Layer · Process Layer · Discipline Layer — bringing engineering rigor to AI-assisted development

[![npm version](https://img.shields.io/npm/v/superman-plugin.svg)](https://www.npmjs.com/package/superman-plugin)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Node.js](https://img.shields.io/badge/node-%3E%3D18-brightgreen.svg)](https://nodejs.org/)
[![Platforms](https://img.shields.io/badge/platforms-Claude%20%7C%20Cursor%20%7C%20Gemini%20%7C%20Codex%20%7C%20Copilot%20%7C%20OpenCode-blue.svg)](#platform-support)

**README:** [English](README.md) | [简体中文](README-zh_CN.md) | [繁體中文](README-zh_TW.md)

---

## Table of Contents

- [Introduction](#introduction)
- [Key Features](#key-features)
- [Quick Start](#quick-start)
- [Installation](#installation)
- [Workflow Deep Dive](#workflow-deep-dive)
- [Skill Library (21 Skills)](#skill-library)
- [Platform Support](#platform-support)
- [CI Gates](#ci-gates)
- [Context Persistence](#context-persistence)
- [CLI Reference](#cli-reference)
- [Project Structure](#project-structure)
- [Development & Contributing](#development--contributing)

---

## Introduction

Superman Plugin is a unified AI coding assistant workflow plugin that merges three battle-tested methodologies into a single, cohesive system:

| Source | Layer | Core Contribution |
|--------|-------|-------------------|
| **OpenSpec** | Requirements | Structured requirement management, spec validation |
| **Superpowers** | Process | Size-based routing, phase gating, sub-agent orchestration |
| **Agent Skills** | Discipline | Enforced TDD, security checklists, debugging protocols |

**Three phases, end to end:**

```
User requirement → [size-classify] → S / M / L
                                       │
              S: ──────────── EXECUTE ──────────────────────────────→ Done
              M: ── DEFINE Lite ── EXECUTE ── VERIFY Lite ─────────→ Done
              L: ── DEFINE Full ── EXECUTE ── VERIFY Full ─────────→ Done
                                              (CI gates enforced)
```

---

## Key Features

- **🎯 Intelligent requirement sizing** — Scores requirements across 3 dimensions (scope, time, impact) and auto-routes to the S/M/L workflow
- **📁 File-driven persistence** — All state written to `.superman/`, fully recoverable after session compression or restart
- **🔒 L-level is non-skippable** — CI gates enforce phase discipline at the code level, not relying on AI self-regulation
- **🛠️ 21 unified skills** — DEFINE / EXECUTE / VERIFY coverage, reused across all 6 platforms
- **🌐 Multi-platform sync** — One skill library, one command to sync to Claude Code, Cursor, Gemini CLI, and more
- **✅ Hard TDD gate** — Built-in anti-rationalization table that pre-blocks every excuse for skipping tests
- **🔍 Spec validation scripts** — Auto-scans for TBD placeholders, missing sections, and unreviewed markers

---

## Quick Start

```bash
# 1. Install
npm install -g superman-plugin

# 2. Initialize in your project
cd your-project
superman init

# 3. Kick off your first task — size it
# Run inside your AI assistant:
/superman:size-classify
```

The AI evaluates your requirement, declares a level (S/M/L), and automatically enters the corresponding workflow.

---

## Installation

### npm (Recommended)

```bash
npm install -g superman-plugin
superman init
```

### Manual Installation

```bash
git clone https://github.com/kevinhu1228/superman.git
cd your-project
bash /path/to/superman/scripts/install.sh .
```

### What `install.sh` Does

1. Creates the `.superman/` directory structure (`context`, `phases`, `archive`, `ci` subdirectories)
2. Runs `scripts/sync-platforms.sh` — detects which AI platforms are present in the project and writes their configs:
   - Claude Code → `CLAUDE.md` + hooks
   - Cursor → `.cursorrules` + hooks
   - Gemini CLI → `GEMINI.md` + `gemini-extension.json` + hooks
   - Codex → `AGENTS.md` + hooks
   - GitHub Copilot → `.github/copilot-instructions.md`
   - OpenCode → `.opencode/plugins/superman.js`
3. Installs the CI gates template at `.superman/ci/gates.json`
4. Recommends adding `.superman/context/`, `.superman/phases/`, and `.superman/archive/` to `.gitignore`

---

## Workflow Deep Dive

### Step 1: Requirement Sizing

Run `superman:size-classify`. The AI scores across three dimensions:

| Dimension | S (Small) | M (Medium) | L (Large) |
|-----------|-----------|------------|-----------|
| Change scope | 1 file / function | 2–5 files / modules | Cross-module / architectural |
| Time estimate | < 1 hour | 1–8 hours | > 1 day |
| Impact surface | Local | Limited spread | Global / critical path |

### Step 2: Phase Routing

| Level | DEFINE | EXECUTE | VERIFY |
|-------|--------|---------|--------|
| **S** | ❌ Skipped | ✅ Full | ❌ Inline review only |
| **M** | ⚡ Lite (one-liner goal + task list) | ✅ Full | ⚡ Lite (code-review, skip production-ready) |
| **L** | ✅ Full (spec doc + plan) | ✅ Full | ✅ Full (CI gates enforced) |

### Key Rules

- **No silent downgrading** — The AI cannot self-downgrade from L to M/S; the user must explicitly state the reason and log it in `decisions.md`
- **Spec must pass before EXECUTE** — L/M levels require `node scripts/validate-spec.js --strict` to pass before coding begins
- **TDD is non-negotiable** — `superman:tdd` has a built-in anti-rationalization table that pre-blocks all "implement first, test later" excuses
- **Incremental commits ≤ 100 lines** — `superman:incremental-impl` enforces diff splitting with an inside-out order: data structures → functions → logic → I/O → UI

---

## Skill Library

**21 skills total**, organized by phase.

### DEFINE Phase (6 skills)

| Skill | Purpose |
|-------|---------|
| `superman:size-classify` | Score across 3 dimensions, output S/M/L classification, write to `.superman/context/size-classification.md` |
| `superman:brainstorming` | Structured requirement clarification via 5 questions (goal, success criteria, constraints, boundaries, risks) |
| `superman:propose` | Generate a change proposal (`proposal.md`) along with spec and task drafts |
| `superman:spec-review` | Scan for TBD/TODO, check consistency, flag ambiguities — write "Spec Review: PASSED" on approval |
| `superman:writing-plans` | Generate a detailed implementation plan (`tasks.md`) with concrete code snippets and test commands |
| `superman:archive` | Move completed changes to `.superman/archive/YYYY-MM-DD-{name}/` and clean the working directory |

### EXECUTE Phase (8 skills)

| Skill | Purpose |
|-------|---------|
| `superman:tdd` | Enforce red-green-refactor; built-in anti-rationalization table blocks every excuse for skipping tests |
| `superman:subagent-dev` | Distribute tasks to independent sub-agents; two-stage review (spec compliance + code quality) |
| `superman:incremental-impl` | Enforce ≤ 100-line commits; inside-out implementation order (data structures → functions → logic → I/O → interface) |
| `superman:security` | Security checklist (input validation, injection prevention, auth/authz, data protection, dependencies, error handling) |
| `superman:api-design` | REST principles (resource naming, HTTP semantics, status codes, unified error format) |
| `superman:frontend-ui` | Component discipline (single responsibility, typed props, state management, accessibility, performance) |
| `superman:debugging` | 5-step debug flow (reproduce → isolate → hypothesize → verify → fix) with hypothesis tracking table |
| `superman:worktrees` | Isolate changes in `git worktree .worktrees/{feature-name}` for parallel development |

### VERIFY Phase (7 skills)

| Skill | Purpose |
|-------|---------|
| `superman:code-review` | Two-way protocol (requester provides context + focus; reviewer uses spec/security/maintainability checklist) |
| `superman:production-ready` | L-level production gate (observability, error handling, config/secrets, DB migrations, dependencies, deploy readiness) |
| `superman:spec-satisfied` | Verify every `spec.md` requirement has corresponding code and tests; generate compliance report |
| `superman:verification` | Run the app in dev/staging and manually verify the golden path and edge cases |
| `superman:git-ship` | Branch strategy (squash merge vs. merge commit) + PR creation + pre-ship checklist |
| `superman:ci-gates` | Execute all gates from `.superman/ci/gates.json` (L-level only); block merge if any gate fails |
| `superman:retrospective` | Structured retro (what worked, what was hard, what to do differently); append best practices to project knowledge base |

---

## Platform Support

Superman uses one shared `skills/` library and adapts to 6 major AI coding platforms via thin adapter layers:

| Platform | Trigger | Config File | Activation |
|----------|---------|-------------|------------|
| **Claude Code** | `/superman:*` slash commands | `plugin.json` + hooks | Direct Skill tool invocation |
| **Cursor** | `@superman` mention | `plugin.json` + `.cursorrules` | Slash command annotation |
| **Gemini CLI** | `/superman:*` commands | `gemini-extension.json` + hooks | `activate_skill` tool |
| **Codex / Agents** | Skill tool calls | `plugin.json` + hooks | Agent skill tool dispatch |
| **GitHub Copilot** | `/superman` chat command | `copilot-instructions.md` | Chat integration |
| **OpenCode** | JavaScript API | `superman.js` | Session start hook + slash command |

Sync all platform configs at once:

```bash
bash scripts/sync-platforms.sh [target-dir]
```

---

## CI Gates

Gate configuration file: `ci/gates-default.json`

**Default gates (L-level only):**

```json
{
  "gates": [
    {
      "name": "validate-skills",
      "command": "node scripts/validate-skills.js",
      "description": "Verify all SKILL.md files contain Goal and Trigger sections"
    },
    {
      "name": "spec-exists",
      "check": "file-exists",
      "path": ".superman/phases/define/spec.md",
      "description": "L-level requirements must have a spec document"
    }
  ]
}
```

Projects can extend with custom gates in `.superman/ci/gates.json` (linting, tests, security scans, etc.).

**Run CI gates:**

```bash
/superman:ci-gates
```

Any gate failure blocks merging and outputs the failure reason with remediation guidance.

---

## Context Persistence

All state is stored as files under `.superman/` — no reliance on session memory:

```
.superman/
├── context/
│   ├── requirements.md         # Append user requirements in real time; never delete
│   ├── decisions.md            # Each decision timestamped
│   └── size-classification.md  # Written once and locked — no silent changes
├── phases/
│   ├── define/
│   │   ├── proposal.md         # Change proposal
│   │   ├── spec.md             # Spec document (M/L levels)
│   │   └── tasks.md            # Implementation task list
│   ├── execute/
│   │   ├── plan.md             # Execution plan
│   │   └── progress.md         # Real-time task progress
│   └── verify/
│       ├── review.md           # Code review findings
│       └── spec-check.md       # Spec compliance report
└── ci/
    └── gates.json              # Project CI gate configuration
```

**Session recovery protocol:**

At the start of every new session, Superman checks whether `.superman/context/requirements.md` exists. If it does, it reads all `.superman/` files and announces:

```
Context restored from .superman/ — currently at EXECUTE phase, task 3/7 in progress
```

---

## CLI Reference

### `superman` Command

```bash
superman init              # Initialize Superman in the current project
superman init [target]     # Initialize in a specified directory
```

### Validation Scripts

```bash
# Validate all SKILL.md file structures
node scripts/validate-skills.js

# Validate spec documents (basic checks)
node scripts/validate-spec.js

# Strict mode — requires "Spec Review: PASSED" marker
node scripts/validate-spec.js --strict

# Validate a specific file
node scripts/validate-spec.js .superman/phases/define/spec.md
```

### Platform Sync

```bash
# Sync all detected platform configs
bash scripts/sync-platforms.sh

# Sync to a specific directory
bash scripts/sync-platforms.sh /path/to/project
```

---

## Project Structure

```
superman/
├── bin/
│   └── superman               # CLI entry point
├── skills/
│   ├── define/                # DEFINE phase skills (6)
│   │   ├── size-classify/SKILL.md
│   │   ├── brainstorming/SKILL.md
│   │   ├── propose/SKILL.md
│   │   ├── spec-review/SKILL.md
│   │   ├── writing-plans/SKILL.md
│   │   └── archive/SKILL.md
│   ├── execute/               # EXECUTE phase skills (8)
│   │   ├── tdd/SKILL.md
│   │   ├── subagent-dev/SKILL.md
│   │   ├── incremental-impl/SKILL.md
│   │   ├── security/SKILL.md
│   │   ├── api-design/SKILL.md
│   │   ├── frontend-ui/SKILL.md
│   │   ├── debugging/SKILL.md
│   │   └── worktrees/SKILL.md
│   └── verify/                # VERIFY phase skills (7)
│       ├── code-review/SKILL.md
│       ├── production-ready/SKILL.md
│       ├── spec-satisfied/SKILL.md
│       ├── verification/SKILL.md
│       ├── git-ship/SKILL.md
│       ├── ci-gates/SKILL.md
│       └── retrospective/SKILL.md
├── platforms/                 # Platform adapter layer
│   ├── claude/plugin.json
│   ├── cursor/plugin.json + cursorrules.md
│   ├── gemini/gemini-extension.json
│   ├── codex/plugin.json
│   ├── copilot/copilot-instructions.md
│   └── opencode/superman.js
├── hooks/                     # Platform hook configs
│   ├── hooks.json             # Claude Code hooks
│   ├── hooks-cursor.json
│   ├── hooks-gemini.json
│   └── hooks-codex.json
├── ci/
│   ├── gates-default.json     # Default CI gates
│   └── gates-schema.json      # Gate config JSON Schema
├── scripts/
│   ├── install.sh             # Installation script
│   ├── sync-platforms.sh      # Platform sync script
│   ├── validate-skills.js     # Skill structure validator
│   └── validate-spec.js       # Spec document validator
├── docs/
│   ├── diagrams/              # Architecture diagrams (PNG)
│   └── superpowers/           # Design specs and implementation plans
├── CLAUDE.md                  # Claude Code platform instructions
├── GEMINI.md                  # Gemini CLI platform instructions
├── AGENTS.md                  # Codex/Agents platform instructions
└── package.json
```

---

## Development & Contributing

### Prerequisites

- Node.js >= 18
- Git

### Local Development

```bash
git clone https://github.com/kevinhu1228/superman.git
cd superman
npm test           # Validate all skill file structures
npm run validate   # Same as above
npm run sync       # Sync platform configs
```

### Adding a New Skill

1. Create `SKILL.md` under `skills/{define|execute|verify}/your-skill/`
2. The file must follow this structure:
   ```markdown
   # Skill Name

   **Goal**: One sentence describing the skill's objective

   ## Trigger
   When this skill should be invoked

   ## Steps
   Execution steps
   ```
3. Run `npm test` to confirm validation passes
4. Register the skill in the relevant platform's `plugin.json`

### Design Documents

- [Design Spec](docs/superpowers/specs/2026-05-24-superman-design.md)
- [Implementation Plan A — Foundation](docs/superpowers/plans/2026-05-24-superman-plan-a-foundation.md)
- [Implementation Plan B — Skill Library](docs/superpowers/plans/2026-05-24-superman-plan-b-skills.md)
- [Implementation Plan C — Platform Adapters](docs/superpowers/plans/2026-05-24-superman-plan-c-platform.md)

---

## License

MIT © [kevinhu1228](https://github.com/kevinhu1228/superman)
