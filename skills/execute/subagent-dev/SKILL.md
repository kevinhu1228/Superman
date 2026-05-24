# superman:subagent-dev

**Goal**: 将 `.superman/phases/define/tasks.md` 中的任务分发给独立 subagent 执行，每个 subagent 持有精确的任务描述和上下文，完成后经两级审查（规格合规 + 代码质量）再进入下一个任务。

**Trigger**: DEFINE 阶段完成（tasks.md 就绪），进入 EXECUTE 阶段时调用。

---

## 说明

本技能是 Superpowers subagent-driven-development 在 Superman 体系中的直接保留，核心行为一致。

## 核心原则

- **Fresh subagent per task**：每个任务派发全新 subagent，不继承当前会话上下文
- **Two-stage review**：每个任务完成后，先做规格合规审查，再做代码质量审查
- **连续执行**：任务之间不停下来询问用户，除非遇到 BLOCKED 状态或真正的歧义

## 执行流程

### 准备阶段

1. 读取 `.superman/phases/define/tasks.md`，提取所有任务的完整文本和上下文
2. 读取 `.superman/phases/execute/plan.md`（如存在），获取实施计划
3. 在 `.superman/phases/execute/progress.md` 创建进度跟踪，列出所有任务

### 每个任务

**1. 派发实现 subagent**

给 subagent 提供：
- 任务完整文本（从 tasks.md 提取）
- 项目上下文（stack、目录结构、相关文件路径）
- spec.md 相关章节（L 级）
- 已完成任务的 commit SHA（用于 code review 对比）

要求 subagent 使用 `superman:tdd` 技能执行任务。

**2. 处理 subagent 状态**

| 状态 | 处理方式 |
|------|---------|
| DONE | 进入规格合规审查 |
| DONE_WITH_CONCERNS | 读取关注点，若涉及正确性则处理后再审查 |
| NEEDS_CONTEXT | 提供缺少的上下文，重新派发 |
| BLOCKED | 评估阻塞原因；提供更多上下文 / 拆分任务 / 升级给用户 |

**3. 规格合规审查**

派发 spec reviewer subagent，验证代码与 spec.md / tasks.md 的要求一致：
- ✅ 无缺失功能
- ✅ 无超出范围的实现
- ❌ 发现问题 → 原 implementer 修复 → 重审

**4. 代码质量审查**

派发 code quality reviewer subagent，检查正确性、可维护性、安全性：
- ❌ 发现 Important 以上问题 → 修复 → 重审

**5. 标记完成**

将任务在 `.superman/phases/execute/progress.md` 中标为 `[x]`，继续下一个任务。

### 完成阶段

所有任务完成后：
1. 派发最终代码审查 subagent（整体实现质量）
2. 调用 `superman:git-ship` 技能
