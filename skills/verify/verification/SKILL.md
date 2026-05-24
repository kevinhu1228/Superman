# superman:verification

**Goal**: 通过在实际运行环境中操作应用，观察和验证代码变更产生了预期的用户可见行为，不依赖测试代码的正确性假设。

**Trigger**: VERIFY 阶段，`superman:spec-satisfied` 通过后调用（L/M/S 级均执行）。

---

## 说明

本技能是 Superpowers verification 在 Superman 体系中的直接保留，核心行为一致。

## 核心原则

**测试通过 ≠ 功能正确。**

测试只验证代码的预期行为。Verification 验证应用在真实环境中的实际行为。

## 验证流程

### Step 1: 启动应用

确保使用开发/staging 环境，不用生产环境。

```bash
npm run dev   # 或 python manage.py runserver，或 go run main.go
```

确认应用启动成功（无启动错误）。

### Step 2: 黄金路径验证

按照 spec.md 中的成功路径，逐步操作：

1. 打开应用（本地 URL）
2. 按照用户故事描述的步骤操作
3. 确认每个步骤产生预期的 UI / 响应 / 数据变化

使用 Chrome DevTools MCP（Web 应用）：

1. `navigate_page` → 打开应用
2. `take_snapshot` → 确认初始状态
3. 执行操作（`fill`、`click` 等）
4. `take_snapshot` → 确认操作后状态
5. `take_screenshot` → 保留视觉证据

### Step 3: 边界条件验证

对以下场景进行手动验证：
- 空输入 / 无效输入 → 确认错误提示符合预期
- 已存在数据（重复创建）→ 确认冲突处理
- 权限边界 → 确认无权操作被正确拒绝

### Step 4: 确认无回归

快速操作之前正常工作的功能，确认无意外破坏。

### Step 5: 生成验证报告

将观察结果记录到 `.superman/phases/verify/review.md`：

```
## Verification 报告

**验证时间：** {ISO 时间戳}
**验证环境：** localhost:3000 / staging

### 黄金路径
- [x] 用户注册 → 成功，跳转到 /dashboard
- [x] 显示欢迎语 → "Welcome, {name}" 正确显示
- [x] 邮件验证链接 → 收到邮件，点击后标记已验证

### 边界条件
- [x] 重复邮件注册 → 显示 "Email already in use" 错误
- [x] 弱密码 → 显示密码强度要求

### 回归
- [x] 登录功能 → 正常
- [x] 用户设置 → 正常

**结论：PASS**
```

## 发现问题时

若发现实际行为与预期不符：
1. 截图记录（`take_screenshot` + 保存文件）
2. 记录复现步骤
3. 返回 EXECUTE 阶段修复
4. 修复后重新执行 verification
