# 🦸 Superman Plugin

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
