# superman:debugging

**Goal**: 通过系统化 5 步调试流程 + 错误恢复模式，避免随机猜测，快速定位并解决 bug。

**Trigger**: 遇到测试失败、代码报错、行为异常，或用户明确要求调试时触发。

---

## 5 步调试流程（Superpowers 主干）

### Step 1: 复现

**先能稳定复现，才能调试。**

- 找到最小复现步骤：能触发 bug 的最少操作
- 若无法复现 → 记录条件，等待下次出现
- 确认复现成功后再继续

### Step 2: 隔离

**缩小问题范围到最小可能的代码单元。**

- 二分法：注释掉一半代码，确认 bug 在哪半
- 逐步缩小范围：系统级 → 模块级 → 函数级 → 行级
- 使用 `git bisect` 定位引入 bug 的提交（有 git 历史时）

### Step 3: 形成假设

**在查看代码前，写下你认为的根因。**

```
假设：{我认为是 X 导致了 Y，因为 Z}
验证方法：{在 L 行添加 log/断点，检查变量 V 的值}
```

不允许没有假设就开始随机修改代码。

### Step 4: 验证假设

- 添加 log / 断点 / 临时 print 验证假设
- 若假设正确 → 进入 Step 5
- 若假设错误 → 返回 Step 3，形成新假设

**Hypothesis tracking（假设跟踪）：**

```
[假设 1] X 导致 Y — 已验证：❌ 错误（Z 变量值为 0 而非 null）
[假设 2] A 导致 B — 已验证：✅ 正确
```

### Step 5: 修复并验证

- 修复最小范围（不扩大改动）
- 运行测试，确认 bug 消失且无回归
- 删除所有临时 log / print
- 提交修复

## 错误恢复模式（Agent Skills 贡献）

根据错误类型选择恢复策略：

| 错误类型 | 恢复策略 |
|---------|---------|
| 测试失败（期望 vs 实际不匹配） | 检查测试本身是否正确；检查实现是否符合规格 |
| 运行时崩溃 / 异常 | 读完整 stack trace，从最内层 frame 开始 |
| 性能问题 | Profile first，找 hot path，不盲目优化 |
| 状态不一致 | 找状态的唯一写入点，检查写入顺序 |
| 第三方库报错 | 先读文档，再看 GitHub Issues，最后才改代码 |
| CI 失败但本地通过 | 检查环境差异（env vars、版本、文件路径大小写） |

## Browser DevTools 集成（Agent Skills 贡献）

前端 bug 调试时使用 Chrome DevTools MCP：

```
1. navigate_page → 打开目标页面
2. take_snapshot → 确认 DOM 状态
3. list_console_messages → 检查 JS 错误
4. list_network_requests → 检查 API 调用
5. evaluate_script → 在页面上下文中执行验证代码
```

## 何时停止调试（Escalation）

若 45 分钟内无进展：
1. 写下已知信息和已排除的假设
2. 请人 / AI review 当前 hypothesis log
3. 考虑临时绕过并记录 issue（不要无限挖洞）
