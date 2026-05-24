# Superman Plugin — Plan C: Platform Adapters, CI & Distribution

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为 Superman 插件创建 6 个平台适配器配置、4 个 hooks 触发规则文件、GitHub Actions CI、pre-commit 配置、sync-platforms.sh 同步脚本，以及 npm 发布配置，使插件可通过三种渠道分发。

**Architecture:** 纯配置文件 + shell 脚本。所有平台共享同一套 `skills/` 目录，适配器层只负责指令注入、触发映射和钩子配置。install.sh 负责将这些配置文件写入目标项目。

**Tech Stack:** JSON, YAML, JavaScript (OpenCode plugin API), Bash, GitHub Actions

---

## 文件清单

| 操作 | 路径 | 职责 |
|------|------|------|
| Create | `platforms/claude/plugin.json` | Claude Code 插件清单，注册 20 个技能和斜线命令 |
| Create | `platforms/cursor/plugin.json` | Cursor 插件清单 |
| Create | `platforms/cursor/cursorrules.md` | `.cursorrules` 模板内容 |
| Create | `platforms/gemini/gemini-extension.json` | Gemini CLI 扩展清单 |
| Create | `platforms/codex/plugin.json` | Codex 插件清单 |
| Create | `platforms/copilot/copilot-instructions.md` | Copilot Chat 指令模板 |
| Create | `platforms/opencode/superman.js` | OpenCode JavaScript 插件 |
| Create | `hooks/hooks.json` | Claude Code hooks（会话启动 + 上下文恢复） |
| Create | `hooks/hooks-cursor.json` | Cursor hooks |
| Create | `hooks/hooks-gemini.json` | Gemini CLI hooks |
| Create | `hooks/hooks-codex.json` | Codex hooks |
| Create | `.github/workflows/validate-skills.yml` | GitHub Actions CI — push/PR 时运行 validate-skills.js |
| Create | `ci/pre-commit-config.yaml` | pre-commit hooks 配置 |
| Create | `scripts/sync-platforms.sh` | 同步所有平台配置到目标项目 |
| Modify | `package.json` | 添加 `files`、`publishConfig`、`engines` 字段 |

---

## Task 1: Claude Code 平台适配器

**Files:**
- Create: `platforms/claude/plugin.json`

- [ ] **Step 1: 创建 platforms/claude/plugin.json**

```json
{
  "name": "superman",
  "version": "0.1.0",
  "description": "Superman — OpenSpec + Superpowers + Agent Skills unified AI development plugin",
  "author": "Superman Plugin Contributors",
  "license": "MIT",
  "skills": [
    { "name": "superman:size-classify", "path": "skills/define/size-classify/SKILL.md" },
    { "name": "superman:brainstorming", "path": "skills/define/brainstorming/SKILL.md" },
    { "name": "superman:propose", "path": "skills/define/propose/SKILL.md" },
    { "name": "superman:spec-review", "path": "skills/define/spec-review/SKILL.md" },
    { "name": "superman:writing-plans", "path": "skills/define/writing-plans/SKILL.md" },
    { "name": "superman:archive", "path": "skills/define/archive/SKILL.md" },
    { "name": "superman:tdd", "path": "skills/execute/tdd/SKILL.md" },
    { "name": "superman:subagent-dev", "path": "skills/execute/subagent-dev/SKILL.md" },
    { "name": "superman:incremental-impl", "path": "skills/execute/incremental-impl/SKILL.md" },
    { "name": "superman:security", "path": "skills/execute/security/SKILL.md" },
    { "name": "superman:api-design", "path": "skills/execute/api-design/SKILL.md" },
    { "name": "superman:frontend-ui", "path": "skills/execute/frontend-ui/SKILL.md" },
    { "name": "superman:debugging", "path": "skills/execute/debugging/SKILL.md" },
    { "name": "superman:worktrees", "path": "skills/execute/worktrees/SKILL.md" },
    { "name": "superman:code-review", "path": "skills/verify/code-review/SKILL.md" },
    { "name": "superman:production-ready", "path": "skills/verify/production-ready/SKILL.md" },
    { "name": "superman:spec-satisfied", "path": "skills/verify/spec-satisfied/SKILL.md" },
    { "name": "superman:verification", "path": "skills/verify/verification/SKILL.md" },
    { "name": "superman:git-ship", "path": "skills/verify/git-ship/SKILL.md" },
    { "name": "superman:ci-gates", "path": "skills/verify/ci-gates/SKILL.md" }
  ],
  "slash_commands": [
    { "command": "superman:size-classify", "description": "对需求进行 S/M/L 三维评分分级" },
    { "command": "superman:brainstorming", "description": "结构化需求澄清（5 问深挖）" },
    { "command": "superman:propose", "description": "创建变更提案和规格草稿" },
    { "command": "superman:spec-review", "description": "规格自检（TBD 扫描 + 一致性 + 歧义）" },
    { "command": "superman:writing-plans", "description": "生成详细实施计划" },
    { "command": "superman:archive", "description": "归档已完成的变更" },
    { "command": "superman:tdd", "description": "测试驱动开发（SP 门控 + AS 反合理化）" },
    { "command": "superman:subagent-dev", "description": "并行 subagent 任务分发" },
    { "command": "superman:incremental-impl", "description": "增量实现策略" },
    { "command": "superman:security", "description": "安全加固检查清单" },
    { "command": "superman:api-design", "description": "API 接口设计原则" },
    { "command": "superman:frontend-ui", "description": "前端 UI 工程纪律" },
    { "command": "superman:debugging", "description": "系统化调试流程" },
    { "command": "superman:worktrees", "description": "git worktree 隔离工作空间" },
    { "command": "superman:code-review", "description": "双向代码审查协议" },
    { "command": "superman:production-ready", "description": "生产就绪门控检查（L 级必须）" },
    { "command": "superman:spec-satisfied", "description": "验证代码变更是否满足规格" },
    { "command": "superman:verification", "description": "变更有效性验证（运行应用）" },
    { "command": "superman:git-ship", "description": "分支决策 + 发布前核查清单" },
    { "command": "superman:ci-gates", "description": "L 级 CI 强制门控" }
  ],
  "hooks": "hooks/hooks.json",
  "context_files": [
    ".superman/context/requirements.md",
    ".superman/context/decisions.md",
    ".superman/context/size-classification.md"
  ]
}
```

