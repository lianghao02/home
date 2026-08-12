# Codex 環境摘要

| 項目 | 類型 | 來源 | 安裝位置 | 用途 | 更新／移除 |
|---|---|---|---|---|---|
| 全域憲法 | 共用設定 | `configs/AGENTS.md` | `%USERPROFILE%/.codex/AGENTS.md`、`%USERPROFILE%/.gemini/config/AGENTS.md` | 兩平台共用行為規則 | 修改中央來源後執行 `sync_codex.ps1`；勿直接改部署檔。 |
| 共用自訂 Skills（8 個） | Skill | `configs/skills/` | Codex：`%USERPROFILE%/.agents/skills/`；Antigravity：`%USERPROFILE%/.gemini/config/skills/` | 規劃、文件轉換、網頁測試、GitHub 與品質流程 | 修改中央來源後執行同步；移除前先封存部署目錄。 |
| skill-creator | Codex 系統 Skill | Codex 內建 | `%USERPROFILE%/.codex/skills/.system/skill-creator/` | 建立或維護 Skill | 由 Codex 更新；不部署自訂同名版本。 |
| MarkItDown | 本機工具 | [Microsoft MarkItDown](https://github.com/microsoft/markitdown) | `%LOCALAPPDATA%/LiangHao/tools/markitdown/.venv/` | PDF、Office 與資料檔轉 Markdown | 依 `document-to-markdown` Skill 的安裝指令更新；刪除該獨立工具資料夾即可移除。 |

## 同步

```powershell
# 唯讀檢查
powershell.exe -NoProfile -ExecutionPolicy Bypass -File 'D:\Development\GitHub\00_home\sync_codex.ps1' -CheckOnly

# 正式同步
powershell.exe -NoProfile -ExecutionPolicy Bypass -File 'D:\Development\GitHub\00_home\sync_codex.ps1'
```

Codex 系統目錄 `%USERPROFILE%/.codex/skills/.system/` 與 Antigravity 平台內建 Skills 不在同步或移除範圍內。
