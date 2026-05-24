# superman:git-ship

**Goal**: 通过结构化分支决策流程 + 发布前核查清单，确保代码安全合并到主分支并正确发布。

**Trigger**: VERIFY 阶段所有检查通过后（spec-satisfied ✅ + verification ✅ + code-review ✅ + production-ready ✅），作为最后一步调用。

---

## 分支决策（Superpowers 贡献）

### 评估分支状态

```bash
git log main..HEAD --oneline    # 本分支领先主分支的 commit 数量
git diff main..HEAD --stat      # 改动规模
git log --oneline -5            # 最近的 commit 历史
```

### 分支策略

| 情况 | 策略 |
|------|------|
| 单个逻辑变更 | squash merge（保持主分支历史干净） |
| 多个独立变更 | merge commit（保留分支结构） |
| 工作在 worktree | 从 worktree 分支发起 PR |
| 快速修复 | cherry-pick 到 main + tag |

### PR 创建（有 GitHub 时）

```bash
gh pr create \
  --title "feat: {变更描述}" \
  --body "## Summary
- {主要变更 1}
- {主要变更 2}

## Test plan
- [x] Unit tests passing
- [x] Manual verification complete
- [x] spec-satisfied check passed"
```

## 发布前核查清单（Agent Skills 贡献）

提交 PR / merge 前逐项确认：

### 代码层面

- [ ] 所有测试通过（`npm test` / `pytest` / `go test`）
- [ ] Linting 通过（无 error 级别告警）
- [ ] 无 `console.log`、`debugger`、临时注释留在代码中
- [ ] 无 `TODO: fix before merge` 类型的标记

### 文档层面

- [ ] 若修改了公开 API → 更新 API 文档
- [ ] 若新增了环境变量 → 更新 `.env.example`
- [ ] 若修改了 schema → 确认 migration 已包含

### 版本层面

- [ ] 版本号已更新（若需要）
- [ ] CHANGELOG 已更新（若有）
- [ ] 所有 CI checks 通过（GitHub Actions / CircleCI）

### 合并后

- [ ] 在 staging 验证合并后的代码
- [ ] 监控错误率 30 分钟（若是生产发布）
- [ ] 若是重大发布：通知相关团队

## Smoke Test（合并后验证）

```bash
# 切回主分支
git checkout main
git pull

# 快速验证关键功能（2-3 个最重要的操作）
curl http://localhost:3000/health   # API 健康检查
# 或手动打开应用验证一个核心流程
```

## 调用 superman:archive

git-ship 完成后，调用 `superman:archive` 将此次变更的所有 .superman/ 产物归档。