- [ ] **Step 2: Commit**

```bash
git add platforms/claude/plugin.json
git commit -m "feat: add Claude Code platform adapter (plugin.json with 20 skills)"
```

---

## Task 2: Cursor + Gemini 平台适配器

**Files:**
- Create: `platforms/cursor/plugin.json`
- Create: `platforms/cursor/cursorrules.md`
- Create: `platforms/gemini/gemini-extension.json`

- [ ] **Step 1: 创建 platforms/cursor/plugin.json**

```json
{
  "name": "superman",
  "version": "0.1.0",
  "description": "Superman plugin for Cursor",
  "trigger": "@superman",
  "skills": [
    { "name": "superman:size-classify", "path": "skills/define/size-classify/SKILL.md" },
    { "name": "superman:brainstorming", "path": "skills/define/brainstorming/SKILL.md" },
    { "name": "superman:propose", "path": "skills/define/propose/SKILL.md" },
    { "name": "superman:spec-review", "path": "skills/define/spec-review/SKILL.md" },
    { "name": "superman:writing-plans", "path": "skills/define/writing-plans/SKILL.md" },
    { "name": "superman:archive", "path": "skills/define/archive/SKILL.md" },
    { "name": "superman:tdd", "path": "skills/execute/tdd/SKILL.md" },
    { "name": "superman:subagent-dev", "path": "skills/execute/subagent-dev/SKILL.md" },
    { "name": "superman:incremental-impl", "path": "skills/execute/incremental-impl/SKILL.md" },
    { "name": "superman:security", "path": "skills/execute/security/SKILL.md" },
    { "name": "superman:api-design", "path": "skills/execute/api-design/SKILL.md" },
    { "name": "superman:frontend-ui", "path": "skills/execute/frontend-ui/SKILL.md" },
    { "name": "superman:debugging", "path": "skills/execute/debugging/SKILL.md" },
    { "name": "superman:worktrees", "path": "skills/execute/worktrees/SKILL.md" },
    { "name": "superman:code-review", "path": "skills/verify/code-review/SKILL.md" },
    { "name": "superman:production-ready", "path": "skills/verify/production-ready/SKILL.md" },
    { "name": "superman:spec-satisfied", "path": "skills/verify/spec-satisfied/SKILL.md" },
    { "name": "superman:verification", "path": "skills/verify/verification/SKILL.md" },
    { "name": "superman:git-ship", "path": "skills/verify/git-ship/SKILL.md" },
    { "name": "superman:ci-gates", "path": "skills/verify/ci-gates/SKILL.md" }
  ],
  "hooks": "hooks/hooks-cursor.json"
}
```

- [ ] **Step 2: 创建 platforms/cursor/cursorrules.md**

```markdown
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
```

- [ ] **Step 3: 创建 platforms/gemini/gemini-extension.json**

