# 🦸 Superman Plugin

> **OpenSpec + Superpowers + Agent Skills 三位一體的 AI 開發工作流插件**
>
> 需求層 · 流程層 · 紀律層 — 讓 AI 開發從混亂走向工程化

[![npm version](https://img.shields.io/npm/v/superman-plugin.svg)](https://www.npmjs.com/package/superman-plugin)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Node.js](https://img.shields.io/badge/node-%3E%3D18-brightgreen.svg)](https://nodejs.org/)
[![Platforms](https://img.shields.io/badge/platforms-Claude%20%7C%20Cursor%20%7C%20Gemini%20%7C%20Codex%20%7C%20Copilot%20%7C%20OpenCode-blue.svg)](#平台支援)

**README：** [English](README.md) | [简体中文](README-zh_CN.md) | [繁體中文](README-zh_TW.md)

---

## 目錄

- [簡介](#簡介)
- [核心特性](#核心特性)
- [快速開始](#快速開始)
- [安裝方式](#安裝方式)
- [工作流程詳解](#工作流程詳解)
- [技能庫（21 個技能）](#技能庫)
- [平台支援](#平台支援)
- [CI 閘門](#ci-閘門)
- [上下文持久化](#上下文持久化)
- [CLI 命令參考](#cli-命令參考)
- [專案結構](#專案結構)
- [開發與貢獻](#開發與貢獻)

---

## 簡介

Superman Plugin 是一個統一的 AI 程式設計助手工作流程插件，將三套成熟方法論融合為一體：

| 來源 | 職責 | 核心貢獻 |
|------|------|----------|
| **OpenSpec** | 需求層 | 結構化需求管理、規格驗證 |
| **Superpowers** | 流程層 | 分級路由、階段閘門、子智能體編排 |
| **Agent Skills** | 紀律層 | TDD 強制執行、安全檢查、除錯協議 |

**三個階段，貫穿始終：**

```
使用者需求 → [size-classify] → S / M / L
                                 │
              S: ──────────── EXECUTE ────────────────────────────→ 完成
              M: ── DEFINE Lite ── EXECUTE ── VERIFY Lite ──────→ 完成
              L: ── DEFINE Full ── EXECUTE ── VERIFY Full ──────→ 完成
                                              (CI 閘門強制)
```

---

## 核心特性

- **🎯 智慧需求分級** — 從 3 個維度（範圍、時間、影響）評分，自動路由至 S/M/L 流程
- **📁 檔案驅動持久化** — 所有狀態寫入 `.superman/` 目錄，會話壓縮或重啟後完整恢復
- **🔒 L 級不可跳過** — CI 閘門在程式碼層面強制執行階段規範，不依賴 AI 自覺
- **🛠️ 21 個統一技能** — DEFINE / EXECUTE / VERIFY 三階段覆蓋，跨 6 個平台複用
- **🌐 多平台適配** — 同一套技能庫，一鍵同步到 Claude Code、Cursor、Gemini CLI 等
- **✅ TDD 硬閘門** — 內建反藉口表，強制先寫測試再實作
- **🔍 規格驗證腳本** — 自動掃描 TBD 佔位符、缺失章節、未通過審查標記

---

## 快速開始

```bash
# 1. 安裝
npm install -g superman-plugin

# 2. 在你的專案中初始化
cd your-project
superman init

# 3. 開始第一個任務 — 分級
# 在 AI 中執行：
/superman:size-classify
```

AI 會評估需求並宣告級別（S/M/L），然後自動進入對應工作流程。

---

## 安裝方式

### npm 安裝（推薦）

```bash
npm install -g superman-plugin
superman init
```

### 手動安裝

```bash
git clone https://github.com/kevinhu1228/superman.git
cd your-project
bash /path/to/superman/scripts/install.sh .
```

### install.sh 做了什麼

1. 建立 `.superman/` 目錄結構（context、phases、archive、ci 子目錄）
2. 執行 `scripts/sync-platforms.sh` — 偵測目前專案安裝了哪些 AI 平台，逐一寫入設定：
   - Claude Code → `CLAUDE.md` + hooks
   - Cursor → `.cursorrules` + hooks
   - Gemini CLI → `GEMINI.md` + `gemini-extension.json` + hooks
   - Codex → `AGENTS.md` + hooks
   - GitHub Copilot → `.github/copilot-instructions.md`
   - OpenCode → `.opencode/plugins/superman.js`
3. 安裝 CI 閘門範本 `.superman/ci/gates.json`
4. 提示將 `.superman/context/`、`.superman/phases/`、`.superman/archive/` 加入 `.gitignore`

---

## 工作流程詳解

### 第一步：需求分級

執行 `superman:size-classify`，AI 從三個維度評分：

| 維度 | S（小）| M（中）| L（大）|
|------|--------|--------|--------|
| 變更範圍 | 1 個檔案/函式 | 2–5 個檔案/模組 | 跨模組/架構 |
| 時間估算 | < 1 小時 | 1–8 小時 | > 1 天 |
| 影響面 | 局部 | 有限擴散 | 全域/核心路徑 |

### 第二步：階段路由

| 級別 | DEFINE | EXECUTE | VERIFY |
|------|--------|---------|--------|
| **S** | ❌ 跳過 | ✅ 完整執行 | ❌ 僅內聯 review |
| **M** | ⚡ Lite（目標 + 任務清單） | ✅ 完整執行 | ⚡ Lite（code-review，跳過生產就緒檢查）|
| **L** | ✅ 完整（規格文件 + 計畫）| ✅ 完整執行 | ✅ 完整（CI 閘門強制）|

### 關鍵規則

- **不允許靜默降級** — AI 不能自行將 L 降為 M/S；使用者必須明確說明原因並寫入 `decisions.md`
- **EXECUTE 前規格必須通過** — L/M 級需執行 `node scripts/validate-spec.js --strict`，通過後才能開始撰寫程式碼
- **TDD 不可繞過** — `superman:tdd` 內建反藉口表，任何「先實作再補測試」的理由均被預先駁回
- **增量提交 ≤ 100 行** — `superman:incremental-impl` 強制拆分大型 diff，實作順序：資料結構 → 函式 → 邏輯 → I/O → 介面

---

## 技能庫

共 **21 個技能**，按階段組織。

### DEFINE 階段（6 個技能）

| 技能 | 用途 |
|------|------|
| `superman:size-classify` | 三維度評分，輸出 S/M/L 分級並寫入 `.superman/context/size-classification.md` |
| `superman:brainstorming` | 5 問題結構化需求澄清（目標、成功標準、約束、邊界、風險） |
| `superman:propose` | 產生變更提案（`proposal.md`）及規格/任務草稿 |
| `superman:spec-review` | 掃描 TBD/TODO、一致性檢查、歧義標記，通過後寫入 "Spec Review: PASSED" |
| `superman:writing-plans` | 產生詳細實施計畫（`tasks.md`），包含具體程式碼片段和測試命令 |
| `superman:archive` | 將完成的變更歸檔至 `.superman/archive/YYYY-MM-DD-{name}/`，清理工作目錄 |

### EXECUTE 階段（8 個技能）

| 技能 | 用途 |
|------|------|
| `superman:tdd` | 紅-綠-重構迴圈強制執行；內建反藉口表阻斷一切跳過測試的理由 |
| `superman:subagent-dev` | 將任務分發給獨立子智能體；兩階段審查（規格符合性 + 程式碼品質） |
| `superman:incremental-impl` | ≤100 行提交限制；由內而外實作順序（資料結構 → 函式 → 邏輯 → I/O → 介面） |
| `superman:security` | 安全檢查清單（輸入驗證、注入防護、認證鑑權、資料保護、依賴、錯誤處理） |
| `superman:api-design` | REST 規範（資源命名、HTTP 語義、狀態碼、統一錯誤格式） |
| `superman:frontend-ui` | 元件規範（單一職責、型別化 Props、狀態管理、無障礙性、效能最佳化） |
| `superman:debugging` | 5 步除錯流程（重現 → 隔離 → 假設 → 驗證 → 修復）+ 假設追蹤表 |
| `superman:worktrees` | 在 `git worktree .worktrees/{feature-name}` 中隔離變更，支援並行開發 |

### VERIFY 階段（7 個技能）

| 技能 | 用途 |
|------|------|
| `superman:code-review` | 雙向協議（請求方提供上下文 + 聚焦點；審查方使用規格/安全/可維護性檢查清單） |
| `superman:production-ready` | L 級生產就緒閘門（可觀測性、錯誤處理、設定/密鑰、資料庫遷移、依賴、部署就緒） |
| `superman:spec-satisfied` | 逐條驗證 `spec.md` 需求已有對應程式碼/測試；產生合規報告 |
| `superman:verification` | 在 dev/staging 環境執行應用程式，手動驗證主幹路徑 + 邊緣情境 |
| `superman:git-ship` | 分支決策（squash merge vs. merge commit）+ PR 建立 + 發布前檢查清單 |
| `superman:ci-gates` | 執行 `.superman/ci/gates.json` 中的所有閘門（僅 L 級）；任一失敗則阻斷合併 |
| `superman:retrospective` | 結構化復盤（做得好的、遇到的困難、下次改進點）；將最佳實踐追加到專案知識庫 |

---

## 平台支援

Superman 使用同一套 `skills/` 技能庫，透過適配層覆蓋 6 個主流 AI 程式設計平台：

| 平台 | 觸發方式 | 設定檔 | 啟動方式 |
|------|---------|--------|----------|
| **Claude Code** | `/superman:*` 斜線命令 | `plugin.json` + hooks | Skill 工具直接呼叫 |
| **Cursor** | `@superman` 提及 | `plugin.json` + `.cursorrules` | 斜線命令注解 |
| **Gemini CLI** | `/superman:*` 命令 | `gemini-extension.json` + hooks | `activate_skill` 工具 |
| **Codex / Agents** | 技能工具呼叫 | `plugin.json` + hooks | Agent 技能工具分發 |
| **GitHub Copilot** | `/superman` 對話命令 | `copilot-instructions.md` | 對話整合 |
| **OpenCode** | JavaScript API | `superman.js` | 會話啟動 Hook + 斜線命令 |

同步所有平台設定：

```bash
bash scripts/sync-platforms.sh [target-dir]
```

---

## CI 閘門

閘門設定檔：`ci/gates-default.json`

**預設閘門（僅 L 級觸發）：**

```json
{
  "gates": [
    {
      "name": "validate-skills",
      "command": "node scripts/validate-skills.js",
      "description": "驗證所有 SKILL.md 檔案包含 Goal 和 Trigger 章節"
    },
    {
      "name": "spec-exists",
      "check": "file-exists",
      "path": ".superman/phases/define/spec.md",
      "description": "L 級需求必須存在規格文件"
    }
  ]
}
```

專案可在 `.superman/ci/gates.json` 中擴充自訂閘門（Lint、測試、安全掃描等）。

**執行 CI 閘門：**

```bash
/superman:ci-gates
```

任一閘門失敗均會阻斷合併，並輸出失敗原因和修復建議。

---

## 上下文持久化

所有狀態以檔案形式儲存在 `.superman/` 目錄，不依賴會話記憶體：

```
.superman/
├── context/
│   ├── requirements.md         # 即時追加使用者需求，永不刪除
│   ├── decisions.md            # 每條決策帶時間戳記
│   └── size-classification.md  # 一次寫入後鎖定，禁止靜默修改
├── phases/
│   ├── define/
│   │   ├── proposal.md         # 變更提案
│   │   ├── spec.md             # 規格文件（M/L 級）
│   │   └── tasks.md            # 實施任務清單
│   ├── execute/
│   │   ├── plan.md             # 執行計畫
│   │   └── progress.md         # 即時任務進度
│   └── verify/
│       ├── review.md           # 程式碼審查結果
│       └── spec-check.md       # 規格符合性報告
└── ci/
    └── gates.json              # 專案 CI 閘門設定
```

**會話恢復協議：**

每次新會話開始時，Superman 檢查 `.superman/context/requirements.md` 是否存在，若存在則讀取所有 `.superman/` 檔案並宣告：

```
Context restored from .superman/ — currently at EXECUTE phase, task 3/7 in progress
```

---

## CLI 命令參考

### `superman` 命令

```bash
superman init              # 在目前專案初始化 Superman 工作目錄
superman init [target]     # 在指定目錄初始化
```

### 驗證腳本

```bash
# 驗證所有 SKILL.md 檔案結構
node scripts/validate-skills.js

# 驗證規格文件（基礎檢查）
node scripts/validate-spec.js

# 嚴格模式（要求 "Spec Review: PASSED" 標記）
node scripts/validate-spec.js --strict

# 驗證指定檔案
node scripts/validate-spec.js .superman/phases/define/spec.md
```

### 平台同步

```bash
# 同步所有偵測到的平台設定
bash scripts/sync-platforms.sh

# 同步到指定目錄
bash scripts/sync-platforms.sh /path/to/project
```

---

## 專案結構

```
superman/
├── bin/
│   └── superman               # CLI 進入點
├── skills/
│   ├── define/                # DEFINE 階段技能（6 個）
│   │   ├── size-classify/SKILL.md
│   │   ├── brainstorming/SKILL.md
│   │   ├── propose/SKILL.md
│   │   ├── spec-review/SKILL.md
│   │   ├── writing-plans/SKILL.md
│   │   └── archive/SKILL.md
│   ├── execute/               # EXECUTE 階段技能（8 個）
│   │   ├── tdd/SKILL.md
│   │   ├── subagent-dev/SKILL.md
│   │   ├── incremental-impl/SKILL.md
│   │   ├── security/SKILL.md
│   │   ├── api-design/SKILL.md
│   │   ├── frontend-ui/SKILL.md
│   │   ├── debugging/SKILL.md
│   │   └── worktrees/SKILL.md
│   └── verify/                # VERIFY 階段技能（7 個）
│       ├── code-review/SKILL.md
│       ├── production-ready/SKILL.md
│       ├── spec-satisfied/SKILL.md
│       ├── verification/SKILL.md
│       ├── git-ship/SKILL.md
│       ├── ci-gates/SKILL.md
│       └── retrospective/SKILL.md
├── platforms/                 # 平台適配層
│   ├── claude/plugin.json
│   ├── cursor/plugin.json + cursorrules.md
│   ├── gemini/gemini-extension.json
│   ├── codex/plugin.json
│   ├── copilot/copilot-instructions.md
│   └── opencode/superman.js
├── hooks/                     # 平台 Hook 設定
│   ├── hooks.json             # Claude Code hooks
│   ├── hooks-cursor.json
│   ├── hooks-gemini.json
│   └── hooks-codex.json
├── ci/
│   ├── gates-default.json     # 預設 CI 閘門
│   └── gates-schema.json      # 閘門設定 JSON Schema
├── scripts/
│   ├── install.sh             # 安裝腳本
│   ├── sync-platforms.sh      # 平台同步腳本
│   ├── validate-skills.js     # 技能結構驗證
│   └── validate-spec.js       # 規格文件驗證
├── docs/
│   ├── diagrams/              # 架構圖（PNG）
│   └── superpowers/           # 設計規格和實施計畫
├── CLAUDE.md                  # Claude Code 平台指令
├── GEMINI.md                  # Gemini CLI 平台指令
├── AGENTS.md                  # Codex/Agents 平台指令
└── package.json
```

---

## 開發與貢獻

### 環境需求

- Node.js >= 18
- Git

### 本地開發

```bash
git clone https://github.com/kevinhu1228/superman.git
cd superman
npm test           # 驗證所有技能檔案結構
npm run validate   # 同上
npm run sync       # 同步平台設定
```

### 新增技能

1. 在 `skills/{define|execute|verify}/your-skill/` 下建立 `SKILL.md`
2. 檔案必須包含以下結構：
   ```markdown
   # 技能名稱

   **Goal**: 一句話說明技能目標

   ## Trigger
   何時觸發該技能

   ## Steps
   執行步驟
   ```
3. 執行 `npm test` 確保驗證通過
4. 在對應平台的 `plugin.json` 中註冊技能

### 設計文件

- [設計規格](docs/superpowers/specs/2026-05-24-superman-design.md)
- [實施計畫 A — 基礎設施](docs/superpowers/plans/2026-05-24-superman-plan-a-foundation.md)
- [實施計畫 B — 技能庫](docs/superpowers/plans/2026-05-24-superman-plan-b-skills.md)
- [實施計畫 C — 平台適配](docs/superpowers/plans/2026-05-24-superman-plan-c-platform.md)

---

## 授權條款

MIT © [kevinhu1228](https://github.com/kevinhu1228/superman)
