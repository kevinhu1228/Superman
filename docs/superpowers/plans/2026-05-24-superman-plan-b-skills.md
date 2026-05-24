# Superman Plugin — Plan B: EXECUTE & VERIFY Phase Skills

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 创建 EXECUTE 阶段 8 个技能和 VERIFY 阶段 6 个技能的 SKILL.md 文件，完成 Superman 插件全部 20 个技能的实现。

**Architecture:** 纯 Markdown 技能文件，每个 SKILL.md 包含 Goal、Trigger 和详细执行指引。按合并策略分类：SP×AS 合并 3 个（tdd/debugging/code-review）、SP 保留 3 个（subagent-dev/worktrees/verification）、AS 保留 5 个（incremental-impl/security/api-design/frontend-ui/production-ready）、新增 2 个（spec-satisfied/ci-gates），git-ship 为 SP×AS 合并。

**Tech Stack:** Markdown, Node.js (validate-skills.js)

---

## 文件清单

| 操作 | 路径 | 来源 |
|------|------|------|
| Create | `skills/execute/tdd/SKILL.md` | SP × AS 合并 |
| Create | `skills/execute/debugging/SKILL.md` | SP × AS 合并 |
| Create | `skills/execute/subagent-dev/SKILL.md` | Superpowers 保留 |
| Create | `skills/execute/worktrees/SKILL.md` | Superpowers 保留 |
| Create | `skills/execute/incremental-impl/SKILL.md` | Agent Skills 保留 |
| Create | `skills/execute/security/SKILL.md` | Agent Skills 保留 |
| Create | `skills/execute/api-design/SKILL.md` | Agent Skills 保留 |
| Create | `skills/execute/frontend-ui/SKILL.md` | Agent Skills 保留 |
| Create | `skills/verify/code-review/SKILL.md` | SP × AS 合并 |
| Create | `skills/verify/git-ship/SKILL.md` | SP × AS 合并 |
| Create | `skills/verify/production-ready/SKILL.md` | Agent Skills 保留 |
| Create | `skills/verify/spec-satisfied/SKILL.md` | 新增 |
| Create | `skills/verify/verification/SKILL.md` | Superpowers 保留 |
| Create | `skills/verify/ci-gates/SKILL.md` | 新增 |

---

## Task 1: EXECUTE 阶段合并技能（tdd + debugging）

**Files:**
- Create: `skills/execute/tdd/SKILL.md`
- Create: `skills/execute/debugging/SKILL.md`

- [ ] **Step 1: 创建 skills/execute/tdd/SKILL.md**

```markdown
# superman:tdd

**Goal**: 通过强制"先写测试后实现"的执行顺序，配合反合理化防线，确保每个实现步骤都有测试覆盖，不接受任何跳过测试的理由。

**Trigger**: EXECUTE 阶段开始时自动调用，或在 subagent-dev 中每个 task 开始执行前触发。

---

## 核心规则（硬性门控）

**以下顺序不可更改：**

写失败测试 → 确认测试失败（RED）→ 写最小实现 → 确认测试通过（GREEN）→ 提交

任何绕过此顺序的理由都是无效的。

## 反合理化防线（Agent Skills 贡献）

遇到以下借口时，直接拒绝并继续 TDD：

| 借口 | 回应 |
|------|------|
| "这个逻辑太简单了，不需要测试" | 简单的逻辑恰好最容易出 bug，先写测试 |
| "我先把功能做出来再补测试" | 补测试从来不会发生，现在写 |
| "这个改动我在脑子里测试过了" | 脑测无法检测未来的回归，先写测试 |
| "时间紧，测试后面再说" | 没有测试的代码是技术债，先写测试 |
| "这只是临时代码" | 临时代码变成永久代码的概率很高，先写测试 |
| "测试这个太难写了" | 测试难写说明设计有问题，先修改设计再写测试 |

## 执行步骤

### Step 1: 确认任务边界

从 `.superman/phases/execute/progress.md` 读取当前任务，明确：
- 要实现什么功能（输入 / 输出 / 行为）
- 测试文件路径
- 实现文件路径

### Step 2: 写失败测试

根据任务要求写最小化测试：
- 只测试当前任务的行为，不测试未实现的功能
- 测试名称描述期望行为（如 `test_returns_error_when_input_empty`）
- 运行测试，确认 **RED**（失败）

若测试意外通过 → 检查测试本身是否正确（可能测试逻辑有误）。

### Step 3: 写最小实现

写能让测试通过的最小代码：
- 不写超出测试覆盖范围的代码
- 不提前优化
- 运行测试，确认 **GREEN**（通过）

### Step 4: 重构（可选）

若实现有明显重复或难以理解的代码：
- 重构，保持测试通过
- 不添加新功能

### Step 5: 提交

```bash
git add {test_file} {impl_file}
git commit -m "feat: {具体描述本次实现的行为}"
```

### Step 6: 更新进度

将 `.superman/phases/execute/progress.md` 中当前任务标记为 `[x]`，继续下一个任务。

## 任务跟踪格式

`.superman/phases/execute/progress.md` 维护如下：

```markdown
## 执行进度