```json
{
  "name": "superman",
  "version": "0.1.0",
  "description": "Superman plugin for Gemini CLI",
  "activation_command": "/superman",
  "skills": [
    { "name": "superman:size-classify", "path": "skills/define/size-classify/SKILL.md", "trigger": "/superman:size-classify" },
    { "name": "superman:brainstorming", "path": "skills/define/brainstorming/SKILL.md", "trigger": "/superman:brainstorming" },
    { "name": "superman:propose", "path": "skills/define/propose/SKILL.md", "trigger": "/superman:propose" },
    { "name": "superman:spec-review", "path": "skills/define/spec-review/SKILL.md", "trigger": "/superman:spec-review" },
    { "name": "superman:writing-plans", "path": "skills/define/writing-plans/SKILL.md", "trigger": "/superman:writing-plans" },
    { "name": "superman:archive", "path": "skills/define/archive/SKILL.md", "trigger": "/superman:archive" },
    { "name": "superman:tdd", "path": "skills/execute/tdd/SKILL.md", "trigger": "/superman:tdd" },
    { "name": "superman:subagent-dev", "path": "skills/execute/subagent-dev/SKILL.md", "trigger": "/superman:subagent-dev" },
    { "name": "superman:incremental-impl", "path": "skills/execute/incremental-impl/SKILL.md", "trigger": "/superman:incremental-impl" },
    { "name": "superman:security", "path": "skills/execute/security/SKILL.md", "trigger": "/superman:security" },
    { "name": "superman:api-design", "path": "skills/execute/api-design/SKILL.md", "trigger": "/superman:api-design" },
    { "name": "superman:frontend-ui", "path": "skills/execute/frontend-ui/SKILL.md", "trigger": "/superman:frontend-ui" },
    { "name": "superman:debugging", "path": "skills/execute/debugging/SKILL.md", "trigger": "/superman:debugging" },
    { "name": "superman:worktrees", "path": "skills/execute/worktrees/SKILL.md", "trigger": "/superman:worktrees" },
    { "name": "superman:code-review", "path": "skills/verify/code-review/SKILL.md", "trigger": "/superman:code-review" },
    { "name": "superman:production-ready", "path": "skills/verify/production-ready/SKILL.md", "trigger": "/superman:production-ready" },
    { "name": "superman:spec-satisfied", "path": "skills/verify/spec-satisfied/SKILL.md", "trigger": "/superman:spec-satisfied" },
    { "name": "superman:verification", "path": "skills/verify/verification/SKILL.md", "trigger": "/superman:verification" },
    { "name": "superman:git-ship", "path": "skills/verify/git-ship/SKILL.md", "trigger": "/superman:git-ship" },
    { "name": "superman:ci-gates", "path": "skills/verify/ci-gates/SKILL.md", "trigger": "/superman:ci-gates" }
  ],
  "hooks": "hooks/hooks-gemini.json",
  "activate_skill_tool": "activate_skill"
}
```

- [ ] **Step 4: Commit**

```bash
git add platforms/cursor/ platforms/gemini/
git commit -m "feat: add Cursor and Gemini platform adapters"
```

---

## Task 3: Codex + Copilot + OpenCode 平台适配器

**Files:**
- Create: `platforms/codex/plugin.json`
- Create: `platforms/copilot/copilot-instructions.md`
- Create: `platforms/opencode/superman.js`

- [ ] **Step 1: 创建 platforms/codex/plugin.json**

```json
{
  "name": "superman",
  "version": "0.1.0",
  "description": "Superman plugin for Codex",
  "tool": "skill",
  "skills": [
    { "name": "superman:size-classify", "path": "skills/define/size-classify/SKILL.md" },
    { "name": "superman:brainstorming", "path": "skills/define/brainstorming/SKILL.md" },
    { "name": "superman:propose", "path": "skills/define/propose/SKILL.md" },
    { "name": "superman:spec-review", "path": "skills/define/spec-review/SKILL.md" },
    { "name": "superman:writing-plans", "path": "skills/define/writing-plans/SKILL.md" },
    { "name": "superman:archive", "path": "skills/define/archive/SKILL.md" },
    { "name": "superman:tdd", "path": "skills/execute/tdd/SKILL.md" },
    { "name": "superman:subagent-dev", "path": "skills/execute/subagent-dev/SKILL.md" },
    { "name": "superman:incremental-impl", "path": "skills/execute/incremental-impl/SKILL.md" },
    { "name": "superman:security", "path": "skills/execute/security/SKILL.md" },
    { "name": "superman:api-design", "path": "skills/execute/api-design/SKILL.md" },
    { "name": "superman:frontend-ui", "path": "skills/execute/frontend-ui/SKILL.md" },
    { "name": "superman:debugging", "path": "skills/execute/debugging/SKILL.md" },
    { "name": "superman:worktrees", "path": "skills/execute/worktrees/SKILL.md" },
    { "name": "superman:code-review", "path": "skills/verify/code-review/SKILL.md" },
    { "name": "superman:production-ready", "path": "skills/verify/production-ready/SKILL.md" },
    { "name": "superman:spec-satisfied", "path": "skills/verify/spec-satisfied/SKILL.md" },
    { "name": "superman:verification", "path": "skills/verify/verification/SKILL.md" },
    { "name": "superman:git-ship", "path": "skills/verify/git-ship/SKILL.md" },
    { "name": "superman:ci-gates", "path": "skills/verify/ci-gates/SKILL.md" }
  ],
  "hooks": "hooks/hooks-codex.json"
}
```

