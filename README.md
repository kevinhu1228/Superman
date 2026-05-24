# 🦸 Superman Plugin

> **OpenSpec + Superpowers + Agent Skills 三位一体的 AI 开发工作流插件**
>
> 需求层 · 流程层 · 纪律层 — 让 AI 开发从混乱走向工程化

[![npm version](https://img.shields.io/npm/v/superman-plugin.svg)](https://www.npmjs.com/package/superman-plugin)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Node.js](https://img.shields.io/badge/node-%3E%3D18-brightgreen.svg)](https://nodejs.org/)
[![Platforms](https://img.shields.io/badge/platforms-Claude%20%7C%20Cursor%20%7C%20Gemini%20%7C%20Codex%20%7C%20Copilot%20%7C%20OpenCode-blue.svg)](#平台支持)

---

## 目录

- [简介](#简介)
- [核心特性](#核心特性)
- [快速开始](#快速开始)
- [安装方式](#安装方式)
- [工作流详解](#工作流详解)
- [技能库（21 个技能）](#技能库)
- [平台支持](#平台支持)
- [CI 门控](#ci-门控)
- [上下文持久化](#上下文持久化)
- [CLI 命令参考](#cli-命令参考)
- [项目结构](#项目结构)
- [开发与贡献](#开发与贡献)

---

## 简介

Superman Plugin 是一个统一的 AI 编程助手工作流插件，将三套成熟方法论融合为一体：

| 来源 | 职责 | 核心贡献 |
|------|------|----------|
| **OpenSpec** | 需求层 | 结构化需求管理、规格验证 |
| **Superpowers** | 流程层 | 分级路由、阶段门控、子智能体编排 |
| **Agent Skills** | 纪律层 | TDD 强制执行、安全检查、调试协议 |

**三个阶段，贯穿始终：**

```
用户需求 → [size-classify] → S / M / L
                               │
              S: ──────────── EXECUTE ────────────────────────────→ 完成
              M: ── DEFINE Lite ── EXECUTE ── VERIFY Lite ──────→ 完成
              L: ── DEFINE Full ── EXECUTE ── VERIFY Full ──────→ 完成
                                              (CI 门控强制)
```

---

## 核心特性

- **🎯 智能需求分级** — 从 3 个维度（范围、时间、影响）评分，自动路由至 S/M/L 流程
- **📁 文件驱动持久化** — 所有状态写入 `.superman/` 目录，会话压缩或重启后完整恢复
- **🔒 L 级不可跳过** — CI 门控在代码层面强制执行阶段规范，不依赖 AI 自觉
- **🛠️ 21 个统一技能** — DEFINE / EXECUTE / VERIFY 三阶段覆盖，跨 6 个平台复用
- **🌐 多平台适配** — 同一套技能库，一键同步到 Claude Code、Cursor、Gemini CLI 等
- **✅ TDD 硬门控** — 内置反借口表，强制先写测试再实现
- **🔍 规格验证脚本** — 自动扫描 TBD 占位符、缺失章节、未通过审查标记

---

## 快速开始

```bash
# 1. 安装
npm install -g superman-plugin

# 2. 在你的项目中初始化
cd your-project
superman init

# 3. 开始第一个任务 — 分级
# 在 AI 中运行：
/superman:size-classify
```

AI 会评估需求并宣告级别（S/M/L），然后自动进入对应工作流。

---

## 安装方式

### npm 安装（推荐）

```bash
npm install -g superman-plugin
superman init
```

### 手动安装

```bash
git clone https://github.com/kevinhu1228/superman.git
cd your-project
bash /path/to/superman/scripts/install.sh .
```

### install.sh 做了什么

1. 创建 `.superman/` 目录结构（context、phases、archive、ci 子目录）
2. 运行 `scripts/sync-platforms.sh` — 检测当前项目安装了哪些 AI 平台，逐一写入配置：
   - Claude Code → `CLAUDE.md` + hooks
   - Cursor → `.cursorrules` + hooks
   - Gemini CLI → `GEMINI.md` + `gemini-extension.json` + hooks
   - Codex → `AGENTS.md` + hooks
   - GitHub Copilot → `.github/copilot-instructions.md`
   - OpenCode → `.opencode/plugins/superman.js`
3. 安装 CI 门控模板 `.superman/ci/gates.json`
4. 提示将 `.superman/context/`、`.superman/phases/`、`.superman/archive/` 添加到 `.gitignore`

---

## 工作流详解

### 第一步：需求分级

运行 `superman:size-classify`，AI 从三个维度打分：

| 维度 | S（小）| M（中）| L（大）|
|------|--------|--------|--------|
| 变更范围 | 1 个文件/函数 | 2–5 个文件/模块 | 跨模块/架构 |
| 时间估算 | < 1 小时 | 1–8 小时 | > 1 天 |
| 影响面 | 局部 | 有限扩散 | 全局/核心路径 |

### 第二步：阶段路由

| 级别 | DEFINE | EXECUTE | VERIFY |
|------|--------|---------|--------|
| **S** | ❌ 跳过 | ✅ 完整执行 | ❌ 仅内联 review |
| **M** | ⚡ Lite（目标 + 任务清单） | ✅ 完整执行 | ⚡ Lite（code-review，跳过生产就绪检查）|
| **L** | ✅ 完整（规格文档 + 计划）| ✅ 完整执行 | ✅ 完整（CI 门控强制）|

### 关键规则

- **不允许静默降级** — AI 不能自行将 L 降为 M/S；用户必须明确说明原因并写入 `decisions.md`
- **EXECUTE 前规格必须通过** — L/M 级需运行 `node scripts/validate-spec.js --strict`，通过后才能开始编码
- **TDD 不可绕过** — `superman:tdd` 内置反借口表，任何"先实现再补测试"的理由均被预先驳回
- **增量提交 ≤ 100 行** — `superman:incremental-impl` 强制拆分大 diff，实现顺序：数据结构 → 函数 → 逻辑 → I/O → 界面

---

## 技能库

共 **21 个技能**，按阶段组织。

### DEFINE 阶段（6 个技能）

| 技能 | 用途 |
|------|------|
| `superman:size-classify` | 三维度评分，输出 S/M/L 分级并写入 `.superman/context/size-classification.md` |
| `superman:brainstorming` | 5 问题结构化需求澄清（目标、成功标准、约束、边界、风险） |
| `superman:propose` | 生成变更提案（`proposal.md`）及规格/任务草稿 |
| `superman:spec-review` | 扫描 TBD/TODO、一致性检查、歧义标记，通过后写入 "Spec Review: PASSED" |
| `superman:writing-plans` | 生成详细实施计划（`tasks.md`），包含具体代码片段和测试命令 |
| `superman:archive` | 将完成的变更归档至 `.superman/archive/YYYY-MM-DD-{name}/`，清理工作目录 |

### EXECUTE 阶段（8 个技能）

| 技能 | 用途 |
|------|------|
| `superman:tdd` | 红-绿-重构循环强制执行；内置反借口表阻断一切跳过测试的理由 |
| `superman:subagent-dev` | 将任务分发给独立子智能体；两阶段审查（规格符合性 + 代码质量） |
| `superman:incremental-impl` | ≤100 行提交限制；内到外实现顺序（数据结构 → 函数 → 逻辑 → I/O → 接口） |
| `superman:security` | 安全检查清单（输入验证、注入防护、认证鉴权、数据保护、依赖、错误处理） |
| `superman:api-design` | REST 规范（资源命名、HTTP 语义、状态码、统一错误格式） |
| `superman:frontend-ui` | 组件规范（单一职责、类型化 Props、状态管理、可访问性、性能优化） |
| `superman:debugging` | 5 步调试流程（复现 → 隔离 → 假设 → 验证 → 修复）+ 假设追踪表 |
| `superman:worktrees` | 在 `git worktree .worktrees/{feature-name}` 中隔离变更，支持并行开发 |

### VERIFY 阶段（7 个技能）

| 技能 | 用途 |
|------|------|
| `superman:code-review` | 双向协议（请求方提供上下文 + 聚焦点；审查方使用规格/安全/可维护性检查清单） |
| `superman:production-ready` | L 级生产就绪门控（可观测性、错误处理、配置/密钥、数据库迁移、依赖、部署就绪） |
| `superman:spec-satisfied` | 逐条验证 `spec.md` 需求已有对应代码/测试；生成合规报告 |
| `superman:verification` | 在 dev/staging 环境运行应用，手动验证主干路径 + 边缘场景 |
| `superman:git-ship` | 分支决策（squash merge vs merge commit）+ PR 创建 + 发布前检查清单 |
| `superman:ci-gates` | 执行 `.superman/ci/gates.json` 中的所有门控（仅 L 级）；任一失败则阻断合并 |
| `superman:retrospective` | 结构化复盘（做得好的、遇到的困难、下次改进点）；将最佳实践追加到项目知识库 |

---

## 平台支持

Superman 使用同一套 `skills/` 技能库，通过适配层覆盖 6 个主流 AI 编程平台：

| 平台 | 触发方式 | 配置文件 | 激活方式 |
|------|---------|----------|----------|
| **Claude Code** | `/superman:*` 斜杠命令 | `plugin.json` + hooks | Skill 工具直接调用 |
| **Cursor** | `@superman` 提及 | `plugin.json` + `.cursorrules` | 斜杠命令注解 |
| **Gemini CLI** | `/superman:*` 命令 | `gemini-extension.json` + hooks | `activate_skill` 工具 |
| **Codex / Agents** | 技能工具调用 | `plugin.json` + hooks | Agent 技能工具分发 |
| **GitHub Copilot** | `/superman` 对话命令 | `copilot-instructions.md` | 对话集成 |
| **OpenCode** | JavaScript API | `superman.js` | 会话启动 Hook + 斜杠命令 |

同步所有平台配置：

```bash
bash scripts/sync-platforms.sh [target-dir]
```

---

## CI 门控

门控配置文件：`ci/gates-default.json`

**默认门控（仅 L 级触发）：**

```json
{
  "gates": [
    {
      "name": "validate-skills",
      "command": "node scripts/validate-skills.js",
      "description": "验证所有 SKILL.md 文件包含 Goal 和 Trigger 章节"
    },
    {
      "name": "spec-exists",
      "check": "file-exists",
      "path": ".superman/phases/define/spec.md",
      "description": "L 级需求必须存在规格文档"
    }
  ]
}
```

项目可在 `.superman/ci/gates.json` 中扩展自定义门控（Lint、测试、安全扫描等）。

**运行 CI 门控：**

```bash
/superman:ci-gates
```

任一门控失败均会阻断合并，并输出失败原因和修复建议。

---

## 上下文持久化

所有状态以文件形式保存在 `.superman/` 目录，不依赖会话内存：

```
.superman/
├── context/
│   ├── requirements.md        # 实时追加用户需求，永不删除
│   ├── decisions.md           # 每条决策带时间戳
│   └── size-classification.md # 一次写入后锁定，禁止静默修改
├── phases/
│   ├── define/
│   │   ├── proposal.md        # 变更提案
│   │   ├── spec.md            # 规格文档（M/L 级）
│   │   └── tasks.md           # 实施任务清单
│   ├── execute/
│   │   ├── plan.md            # 执行计划
│   │   └── progress.md        # 实时任务进度
│   └── verify/
│       ├── review.md          # 代码审查结果
│       └── spec-check.md      # 规格符合性报告
└── ci/
    └── gates.json             # 项目 CI 门控配置
```

**会话恢复协议：**

每次新会话开始时，Superman 检查 `.superman/context/requirements.md` 是否存在，若存在则读取所有 `.superman/` 文件并宣告：

```
Context restored from .superman/ — currently at EXECUTE phase, task 3/7 in progress
```

---

## CLI 命令参考

### `superman` 命令

```bash
superman init              # 在当前项目初始化 Superman 工作目录
superman init [target]     # 在指定目录初始化
```

### 验证脚本

```bash
# 验证所有 SKILL.md 文件结构
node scripts/validate-skills.js

# 验证规格文档（基础检查）
node scripts/validate-spec.js

# 严格模式（要求 "Spec Review: PASSED" 标记）
node scripts/validate-spec.js --strict

# 验证指定文件
node scripts/validate-spec.js .superman/phases/define/spec.md
```

### 平台同步

```bash
# 同步所有检测到的平台配置
bash scripts/sync-platforms.sh

# 同步到指定目录
bash scripts/sync-platforms.sh /path/to/project
```

---

## 项目结构

```
superman/
├── bin/
│   └── superman              # CLI 入口
├── skills/
│   ├── define/               # DEFINE 阶段技能（6 个）
│   │   ├── size-classify/SKILL.md
│   │   ├── brainstorming/SKILL.md
│   │   ├── propose/SKILL.md
│   │   ├── spec-review/SKILL.md
│   │   ├── writing-plans/SKILL.md
│   │   └── archive/SKILL.md
│   ├── execute/              # EXECUTE 阶段技能（8 个）
│   │   ├── tdd/SKILL.md
│   │   ├── subagent-dev/SKILL.md
│   │   ├── incremental-impl/SKILL.md
│   │   ├── security/SKILL.md
│   │   ├── api-design/SKILL.md
│   │   ├── frontend-ui/SKILL.md
│   │   ├── debugging/SKILL.md
│   │   └── worktrees/SKILL.md
│   └── verify/               # VERIFY 阶段技能（7 个）
│       ├── code-review/SKILL.md
│       ├── production-ready/SKILL.md
│       ├── spec-satisfied/SKILL.md
│       ├── verification/SKILL.md
│       ├── git-ship/SKILL.md
│       ├── ci-gates/SKILL.md
│       └── retrospective/SKILL.md
├── platforms/                # 平台适配层
│   ├── claude/plugin.json
│   ├── cursor/plugin.json + cursorrules.md
│   ├── gemini/gemini-extension.json
│   ├── codex/plugin.json
│   ├── copilot/copilot-instructions.md
│   └── opencode/superman.js
├── hooks/                    # 平台 Hook 配置
│   ├── hooks.json            # Claude Code hooks
│   ├── hooks-cursor.json
│   ├── hooks-gemini.json
│   └── hooks-codex.json
├── ci/
│   ├── gates-default.json    # 默认 CI 门控
│   └── gates-schema.json     # 门控配置 JSON Schema
├── scripts/
│   ├── install.sh            # 安装脚本
│   ├── sync-platforms.sh     # 平台同步脚本
│   ├── validate-skills.js    # 技能结构验证
│   └── validate-spec.js      # 规格文档验证
├── docs/
│   ├── diagrams/             # 架构图（PNG）
│   └── superpowers/          # 设计规格和实施计划
├── CLAUDE.md                 # Claude Code 平台指令
├── GEMINI.md                 # Gemini CLI 平台指令
├── AGENTS.md                 # Codex/Agents 平台指令
└── package.json
```

---

## 开发与贡献

### 环境要求

- Node.js >= 18
- Git

### 本地开发

```bash
git clone https://github.com/kevinhu1228/superman.git
cd superman
npm test           # 验证所有技能文件结构
npm run validate   # 同上
npm run sync       # 同步平台配置
```

### 添加新技能

1. 在 `skills/{define|execute|verify}/your-skill/` 下创建 `SKILL.md`
2. 文件必须包含以下结构：
   ```markdown
   # 技能名称

   **Goal**: 一句话说明技能目标

   ## Trigger
   何时触发该技能

   ## Steps
   执行步骤
   ```
3. 运行 `npm test` 确保验证通过
4. 在对应平台的 `plugin.json` 中注册技能

### 设计文档

- [设计规格](docs/superpowers/specs/2026-05-24-superman-design.md)
- [实施计划 A — 基础设施](docs/superpowers/plans/2026-05-24-superman-plan-a-foundation.md)
- [实施计划 B — 技能库](docs/superpowers/plans/2026-05-24-superman-plan-b-skills.md)
- [实施计划 C — 平台适配](docs/superpowers/plans/2026-05-24-superman-plan-c-platform.md)

---

## License

MIT © [kevinhu1228](https://github.com/kevinhu1228/superman)
