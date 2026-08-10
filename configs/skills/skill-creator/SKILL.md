---
name: skill-creator
description: 元技能（Meta-Skill）。協助建立、重構與驗證新的 Antigravity Skills，遵循標準 YAML frontmatter 規範與漸進式揭露原則。當需要封裝重複性工作流程為可重用 Skill 時啟用。
---

# Skill Creator — 元技能封裝工具

## 什麼時候使用這個 Skill

- 你發現自己對某類任務**重複給 AI 相同指令**（超過 3 次）
- 你想將某個**複雜工作流程**固化為可複用的 Skill
- 你需要**標準化**某個專案的 AI 行為邊界

## Skill 標準結構

```
skills/
└── your-skill-name/          ← 全小寫，連字號分隔
    ├── SKILL.md              ← 必要：核心指令與 YAML frontmatter
    ├── scripts/              ← 選用：輔助腳本
    ├── examples/             ← 選用：參考實作範例
    └── resources/            ← 選用：相關資源、模板
```

## SKILL.md 規格要求

### YAML Frontmatter（必填欄位）

```yaml
---
name: skill-name              # 必填：全小寫，連字號分隔的唯一識別碼
description: |                # 必填：觸發條件 + 功能說明（影響 AI 是否自動啟用）
  說明此 Skill 的觸發情境與核心功能。
  描述越精確，AI 越能在正確時機自動載入此 Skill。
---
```

### Markdown 指令內容規範

- **使用祈使句**：「執行 X」「驗證 Y」「回傳 Z」，而非「你應該...」
- **具體範例優先**：每個步驟附上程式碼片段或命令範例
- **漸進式揭露**：從高層概覽開始，再深入細節
- **台灣繁體中文**：符合全域憲法語言規範

## 建立新 Skill 的步驟

### 步驟一：確認封裝價值

回答以下問題（任一「是」則值得封裝）：
- [ ] 這個工作流程是否跨專案通用？
- [ ] 是否需要超過 200 字的指令說明？
- [ ] 是否涉及多步驟、有順序依賴的流程？

### 步驟二：選擇存放位置

| 範疇 | 路徑 | 適用情境 |
|:---|:---|:---|
| **全域**（所有專案） | `C:\Users\chia-hao\.gemini\config\skills\` | 通用工具、工程標準 |
| **專案層級** | `[專案]\.agents\skills\` | 專案特定的工作流程 |

### 步驟三：撰寫 SKILL.md

```markdown
---
name: your-skill-name
description: 一句話說明觸發條件。詳細說明此 Skill 覆蓋的任務範疇。
---

# [技能名稱]

## 前置條件
- 需要的環境或工具

## 執行步驟
1. 第一步：...
2. 第二步：...

## 驗證方式
- 如何確認執行成功

## 範例
\`\`\`語言
# 具體程式碼範例
\`\`\`
```

### 步驟四：測試驗證

```powershell
# 確認能偵測到新 Skill
Get-ChildItem "C:\Users\chia-hao\.gemini\config\skills" -Recurse -Filter "SKILL.md"
```

## 現有 Skills 目錄一覽

| Skill 名稱 | 用途 |
|:---|:---|
| `github-workflow` | GitHub 搜尋、PR、upstream 同步與 Release CI/CD |
| `release-notes` | 撰寫發布說明 (Release Note) 與 `CHANGELOG.md` 格式化 |
| `webapp-testing` | Playwright 瀏覽器自動化測試與 UI 視覺驗證 |
| `caveman` | 省 Token 快速輸出模式（需使用者明確指定時啟用） |
| `accesslint` | WCAG 無障礙規範合規檢測 |
| `addyosmani-perf` | Core Web Vitals 效能量測與針對性優化 |
| `skill-creator` | 本技能（封裝與維護 Skill） |