- [ ] **Step 2: 创建 platforms/copilot/copilot-instructions.md**

```markdown
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
```

- [ ] **Step 3: 创建 platforms/opencode/superman.js**

```javascript
// Superman Plugin for OpenCode
// Registers 20 superman:* skills and hooks via OpenCode Plugin API

const path = require('path');
const fs = require('fs');

const SUPERMAN_ROOT = path.resolve(__dirname, '../..');

const SKILLS = [
  // DEFINE
  { name: 'superman:size-classify', phase: 'define', path: 'skills/define/size-classify/SKILL.md' },
  { name: 'superman:brainstorming', phase: 'define', path: 'skills/define/brainstorming/SKILL.md' },
  { name: 'superman:propose', phase: 'define', path: 'skills/define/propose/SKILL.md' },
  { name: 'superman:spec-review', phase: 'define', path: 'skills/define/spec-review/SKILL.md' },
  { name: 'superman:writing-plans', phase: 'define', path: 'skills/define/writing-plans/SKILL.md' },
  { name: 'superman:archive', phase: 'define', path: 'skills/define/archive/SKILL.md' },
  // EXECUTE
  { name: 'superman:tdd', phase: 'execute', path: 'skills/execute/tdd/SKILL.md' },
  { name: 'superman:subagent-dev', phase: 'execute', path: 'skills/execute/subagent-dev/SKILL.md' },
  { name: 'superman:incremental-impl', phase: 'execute', path: 'skills/execute/incremental-impl/SKILL.md' },
  { name: 'superman:security', phase: 'execute', path: 'skills/execute/security/SKILL.md' },
  { name: 'superman:api-design', phase: 'execute', path: 'skills/execute/api-design/SKILL.md' },
  { name: 'superman:frontend-ui', phase: 'execute', path: 'skills/execute/frontend-ui/SKILL.md' },
  { name: 'superman:debugging', phase: 'execute', path: 'skills/execute/debugging/SKILL.md' },
  { name: 'superman:worktrees', phase: 'execute', path: 'skills/execute/worktrees/SKILL.md' },
  // VERIFY
  { name: 'superman:code-review', phase: 'verify', path: 'skills/verify/code-review/SKILL.md' },
  { name: 'superman:production-ready', phase: 'verify', path: 'skills/verify/production-ready/SKILL.md' },
  { name: 'superman:spec-satisfied', phase: 'verify', path: 'skills/verify/spec-satisfied/SKILL.md' },
  { name: 'superman:verification', phase: 'verify', path: 'skills/verify/verification/SKILL.md' },
  { name: 'superman:git-ship', phase: 'verify', path: 'skills/verify/git-ship/SKILL.md' },
  { name: 'superman:ci-gates', phase: 'verify', path: 'skills/verify/ci-gates/SKILL.md' },
];

function loadSkill(skillPath) {
  const fullPath = path.join(SUPERMAN_ROOT, skillPath);
  if (!fs.existsSync(fullPath)) return null;
  return fs.readFileSync(fullPath, 'utf8');
}

function register(plugin) {
  // Register each skill as a slash command
  for (const skill of SKILLS) {
    plugin.registerCommand(skill.name, {
      description: `Superman ${skill.phase} skill: ${skill.name}`,
      execute: async (context) => {
        const content = loadSkill(skill.path);
        if (!content) {
          context.output(`Error: skill file not found at ${skill.path}`);
          return;
        }
        context.injectSystemPrompt(content);
        context.output(`Loaded skill: ${skill.name}`);
      }
    });
  }

  // Session start hook: restore superman context
  plugin.on('session:start', async (context) => {
    const requirementsPath = path.join(context.workspaceRoot, '.superman/context/requirements.md');
    if (!fs.existsSync(requirementsPath)) return;

    const contextFiles = [
      '.superman/context/requirements.md',
      '.superman/context/decisions.md',
      '.superman/context/size-classification.md',
    ];

    let restoredContext = '# Superman Context (Restored)\n\n';
    for (const file of contextFiles) {
      const fullPath = path.join(context.workspaceRoot, file);
      if (fs.existsSync(fullPath)) {
        restoredContext += `## ${file}\n\n${fs.readFileSync(fullPath, 'utf8')}\n\n`;
      }
    }

    context.injectSystemPrompt(restoredContext);
    context.output('Superman: Context restored from .superman/');
  });
}

