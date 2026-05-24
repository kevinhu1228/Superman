# superman:propose

**Goal**: 创建结构化变更提案，在 `.superman/phases/define/` 下生成 `proposal.md` 和 `spec.md` 草稿。

**Trigger**: `superman:brainstorming` 完成需求确认后自动调用（M/L 级）。M Lite 级只生成 tasks.md，跳过 spec.md。

---

## 执行步骤

1. 创建目录（如不存在）：

```
mkdir -p .superman/phases/define
```

2. 生成 `.superman/phases/define/proposal.md`：

```
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

```
# 任务清单

**来源：** proposal.md
**状态：** 待执行

- [ ] Task 1: {具体任务描述}
- [ ] Task 2: {具体任务描述}
```

5. 向用户展示 proposal.md，请求确认后进入 `superman:writing-plans`