- [x] Task 1: 描述
- [ ] Task 2: 描述（进行中）
- [ ] Task 3: 描述
```
```

- [ ] **Step 2: 创建 skills/execute/debugging/SKILL.md**

```markdown
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
```

- [ ] **Step 3: 运行校验器**

```bash
node scripts/validate-skills.js
```

预期输出：`✅ All 8 skills validated successfully.`（6 个 DEFINE + 2 个 EXECUTE）

- [ ] **Step 4: Commit**

```bash
git add skills/execute/tdd/ skills/execute/debugging/
git commit -m "feat: add superman:tdd and superman:debugging skills (SP×AS merge)"
```

---

## Task 2: EXECUTE 阶段 Superpowers 保留技能（subagent-dev + worktrees）

**Files:**
- Create: `skills/execute/subagent-dev/SKILL.md`
- Create: `skills/execute/worktrees/SKILL.md`

- [ ] **Step 1: 创建 skills/execute/subagent-dev/SKILL.md**

```markdown
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
```

- [ ] **Step 2: 创建 skills/execute/worktrees/SKILL.md**

```markdown
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

```bash
# 在主仓库根目录执行
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
```

- [ ] **Step 3: 运行校验器**

```bash
node scripts/validate-skills.js
```

预期输出：`✅ All 10 skills validated successfully.`

- [ ] **Step 4: Commit**

```bash
git add skills/execute/subagent-dev/ skills/execute/worktrees/
git commit -m "feat: add superman:subagent-dev and superman:worktrees skills (SP preserved)"
```

---

## Task 3: EXECUTE 阶段 Agent Skills 保留技能（incremental-impl + security + api-design + frontend-ui）

**Files:**
- Create: `skills/execute/incremental-impl/SKILL.md`
- Create: `skills/execute/security/SKILL.md`
- Create: `skills/execute/api-design/SKILL.md`
- Create: `skills/execute/frontend-ui/SKILL.md`

- [ ] **Step 1: 创建 skills/execute/incremental-impl/SKILL.md**

```markdown
# superman:incremental-impl

**Goal**: 通过强制增量实现策略，防止大块不可追溯的代码变更，确保每次提交都是可理解、可回滚的最小单元。

**Trigger**: EXECUTE 阶段每个任务实现时自动遵守。作为 superman:tdd 和 superman:subagent-dev 的辅助纪律层。

---

## 核心规则

**每次提交不超过以下任一阈值：**
- 单个功能点（一个函数、一个接口、一个配置项）
- 时间跨度：不超过 30 分钟的工作量
- 代码行数：新增/修改不超过 100 行（纯机械代码除外）

超出阈值 → 拆分为更小的步骤。

## 实现顺序

**总是从内向外实现：**

1. 核心数据结构 / 类型定义
2. 纯函数 / 工具函数（无副作用）
3. 核心业务逻辑
4. 副作用层（I/O、网络、数据库）
5. 接口层（API、UI、CLI）
6. 集成测试