module.exports = { register, SKILLS };
```

- [ ] **Step 4: Commit**

```bash
git add platforms/codex/ platforms/copilot/ platforms/opencode/
git commit -m "feat: add Codex, Copilot, and OpenCode platform adapters"
```

---

## Task 4: Hooks 触发规则

**Files:**
- Create: `hooks/hooks.json`
- Create: `hooks/hooks-cursor.json`
- Create: `hooks/hooks-gemini.json`
- Create: `hooks/hooks-codex.json`

- [ ] **Step 1: 创建 hooks/hooks.json（Claude Code）**

Claude Code hooks 格式（PostToolUse/PreToolUse/Stop 等事件 + shell 命令）：

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'if [ -f .superman/context/size-classification.md ]; then level=$(grep -o \"综合等级：[SML]\" .superman/context/size-classification.md | head -1 | cut -d\"：\" -f2); [ \"$level\" = \"L\" ] && echo \"[Superman] L-level requirement active — CI gates will be enforced at VERIFY phase\"; fi'"
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'if [ -d .superman/context ] && [ ! -f .superman/context/requirements.md ]; then echo \"[Superman] Reminder: use superman:size-classify to classify your next requirement\"; fi'"
          }
        ]
      }
    ]
  }
}
```

- [ ] **Step 2: 创建 hooks/hooks-cursor.json**

```json
{
  "hooks": [
    {
      "event": "session_start",
      "description": "Restore Superman context from .superman/ files",
      "action": {
        "type": "inject_prompt",
        "prompt": "Check if .superman/context/requirements.md exists. If yes, read all .superman/ files and announce: 'Superman context restored — currently at [phase], task [N/M]'. If no .superman/ context exists, remind the user to start with @superman size-classify."
      }
    },
    {
      "event": "file_save",
      "description": "Remind about context persistence on code changes",
      "filter": { "not": ".superman/**" },
      "action": {
        "type": "check",
        "condition": "has_active_requirement",
        "prompt": "If there is an active requirement in .superman/context/size-classification.md, ensure progress is being tracked in .superman/phases/execute/progress.md."
      }
    }
  ]
}
```

- [ ] **Step 3: 创建 hooks/hooks-gemini.json**

```json
{
  "hooks": [
    {
      "event": "session_start",
      "description": "Restore Superman context",
      "action": {
        "type": "activate_skill",
        "condition": "file_exists:.superman/context/requirements.md",
        "prompt": "Superman context found. Read .superman/context/requirements.md, .superman/context/decisions.md, and .superman/context/size-classification.md. Announce the current phase and task progress to the user."
      }
    },
    {
      "event": "user_message",
      "description": "Auto-trigger size-classify for new requirements",
      "pattern": "(?i)(需求|requirement|feature|implement|build|create|add|fix)",
      "condition": "no_active_size_classification",
      "action": {
        "type": "suggest_skill",
        "skill": "superman:size-classify",
        "message": "检测到新需求描述。建议先运行 /superman:size-classify 进行分级。"
      }
    }
  ]
}
```

- [ ] **Step 4: 创建 hooks/hooks-codex.json**

```json
{
  "hooks": [
    {
      "event": "session_start",
      "description": "Restore Superman context at session start",
      "action": {
        "type": "command",
        "condition": "file_exists:.superman/context/requirements.md",
        "prompt": "Read .superman/context/ files and announce current Superman workflow state."
      }
    },
    {
      "event": "tool_call",
      "tool": "skill",
      "description": "Log Superman skill invocations",
      "filter": { "name_prefix": "superman:" },
      "action": {
        "type": "log",
        "target": ".superman/context/decisions.md",
        "format": "[{timestamp}] Skill invoked: {skill_name}"
      }
    }
  ]
}
```

- [ ] **Step 5: Commit**

```bash
git add hooks/
git commit -m "feat: add hooks trigger rules for all 4 platforms"
```

