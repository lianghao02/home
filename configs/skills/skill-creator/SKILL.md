---
name: skill-creator
description: 協助建立、重構與驗證 Antigravity 專用或雙平台共用 Skill。使用於需將重複工作流程固化成 Skill，或維護 Skill 分流與 YAML frontmatter 時。
---

# Skill 維護

## 何時建立

只有在流程跨專案可重複使用、已重複出現，且需要明確步驟或資源時才建立。小型專案規則留在專案 `AGENTS.md`，不要建立全域 Skill。

## 結構與內容

```text
skill-name/
├── SKILL.md
├── scripts/       # 需要可重複、可驗證的自動化時才建立
├── references/    # 詳細參考資料，按需讀取
└── assets/        # 產出用模板或資源
```

- 資料夾與 `name` 使用全小寫連字號。
- YAML frontmatter 只保留 `name` 與 `description`；描述須說明功能與觸發情境。
- `SKILL.md` 保持精簡，使用祈使句；詳細內容放入 `references/`。
- 新增或修改後驗證 frontmatter、名稱、路徑與實際工作流程；不得宣稱未執行的測試。

## 單一來源與分流

- 唯一維護來源：`D:\Development\GitHub\00_Dev-Control-Center\configs\skills\`。
- 分流定義：`D:\Development\GitHub\00_Dev-Control-Center\configs\skills-manifest.json`。
- Codex 共用部署：`C:\Users\chia-hao\.agents\skills\`。
- Antigravity 共用部署：`C:\Users\chia-hao\.gemini\config\skills\`。
- 專案專屬規則分開維護於 `[專案]\.agents\AGENTS.md` 與 `[專案]\.gemini\AGENTS.md`；不得由全域同步腳本互相複製。

新增 Skill 前先更新分流清單，再執行 `D:\Development\GitHub\00_Dev-Control-Center\scripts\sync_codex.ps1 -CheckOnly`。確認無誤後才正式同步。