**禁止跳过顺序：** 不在没有内层实现的情况下写接口层。

## 增量提交规范

每个提交必须：
1. 能独立编译（不依赖尚未提交的代码）
2. 测试通过（使用 `superman:tdd` 门控）
3. 描述清楚（提交信息说明做了什么，为什么）

```bash
# 好的增量提交
git commit -m "feat: add User.validate() method with email format check"
git commit -m "feat: add POST /users endpoint using User.validate()"

# 错误的大块提交
git commit -m "feat: add complete user management system"
```

## 大任务拆解方法

若任务看起来太大，使用此拆解策略：

1. **列出所有需要的数据结构** → 每个数据结构是一个提交
2. **列出所有接口/函数签名** → 每个函数是一个提交（先写 stub）
3. **逐个实现函数** → 配合 TDD，每个函数通过测试后提交
4. **集成** → 连接各函数，提交集成代码

## 何时允许大提交

以下情况允许超出 100 行：
- 自动生成代码（如 schema 迁移、protobuf 生成）
- 纯格式化（`prettier`、`gofmt` 等）
- 复制现有模式的样板代码（需在提交信息中说明）
```

- [ ] **Step 2: 创建 skills/execute/security/SKILL.md**

```markdown
# superman:security

**Goal**: 在 EXECUTE 阶段对每个实现步骤进行安全检查，防止引入常见安全漏洞，确保代码在发布前满足基本安全要求。

**Trigger**: EXECUTE 阶段每次完成一个任务时，在提交前执行安全自检。L/M 级均执行。

---

## 安全自检清单

完成每个任务后，对以下项目执行检查：

### 1. 输入验证

- [ ] 所有用户输入（表单、URL 参数、API 请求体）在使用前已验证
- [ ] 文件路径操作使用白名单而非黑名单
- [ ] 数字类型检查（整数溢出、负数、NaN）
- [ ] 字符串长度限制（防止拒绝服务）

### 2. 注入防护

- [ ] SQL 查询使用参数化查询，不拼接字符串
- [ ] Shell 命令使用参数数组，不拼接字符串
- [ ] 模板渲染对用户数据进行转义
- [ ] XML/JSON 解析时防止实体注入

### 3. 认证与授权

- [ ] 每个 API 端点都有明确的权限检查
- [ ] 敏感操作有二次确认（如删除、付款）
- [ ] 会话 token 有过期时间
- [ ] 密码使用强哈希（bcrypt/argon2），不存明文

### 4. 数据保护

- [ ] 密钥和凭据不在代码中硬编码，使用环境变量
- [ ] 敏感数据不写入日志
- [ ] HTTPS 传输敏感数据
- [ ] 数据库中的敏感字段加密存储

### 5. 依赖安全

- [ ] 新增依赖来源可信（官方 npm / PyPI / Maven）
- [ ] 无已知高危漏洞的依赖版本

### 6. 错误处理

- [ ] 错误信息不暴露内部实现细节（stack trace、路径、版本）
- [ ] 预期错误返回用户友好信息，内部错误记录日志

## 发现安全问题时

1. **不跳过**：安全问题不允许用 TODO 标记留到后面
2. 评估严重级别：
   - **Critical**（注入、认证绕过）→ 立即修复，不提交存在此问题的代码
   - **High**（权限缺失、敏感数据泄露）→ 当前任务修复
   - **Medium/Low**（最佳实践缺失）→ 当前任务修复或创建跟踪 issue

## 与 superman:ci-gates 的关系

可自动化的安全检查（如 `npm audit`）应配置为 ci-gates 的 gate 项：

```json
{
  "id": "security-audit",
  "name": "npm audit for high+ vulnerabilities",
  "command": "npm audit --audit-level=high",
  "expected_exit_code": 0,
  "phase": "verify",
  "required_level": "L"
}
```
```

- [ ] **Step 3: 创建 skills/execute/api-design/SKILL.md**

```markdown
# superman:api-design