---

## Task 5: GitHub Actions CI + Pre-commit 配置

**Files:**
- Create: `.github/workflows/validate-skills.yml`
- Create: `ci/pre-commit-config.yaml`

- [ ] **Step 1: 创建 .github/workflows/ 目录**

```bash
mkdir -p .github/workflows
```

- [ ] **Step 2: 创建 .github/workflows/validate-skills.yml**

```yaml
name: Validate Skills

on:
  push:
    branches: [ main, master ]
    paths:
      - 'skills/**'
      - 'scripts/validate-skills.js'
  pull_request:
    branches: [ main, master ]
    paths:
      - 'skills/**'
      - 'scripts/validate-skills.js'

jobs:
  validate:
    name: Validate skill structure
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'

      - name: Validate skills
        run: node scripts/validate-skills.js

      - name: Count skills
        run: |
          echo "Skills found:"
          find skills -name "SKILL.md" | sort
          echo ""
          echo "Total: $(find skills -name 'SKILL.md' | wc -l | tr -d ' ') skills"
```

- [ ] **Step 3: 创建 ci/pre-commit-config.yaml**

```yaml
# Superman Plugin — Pre-commit Configuration
# Install: pip install pre-commit && pre-commit install

repos:
  - repo: local
    hooks:
      - id: validate-skills
        name: Validate Superman skills structure
        language: node
        entry: node scripts/validate-skills.js
        pass_filenames: false
        files: ^skills/.*SKILL\.md$
        types: [file]

      - id: no-tbd-in-skills
        name: Check for TBD/TODO in skill files
        language: pygrep
        entry: "(?i)\\bTBD\\b|\\bTODO\\b|\\b待定\\b"
        files: ^skills/.*SKILL\.md$
        types: [markdown]

      - id: skill-goal-trigger
        name: Verify SKILL.md has Goal and Trigger
        language: pygrep
        entry: "(?!.*\\*\\*Goal\\*\\*)"
        files: ^skills/.*SKILL\.md$
        types: [markdown]
        args: [--multiline]
```

- [ ] **Step 4: Commit**

```bash
git add .github/ ci/pre-commit-config.yaml
git commit -m "feat: add GitHub Actions CI workflow and pre-commit config"
```

---

## Task 6: sync-platforms.sh + npm 发布配置

**Files:**
- Create: `scripts/sync-platforms.sh`
- Modify: `package.json`

- [ ] **Step 1: 创建 scripts/sync-platforms.sh**

