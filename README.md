# LiangHao 開發環境入口

本 Repository 保存全域開發憲法 v8.0、共用 Agent Skills、12 個開發 Repository 清單，以及 Windows 環境重建與一鍵自癒佈置腳本。目前版本為 **v1.2.3**。

## 雙擊快捷捷徑 (One-Click Batch Tools)

在 `00_home` 根目錄提供 5 個一鍵雙擊 `.bat` 啟動捷徑：
- `0_檢查專案更新狀態_預覽.bat`：唯讀掃描 12 個專案 Git 變更狀態。
- `1_推送所有專案至GitHub.bat`：一鍵自動 Commit 並推播所有修改至 GitHub。
- `2_從GitHub更新所有專案.bat`：一鍵從 GitHub 更新所有專案進度，自動 Clone 缺漏專案並部署 AI 規範。
- `3_同步AI設定與Skills.bat`：獨立同步全域憲法與共用 Agent Skills 至 Codex / Antigravity。
- `4_建置所有Python專案環境.bat`：一鍵自動為 5 個 Python 專案（`01`, `06`, `07`, `09`, `10`）佈置免安裝的可攜版 Python 3.13 獨立環境與相依套件。

## 新電腦快速開始

先安裝 Git for Windows，再於 PowerShell 執行：

```powershell
New-Item -ItemType Directory -Path 'D:\Development\GitHub' -Force
git clone https://github.com/lianghao02/home.git 'D:\Development\GitHub\00_home'

# 預覽，不修改檔案
powershell.exe -NoProfile -ExecutionPolicy Bypass -File 'D:\Development\GitHub\00_home\sync_projects.ps1'

# 正式複製／更新專案並部署 Codex、Antigravity 規則
powershell.exe -NoProfile -ExecutionPolicy Bypass -File 'D:\Development\GitHub\00_home\sync_projects.ps1' -Execute
```

腳本會依 [development-repositories.json](development-repositories.json) 處理 12 個 Repository。遇到既有未提交變更時會略過，不會自動刪除任何本機資料夾，也不會強制覆蓋 Git 歷史。

## Agent 設定

`scripts/sync_codex.ps1` 會同步：

- 全域憲法至 `%USERPROFILE%\.codex\AGENTS.md`
- 全域憲法至 `%USERPROFILE%\.gemini\config\AGENTS.md`
- Codex 自訂 Skills 至 `%USERPROFILE%\.agents\skills`
- Antigravity Skills 至 `%USERPROFILE%\.gemini\config\skills`

`configs\skills` 是唯一維護來源。共用 Skill 會分別部署至 Codex 與 Antigravity；Codex 內建已有 `skill-creator`，因此自訂版本只部署至 Antigravity，避免同名 Skill 衝突。`%USERPROFILE%\.codex\skills\.system` 僅保留 Codex 系統內建 Skill，不由同步腳本修改。

目前的核心能力已完成去重：

- `project-planning`：合併 Brainstorming 與 Planning with Files，只在大型或跨階段工作啟用。
- `webapp-testing`：沿用既有 Playwright 自動化測試，不另裝同功能 Skill。
- `document-to-markdown`：使用 Microsoft MarkItDown 做文件分析前處理；正式文件編輯仍交由格式專屬工具。
- `skill-creator`：Codex 使用系統原生版本，Antigravity 使用中央來源的自訂版本。

單獨檢查或同步 Agent 設定：

```powershell
# 唯讀檢查
.\scripts\sync_codex.ps1 -CheckOnly

# 正式同步
.\scripts\sync_codex.ps1
```

## 本機專屬資料

以下資料不得提交至 GitHub，必須在每台電腦個別設定：

- `.env`、API Key、Token、密碼
- Python `.venv`
- `node_modules`
- 瀏覽器登入狀態與 Cookie
- 大型模型快取、pip 快取、應用程式快取

各 Python 專案應依自己的 `requirements.txt` 或 `pyproject.toml` 重新建立虛擬環境，不得直接複製其他電腦的 `.venv`。

## 安全設計

- 同步專案前先檢查 Git 狀態；有未提交變更時直接略過。
- 只允許 `pull --ff-only`，不自動合併、rebase 或 force push。
- 產生 JSON 與部署文件時使用 UTF-8 無 BOM，避免 PowerShell 5.1 編碼差異。
- 部署前保留可復原備份，並限制備份數量，避免長期累積。

## 路徑架構

- 實體開發路徑：`D:\Development\GitHub`
- 舊工具相容路徑：`C:\Users\<使用者名稱>\Documents\GitHub`

Junction 屬於選用的本機相容設定，不儲存在 Git 中。詳細規範請參閱 [docs/DEVELOPMENT_ENVIRONMENT.md](docs/DEVELOPMENT_ENVIRONMENT.md)。