**Goal**: 在设计和实现 API 接口时，遵循一致性、可预测性和向后兼容性原则，避免常见 API 设计错误。

**Trigger**: EXECUTE 阶段涉及 API 设计（新建端点、修改接口、设计 SDK）时调用。

---

## REST API 设计原则

### 资源命名

```
✅ /users/{id}/orders          # 复数名词，层级关系清晰
✅ /orders?status=pending      # 过滤用查询参数
❌ /getUser                    # 动词命名
❌ /user_orders                # 下划线（REST 用连字符）
```

### HTTP 方法语义

| 方法 | 用途 | 幂等性 |
|------|------|--------|
| GET | 读取，不修改状态 | ✅ 幂等 |
| POST | 创建资源 | ❌ 非幂等 |
| PUT | 全量替换（需提供完整资源） | ✅ 幂等 |
| PATCH | 部分更新（只提供要改的字段） | ✅ 幂等 |
| DELETE | 删除 | ✅ 幂等 |

### 状态码

```
200 OK           — 成功读取 / 更新
201 Created      — 成功创建，含 Location header
204 No Content   — 成功删除（无响应体）
400 Bad Request  — 客户端输入错误（含错误详情）
401 Unauthorized — 未认证
403 Forbidden    — 已认证但无权限
404 Not Found    — 资源不存在
409 Conflict     — 状态冲突（如重复创建）
422 Unprocessable — 语法正确但业务逻辑失败
500 Internal     — 服务端错误（不暴露细节）
```

### 错误响应格式（统一）

```json
{
  "error": {
    "code": "VALIDATION_FAILED",
    "message": "Email format is invalid",
    "field": "email"
  }
}
```

## 向后兼容原则

**添加是安全的，删除/修改是危险的：**

- ✅ 添加新的可选字段
- ✅ 添加新的端点
- ✅ 添加新的枚举值（需客户端容错）
- ❌ 删除字段（改为 deprecated + 迁移文档）
- ❌ 修改字段类型
- ❌ 修改 URL 路径（改为重定向 + 保留旧路径）

## 版本管理

```
/v1/users    # URL 版本（推荐，显式）
             # 或 header: API-Version: 2024-01-01（日期版本）
```

## 接口文档

每个新接口必须在实现前写接口文档（OpenAPI / 注释），包含：
- 请求参数（类型、是否必填、示例）
- 响应格式（成功和错误）
- 认证要求
- 速率限制（若有）

## 与 superman:spec-review 的关系

API 接口定义写在 spec.md 中，`superman:spec-review` 会检查接口定义是否有歧义或矛盾。API 实现必须与 spec.md 中的定义完全一致。
```

- [ ] **Step 4: 创建 skills/execute/frontend-ui/SKILL.md**

```markdown
# superman:frontend-ui

**Goal**: 在前端 UI 开发中遵循工程纪律，确保组件可测试、可访问、性能可预期，避免常见前端陷阱。

**Trigger**: EXECUTE 阶段涉及前端组件实现、样式修改、交互逻辑时调用。

---

## 组件设计原则

### 单一职责

每个组件只做一件事：

```
✅ UserAvatar     — 显示头像
✅ UserCard       — 组合 Avatar + 用户名 + 状态
❌ UserDashboard  — 包含头像 + 设置 + 权限 + 通知（太多）
```

### Props 设计

```typescript
// ✅ 明确的 props interface
interface ButtonProps {
  label: string;
  variant: 'primary' | 'secondary' | 'danger';
  disabled?: boolean;
  onClick: () => void;
}

// ❌ 模糊的 props
interface ButtonProps {
  data: any;
  config: object;
}
```

### 状态管理

- **本地状态**（UI 交互、临时值）→ `useState` / 组件内 state
- **共享状态**（多组件需要）→ Context / Store
- **服务端数据**（API 响应）→ React Query / SWR（自动缓存和重验证）

禁止将服务端数据和 UI 状态混在同一个全局 store。

## 可访问性（Accessibility）

每个交互元素必须：

