# LiangHao 開發環境入口

本 Repository 保存全域開發憲法 v8.1、共用 Agent Skills、12 個開發 Repository 清單，以及 Windows 環境重建與一鍵自癒佈置腳本。目前版本為 **v1.4.0**。

## 技術架構現況（2026-08-24）

- 工作區主力技術依專案用途分流：AI 鑑識與行政自動化維持 Python、免安裝資料工具維持純 Web、Windows 原生工具採 C#／.NET 8／WPF。
- `03_Police-Image-Toolkit` 與 `06_System-Optimizer-Tool` 已完成 C#／.NET 8／WPF 遷移；舊版分別封存於 `legacy_web/` 與 `legacy-python/`，供回歸比對與備援。
- `04_Photo-Report-Generator` 已為純前端 SPA，並不依賴 VBA 或 Microsoft Office；其餘專案尚未進行 Rust、Tauri 或 TypeScript 遷移。

## 下載、需求與執行入口

- **用途**：集中管理專案清單、Git 同步、Codex／Antigravity 規則，以及仍採 Python 的專案可攜環境。
- **必要軟體**：Windows 10/11、Git for Windows、Windows PowerShell 5.1 以上；管理功能本身不要求先安裝 Python。
- **下載**：`git clone https://github.com/lianghao02/home.git 00_home`。
- **主要入口**：一般使用者直接雙擊根目錄的 `0_`～`4_` 批次檔；進階使用者可執行 `scripts/` 下對應 PowerShell 腳本。
- **網路需求**：Clone、Pull、Push 與首次下載 Python 可攜核心時需要網路；若 `downloads/` 已有安裝母檔，Python 環境可離線建置。
- **打包方式**：本專案是管理腳本集合，不需編譯或安裝；備份時保留完整資料夾即可。

## 雙擊快捷捷徑 (One-Click Batch Tools)

在 `00_home` 根目錄提供 7 個一鍵雙擊 `.bat` 啟動捷徑：
- `0_檢查專案更新狀態_預覽.bat`：唯讀掃描 12 個專案 Git 變更狀態。
- `1_推送所有專案至GitHub.bat`：一鍵自動 Commit 並推播所有修改至 GitHub。
- `2_從GitHub更新所有專案.bat`：一鍵從 GitHub 更新所有專案進度，自動 Clone 缺漏專案並部署 AI 規範。
- `3_同步AI設定與Skills.bat`：獨立同步全域憲法與共用 Agent Skills 至 Codex / Antigravity。
- `4_建置所有Python專案環境.bat`：供仍採 Python 的專案建立可攜版 Python 3.13 環境；`06` 的主力發行版已改為 C#／.NET，不應將其視為 Python 主程式。
- `5_安裝GitHub與Playwright工具.bat`：新電腦首次使用時，安裝 Git、GitHub CLI、Playwright 與 Chromium；需要 GitHub 網頁登入授權。
- `6_建立雙Agent工作區.bat`：選單式一鍵建立指定專案的 `*-codex` 與 `*-ag` 獨立 Worktree，支援自動預覽與確認機制。

## 新電腦快速開始

先安裝 Git for Windows，再於 PowerShell 執行：

```powershell
New-Item -ItemType Directory -Path 'D:\Development\GitHub' -Force
git clone https://github.com/lianghao02/home.git 'D:\Development\GitHub\00_home'

# 預覽，不修改檔案
powershell.exe -NoProfile -ExecutionPolicy Bypass -File 'D:\Development\GitHub\00_home\scripts\sync_projects.ps1'

# 正式複製／更新專案並部署 Codex、Antigravity 規則
powershell.exe -NoProfile -ExecutionPolicy Bypass -File 'D:\Development\GitHub\00_home\scripts\sync_projects.ps1' -Execute
```

腳本會依 [development-repositories.json](development-repositories.json) 處理 12 個 Repository。遇到既有未提交變更時會略過，不會自動刪除任何本機資料夾，也不會強制覆蓋 Git 歷史。

## Agent 設定

`scripts/sync_codex.ps1` 會同步：

- 全域憲法至 `%USERPROFILE%\.codex\AGENTS.md`
- 全域憲法至 `%USERPROFILE%\.gemini\config\AGENTS.md`
- Codex 共用／專用 Skills 至 `%USERPROFILE%\.agents\skills`
- Antigravity 共用／專用 Skills 至 `%USERPROFILE%\.gemini\config\skills`

`configs\skills` 是唯一維護來源，`configs\skills-manifest.json` 決定每個 Skill 的分流：`shared` 會同步至兩端、`codexOnly` 只同步 Codex、`antigravityOnly` 只同步 Antigravity。Codex 內建已有 `skill-creator`，因此自訂版本維持 Antigravity 專用，避免同名 Skill 衝突。`%USERPROFILE%\.codex\skills` 的個人獨立 Skill 與 `.system` 系統 Skill 均不會由同步腳本覆寫。

目前的核心能力已完成去重：

- `project-planning`：合併 Brainstorming 與 Planning with Files，只在大型或跨階段工作啟用。
- `webapp-testing`：沿用既有 Playwright 自動化測試，不另裝同功能 Skill。
- `document-to-markdown`：使用 Microsoft MarkItDown 做文件分析前處理；正式文件編輯仍交由格式專屬工具。
- `skill-creator`：Codex 使用系統原生版本，Antigravity 使用中央來源的自訂版本。
- `project-readiness-check`：Git 狀態、測試、Web 實測、差異與敏感資料的交付前檢查，會同步至 Codex 與 Antigravity。

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
