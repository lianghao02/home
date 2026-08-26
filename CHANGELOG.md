# 📜 變更歷史 (CHANGELOG)

## 未發布（2026-08-26）
- **批次檔編碼標準化**：根目錄 7 個 `.bat` 批次檔全數改採 UTF-8 with BOM 與標準 Windows CRLF 行尾，徹底排除 CMD.exe 雙擊啟動時解析中文造成的語法錯誤、標籤跳轉失敗與閃退。
- **控制台編碼強化**：所有核心 PowerShell 腳本強制設定 `[Console]::OutputEncoding = UTF8`，杜絕 PowerShell 5.1 在繁體中文環境預設 CP950 引起的終端問號與方塊亂碼。
- **AI 設定同步容錯自癒**：修復 `sync_codex.ps1` 遇 0 位元組空檔案（如未配置的 `mcp_config.json`）直接崩潰的臭蟲，並優化預覽模式為非中斷警告。
- **00_home 免 Git 自癒升級**：`sync_projects.ps1` 新增非 Git 目錄自癒機制，若新電腦以 ZIP 下載解壓，執行更新時會自動初始化為標準 Git 版本庫並連結遠端。
- **Python 專案清單校準**：將已全面升級為 C# .NET 8 原生架構的 `09_PaperSwitch` 自主力 Python 可攜清單移除，確保三大 Python 專案（`01`, `07`, `10`）建置與健康診斷 100% 綠燈。
- **工具鏈安裝容錯**：`setup_developer_tools.ps1` 針對權限不足的 winget 安裝失敗加入明確導引提示，避免拋出未捕獲中斷例外。

## 2026-08-24
- **技術盤點文件**：README 明列工作區的實際技術分流，以及 `03`、`06` 已完成 C#／.NET 8／WPF 遷移的狀態。
- **說明校正**：將 `06` 自主力 Python 可攜專案清單移除，保留其歷史 Python 備援版本的定位。
- **環境管理校準**：第 5 支工具改以核心／建議／選配分級檢測語言環境；Node.js 不再列為全域必要項目，Rust、WebView2 Runtime 與 C++ Build Tools 僅於 Tauri 工作需要時提示。

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