- [ ] `button` 有 `aria-label`（若无文本）
- [ ] 图片有 `alt` 属性（装饰图用 `alt=""`）
- [ ] 表单 `input` 关联 `label`（`htmlFor` / `aria-labelledby`）
- [ ] 键盘可导航（Tab 顺序逻辑，Enter/Space 触发按钮）
- [ ] 颜色对比度 ≥ 4.5:1（WCAG AA）

## 性能规则

- 不在 render 中计算重型数据 → 使用 `useMemo` 或预计算
- 列表使用虚拟化 → 超过 50 项使用 `react-window` 或类似库
- 图片懒加载 → `loading="lazy"` 或 Intersection Observer
- 避免不必要的 re-render → 合理使用 `React.memo`，父组件拆分

## 测试策略

```typescript
// ✅ 测试行为，不测试实现细节
test('shows error message when email is invalid', async () => {
  render(<LoginForm />);
  await userEvent.type(screen.getByLabelText('Email'), 'not-an-email');
  await userEvent.click(screen.getByRole('button', { name: 'Submit' }));
  expect(screen.getByText('Email format is invalid')).toBeInTheDocument();
});

// ❌ 测试内部状态
test('sets hasError to true', () => {
  const { result } = renderHook(() => useLoginForm());
  act(() => result.current.setEmail('not-an-email'));
  expect(result.current.hasError).toBe(true);
});
```

## 使用 Chrome DevTools MCP 验证

前端实现完成后，用 Chrome DevTools MCP 验证：

```
1. navigate_page → 加载目标页面
2. take_snapshot → 确认 DOM 结构正确
3. list_console_messages → 确认无 JS 错误
4. take_screenshot → 视觉确认布局
5. evaluate_script → 验证关键 DOM 属性（aria, data-testid）
```

## 与 superman:verification 的关系

`superman:verification` 负责在真实浏览器中观察实际行为，本技能负责实现时的工程纪律。两者互补。
```

- [ ] **Step 5: 运行校验器**

```bash
node scripts/validate-skills.js
```

预期输出：`✅ All 14 skills validated successfully.`

- [ ] **Step 6: Commit**

```bash
git add skills/execute/incremental-impl/ skills/execute/security/ skills/execute/api-design/ skills/execute/frontend-ui/
git commit -m "feat: add 4 AS-preserved EXECUTE skills (incremental-impl, security, api-design, frontend-ui)"
```

---

## Task 4: VERIFY 阶段合并技能（code-review + git-ship）

**Files:**
- Create: `skills/verify/code-review/SKILL.md`
- Create: `skills/verify/git-ship/SKILL.md`

- [ ] **Step 1: 创建 skills/verify/code-review/SKILL.md**

```markdown
# superman:code-review

**Goal**: 通过双向 code review 协议（请求方 + 接收方）配合结构化检查清单，确保代码在合并前达到正确性、安全性和可维护性标准。

**Trigger**: EXECUTE 阶段每个任务完成后（在 subagent-dev 的两级审查中）以及 VERIFY 阶段开始时触发。

---

## 双向协议（Superpowers 贡献）

### 请求方（实现者）职责

提交 review 时必须提供：

1. **变更摘要**：这个 PR/commit 做了什么（1-3 句话）
2. **测试情况**：已运行哪些测试，结果如何
3. **关注点**：希望 reviewer 重点看哪里
4. **不在范围内**：明确说明此次不解决什么

```markdown
## Code Review Request

**变更**：为 User 模型添加邮件验证逻辑，含正则和 MX 记录检查
**测试**：unit tests 5/5 通过；集成测试覆盖正常路径和三种错误路径
**关注点**：MX 记录查询的超时处理，不确定 5 秒是否合适
**范围外**：手机号验证将在下一个 PR 中处理
```

### 接收方（审查者）职责

按以下清单检查，每项明确标注 ✅/❌/⚠️：

#### 正确性

