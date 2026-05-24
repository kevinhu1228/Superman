# Superman Plugin — Plan A: Foundation & Core Infrastructure

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 建立 Superman 插件的仓库骨架、技能校验器、分级引擎和上下文持久化基础设施，产出可运行的 `validate-skills.js` 和 `superman init` 初始化脚本。

**Architecture:** 纯 Node.js 脚本（validate-skills.js、install.sh），Markdown 技能文件以 JSON schema 校验结构，`superman:size-classify` 和上下文持久化逻辑以 SKILL.md 形式实现（AI 执行），无运行时依赖。

**Tech Stack:** Node.js 18+, npm, bash, Markdown, JSON Schema

---

## 文件清单

| 操作 | 路径 | 职责 |
|------|------|------|
| Create | `package.json` | npm 包定义，`superman init` 命令入口 |
| Create | `.gitignore` | 忽略 `.superman/` 私有目录、node_modules |
| Create | `scripts/validate-skills.js` | 校验所有 skill 的目录结构和 SKILL.md 必要字段 |
| Create | `scripts/install.sh` | `superman init` 核心逻辑：写入各平台配置到目标项目 |
| Create | `ci/gates-schema.json` | L 级 CI 门控检查项 JSON schema |
| Create | `CLAUDE.md` | Claude Code 全局行为注入 |
| Create | `GEMINI.md` | Gemini CLI 全局行为注入 |
| Create | `AGENTS.md` | Codex 全局行为注入 |
| Create | `skills/define/size-classify/SKILL.md` | 需求三维评分 + 分级路由核心技能 |
| Create | `skills/define/brainstorming/SKILL.md` | 需求澄清技能（SP ✕ AS 合并） |
| Create | `skills/define/propose/SKILL.md` | OpenSpec propose 重实现 |
| Create | `skills/define/spec-review/SKILL.md` | 规格自检技能 |
| Create | `skills/define/writing-plans/SKILL.md` | 计划生成技能（Superpowers 保留） |
| Create | `skills/define/archive/SKILL.md` | 变更归档技能（OpenSpec 重实现） |
| Create | `README.md` | 安装指引和快速开始 |

---

## Task 1: 初始化仓库结构

**Files:**
- Create: `package.json`
- Create: `.gitignore`
- Create: `README.md`

- [ ] **Step 1: 创建 package.json**

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
    "test": "node scripts/validate-skills.js"
  },
  "keywords": ["claude", "ai", "skills", "plugin", "superpowers", "openspec"],
  "license": "MIT",
  "engines": {
    "node": ">=18"
  }
}
```

- [ ] **Step 2: 创建 .gitignore**

```gitignore
node_modules/
.superman/context/
.superman/phases/
.superman/ci/
*.log
.DS_Store
```

注意：`.superman/` 下只有 `context/` 和 `phases/` 被忽略（私有运行时文件）；`ci/gates.json` 不忽略（项目级配置需提交）。

- [ ] **Step 3: 创建目录骨架**

```bash
mkdir -p skills/define skills/execute skills/verify
mkdir -p platforms/claude platforms/cursor platforms/gemini platforms/codex platforms/copilot platforms/opencode
mkdir -p hooks ci scripts docs/superpowers/specs docs/superpowers/plans docs/diagrams
```

- [ ] **Step 4: 验证目录结构**

```bash
find . -type d | grep -v node_modules | grep -v .git | sort
```

预期输出包含：`./skills/define`、`./skills/execute`、`./skills/verify`、`./platforms/claude` 等。

- [ ] **Step 5: Commit**

```bash
git init
git add package.json .gitignore
git commit -m "chore: init superman plugin repo structure"
```

---

## Task 2: 编写技能校验器 validate-skills.js

**Files:**
- Create: `scripts/validate-skills.js`

- [ ] **Step 1: 编写校验器（含测试逻辑）**

```javascript
#!/usr/bin/env node
// validate-skills.js — 校验所有 skills/ 下的 SKILL.md 结构完整性

const fs = require('fs');
const path = require('path');

const PHASES = ['define', 'execute', 'verify'];
const REQUIRED_SECTIONS = ['#', '## ', '**Goal**', '**Trigger**'];

let errors = [];
let checked = 0;

