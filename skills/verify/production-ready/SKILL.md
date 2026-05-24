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
