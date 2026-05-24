# superman:spec-satisfied

**Goal**: 对照 DEFINE 阶段生成的 spec.md，逐条验证 EXECUTE 阶段的代码变更是否完整实现了所有规格要求。

**Trigger**: VERIFY 阶段开始时，在 code-review 之前触发（L 级必须，M 级运行 Lite 版本，S 级跳过）。

---

## 执行步骤

### Step 1: 读取规格

读取 `.superman/phases/define/spec.md`，提取所有功能要求项。

若 spec.md 不存在：
- L 级：报错，VERIFY 不能继续，需先补写 spec.md
- M 级：改用 `.superman/phases/define/tasks.md` 作为验证依据

### Step 2: 对照代码

对每个规格要求，通过以下方式验证实现：
- 读取相关代码文件
- 运行相关测试（`npm test` / `pytest` / `go test`）
- 若有 API 端点：通过 curl 或 Chrome DevTools MCP 验证

### Step 3: 生成验证报告

将结果写入 `.superman/phases/verify/spec-check.md`：

```
# 规格满足度验证报告

**验证时间：** {ISO 时间戳}
**需求等级：** {L/M/S}
**Spec 来源：** .superman/phases/define/spec.md

## 验证结果

| # | 规格要求 | 状态 | 验证方式 | 备注 |
|---|---------|------|---------|------|
| 1 | 用户注册支持邮件+密码 | ✅ 满足 | test: test_user_registration | - |
| 2 | 密码强度检查（8位+数字+大写） | ✅ 满足 | test: test_password_strength | - |
| 3 | 注册后发送欢迎邮件 | ❌ 未实现 | 无相关测试，代码搜索未找到邮件发送逻辑 | 阻塞 |

## 总结

- ✅ 已满足：{N} 项
- ❌ 未满足：{M} 项
- ⚠️ 部分满足：{K} 项

**结论：PASS / FAIL**
```

### Step 4: 处理未满足项

若存在 ❌ 未满足项：
1. 报告给用户，说明缺少的实现
2. 用户确认 → 返回 EXECUTE 阶段补充实现
3. 实现完成后重新执行 spec-satisfied

若全部满足（✅）：
1. 在报告末尾追加 `*Spec Satisfied: PASSED [{ISO 时间戳}]*`
2. 继续 `superman:verification`

## Lite 模式（M 级）

使用 tasks.md 替代 spec.md：
- 只验证 tasks.md 中每个任务是否有对应实现和测试
- 不做深度规格比对
- 生成简化报告到 spec-check.md
