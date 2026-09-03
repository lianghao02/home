# 00_home Agent 開發規範

本專案遵循目前有效之全域開發憲法；本檔僅定義專案專屬規則與例外。

---

## 1. 專案核心定位與治理邊界
- **中央開發中樞定位**：
  - 本專案本質為 **Git 同步中樞、Codex / Antigravity Agent 全域規則部署源、共用 Skills 倉庫、桌面應用批次建置與 Windows 環境自癒腳本庫**。
  - **嚴禁同時將 home 作為作品展示網站或混合商業入口**；若未來需要作品展示站，必須另闢獨立 Repository 存放。
  - 全域開發憲法之唯一編輯源為 `configs/AGENTS.md`；Skills 來源為 `configs/skills/`，並依 `configs/skills-manifest.json` 進行分流。

---

## 2. BAT 與腳本生態邊界
- **BAT 薄啟動器原則**：
  - 根目錄之批次檔（`1_全專案智慧同步中樞.bat`、`2_建置所有桌面應用程式.bat`、`3_環境建置與工具安裝.bat`）必須維持「薄啟動器」架構：僅負責工作目錄鎖定、PowerShell 呼叫與必要暫停。
  - 所有實質同步、比對、編譯與錯誤捕捉，必須留在 `scripts/*.ps1`。
- **編碼防禦與路徑動態化**：
  - 所有 PowerShell 腳本開頭必須強制設定 UTF-8 編碼環境（`[Console]::OutputEncoding = [Text.Encoding]::UTF8`）。
  - 路徑計算一律優先使用 `$PSScriptRoot` 與 `Join-Path`，嚴禁寫死特定使用者的本機個人路徑。

---

## 3. 同步與安全防線
- **未提交變更防護**：
  - 智慧同步工具 (`sync_projects.ps1`) 掃描到專案有未提交之工作區變更時，必須主動略過（Skip）並列出提示，**絕對禁止強制 checkout、stash 或覆寫未提交程式碼**。
- **配置部署檢核流程**：
  - 變更全域憲法或共用 Skills 後，必須先執行：
    ```powershell
    powershell -ExecutionPolicy Bypass -File scripts\sync_codex.ps1 -CheckOnly
    ```
  - 確認差異無誤後，始得以 `-Execute` 正式同步部署至本機各 Agent 環境。
