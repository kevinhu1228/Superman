# Superman Plugin — 设计规格文档

**日期**：2026-05-24  
**状态**：已批准  
**版本**：v1.0

---

## 1. 背景与目标

### 1.1 问题陈述

现有三个优秀工具各司其职，但单独使用时存在短板：

| 工具 | 优势 | 短板 |
|------|------|------|
| [OpenSpec](https://github.com/Fission-AI/OpenSpec) | 规格优先、CLI 可验证、工件化管理 | 无执行层纪律，不含技能调用框架 |
| [Superpowers](https://github.com/obra/superpowers) | 11 个链式 skill、上下文触发、多平台插件体系 | 无需求结构化层，无 CI 强制门控 |
| [Agent Skills](https://github.com/addyosmani/agent-skills) | 27 个生产级工程纪律、反合理化防线 | 无调用框架，仅靠 AI 自觉，缺乏 CI 双保险 |

### 1.2 设计目标

将三者融合为 **Superman** 插件，实现：

1. **层次分明，各司其职**：需求层（OpenSpec）→ 流程层（Superpowers）→ 纪律层（Agent Skills）
2. **顺序执行，不可跳跃**：三层按序推进，AI + CI 双保险强制
3. **工具互补，避免冲突**：OpenSpec tasks.md 是 writing-plans 的输入；subagent-dev 执行 Agent Skills 纪律约束；production-ready 验证 spec 是否满足
4. **按需分级**：根据需求大小智能跳过非必要步骤
5. **会话压缩保护**：原始需求 100% 落盘，不依赖会话记忆
6. **原始功能保全**：三源仓库功能与逻辑完整保留

---

## 2. 整体架构

### 2.1 架构模式

**统一内核 + 生命周期路由（Unified Core + Lifecycle Router）**

单一 npm 包，Superman Core 负责需求分级与路由，按 `DEFINE → EXECUTE → VERIFY` 三阶段调度技能，底层对接 6 个平台适配器。

```
┌─────────────────────────────────────────────────────┐
│            三源仓库（输入）                           │
│  OpenSpec（需求工件）  Superpowers（执行框架）  AS（纪律）│
└──────────────────┬──────────────────────────────────┘
                   │ 融合
┌──────────────────▼──────────────────────────────────┐
│              Superman Core                           │
│  ┌─────────────────┐  ┌──────────────────────────┐  │
│  │  需求分级引擎    │  │  生命周期路由器           │  │
│  │  三维度评分      │  │  DEFINE→EXECUTE→VERIFY   │  │
│  │  max(A,B,C)→S/M/L│  │  阶段门控 + 上下文传递  │  │
│  └─────────────────┘  └──────────────────────────┘  │
│  ┌─────────────────┐  ┌──────────────────────────┐  │
│  │  上下文持久化    │  │  技能编排                │  │
│  │  实时落盘        │  │  20 个统一技能            │  │
│  └─────────────────┘  └──────────────────────────┘  │
└────────────┬────────────────────┬───────────────────┘
             │                    │
    ┌────────▼────────┐  ┌────────▼────────┐
    │   三阶段技能     │  │   平台适配器层   │
    │ DEFINE(6)       │  │ Claude/Cursor/  │
    │ EXECUTE(8)      │  │ Gemini/Codex/   │
    │ VERIFY(6)       │  │ Copilot/OpenCode│
    └─────────────────┘  └────────────────┘
```

### 2.2 设计原则

- **单包**：一个 npm 包包含所有内容，`superman init` 写入项目配置
- **文件为唯一真相源**：所有状态写文件，AI 每次从文件读，不依赖会话记忆
- **门控不可绕过**：L 级需求阶段间有 CI 硬门控；AI 不得自行降级需求等级
- **原始功能不丢失**：三源 skill 内容合并取优，不裁剪原有逻辑

---

## 3. 需求分级与路由逻辑

### 3.1 三维度评分

每个维度独立打 1-3 分，用 `max(A, B, C)` 取最高分：

| 分数 | 维度 A：改动范围 | 维度 B：时间估算 | 维度 C：影响面 |
|------|----------------|----------------|---------------|
| 1 | 单文件/单函数 | < 30 分钟 | 仅私有代码 |
| 2 | 跨模块/多文件 | 30 分钟 – 2 小时 | 涉及 API/对外接口 |
| 3 | 新系统/架构重构 | > 2 小时 | 多团队/生产环境影响 |

**规则**：`综合得分 = max(A, B, C)`，任一维度达到阈值即整体升级。

### 3.2 分级路由表

| 等级 | 条件 | DEFINE | EXECUTE | VERIFY |
|------|------|--------|---------|--------|
| **S 小** | max ≤ 1 | ❌ 跳过 | ✅ 完整执行 | ❌ 跳过（inline review） |
| **M 中** | max = 2 | ⚡ Lite 模式 | ✅ 完整执行 | ⚡ Lite 模式 |
| **L 大** | max = 3 | ✅ 强制完整 | ✅ 强制完整 | ✅ 强制完整 |

**M 级 Lite 模式说明**：
- DEFINE Lite：一句话目标 + 任务清单，无需完整规格文档
- VERIFY Lite：仅 code-review，跳过 production-ready 和 spec-satisfied 检查

### 3.3 降级规则

- **AI 不得自行降级**：分级结果写入 `size-classification.md` 后锁定
- **用户可手动降级**：需在 `requirements.md` 中记录降级原因和风险承认
- **升级优先**：任一维度达 3 分，整体强制 L 级，不做平均

---

## 4. 三阶段技能体系

### 4.1 DEFINE 阶段（6 个技能）

对应**需求层**，来源：OpenSpec + Superpowers brainstorming + Agent Skills idea-refine

| 技能名 | 来源 | 职责 |
|--------|------|------|
| `superman:size-classify` | 新增 | 三维评分，输出分级结果到 `size-classification.md` |
| `superman:brainstorming` | SP ✕ AS 合并 | 需求澄清；SP 框架 + AS 的 5 问深挖 + interview-me 模式 |
| `superman:propose` | OpenSpec 重实现 | 创建 `.superman/phases/define/` 目录，生成提案文件 |
| `superman:spec-review` | OpenSpec 重实现 | 规格自检（TBD 扫描、一致性、歧义检查） |
| `superman:writing-plans` | Superpowers 保留 | 生成 `tasks.md` + `plan.md`，为 EXECUTE 提供输入 |
| `superman:archive` | OpenSpec 重实现 | 将完成的变更移入 `.superman/archive/`，更新规格 |

**阶段产物**：`.superman/phases/define/spec.md`、`tasks.md`（M/L 级）

### 4.2 EXECUTE 阶段（8 个技能）

对应**流程层**，来源：Superpowers + Agent Skills build 类

| 技能名 | 来源 | 职责 |
|--------|------|------|
| `superman:tdd` | SP ✕ AS 合并 | SP 严格门控（先测试后实现）+ AS 反合理化防线 |
| `superman:subagent-dev` | Superpowers 保留 | 并行 subagent 分发，每个 task 独立执行 |
| `superman:incremental-impl` | Agent Skills 保留 | 增量实现策略，防止大块变更 |
| `superman:security` | Agent Skills 保留 | 安全加固检查清单 |
| `superman:api-design` | Agent Skills 保留 | API 接口设计原则 |
| `superman:frontend-ui` | Agent Skills 保留 | 前端 UI 工程纪律 |
| `superman:debugging` | SP ✕ AS 合并 | SP 5 步调试流程 + AS 错误恢复模式 + browser devtools 集成 |
| `superman:worktrees` | Superpowers 保留 | git worktree 隔离工作空间 |

**阶段产物**：`.superman/phases/execute/progress.md`（实时更新）

### 4.3 VERIFY 阶段（6 个技能）

对应**纪律层**，来源：Agent Skills 门控 + Superpowers code-review

| 技能名 | 来源 | 职责 |
|--------|------|------|
| `superman:code-review` | SP ✕ AS 合并 | SP 双向审查协议 + AS 结构化 checklist（正确性/安全/性能） |
| `superman:production-ready` | Agent Skills 保留 | 生产就绪门控检查（L 级必须，M Lite 跳过） |
| `superman:spec-satisfied` | 新增 | 验证代码变更是否满足 DEFINE 阶段的 spec 要求 |
| `superman:verification` | Superpowers 保留 | 变更有效性验证（运行应用观察实际行为） |
| `superman:git-ship` | SP ✕ AS 合并 | SP 分支决策 + AS 发布前核查清单 |
| `superman:ci-gates` | 新增 | L 级需求的 CI 强制门控，读取 `gates.json` 执行检查 |

**阶段产物**：`.superman/phases/verify/review.md`、`spec-check.md`

---

## 5. 技能合并策略

5 对重叠技能的合并原则：**SP 提供调用框架和执行纪律，AS 提供内容深度和反合理化防线**。

| 合并技能 | SP 贡献 | AS 贡献 | 合并结果 |
|---------|---------|---------|---------|
| `tdd` | 先写测试的硬性门控 + task 跟踪 | 反合理化表格（"这太简单"等借口的反驳） | SP 门控为主干 + AS 防线嵌入 |
| `debugging` | 系统化 5 步流程 + hypothesis tracking | 错误恢复模式 + browser devtools 指引 | SP 流程为主干，AS 补充工具层 |
| `code-review` | requesting + receiving 双向流程 | 结构化 checklist（正确性/安全/性能） | SP 双向协议 + AS checklist |
| `brainstorming` | brainstorm→spec→writing-plans 完整链路 | idea-refine 5 问 + interview-me 访谈模式 | SP 为框架，AS 模式作为 DEFINE 增强 |
| `git-ship` | finishing-a-development-branch 分支决策 | git-workflow + shipping-and-launch 发布清单 | SP 决策 + AS 发布前核查 |

**OpenSpec 的 3 个核心功能**（propose/spec-review/archive）重新实现为 Superman skill，不依赖外部 OpenSpec CLI，内嵌核心逻辑。

---

## 6. 会话压缩保护与上下文持久化

### 6.1 文件结构

```
.superman/                    # 项目级上下文（spec 文件提交，私有文件加 .gitignore）
├── context/
│   ├── requirements.md       # 原始需求对话逐条追加（用户原话，实时写入）
│   ├── decisions.md          # 每次方案选择记录（含时间戳）
│   └── size-classification.md # 分级结果（写入后锁定）
├── phases/
│   ├── define/
│   │   ├── spec.md           # 规格文档（M/L 级）
│   │   └── tasks.md          # 任务清单（EXECUTE 输入）
│   ├── execute/
│   │   ├── plan.md           # 实施计划
│   │   └── progress.md       # 任务完成状态（实时更新）
│   └── verify/
│       ├── review.md         # 代码审查结果
│       └── spec-check.md     # 规格满足度验证报告
└── ci/
    └── gates.json            # L 级 CI 检查项列表
```

### 6.2 四个实时写入节点

1. **需求捕获**：用户发出需求后，立即将原文追加到 `requirements.md`，不等 AI 理解确认
2. **决策记录**：每次 A/B/C 选择立刻写入 `decisions.md`（含时间戳和选择内容）
3. **阶段产物落盘**：每阶段完成后产物必须写入文件，才能进入下一阶段
4. **会话恢复**：新会话或压缩后，Superman 读取全部 `.superman/` 文件重建上下文，向用户宣告恢复状态

### 6.3 会话恢复协议

```
Step 1: 检测 .superman/context/ 是否存在
Step 2: 顺序读取 requirements.md → decisions.md → size-classification.md → 当前阶段产物
Step 3: 向用户宣告："已从文件恢复上下文，当前处于 X 阶段，任务 N/M 进行中"
Step 4: 继续执行
```

### 6.4 保障承诺

- 原始需求对话：用户原话逐条追加，不做 AI 重新解释
- 需求演化可追溯：每次变更有时间戳，可 diff 查看演化路径
- 阶段门控持久：产物未落盘前，下一阶段不开始
- 分级结果锁定：`size-classification.md` 写入后不可静默修改

---

## 7. 平台适配器

### 7.1 支持平台

| 平台 | 配置文件 | 触发机制 |
|------|---------|---------|
| Claude Code | `.claude-plugin/plugin.json`、`CLAUDE.md`、`hooks/hooks.json` | `/superman:*` 斜线命令 + hooks 自动触发 |
| Cursor | `.cursor-plugin/plugin.json`、`.cursorrules`、`hooks/hooks-cursor.json` | `@superman` 命令 + 文件保存触发 |
| Gemini CLI | `GEMINI.md`、`gemini-extension.json`、`hooks/hooks-gemini.json` | `/superman:*` + `activate_skill` |
| Codex | `.codex-plugin/plugin.json`、`AGENTS.md`、`hooks/hooks-codex.json` | `skill` 工具调用 |
| GitHub Copilot | `.github/copilot-instructions.md`、`copilot-setup.md` | `/superman` Chat 命令 |
| OpenCode | `.opencode/plugins/superman.js`、`.opencode/config.json` | JavaScript 插件 API |

### 7.2 适配器统一抽象

所有平台共享同一套 `skills/` 目录，适配器层只负责：
- **指令注入**：将 Superman 行为规则注入平台上下文（CLAUDE.md/GEMINI.md/AGENTS.md 等）
- **触发映射**：将平台特定命令映射到 `superman:*` 技能调用
- **钩子配置**：定义自动触发时机（会话开始、文件保存、特定命令等）

---

## 8. 仓库目录结构

```
superman/
├── skills/                          # 核心技能（20 个）
│   ├── define/                      # DEFINE 阶段（6 个）
│   │   ├── size-classify/
│   │   ├── brainstorming/
│   │   ├── propose/
│   │   ├── spec-review/
│   │   ├── writing-plans/
│   │   └── archive/
│   ├── execute/                     # EXECUTE 阶段（8 个）
│   │   ├── tdd/
│   │   ├── subagent-dev/
│   │   ├── incremental-impl/
│   │   ├── security/
│   │   ├── api-design/
│   │   ├── frontend-ui/
│   │   ├── debugging/
│   │   └── worktrees/
│   └── verify/                      # VERIFY 阶段（6 个）
│       ├── code-review/
│       ├── production-ready/
│       ├── spec-satisfied/
│       ├── verification/
│       ├── git-ship/
│       └── ci-gates/
├── platforms/                       # 平台适配器
│   ├── claude/
│   ├── cursor/
│   ├── gemini/
│   ├── codex/
│   ├── copilot/
│   └── opencode/
├── hooks/                           # 触发规则
│   ├── hooks.json                   # Claude Code
│   ├── hooks-cursor.json
│   ├── hooks-gemini.json
│   └── hooks-codex.json
├── ci/                              # CI 门控
│   ├── .github/workflows/
│   ├── pre-commit-config.yaml
│   └── gates-schema.json
├── scripts/
│   ├── install.sh                   # 初始化脚本
│   ├── sync-platforms.sh            # 同步平台配置
│   └── validate-skills.js           # CI 技能结构验证
├── docs/
│   └── superpowers/specs/           # 设计规格文档
├── package.json
├── CLAUDE.md
├── GEMINI.md
├── AGENTS.md
└── README.md
```

---

## 9. 发布策略

### 9.1 三渠道并行

| 渠道 | 适用对象 | 安装方式 |
|------|---------|---------|
| **npm** | CLI 工具用户 + 自动化流程 | `npm install -g superman-plugin && superman init` |
| **GitHub Release** | 手动配置用户 + 源码参考 | ZIP 下载 + 手动配置，GitHub Actions 自动验证 |
| **Plugin Marketplace** | Claude Code 用户 | 走 Superpowers `.claude-plugin/` 发布流程，一键安装 |

### 9.2 版本管理

- 语义化版本（semver）
- `scripts/sync-platforms.sh` 统一同步所有平台配置
- GitHub Actions 自动运行 `validate-skills.js` 验证技能结构完整性

---

## 10. 执行确认规则

- **混合模式**：设计阶段逐步确认，方案批准后自动执行
- **必须等待用户回答**：方案选择（A/B/C/D）、手动降级需求等级、发布操作
- **自动执行**：技能文件编写、hooks 配置、平台适配器生成、目录创建

---

## 附录：可视化设计图

| 图表 | 路径 |
|------|------|
| 三种融合方案对比 | `docs/diagrams/01-approaches.png` |
| 整体架构图 | `docs/diagrams/02-architecture.png` |
| 需求分级与路由逻辑 | `docs/diagrams/03-sizing-routing.png` |
| 技能合并策略 | `docs/diagrams/04-skills-merge.png` |
| 会话压缩保护 | `docs/diagrams/05-context-persistence.png` |
| 平台适配器与发布策略 | `docs/diagrams/06-platform-dist.png` |
