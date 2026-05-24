# superman:retrospective

**Goal**: 对已完成的任务进行结构化复盘，提炼可复用的最佳实践，输出本次回顾文档并追加到项目累积知识库。

**Trigger**: 任意任务完成后手动触发，或 VERIFY 阶段结束时触发。

---

## 执行步骤

### 1. 收集上下文

依次读取（存在才读）：

- `.superman/context/requirements.md` — 原始需求
- `.superman/context/size-classification.md` — 复杂度分级
- `.superman/context/decisions.md` — 本次关键决策
- 近期 git log（`git log --oneline -20`）

如果以上文件均不存在，向用户说明并询问需要回顾的内容。

### 2. 结构化提问（可选）

如用户未主动提供反馈，逐一询问：

1. **这次任务最顺利的环节是什么？**（工具、流程、方法论）
2. **遇到了哪些阻力或意外？如何解决的？**
3. **如果重来一次，哪里会做得不同？**
4. **有没有发现值得记录的模式或技巧？**

每次一个问题，等待用户回答后继续。

### 3. 生成本次回顾

写入 `.superman/context/retrospective.md`（每次覆盖）：

```markdown
# Retrospective: [需求摘要，一句话]

**Date**: YYYY-MM-DD
**Size**: S / M / L
**Phase reached**: DEFINE / EXECUTE / VERIFY

## What Was Built
[2-4 句话描述交付内容]

## Key Decisions
[列出 decisions.md 中的关键决策，或本次回顾中提到的决策点]

## What Worked Well
- [具体实践或工具，说明为什么有效]

## What Could Be Improved
- [具体问题，附上改进建议]

## Best Practices Extracted
- [可被未来任务复用的模式，每条独立可读]
```

### 4. 追加最佳实践

首先确保目录存在：`mkdir -p .superman/learnings/`

读取 `.superman/learnings/best-practices.md`（不存在则创建）。

将"Best Practices Extracted"中的每条实践，按以下分类追加：

| 分类 | 适用内容 |
|------|---------|
| **Workflow** | 流程顺序、阶段切换、任务拆分 |
| **Testing** | 测试策略、覆盖范围、TDD 节奏 |
| **Architecture** | 设计决策、模式选择、接口边界 |
| **Tooling** | 工具使用技巧、脚本、自动化 |
| **Communication** | 需求澄清、决策记录、文档习惯 |

每条格式：
```
- **YYYY-MM-DD** [实践内容，一句话可读] — [来源：需求摘要]
```

若某条实践与已有条目高度重复（含义相同），跳过追加，避免噪音。

### 5. 输出摘要

向用户展示：

```
✅ 回顾完成

本次回顾已写入：.superman/context/retrospective.md
最佳实践已追加：.superman/learnings/best-practices.md（新增 N 条）

--- 本次提炼的最佳实践 ---
• [实践 1]
• [实践 2]
...
```

---

## 输出文件说明

| 文件 | 说明 | Git 状态 |
|------|------|---------|
| `.superman/context/retrospective.md` | 本次回顾，每次覆盖 | gitignored |
| `.superman/learnings/best-practices.md` | 累积最佳实践，持续追加 | **committed** |

`.superman/learnings/` 应提交到版本库，供团队共享。首次使用前确认该目录未在 `.gitignore` 中。

---

## 质量标准

- 每条最佳实践**独立可读**：不依赖上下文即可理解
- 描述**行为而非结果**："在 DEFINE 阶段先写 spec 再设计接口"，而非"接口设计很好"
- 避免**泛泛而谈**："保持代码整洁" 不是最佳实践，"函数超过 40 行时拆分为独立职责单元" 才是
