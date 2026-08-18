# 📜 變更歷史 (CHANGELOG)

## 🚀 v1.4.0 (2026-08-19)
- **分類儀表板**：首頁門戶重構為雙分區固定結構（「🌐 免安裝．瀏覽器即開即用」與「💻 本機應用．高效桌面與 AI 工具」）。
- **視覺標籤升級**：卡片增加「免安裝」綠色膠囊標籤與「Python / AI Skill」環境屬性標籤，大幅提升使用者的執行決策速度。
- **排版固定與穩定性**：優化 CSS Grid 與等高拉伸版面，徹底解決不同螢幕與文字行數伸縮造成的版面錯位問題。

## 🚀 v1.3.0 (2026-08-17)
- **發布指南**：補齊下載、必要軟體、執行入口、離線環境與備份方式。
- **路徑修正**：快速開始範例改為實際的 `scripts\sync_projects.ps1` 路徑。
- **版本盤點**：同步 12 個 Repository 的發布版本與首頁卡片資料。

## 🚀 v1.2.3 (2026-08-17)
- **環境自癒系統**：新增 `setup_all_envs.ps1` 與 `4_建置所有Python專案環境.bat`，支援一鍵為 5 個 Python 專案佈置免安裝可攜版 Python 3.13。
- **單一專案獨立發布**：各 Python 專案（`01`, `06`, `07`, `09`, `10`）全面配備 `RUN.bat` 與 `setup_and_run.ps1`，支援隨身碟即插即用、本機 ZIP 優先解壓與線上自動自癒下載。
- **相容性修復**：解決可攜版 Python `._pth` 載入編碼問題，採用嚴格 ASCII 無 BOM 格式，杜絕 `ModuleNotFoundError: No module named 'encodings'` 崩潰。

## 🚀 v1.2.2 (2026-08-16)
- **智慧偵測**：`scripts/sync_projects.ps1` 升級自動磁碟判斷機制（優先判定 `D:\Development\GitHub`，無 D 槽電腦自動自適應至 `C:\Development\GitHub`）。
- **防禦安全**：新增危險路徑黑名單防禦（`Test-IsDangerousPath`），阻擋誤在桌面（Desktop）、下載（Downloads）、使用者目錄或系統根目錄執行，杜絕檔案污染。
- **批次推播與捷徑**：新增 `scripts/push_projects.ps1` 批次推播腳本與 4 個一鍵雙擊 `.bat` 啟動捷徑；批次檔統一使用 UTF-8（無 BOM），啟動時切換至 UTF-8 字碼頁以顯示繁體中文。
- **體驗中文化**：全面升級推播與同步腳本之控制台輸出為 100% 繁體中文，並隔離 Git 底層 stderr 避免 PowerShell 5.1 `NativeCommandError` 誤判中斷。
- **門戶頁面校準**：`index.html` 修正卡片標籤嵌套問題，依專案編號排序 12 個作品卡片並同步最新版本號。

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