```bash
#!/usr/bin/env bash
# sync-platforms.sh — 将 Superman 平台配置同步到目标项目
# Usage: bash scripts/sync-platforms.sh [target-dir]

set -e

SUPERMAN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="${1:-$(pwd)}"

echo "🦸 Superman Platform Sync"
echo "  Source: $SUPERMAN_DIR"
echo "  Target: $TARGET_DIR"
echo ""

if [ ! -d "$TARGET_DIR" ]; then
  echo "❌ Target directory does not exist: $TARGET_DIR"
  exit 1
fi

# Sync Claude Code
sync_claude() {
  echo "  Syncing Claude Code..."
  mkdir -p "$TARGET_DIR/.claude-plugin"
  cp "$SUPERMAN_DIR/platforms/claude/plugin.json" "$TARGET_DIR/.claude-plugin/superman-plugin.json"

  # Merge CLAUDE.md (append Superman section if not present)
  if [ -f "$TARGET_DIR/CLAUDE.md" ]; then
    if ! grep -q "Superman Plugin" "$TARGET_DIR/CLAUDE.md" 2>/dev/null; then
      echo "" >> "$TARGET_DIR/CLAUDE.md"
      cat "$SUPERMAN_DIR/CLAUDE.md" >> "$TARGET_DIR/CLAUDE.md"
      echo "  ✓ Appended Superman instructions to existing CLAUDE.md"
    else
      echo "  ✓ CLAUDE.md already contains Superman instructions (skipped)"
    fi
  else
    cp "$SUPERMAN_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
    echo "  ✓ Created CLAUDE.md"
  fi

  # Install hooks
  if [ -f "$SUPERMAN_DIR/hooks/hooks.json" ]; then
    mkdir -p "$TARGET_DIR/.claude"
    cp "$SUPERMAN_DIR/hooks/hooks.json" "$TARGET_DIR/.claude/hooks.json"
    echo "  ✓ Installed Claude Code hooks"
  fi
}

# Sync Cursor
sync_cursor() {
  echo "  Syncing Cursor..."
  mkdir -p "$TARGET_DIR/.cursor-plugin"
  cp "$SUPERMAN_DIR/platforms/cursor/plugin.json" "$TARGET_DIR/.cursor-plugin/superman-plugin.json"

  if [ ! -f "$TARGET_DIR/.cursorrules" ]; then
    cp "$SUPERMAN_DIR/platforms/cursor/cursorrules.md" "$TARGET_DIR/.cursorrules"
    echo "  ✓ Created .cursorrules"
  else
    echo "  ⚠ .cursorrules already exists — manual merge may be needed"
    echo "    Superman rules are in: $SUPERMAN_DIR/platforms/cursor/cursorrules.md"
  fi

  if [ -f "$SUPERMAN_DIR/hooks/hooks-cursor.json" ]; then
    cp "$SUPERMAN_DIR/hooks/hooks-cursor.json" "$TARGET_DIR/.cursor-hooks.json"
    echo "  ✓ Installed Cursor hooks"
  fi
}

# Sync Gemini CLI
sync_gemini() {
  echo "  Syncing Gemini CLI..."
  cp "$SUPERMAN_DIR/platforms/gemini/gemini-extension.json" "$TARGET_DIR/gemini-extension.json"

  if [ -f "$TARGET_DIR/GEMINI.md" ]; then
    if ! grep -q "Superman Plugin" "$TARGET_DIR/GEMINI.md" 2>/dev/null; then
      echo "" >> "$TARGET_DIR/GEMINI.md"
      cat "$SUPERMAN_DIR/GEMINI.md" >> "$TARGET_DIR/GEMINI.md"
    fi
  else
    cp "$SUPERMAN_DIR/GEMINI.md" "$TARGET_DIR/GEMINI.md"
  fi
  echo "  ✓ Gemini CLI configured"
}

# Sync Codex
sync_codex() {
  echo "  Syncing Codex..."
  mkdir -p "$TARGET_DIR/.codex-plugin"
  cp "$SUPERMAN_DIR/platforms/codex/plugin.json" "$TARGET_DIR/.codex-plugin/superman-plugin.json"

  if [ -f "$TARGET_DIR/AGENTS.md" ]; then
    if ! grep -q "Superman Plugin" "$TARGET_DIR/AGENTS.md" 2>/dev/null; then
      echo "" >> "$TARGET_DIR/AGENTS.md"
      cat "$SUPERMAN_DIR/AGENTS.md" >> "$TARGET_DIR/AGENTS.md"
    fi
  else
    cp "$SUPERMAN_DIR/AGENTS.md" "$TARGET_DIR/AGENTS.md"
  fi
  echo "  ✓ Codex configured"
}

# Sync Copilot
sync_copilot() {
  echo "  Syncing GitHub Copilot..."
  mkdir -p "$TARGET_DIR/.github"
  if [ ! -f "$TARGET_DIR/.github/copilot-instructions.md" ]; then
    cp "$SUPERMAN_DIR/platforms/copilot/copilot-instructions.md" "$TARGET_DIR/.github/copilot-instructions.md"
    echo "  ✓ Created .github/copilot-instructions.md"
  else
    echo "  ⚠ .github/copilot-instructions.md exists — manual merge may be needed"
  fi
}

# Sync OpenCode
sync_opencode() {
  echo "  Syncing OpenCode..."
  mkdir -p "$TARGET_DIR/.opencode/plugins"
  cp "$SUPERMAN_DIR/platforms/opencode/superman.js" "$TARGET_DIR/.opencode/plugins/superman.js"
  echo "  ✓ OpenCode plugin installed"
}

# Detect and sync all present platforms
SYNCED=0

if [ -d "$TARGET_DIR/.claude" ] || [ -f "$TARGET_DIR/CLAUDE.md" ]; then
  sync_claude; SYNCED=$((SYNCED+1))
fi

if [ -d "$TARGET_DIR/.cursor" ] || [ -f "$TARGET_DIR/.cursorrules" ]; then
  sync_cursor; SYNCED=$((SYNCED+1))
fi

if [ -f "$TARGET_DIR/GEMINI.md" ]; then
  sync_gemini; SYNCED=$((SYNCED+1))
fi

if [ -f "$TARGET_DIR/AGENTS.md" ]; then
  sync_codex; SYNCED=$((SYNCED+1))
fi

if [ -d "$TARGET_DIR/.github" ]; then
  sync_copilot; SYNCED=$((SYNCED+1))
fi

if [ -d "$TARGET_DIR/.opencode" ]; then
  sync_opencode; SYNCED=$((SYNCED+1))
fi

if [ "$SYNCED" -eq 0 ]; then
  echo "  No platform config detected. Running full sync..."
  sync_claude
  SYNCED=1
fi

# Sync CI gates
if [ -f "$SUPERMAN_DIR/ci/gates-default.json" ]; then
  mkdir -p "$TARGET_DIR/.superman/ci"
  cp "$SUPERMAN_DIR/ci/gates-default.json" "$TARGET_DIR/.superman/ci/gates.json"
  echo "  ✓ CI gates installed"
fi

echo ""
echo "✅ Synced $SYNCED platform(s) in $TARGET_DIR"
echo ""
echo "To update later, re-run: bash $SUPERMAN_DIR/scripts/sync-platforms.sh $TARGET_DIR"
```