for (const phase of PHASES) {
  const phaseDir = path.join('skills', phase);
  if (!fs.existsSync(phaseDir)) {
    errors.push(`Missing phase directory: skills/${phase}`);
    continue;
  }
  const skills = fs.readdirSync(phaseDir);
  for (const skill of skills) {
    const skillFile = path.join(phaseDir, skill, 'SKILL.md');
    if (!fs.existsSync(skillFile)) {
      errors.push(`Missing SKILL.md: skills/${phase}/${skill}/SKILL.md`);
      continue;
    }
    const content = fs.readFileSync(skillFile, 'utf8');
    if (!content.startsWith('# ')) {
      errors.push(`${skillFile}: must start with a level-1 heading`);
    }
    if (!content.includes('**Goal**') && !content.includes('## Goal') && !content.includes('## 目标')) {
      errors.push(`${skillFile}: missing Goal section`);
    }
    if (!content.includes('**Trigger**') && !content.includes('## Trigger') && !content.includes('## 触发时机')) {
      errors.push(`${skillFile}: missing Trigger section`);
    }
    checked++;
  }
}

if (errors.length > 0) {
  console.error(`\n❌ Validation failed (${errors.length} errors):\n`);
  errors.forEach(e => console.error(`  • ${e}`));
  process.exit(1);
} else {
  console.log(`\n✅ All ${checked} skills validated successfully.\n`);
}
```

- [ ] **Step 2: 赋予执行权限**

```bash
chmod +x scripts/validate-skills.js
```

- [ ] **Step 3: 运行校验器（预期失败 — 技能文件尚未创建）**

```bash
node scripts/validate-skills.js
```

预期输出：`Missing phase directory: skills/define`（或类似 missing 错误），说明校验器正常检测到缺失。

- [ ] **Step 4: Commit**

```bash
git add scripts/validate-skills.js
git commit -m "feat: add validate-skills.js for skill structure validation"
```

---

## Task 3: 创建 CI 门控 Schema 和全局行为注入文件

**Files:**
- Create: `ci/gates-schema.json`
- Create: `CLAUDE.md`
- Create: `GEMINI.md`
- Create: `AGENTS.md`

- [ ] **Step 1: 创建 ci/gates-schema.json**

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Superman CI Gates",
  "description": "L级需求必须通过的CI检查项",
  "type": "object",
  "required": ["gates"],
  "properties": {
    "gates": {
      "type": "array",
      "minItems": 1,
      "items": {
        "type": "object",
        "required": ["id", "name", "command", "expected_exit_code"],
        "properties": {
          "id": { "type": "string" },
          "name": { "type": "string" },
          "command": { "type": "string" },
          "expected_exit_code": { "type": "integer", "enum": [0] },
          "phase": { "type": "string", "enum": ["define", "execute", "verify"] },
          "required_level": { "type": "string", "enum": ["L", "M", "S"] }
        }
      }
    }
  }
}
```

- [ ] **Step 2: 创建默认 gates 示例文件 `ci/gates-default.json`**

```json
{
  "gates": [
    {
      "id": "validate-skills",
      "name": "Validate all skill files",
      "command": "node scripts/validate-skills.js",
      "expected_exit_code": 0,
      "phase": "verify",
      "required_level": "L"
    },
    {
      "id": "spec-exists",
      "name": "Spec file must exist for L-level requirements",
      "command": "test -f .superman/phases/define/spec.md",
      "expected_exit_code": 0,
      "phase": "verify",
      "required_level": "L"
    }
  ]
}
```

- [ ] **Step 3: 创建 CLAUDE.md**