- [ ] 逻辑是否实现了规格要求（对照 spec.md 逐条验证）
- [ ] 边界条件处理是否完整（空值、零值、最大值、并发）
- [ ] 错误路径是否有测试覆盖
- [ ] 异步代码的错误处理（未处理的 Promise rejection）

#### 安全（基础检查）

- [ ] 用户输入是否经过验证（参考 `superman:security`）
- [ ] 无硬编码密钥或凭据
- [ ] SQL/Shell/模板注入风险

#### 可维护性

- [ ] 函数命名是否描述行为
- [ ] 单个函数不超过 50 行（超过考虑拆分）
- [ ] 重复代码（DRY 原则，超过 3 次重复应提取）
- [ ] 注释是否解释"为什么"（不是"是什么"）

#### 性能（仅当相关）

- [ ] 是否在循环中做了不必要的 I/O / 计算
- [ ] 大数据集是否有分页或流式处理

## 反馈分级

| 级别 | 含义 | 是否阻塞合并 |
|------|------|------------|
| **Critical** | 正确性/安全问题，必须修复 | ✅ 阻塞 |
| **Important** | 显著影响可维护性，强烈建议修复 | ✅ 阻塞 |
| **Minor** | 代码风格/偏好，可选修复 | ❌ 不阻塞 |
| **Note** | 观察和建议，供参考 | ❌ 不阻塞 |

## 反馈格式

```
[Critical] UserService.validate(): 正则表达式未转义点号，
  `user@company.com` 会匹配 `user@companyXcom`
  建议：将 `.` 改为 `\.`，并添加测试用例验证

[Minor] 变量名 `d` → 建议改为 `userData`，更具可读性
```

## Review 结束条件

- 所有 Critical 和 Important 问题已修复
- 修复已重新提交，reviewer 已验证
- Reviewer 明确宣告 ✅ APPROVED

## 与 superman:subagent-dev 的关系

`superman:subagent-dev` 在每个任务后自动派发 code reviewer subagent，使用本技能的清单进行审查。最终合并前还有一次全局 code review。
```

- [ ] **Step 2: 创建 skills/verify/git-ship/SKILL.md**

```markdown
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
```

- [ ] **Step 3: 运行校验器**

```bash
node scripts/validate-skills.js
```

预期输出：`✅ All 16 skills validated successfully.`

- [ ] **Step 4: Commit**

```bash
git add skills/verify/code-review/ skills/verify/git-ship/
git commit -m "feat: add superman:code-review and superman:git-ship skills (SP×AS merge)"
```

---

## Task 5: VERIFY 阶段其余 4 个技能（production-ready + spec-satisfied + verification + ci-gates）

**Files:**
- Create: `skills/verify/production-ready/SKILL.md`
- Create: `skills/verify/spec-satisfied/SKILL.md`
- Create: `skills/verify/verification/SKILL.md`
- Create: `skills/verify/ci-gates/SKILL.md`

- [ ] **Step 1: 创建 skills/verify/production-ready/SKILL.md**

```markdown
# superman:production-ready

**Goal**: 在进入发布流程前，通过生产就绪门控检查，确保代码在生产环境中的行为可预期、可监控、可恢复。

**Trigger**: VERIFY 阶段，L 级需求必须通过，M Lite 跳过，S 级跳过。

---

## 生产就绪检查清单

### 1. 可观测性

- [ ] 关键操作有结构化日志（不是 `console.log`）
  - 格式：`{ timestamp, level, service, operation, duration_ms, result }`
- [ ] 错误有完整 stack trace（服务端），用户友好信息（客户端）
- [ ] 关键业务指标有埋点（注册量、支付成功率、API 延迟）
- [ ] 健康检查端点 `/health` 返回应用状态

### 2. 错误处理与恢复

- [ ] 所有 I/O 操作有超时设置（数据库查询、外部 API、文件操作）
- [ ] 网络请求有重试逻辑（指数退避，最多 3 次）
- [ ] 数据库操作有事务保护（避免部分提交）
- [ ] 无 unhandled Promise rejection / uncaught exception

### 3. 配置与密钥

