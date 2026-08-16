# 📜 變更歷史 (CHANGELOG)

## 🚀 v1.2.2 (2026-08-16)
- **智慧偵測**：`sync_projects.ps1` 升級自動磁碟判斷機制（優先判定 `D:\Development\GitHub`，無 D 槽電腦自動自適應至 `C:\Development\GitHub`）。
- **防禦安全**：新增危險路徑黑名單防禦（`Test-IsDangerousPath`），阻擋誤在桌面（Desktop）、下載（Downloads）、使用者目錄或系統根目錄執行，杜絕檔案污染。

## 🚀 v1.2.1 (2026-08-13)
- **修復**：修正 `CHANGELOG.md` UTF-8 無 BOM 檔案編碼，排除歷史文字亂碼問題。
- **文件**：更新 README，補充同步腳本的安全邊界、版本資訊與編碼原則。
- **安全性**：升級 `sync_codex.ps1` 與 `sync_projects.ps1` 的寫入機制，採用 .NET API (`WriteAllText`) 避免 PowerShell 5.1 產生 UTF-8 BOM 導致雜湊比對失敗。
- **防禦**：補強 `sync_projects.ps1` 之 Git 指令 Exit Code 攔截與路徑引號防護。
- **防禦**：升級 `update_home_html.py`，新增符號連結 (Symlink) 檢驗與路徑安全邊界防禦。

## 🚀 v1.2.0 (2026-08-10)
- **核心架構更新**：全域憲法 v7.1 及 Configs 備份與 D 槽架構對齊。
- **路徑與快取優化**：清除 C 槽與 D 槽開發環境雜亂，設置 `D:\Caches` 統一快取目錄（`HF_HOME` / `PIP_CACHE_DIR` / `PLAYWRIGHT_BROWSERS_PATH`）。
- **專案結構與文件**：專案資料夾前綴數字命名法，更新全域憲法 v7.1 與 `CODEX.md`。