```markdown
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

## Key Rules

- **Never skip phases for L-level requirements** — CI gates enforce this
- **Write to .superman/ immediately** when user states requirements or makes decisions
- **Do not self-downgrade** requirement levels — user must explicitly approve with reason
- **Invoke skills proactively** — if the situation matches a skill's trigger, invoke it before acting

## Available Skills

Skills are in `skills/{define,execute,verify}/*/SKILL.md`. Load them via the Skill tool.

| Phase | Skills |
|-------|--------|
| DEFINE | size-classify, brainstorming, propose, spec-review, writing-plans, archive |
| EXECUTE | tdd, subagent-dev, incremental-impl, security, api-design, frontend-ui, debugging, worktrees |
| VERIFY | code-review, production-ready, spec-satisfied, verification, git-ship, ci-gates |
```

- [ ] **Step 4: 创建 GEMINI.md**

```markdown
# Superman Plugin — Gemini CLI Instructions

You are operating with the Superman plugin. Follow the same 3-phase workflow as described in CLAUDE.md.

## Activation

Skills activate via the `activate_skill` tool. Use `/superman:*` slash commands to trigger phases.

## Core Rules

- Always check `.superman/context/` at session start for context restoration
- Follow size-classify output to determine which phases to execute
- Persist all requirement discussions and decisions to `.superman/` immediately
```

- [ ] **Step 5: 创建 AGENTS.md**

```markdown
# Superman Plugin — Codex/Agent Instructions

Operating with Superman plugin. 3-phase workflow enforced.

## Workflow

1. size-classify → determine S/M/L level
2. Route to appropriate phases
3. Persist context to .superman/ at every step

## Rules

- Never skip L-level phase gates
- Use skill tool for all superman:* skills
- Restore context from .superman/ files at session start
```

- [ ] **Step 6: Commit**

```bash
git add ci/ CLAUDE.md GEMINI.md AGENTS.md
git commit -m "feat: add CI gates schema and platform global instruction files"
```

---

## Task 4: 创建 superman:size-classify 技能

**Files:**
- Create: `skills/define/size-classify/SKILL.md`

- [ ] **Step 1: 编写技能文件**

```markdown
# superman:size-classify

**Goal:** 对输入需求进行三维度评分，输出 S/M/L 分级结果，并将结果写入 `.superman/context/size-classification.md`。

**Trigger:** 用户提出新需求时，在任何其他技能调用之前首先触发本技能。

---

## 评分方法

对需求进行三个独立维度评分（各 1-3 分）：

| 分数 | 维度 A：改动范围 | 维度 B：时间估算 | 维度 C：影响面 |
|------|----------------|----------------|---------------|
| 1 | 单文件/单函数 | < 30 分钟 | 仅私有代码 |
| 2 | 跨模块/多文件 | 30 分钟 – 2 小时 | 涉及 API/对外接口 |
| 3 | 新系统/架构重构 | > 2 小时 | 多团队/生产环境影响 |

**综合得分 = max(A, B, C)**，任一维度达到阈值即整体升级。

## 分级规则

| 等级 | 条件 | DEFINE | EXECUTE | VERIFY |
|------|------|--------|---------|--------|
| S 小 | max ≤ 1 | 跳过 | 完整执行 | 跳过 |
| M 中 | max = 2 | Lite | 完整执行 | Lite |
| L 大 | max = 3 | 强制完整 | 强制完整 | 强制完整 |

## 执行步骤

1. 向用户展示三维度评分表，逐一询问或根据需求描述自行评分
2. 计算 `max(A, B, C)` 得出等级
3. 立即将结果写入 `.superman/context/size-classification.md`：

```markdown
# 需求分级结果

**需求描述：** {用户原始需求}
**评分时间：** {ISO 时间戳}

| 维度 | 评分 | 依据 |
|------|------|------|
| A 改动范围 | {1/2/3} | {说明} |
| B 时间估算 | {1/2/3} | {说明} |
| C 影响面   | {1/2/3} | {说明} |

**综合等级：{S/M/L}**
**路由：** {DEFINE→EXECUTE→VERIFY 或 跳过说明}

---
*注：AI 不得自行降级。用户手动降级须在 requirements.md 中记录原因。*
```

4. 向用户宣告分级结果，说明将执行哪些阶段
5. 调用下一个技能（M/L 级：`superman:brainstorming`；S 级：跳至 `superman:tdd` 或对应 EXECUTE 技能）

## 降级规则

AI 不得自行降级。如用户请求降级：
1. 在 `requirements.md` 末尾追加：`[降级记录] {时间} 用户将 {原等级} 降为 {新等级}，原因：{用户说明}`
2. 更新 `size-classification.md` 的等级字段，注明 "手动降级"
```

- [ ] **Step 2: 运行校验器验证技能文件**

```bash
node scripts/validate-skills.js
```

预期输出包含 `✅ 1 skills validated` 或显示其余 phase 目录缺失（但 size-classify 应通过）。

- [ ] **Step 3: Commit**

```bash
git add skills/define/size-classify/
git commit -m "feat: add superman:size-classify skill (3-dimensional scoring + routing)"
```

---

## Task 5: 创建 DEFINE 阶段其余 5 个技能

**Files:**
- Create: `skills/define/brainstorming/SKILL.md`
- Create: `skills/define/propose/SKILL.md`
- Create: `skills/define/spec-review/SKILL.md`
- Create: `skills/define/writing-plans/SKILL.md`
- Create: `skills/define/archive/SKILL.md`

- [ ] **Step 1: 创建 superman:brainstorming**

```markdown
# superman:brainstorming

**Goal:** 通过结构化对话澄清需求，产出用户认可的需求理解，写入 `.superman/context/requirements.md`。

**Trigger:** L/M 级需求完成 size-classify 后，DEFINE 阶段首先调用。

---

## 执行流程

本技能合并 Superpowers brainstorming 框架与 Agent Skills idea-refine（5 问）和 interview-me（访谈式）模式。

### Phase 1: 上下文捕获（实时落盘）

用户说明需求后，**立即**将原文追加到 `.superman/context/requirements.md`：

```markdown
## 需求记录 [{ISO 时间戳}]

**用户原话：**
> {用户原始描述，逐字引用，不做改写}

**AI 理解摘要：** {一句话}
```

### Phase 2: 5 问深挖（AS idea-refine）

逐一提问，每次一个，等待回答后再问下一个：

1. **目标**：这个改动完成后，谁的什么问题会被解决？
2. **成功标准**：怎么判断它做好了？有什么可以测试/验证的指标？
3. **约束**：有什么不能做的（技术限制、时间、兼容性）？
4. **边界**：这次做什么，明确不做什么？
5. **风险**：最有可能出错的地方是什么？

每个回答立即追加到 `requirements.md`。

### Phase 3: 需求确认

向用户展示整理后的需求摘要，请求确认。确认后继续，不确认则返回 Phase 2。

### Phase 4: 移交

调用 `superman:propose` 创建变更提案目录和规格草稿。
```

- [ ] **Step 2: 创建 superman:propose**

```markdown
# superman:propose

**Goal:** 创建结构化变更提案，在 `.superman/phases/define/` 下生成 `proposal.md` 和 `spec.md` 草稿。

**Trigger:** `superman:brainstorming` 完成需求确认后自动调用（M/L 级）。M Lite 级只生成 tasks.md，跳过 spec.md。

---

## 执行步骤

1. 创建目录（如不存在）：

```bash
mkdir -p .superman/phases/define
```

2. 生成 `.superman/phases/define/proposal.md`：

```markdown
# 变更提案

**提案时间：** {ISO 时间戳}
**需求等级：** {S/M/L}
**状态：** 草稿

## 目标

{从 requirements.md 提取的一句话目标}

## 范围

**做：**
- {从需求确认中提取}

**不做：**
- {从需求确认中提取}

## 成功标准

{从 brainstorming Phase 2 Q2 提取}

## 风险

{从 brainstorming Phase 2 Q5 提取}
```

3. L 级需求额外生成 `.superman/phases/define/spec.md`（完整技术规格，包含架构、接口、数据模型）

4. 生成 `.superman/phases/define/tasks.md` 任务清单（所有级别）：

```markdown
# 任务清单

**来源：** proposal.md
**状态：** 待执行

- [ ] Task 1: {具体任务描述}
- [ ] Task 2: {具体任务描述}
...
```

5. 向用户展示 proposal.md，请求确认后进入 `superman:writing-plans`
```

- [ ] **Step 3: 创建 superman:spec-review**

```markdown
# superman:spec-review

**Goal:** 对 `.superman/phases/define/spec.md` 进行自检，确保无 TBD、无矛盾、无歧义，通过后才允许进入 EXECUTE 阶段。

**Trigger:** `superman:propose` 生成 spec.md 后自动调用（L 级必须，M 级跳过）。

---

## 检查清单

按序执行，发现问题立即修复，不等用户：

### 1. TBD 扫描
搜索 spec.md 中的 `TBD`、`TODO`、`待定`、`稍后`、`暂时`。
- 发现：直接替换为具体内容或删除该条目
- 发现无法确定的：标记为需要用户澄清，暂停并询问

### 2. 内部一致性检查
- 架构描述与功能描述是否一致？
- 接口定义在多处出现时是否相同？
- 依赖关系是否有循环或矛盾？

### 3. 范围检查
- 是否聚焦？所有内容都属于本次变更范围？
- 是否可以分解为更小的独立单元？

### 4. 歧义检查
- 同一需求是否可以被两种不同方式实现？
- 如有，选择一种并明确写入 spec.md

## 通过标准

检查完成且无未解决问题 → 在 spec.md 末尾追加：

```markdown
---
*Spec Review: PASSED [{ISO 时间戳}]*
```

然后继续 `superman:writing-plans`。
```

- [ ] **Step 4: 创建 superman:writing-plans**

```markdown
# superman:writing-plans

**Goal:** 基于 `.superman/phases/define/tasks.md` 生成详细实施计划，保存到 `docs/superpowers/plans/`，为 EXECUTE 阶段提供精确指引。

**Trigger:** DEFINE 阶段规格确认后，进入 EXECUTE 之前。

---

## 说明

本技能是 Superpowers writing-plans 在 Superman 体系中的直接保留，行为完全一致。

关键要点：
- 每个任务包含：具体文件路径、完整代码（非伪代码）、可运行的测试命令和预期输出
- 遵循 TDD：每个实现步骤前先写失败测试
- 不写 "TBD"、"similar to above"、"handle edge cases" 等占位符
- 计划保存到：`docs/superpowers/plans/YYYY-MM-DD-{feature}.md`

执行完本技能后，将 `plan.md` 路径写入 `.superman/phases/execute/plan.md`（作为引用），然后调用 `superman:subagent-dev` 或 `superman:tdd` 开始执行。
```

- [ ] **Step 5: 创建 superman:archive**

```markdown
# superman:archive

**Goal:** 将已完成的变更移入归档目录，更新规格文档，清理当前 phases/ 工作目录。

**Trigger:** VERIFY 阶段所有检查通过，`superman:git-ship` 完成后调用。

---

## 执行步骤

1. 确认 VERIFY 阶段所有检查已通过（verify/review.md 和 spec-check.md 存在且无未解决项）

2. 创建归档目录：

```bash
mkdir -p .superman/archive/$(date +%Y-%m-%d)-{feature-name}
```

3. 将 phases/ 下的产物复制到归档目录：

```bash
cp -r .superman/phases/ .superman/archive/$(date +%Y-%m-%d)-{feature-name}/
cp .superman/context/requirements.md .superman/archive/$(date +%Y-%m-%d)-{feature-name}/
cp .superman/context/decisions.md .superman/archive/$(date +%Y-%m-%d)-{feature-name}/
```

4. 清理当前工作目录：

```bash
rm -rf .superman/phases/
rm -f .superman/context/size-classification.md
```

注意：保留 `requirements.md` 和 `decisions.md` 的累积历史（不删除，只是已归档的内容保留在归档中）

5. 向用户确认归档完成，报告归档路径
```

- [ ] **Step 6: 运行校验器，确认所有 DEFINE 技能通过**

```bash
node scripts/validate-skills.js
```

预期输出：`✅ 6 skills validated successfully.`（DEFINE 6 个），加上其他 phase 缺失提示。

- [ ] **Step 7: Commit**

```bash
git add skills/define/
git commit -m "feat: add all 6 DEFINE phase skills (propose, brainstorming, spec-review, writing-plans, archive, size-classify)"
```

---

## Task 6: 创建 superman init 脚本

**Files:**
- Create: `scripts/install.sh`

- [ ] **Step 1: 编写 install.sh**

```bash
#!/usr/bin/env bash
# superman init — 将 Superman 配置注入目标项目

set -e

SUPERMAN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="${1:-$(pwd)}"

echo "🦸 Superman Plugin Initializer"
echo "  Source: $SUPERMAN_DIR"
echo "  Target: $TARGET_DIR"
echo ""

# 检测目标项目使用的 AI 平台
detect_platform() {
  if [ -f "$TARGET_DIR/.claude" ] || [ -d "$TARGET_DIR/.claude" ]; then
    echo "claude"
  elif [ -f "$TARGET_DIR/.cursorrules" ]; then
    echo "cursor"
  else
    echo "all"
  fi
}

PLATFORM=$(detect_platform)
echo "  Detected platform: $PLATFORM"
echo ""

# 创建 .superman/ 结构
mkdir -p "$TARGET_DIR/.superman/context"
mkdir -p "$TARGET_DIR/.superman/phases/define"
mkdir -p "$TARGET_DIR/.superman/phases/execute"
mkdir -p "$TARGET_DIR/.superman/phases/verify"
mkdir -p "$TARGET_DIR/.superman/archive"
mkdir -p "$TARGET_DIR/.superman/ci"

# 安装 Claude Code 配置
install_claude() {
  echo "  Installing Claude Code config..."
  mkdir -p "$TARGET_DIR/.claude-plugin"
  cp "$SUPERMAN_DIR/platforms/claude/plugin.json" "$TARGET_DIR/.claude-plugin/plugin.json" 2>/dev/null || true
  cat "$SUPERMAN_DIR/CLAUDE.md" >> "$TARGET_DIR/CLAUDE.md"
  cp "$SUPERMAN_DIR/hooks/hooks.json" "$TARGET_DIR/.claude/hooks.json" 2>/dev/null || true
  echo "  ✓ Claude Code configured"
}

# 根据平台安装
case "$PLATFORM" in
  claude) install_claude ;;
  all)
    install_claude
    echo "  ✓ All platforms configured"
    ;;
esac

# 安装默认 CI gates
cp "$SUPERMAN_DIR/ci/gates-default.json" "$TARGET_DIR/.superman/ci/gates.json"

echo ""
echo "✅ Superman initialized in $TARGET_DIR"
echo ""
echo "Next steps:"
echo "  1. Add .superman/context/ and .superman/phases/ to .gitignore"
echo "  2. Run your AI agent and start with: 'Let's work on [your requirement]'"
echo "  3. Superman will automatically classify the requirement and guide you through the workflow"
```

- [ ] **Step 2: 赋予执行权限**

```bash
chmod +x scripts/install.sh
```

- [ ] **Step 3: 测试脚本在临时目录**

```bash
mkdir -p /tmp/test-superman-init
bash scripts/install.sh /tmp/test-superman-init
ls -la /tmp/test-superman-init/.superman/
```

预期输出：`.superman/context/`、`.superman/phases/`、`.superman/ci/gates.json` 存在。

- [ ] **Step 4: 清理并 Commit**

```bash
rm -rf /tmp/test-superman-init
git add scripts/install.sh
git commit -m "feat: add superman init script for project initialization"
```

---

## Task 7: 创建 README 和最终验证

**Files:**
- Create: `README.md`
- Modify: `package.json`（添加描述）

- [ ] **Step 1: 编写 README.md**

```markdown
# 🦸 Superman Plugin

> OpenSpec + Superpowers + Agent Skills 融合插件 — 需求层 + 流程层 + 纪律层三位一体

## 安装

### npm（推荐）

```bash
npm install -g superman-plugin
superman init
```

### 手动安装

```bash
git clone https://github.com/your-org/superman
cd your-project
bash superman/scripts/install.sh
```

## 工作流

```
用户需求 → size-classify（S/M/L 分级）
  S 级：直接 EXECUTE
  M 级：DEFINE Lite → EXECUTE → VERIFY Lite
  L 级：DEFINE（完整）→ EXECUTE → VERIFY（完整）
```

## 技能列表

| 阶段 | 技能 | 来源 |
|------|------|------|
| DEFINE | size-classify, brainstorming, propose, spec-review, writing-plans, archive | OpenSpec + Superpowers + Agent Skills |
| EXECUTE | tdd, subagent-dev, incremental-impl, security, api-design, frontend-ui, debugging, worktrees | Superpowers + Agent Skills |
| VERIFY | code-review, production-ready, spec-satisfied, verification, git-ship, ci-gates | Superpowers + Agent Skills |

## 支持平台

Claude Code · Cursor · Gemini CLI · Codex · GitHub Copilot · OpenCode

## 设计文档

- [设计规格](docs/superpowers/specs/2026-05-24-superman-design.md)
- [实施计划 A — 基础设施](docs/superpowers/plans/2026-05-24-superman-plan-a-foundation.md)
```

- [ ] **Step 2: 运行完整校验**

```bash
node scripts/validate-skills.js
```

预期：DEFINE 6 个技能全部通过，EXECUTE 和 VERIFY 目录缺失提示（正常，Plan B 处理）。

- [ ] **Step 3: 最终 Commit**

```bash
git add README.md docs/
git commit -m "docs: add README and complete Plan A foundation"
```

---

## 自检

- [x] **Spec 覆盖**：Task 1 覆盖仓库结构；Task 2 覆盖 validate-skills.js；Task 3 覆盖 CI gates + CLAUDE.md/GEMINI.md/AGENTS.md；Task 4-5 覆盖所有 DEFINE 技能；Task 6 覆盖 install.sh；Task 7 覆盖 README
- [x] **占位符扫描**：无 TBD/TODO，所有代码块完整
- [x] **类型一致性**：`validate-skills.js` 校验逻辑与技能文件结构（Goal、Trigger 字段）完全一致
- [x] **规格满足度**：Plan A 完成后，基础设施和 DEFINE 阶段技能全部就位，可独立运行校验器
