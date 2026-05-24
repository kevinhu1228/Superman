# superman:worktrees

**Goal**: 在 git worktree 中创建隔离工作空间，确保 EXECUTE 阶段的改动不影响主分支，便于并行开发和安全回滚。

**Trigger**: 进入 EXECUTE 阶段前，或用户要求隔离开发环境时调用。

---

## 说明

本技能是 Superpowers using-git-worktrees 在 Superman 体系中的直接保留，核心行为一致。

## 何时使用

- L 级需求的 EXECUTE 阶段（强烈推荐）
- 需要并行工作在多个功能时
- 需要保持主分支干净可部署时

## 创建 Worktree

在主仓库根目录执行：

```bash
git worktree add .worktrees/{feature-name} -b {feature-branch}
```

例：

```bash
git worktree add .worktrees/auth-refactor -b feat/auth-refactor
```

## 切换到 Worktree

```bash
cd .worktrees/{feature-name}
```

切换后，继续 EXECUTE 阶段的任务。所有改动在此 worktree 的分支上，不影响主分支。

## Worktree 规则

- **一个需求一个 worktree**：不在同一 worktree 混合多个功能
- **定期 rebase**：若主分支有更新，从 worktree 内执行 `git rebase main`
- **完成即合并**：VERIFY 阶段通过后，通过 `superman:git-ship` 合并到主分支

## 清理

```bash
# 在主仓库根目录
git worktree remove .worktrees/{feature-name}
```

若 worktree 有未提交更改：

```bash
git worktree remove --force .worktrees/{feature-name}
```

## 与 subagent-dev 配合

若使用 `superman:subagent-dev`，subagent 在 worktree 目录中执行任务：
- 每个 subagent 的提交都在 worktree 分支上
- Controller（当前会话）从主仓库目录协调