- [ ] **Step 2: 赋予执行权限**

```bash
chmod +x scripts/sync-platforms.sh
```

- [ ] **Step 3: 更新 package.json**

将现有 `package.json` 更新为：

```json
{
  "name": "superman-plugin",
  "version": "0.1.0",
  "description": "Superman — OpenSpec + Superpowers + Agent Skills unified AI development plugin",
  "bin": {
    "superman": "./scripts/install.sh"
  },
  "scripts": {
    "validate": "node scripts/validate-skills.js",
    "test": "node scripts/validate-skills.js",
    "sync": "bash scripts/sync-platforms.sh",
    "prepublishOnly": "node scripts/validate-skills.js"
  },
  "files": [
    "skills/",
    "platforms/",
    "hooks/",
    "ci/",
    "scripts/",
    "CLAUDE.md",
    "GEMINI.md",
    "AGENTS.md",
    "README.md"
  ],
  "keywords": [
    "claude",
    "cursor",
    "gemini",
    "codex",
    "copilot",
    "ai",
    "skills",
    "plugin",
    "superpowers",
    "openspec",
    "agent-skills",
    "workflow"
  ],
  "license": "MIT",
  "engines": {
    "node": ">=18"
  },
  "publishConfig": {
    "access": "public"
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add scripts/sync-platforms.sh package.json
git commit -m "feat: add sync-platforms.sh and update package.json for npm publish"
```

---

## Task 7: 最终验证

- [ ] **Step 1: 运行 validate-skills.js 确认 20 个技能全部通过**

```bash
node scripts/validate-skills.js
```

预期：`✅ All 20 skills validated successfully.`

- [ ] **Step 2: 验证所有平台文件存在**

```bash
echo "=== Platform adapters ===" && \
ls platforms/claude/ platforms/cursor/ platforms/gemini/ platforms/codex/ platforms/copilot/ platforms/opencode/ && \
echo "=== Hooks ===" && \
ls hooks/ && \
echo "=== CI ===" && \
ls .github/workflows/ ci/ && \
echo "=== Scripts ===" && \
ls scripts/
```

预期：所有文件列出，无报错。

- [ ] **Step 3: 测试 sync-platforms.sh**

```bash
mkdir -p /tmp/test-superman-sync && \
touch /tmp/test-superman-sync/CLAUDE.md && \
bash scripts/sync-platforms.sh /tmp/test-superman-sync && \
ls /tmp/test-superman-sync/.claude-plugin/ && \
cat /tmp/test-superman-sync/CLAUDE.md | grep -c "Superman" && \
rm -rf /tmp/test-superman-sync
```

预期：`.claude-plugin/superman-plugin.json` 存在，CLAUDE.md 包含 "Superman" 字样。

- [ ] **Step 4: 验证 package.json 的 files 字段**

```bash
node -e "const p = require('./package.json'); console.log('files:', p.files); console.log('publishConfig:', p.publishConfig); console.log('prepublishOnly:', p.scripts.prepublishOnly);"
```

预期：files 数组、publishConfig、prepublishOnly 均正确输出。

- [ ] **Step 5: 最终 Commit（若有未提交文件）**

```bash
git status && git log --oneline -5
```

---

## 自检

- [x] **Spec 覆盖**：Task 1-3 覆盖 6 个平台适配器；Task 4 覆盖 4 个 hooks 文件；Task 5 覆盖 CI/GitHub Actions 和 pre-commit；Task 6 覆盖 sync-platforms.sh 和 npm 发布配置；Task 7 覆盖最终验证
- [x] **占位符扫描**：无 TBD/TODO，所有代码块完整可执行
- [x] **类型一致性**：所有 plugin.json 中的 skill path 与实际 SKILL.md 路径匹配；sync-platforms.sh 中的文件路径与 install.sh 保持一致
- [x] **规格满足度**：设计规格 §7.1 表格中所列 6 个平台的配置文件全部创建