- [ ] 所有环境配置通过环境变量注入
- [ ] 无硬编码的生产密钥、IP 地址、端口号
- [ ] 存在 `.env.example` 文件列出所有必需的环境变量
- [ ] 密钥不在 git 历史中出现（使用 `git log -S "secret"` 验证）

### 4. 数据库

- [ ] 所有 schema 变更有可逆 migration（`up` 和 `down`）
- [ ] 新索引已添加（在查询计划中验证）
- [ ] 大表操作使用批处理而非一次性全表扫描

### 5. 依赖

- [ ] 所有依赖版本锁定（`package-lock.json` / `poetry.lock` 提交）
- [ ] 无 `latest`、`*` 等不确定版本
- [ ] `npm audit` / `safety check` 通过（无高危漏洞）

### 6. 部署

- [ ] 代码在 staging 环境完整运行过
- [ ] 有回滚方案（旧版本容器 / feature flag 关闭）
- [ ] 部署完成后有验证步骤（smoke test）

## 不通过时的处理

发现未通过项：
1. 不允许跳过进入下一步
2. 修复该项
3. 重新检查整个清单（修复可能影响其他项）

## 与 superman:ci-gates 的关系

生产就绪检查中可自动化的项（如 `npm audit`、健康检查）应配置为 `superman:ci-gates` 的 gate 项，实现自动化强制。
```

- [ ] **Step 2: 创建 skills/verify/spec-satisfied/SKILL.md**

```markdown
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

```markdown
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
```

- [ ] **Step 3: 创建 skills/verify/verification/SKILL.md**

```markdown
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

```bash
# 确保使用开发/staging 环境，不用生产环境
npm run dev   # 或 python manage.py runserver，或 go run main.go
```

确认应用启动成功（无启动错误）。

### Step 2: 黄金路径验证

按照 spec.md 中的成功路径，逐步操作：

1. 打开应用（本地 URL）
2. 按照用户故事描述的步骤操作
3. 确认每个步骤产生预期的 UI / 响应 / 数据变化

使用 Chrome DevTools MCP（Web 应用）：

```
navigate_page → 打开应用
take_snapshot → 确认初始状态
[执行操作：fill, click 等]
take_snapshot → 确认操作后状态
take_screenshot → 保留视觉证据
```

### Step 3: 边界条件验证

对以下场景进行手动验证：
- 空输入 / 无效输入 → 确认错误提示符合预期
- 已存在数据（重复创建）→ 确认冲突处理
- 权限边界 → 确认无权操作被正确拒绝

### Step 4: 确认无回归

快速操作之前正常工作的功能，确认无意外破坏。

### Step 5: 生成验证报告

将观察结果记录到 `.superman/phases/verify/review.md`：

```markdown
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
```

- [ ] **Step 4: 创建 skills/verify/ci-gates/SKILL.md**

```markdown
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

```markdown
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
```

- [ ] **Step 5: 运行最终校验**

```bash
node scripts/validate-skills.js
```

预期输出：`✅ All 20 skills validated successfully.`

- [ ] **Step 6: Commit**

```bash
git add skills/verify/production-ready/ skills/verify/spec-satisfied/ skills/verify/verification/ skills/verify/ci-gates/
git commit -m "feat: add 4 VERIFY skills (production-ready, spec-satisfied, verification, ci-gates)"
```

---

## 自检

- [x] **Spec 覆盖**：20 个技能全部覆盖（DEFINE 6 + EXECUTE 8 + VERIFY 6）
- [x] **占位符扫描**：无 TBD/TODO，所有技能内容完整
- [x] **Goal/Trigger 一致性**：所有技能文件均含 `**Goal**` 和 `**Trigger**` 字段
- [x] **技能引用一致性**：所有 `superman:{name}` 引用均指向实际存在或 Plan B 将创建的技能
- [x] **文件路径一致性**：所有 `.superman/` 路径与设计规格第 6.1 节一致
- [x] **validate-skills.js 兼容**：所有文件以 `# ` 开头，含 `**Goal**`，含 `**Trigger**`
