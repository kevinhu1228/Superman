# superman:writing-plans

**Goal**: 基于 `.superman/phases/define/tasks.md` 生成详细实施计划，保存到 `docs/superpowers/plans/`，为 EXECUTE 阶段提供精确指引。

**Trigger**: DEFINE 阶段规格确认后，进入 EXECUTE 之前自动调用。

---

## 说明

本技能是 Superpowers writing-plans 在 Superman 体系中的直接保留，行为完全一致。

## 关键要点

- 每个任务包含：具体文件路径、完整代码（非伪代码）、可运行的测试命令和预期输出
- 遵循 TDD：每个实现步骤前先写失败测试
- 不写 "TBD"、"similar to above"、"handle edge cases" 等占位符
- 计划保存到：`docs/superpowers/plans/YYYY-MM-DD-{feature}.md`

## 计划文档格式

每个计划必须以如下 header 开始：

```
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superman:subagent-dev or superman:tdd to implement this plan task-by-task.

**Goal:** [一句话描述目标]
**Architecture:** [2-3 句架构描述]
**Tech Stack:** [关键技术栈]

---
```

## 执行完成后

将 plan.md 路径写入 `.superman/phases/execute/plan.md`（作为引用），然后调用 `superman:subagent-dev` 或 `superman:tdd` 开始执行。
