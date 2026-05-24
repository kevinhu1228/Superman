# superman:ci-gates

**Goal**: 读取 `.superman/ci/gates.json`，执行所有配置的 CI 门控检查，确保 L 级需求在合并前通过所有自动化验证。

**Trigger**: VERIFY 阶段，L 级需求在 `superman:spec-satisfied` 之后调用。M 级和 S 级跳过此技能。

---

## 执行流程

### Step 1: 读取 gates 配置

```bash
cat .superman/ci/gates.json
```

若文件不存在：
- L 级：报错停止，提示用户配置 CI gates（参考项目根目录 `ci/gates-default.json`）
- gates 为空数组：跳过并记录日志，继续下一步

### Step 2: 逐个执行 gate

对每个 gate 对象（`{ id, name, command, expected_exit_code }`）执行：

```bash
echo "Running gate: {gate.name}"
{gate.command}
EXIT_CODE=$?

if [ $EXIT_CODE -eq {gate.expected_exit_code} ]; then
  echo "✅ PASS: {gate.name}"
else
  echo "❌ FAIL: {gate.name} (exit code: $EXIT_CODE, expected: {gate.expected_exit_code})"
fi
```

### Step 3: 汇总结果

将结果追加到 `.superman/phases/verify/review.md`：

```
## CI Gates 结果

**执行时间：** {ISO 时间戳}
**需求等级：** L

| Gate ID | Gate Name | 结果 | 退出码 |
|---------|-----------|------|--------|
| validate-skills | Validate all skill files | ✅ PASS | 0 |
| spec-exists | Spec file must exist | ✅ PASS | 0 |

**总计：** {N} 个 gate，✅ {P} 通过，❌ {F} 失败

**结论：PASS / FAIL**
```

### Step 4: 处理失败

若任何 gate 失败：
1. 显示 gate 的完整输出（用于诊断）
2. 停止 VERIFY 阶段，不允许继续 git-ship
3. 返回 EXECUTE 阶段修复失败的检查项
4. 修复完成后重新执行 ci-gates

若全部通过：继续 `superman:git-ship`

## 添加自定义 Gate

在 `.superman/ci/gates.json` 中添加项目特定的检查：

```json
{
  "gates": [
    {
      "id": "unit-tests",
      "name": "All unit tests must pass",
      "command": "npm test",
      "expected_exit_code": 0,
      "phase": "verify",
      "required_level": "L"
    },
    {
      "id": "type-check",
      "name": "TypeScript type check",
      "command": "npx tsc --noEmit",
      "expected_exit_code": 0,
      "phase": "verify",
      "required_level": "L"
    }
  ]
}
```

## 与 superman:production-ready 的关系

`superman:production-ready` 是手动检查清单，`superman:ci-gates` 是自动化门控。可自动化的生产就绪检查项（如 `npm audit`、测试、类型检查）应同时配置为 ci-gates，实现双重保障。
