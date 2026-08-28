# 實作計畫

## 目標與驗收條件

將共用自訂 Skill 的 Codex 部署位置遷移至官方個人位置 `%USERPROFILE%\.agents\skills`，維持 Antigravity 部署與中央來源不變，並移除工作區根目錄重複的全域憲法。

## 不做範圍

- 不安裝新 Plugin、MCP、Skill 或修改 Codex 系統內建 Skill。
- 不刪除資料；舊部署一律先移至可復原備份。

## 已確認決策

- 中央來源：`configs\skills` 與 `configs\AGENTS.md`。
- Codex 自訂 Skill：`%USERPROFILE%\.agents\skills`。
- Codex 系統 Skill：`%USERPROFILE%\.codex\skills\.system`，保持不動。

## 工作清單

- [x] 更新同步腳本與說明文件｜PowerShell 語法與 UTF-8 BOM 檢查通過。
- [x] 部署至新的 Codex 個人 Skill 位置｜檔案與中央來源一致；待重啟 Codex 驗證探索。
- [x] 備份並移除舊 `.codex\skills` 自訂部署與根目錄重複 `AGENTS.md`｜備份存在，`.system` 保留。
- [x] 驗證中央來源、Codex、Antigravity 的雜湊一致性｜`sync_codex.ps1 -CheckOnly` 全數 Current。
- [x] 建立精簡 `CODEX_SETUP.md`｜內容與實際狀態一致。

## 風險與因應

- Skill 探索會在新工作階段重新讀取：先部署，再由使用者重新啟動 Codex 驗證；舊檔案保留可復原備份。

## 驗證紀錄

- `sync_codex.ps1 -CheckOnly`：所有受管理項目為 `Current`。
- Codex 與 Antigravity 的 `AGENTS.md` SHA-256 均與中央來源一致。

## 剩餘問題

- 重新啟動 Codex 後確認 `.agents\skills` 的 8 個自訂 Skill 已出現在可用清單。

---

## 2026-08-26 集中建置桌面應用程式

### 目標與驗收條件

- 在 `00_home` 提供一個可由任何目前工作目錄執行的 PowerShell 腳本與同風格 BAT 捷徑。
- 一次發布目前具原生 Windows 發行契約的 `03_Police-Image-Toolkit`、`06_System-Optimizer-Tool`、`09_PaperSwitch`，並保留可直接執行的 Self-Contained EXE 在各專案既有發布目錄。
- 預覽模式不得修改檔案；實際建置前須明確確認，並在結尾回報每個專案的成功或失敗結果。

### 不做範圍

- 不將純 Web 或 Python 專案強制封裝為 EXE。
- 不將二進位發行成品提交至 Git，也不建立集中副本。
- 不修改三個專案既有的個別發布腳本。

### 已確認決策

- 使用各專案既有發布腳本，避免在管理端複製或分岔 .NET 發行參數。
- `06` 與 `09` 選用 Self-Contained 發行；`03` 的既有發布流程即為 Self-Contained。
- 集中腳本只負責觸發發布及回報來源成品路徑，避免產生兩套可能不同步的 EXE。

### 工作清單

- [x] 新增集中發布 PowerShell 腳本與 BAT 捷徑｜Windows PowerShell Parser 與預覽模式通過。
- [x] 更新 README 與 Git 忽略規則｜路徑與入口文字檢核通過。
- [x] 執行實際批次發布並驗證三個 EXE｜三個檔案皆存在於各自發布目錄。

### 風險與因應

- Self-Contained 發行需要 .NET 8 SDK，且可能耗時：先以預覽模式檢查所有腳本與來源路徑，再由使用者啟動實際建置。
- 個別發布腳本會清理其既有輸出目錄：集中腳本在執行前顯示範圍並要求確認。

### 驗證紀錄

- `build_all_desktop_apps.ps1` 預覽模式：三個發布腳本均顯示「就緒」，結束代碼 `0`。
- `03_Police-Image-Toolkit`：`03_Police-Image-Toolkit\dist\PoliceImageToolkit.exe`，69.08 MB。
- `06_System-Optimizer-Tool`：`06_System-Optimizer-Tool\dotnet-src\publish\standalone\SystemOptimizer.App.exe`，68.41 MB。
- `09_PaperSwitch`：先以 `dotnet restore -r win-x64` 建立 Runtime 對應資產後成功發布；`09_PaperSwitch\dist\publish\PaperSwitch.exe`，75.18 MB。

---

## 2026-08-13 跨專案文件與發布同步

### 目標與驗收條件

- 更新除 `07_auto-learning-bot` 外 11 個儲存庫的 README、正式版本標示與 CHANGELOG。
- 修復文件亂碼，統一使用 UTF-8 無 BOM。
- 依各專案既有差異執行語法或測試驗證，逐案提交並推送 `main`。

### 不做範圍

- 不修改或推送 `07_auto-learning-bot`。
- 不使用 force push，不改寫遠端歷史。
- 不納入快取、虛擬環境或其他產生檔。

### 工作清單

- [x] 盤點 11 個儲存庫、既有差異、版本來源與文件編碼。
- [ ] 更新 README、版本與 CHANGELOG｜以亂碼掃描與版本一致性檢查驗證。
- [ ] 執行各專案適用的語法、單元或一致性測試。
- [ ] 逐案提交並推送 `main`，核對 `origin/main`。

### 已知風險

- 多個儲存庫含先前工作階段留下的未提交修正；必須先驗證再納入提交。
- Office COM、瀏覽器互動與 Windows 權限相關流程無法完全由純語法檢查取代，需在回報中保留限制。

---

## 2026-08-16 HTML 專案莫蘭迪淺色介面改版

### 目標與驗收條件

- 為 `00_home`、`01_AG-Monitor-Forensics`、`02_Cell-Tower-Map-Locator`、`03_Police-Image-Toolkit`、`04_Photo-Report-Generator`、`08_Financial-Data-Parser`、`10_Smart-Photo-Organizer`、`11_Calendar-Card-App` 導入一致的莫蘭迪淺色 UI Token。
- 第一階段只處理背景、面板、文字、按鈕、輸入框、焦點與陰影；不改動功能邏輯或 DOM 結構。
- 保留影像／影片預覽區的黑色畫面、錯誤與危險操作的語意辨識度。

### 不做範圍

- 不加入 SVG 空狀態插圖、Banner 或任何點陣圖素材。
- 不修改後端、Python、VBA、Google Apps Script 或資料處理流程。
- 不 commit、push、安裝套件或同步全域設定。

### 已確認決策

- 使用共用基準：背景 `#F3F5F8`、表面 `rgba(255,255,255,.85)`、主文字 `#2B364B`、次要文字 `#737C8B`、主色 `#6B8BB0`、成功色 `#6E9C83`、警示色 `#C78876`。
- 以現有樣式檔或頁尾覆寫區導入 Token，避免重構既有 DOM 與 JavaScript 選擇器。

### 工作清單

- [x] 盤點 8 個專案的樣式入口與既有工作樹狀態｜已完成樣式檔與色彩掃描。
- [x] 導入莫蘭迪淺色 Token 與控制元件樣式｜已更新 8 個專案的主要 HTML／CSS 樣式入口。
- [x] 執行 HTML／CSS 靜態檢查與可用的瀏覽器視覺驗證｜8 個專案皆通過 Token 與 `git diff --check`；此環境未安裝 Playwright，未執行瀏覽器截圖。

### 風險與因應

- `01` 與 `10` 有大量內嵌色彩：以精準覆寫維持功能性媒體預覽與狀態顏色。
- 各專案工作樹可能同時有使用者變更：修改前後僅納入本次指定的 HTML／CSS 檔案。

### 第二階段：空狀態與拖曳區引導

- [x] 盤點既有空狀態、拖曳區與資料載入狀態｜未對沒有既有空狀態的入口頁與下載頁硬塞視覺素材。
- [x] 以內嵌 SVG／CSS 加入低彩度操作引導｜已套用至鑑識預覽、基地台輸入、影像證物、金融拖曳區與行事曆無行程區。
- [x] 驗證載入資料後引導不遮擋工作區，並以 Playwright 留存桌面與行動版截圖｜使用 Codex 內建 Node Playwright 1.62.1；金融檔案載入後引導自動隱藏，行事曆空狀態渲染通過。

### 第三階段：入口封面與瀏覽器驗收

- [x] 以影像生成工具製作 12 張無文字、淺色莫蘭迪 Banner｜新增為 PNG，原有 JPG 保留未刪除。
- [x] 更新入口頁的 12 個 Banner 引用｜只變更圖片副檔名與公文範本的後備圖片。
- [x] 以 Playwright 驗證首頁 Banner、第二階段空狀態與桌面／行動版版面｜16 組桌面／行動版截圖完成；首頁 12 張 Banner 載入與空狀態互動通過。
- [x] 檢查共用 Token 的文字與底色對比｜調整為符合 WCAG 2.1 AA 的莫蘭迪深灰調，正文最小對比 4.58:1。

---

## 2026-08-16 跨專案目錄架構整理

### 目標與驗收條件

- 採用「共通根目錄規則＋依專案類型調整」，不強迫靜態網站、Skill 與 Python 應用程式使用相同目錄。
- 根目錄只保留 Repository 契約文件、主要入口、必要設定與使用者直接操作的啟動器。
- 將內部文件、維護腳本、Apps Script 後端及大型 Python 模組移至語意清楚的位置。
- 所有移動都更新引用路徑，並通過適用的語法、單元、建置或 Playwright 驗證。

### 保護邊界

- 不刪除或搬移使用者資料、模型、輸入影片、資料庫、設定備份與執行紀錄，除非確認為 Git 可復原的一次性工具檔。
- 不為單頁靜態網站或 Skill Repository 硬加低價值的 `src/`、`docs/` 空目錄。
- 不改變 Git 遠端、分支或歷史，不執行 force push。

### 分類決策

- `00_home`：文件移至 `docs/`，維護程式移至 `scripts/`，根目錄保留四個操作捷徑。
- `01_AG-Monitor-Forensics`：規劃文件移至 `docs/`；保留可攜式入口、模型與 Web 資源位置。
- `02`、`03`、`04`、`05`、`06`、`08`：既有結構符合專案類型，只處理確定的雜項，不為一致外觀重構。
- `07_auto-learning-bot`：先保留可攜版根目錄契約，僅移動不影響封裝的文件或維護工具。
- `09_PaperSwitch`：工程文件移至 `docs/`，`app.py` 在尚未真正拆模組前保留根目錄。
- `10_Smart-Photo-Organizer`：完成 `src/smart_photo_organizer/` 正式 package、package 匯入與測試路徑。
- `11_Calendar-Card-App`：Apps Script 後端移至 `apps-script/`，清除已完成使命的歷史改寫工具。

### 工作清單

- [x] 整理低風險文件、腳本與 Apps Script 路徑｜引用搜尋、PowerShell parser 與 Node 語法檢查通過。
- [x] 完成 Smart-Photo-Organizer 正式 package 化｜Python 3.13 共 140 項測試通過、1 項因 Windows 權限限制略過，SQLite ResourceWarning 已排除。
- [x] 驗證 auto-learning-bot 可攜版與測試引用後再決定安全移動範圍｜保留根目錄執行契約，僅移動發行文件與建置工具；12 項測試通過。
- [x] 執行各專案適用驗證並檢查 Git 差異｜Calendar Card 以 Playwright 產生 42 個日期格；未納入快取或使用者資料。

### 已知風險

- Windows BAT、PowerShell `$PSScriptRoot`、PyInstaller／可攜版清單及 GitHub Pages 根目錄均依賴相對路徑。
- Python `src-layout` 若只注入 `sys.path` 而沒有正式 package，容易造成測試環境與實際啟動行為不一致。

---

## 2026-08-17 全專案 GitHub 發布文件與版本一致化

### 目標與驗收條件

- 12 個 Repository 的 README 都能讓首次下載者看懂功能、依賴、安裝、啟動、打包或部署方式。
- 版本號依實際異動採語意化版本調整，README、CHANGELOG、程式內版本與套件清單保持一致。
- Python 專案清楚區分 `RUN.bat` 自癒啟動、手動 Python 3.13 安裝及可攜版用途。
- 完成適用的語法、測試、文件一致性與 Git 差異驗證後，才提交並推送各 Repository。

### 不做範圍

- 不更動核心功能流程，不新增非必要執行依賴。
- 不建立虛構的安裝或打包流程；沒有建置步驟的靜態網站明確標示無須打包。
- 不 force push、不改 remote、不提交密碼、Token、使用者資料或快取。

### 工作清單

- [x] 盤點 12 個專案的版本來源、依賴與入口檔｜README、CHANGELOG、manifest 與程式版本交叉核對。
- [x] 更新 README、CHANGELOG 與版本號｜依功能／修訂幅度套用語意化版本。
- [x] 執行各專案適用驗證｜Python、Node、PowerShell、Office 檔案存在性與文件一致性。
- [x] 確認 main／origin 後逐一提交與推送｜禁止 force push。

### 風險與因應

- 可攜式 Python 依賴與開發環境不同：文件分開說明，不混用 requirements。
- 靜態網站仍可能使用 CDN：README 明列網路依賴與核心離線能力邊界。
- 版本散落於 HTML、Python、package manifest：以全文搜尋及測試確認沒有殘留舊版號。

### 驗證紀錄

- `05_tw-formal-writing`：建置 `STANDALONE.md`、一致性與封裝清單檢查通過；另修復 CP950 主控台不支援核取符號造成的崩潰。
- `06_System-Optimizer-Tool`：8 項單元測試通過。
- `07_auto-learning-bot`：19 項單元測試及 Python 編譯檢查通過。
- `10_Smart-Photo-Organizer`：140 項單元測試通過，1 項因 Windows symlink 權限略過。
- `02`、`08`、`11`：JavaScript／npm 語法檢查通過；5 個自癒啟動器與 00 管理腳本通過 PowerShell Parser。
- 全部異動文字檔均為有效 UTF-8、未含 U+FFFD，且 12 個 Repository 均通過 `git diff --check`。
- `01_AG-Monitor-Forensics`：Python 編譯通過；完整測試因目前沙箱無法提供 Torch 載入所需記憶體而未完成，列為環境驗證限制。

---

## 2026-08-24 雙 Agent Worktree 協作架構

### 目標與驗收條件

- 同一 Repository 內共用程式、測試、文件、驗證腳本與 CI；Codex 與 Antigravity 使用獨立工作區與專案指引。
- `00_home` 提供可預覽、可重複執行且不覆寫既有目標的 Worktree 建立工具。
- 先在 `10_Smart-Photo-Organizer` 套用並驗證，不一次重構所有專案。

### 已確認決策

- 全域 Skill 部署保持既有 `sync_codex.ps1` 行為；`skills-manifest.json` 僅新增專案層能力／路徑映射，不強制同步專案 Prompt 或 `SKILL.md`。
- 專案層 Codex 指引放 `.agents/AGENTS.md`，Antigravity 指引放 `.gemini/AGENTS.md`；可執行驗證只維護在 `scripts/`。
- Worktree 固定命名為 `<原專案>-codex` 與 `<原專案>-ag`，分支固定為 `codex/dev` 與 `ag/dev`。

### 工作清單

- [x] 新增共用規則、能力映射與 `New-AgentWorktree.ps1`｜PowerShell Parser、JSON 解析、`-WhatIf` 保護條件驗證。
- [x] Smart-Photo-Organizer 套用 QA 腳本、分離 Agent 指引與 Linux CI｜腳本 Parser、敏感資料掃描與 Git 差異檢查通過。
- [ ] 於乾淨的 main 執行實際 Worktree 建立｜本次架構檔尚未提交，工具正確阻擋髒工作區。
- [ ] 在具備完整 Tkinter 的 Python 3.13 環境執行完整測試與推送後檢查 GitHub Actions｜目前可攜式 Python 缺少 `tkinter`，數個 UI 相關測試模組無法載入。

### 驗證紀錄

- `sync_codex.ps1 -CheckOnly`：既有全域 Skill 與 Agent 設定皆為 `Current`。
- `security-check.ps1`：包含未追蹤檔案的掃描通過。
- `git-verify.ps1`：通過 `git diff --check`；如預期列出本次尚未提交檔案。
- `test.ps1`：可攜式 Python 已執行大部分單元測試；依賴 `main.py` 的測試因 `ModuleNotFoundError: tkinter` 未完成。

---

## 2026-08-24 技術架構文件同步

### 目標與驗收條件

- 12 個專案 README 與 CHANGELOG 都記錄實際主力技術、已完成遷移及未實作的技術邊界。
- 修正 `06_System-Optimizer-Tool` 對 0.30 MB Framework-dependent 發行模式的說明。

### 工作清單

- [x] 盤點各專案現行語言、框架與舊版隔離目錄。
- [x] 更新 12 個 README 與 CHANGELOG 的技術架構條目。
- [x] 以 README／CHANGELOG 標記搜尋與 `git diff --check` 檢核文件異動。

### 驗證紀錄

- README 技術架構標記：12 個專案均已存在。
- CHANGELOG 未發布條目：12 個專案均已存在。
- `06` 的發行腳本及專案設定均確認為 `--self-contained false`／`SelfContained=false`。

---

## 2026-08-28 跨裝置 Git 同步修復

### 目標與驗收條件

- 重新核對清單內所有 Repository 的本機分支、上游分支與 GitHub 最新提交。
- 保留公司與家中電腦產生的有效修改；遇到分歧時逐檔合併，禁止 force push。
- 同步腳本即使單一專案有髒工作區或分支分歧，也必須繼續檢查其餘專案並在結尾正確摘要。
- 完成適用測試、差異與敏感資料檢核後，才提交並推送需要整合的 Repository。

### 工作清單

- [x] 重新取得遠端分支並分類為同步、可快轉、本機超前或已分歧｜確認 04 分歧、06／07／09 遠端領先，其餘同步。
- [x] 快轉無衝突專案並下載清單內缺少的 Repository｜06、07 安全快轉；12 依 GitHub 預設 `master` 下載。
- [x] 合併 `04_Photo-Report-Generator` 與 `09_PaperSwitch` 的跨裝置修改｜04 保留雙方提交歷史；09 以 stash 保存點整合本機功能。
- [x] 修正 `sync_projects.ps1` 的遠端檢查、不中斷處理與結果摘要｜預覽會 fetch、分類前後差異、失敗重試一次並繼續其餘專案。
- [x] 執行專案測試及推送前檢核，提交並一般推送至正確的 origin 分支｜00、04、09 一般推送成功；推送後 13 個清單專案均與 GitHub 同步。

### 安全邊界

- 不刪除舊版 `01_AG-Monitor-Forensics` 資料夾或其未追蹤模型檔。
- 不修改 remote、不重寫歷史、不使用 force push。
- 任何尚未完成或未通過驗證的本機程式修改，先建立可回復保存點再進行遠端整合。

### 驗證紀錄

- `04_Photo-Report-Generator`：內嵌 JavaScript 語法、資源重建、QA 與本機 Browser 實測通過；Undo／Redo、案件欄位復原／重做、專案與 PDF 入口正常，無 console error。
- `06_System-Optimizer-Tool`：Release 組態 10 項 .NET 測試通過。
- `07_auto-learning-bot`：Python 3.13 開發環境 40 項測試通過；可攜式 Python 因隔離模式不作為開發測試入口。
- `09_PaperSwitch`：Release 建置 0 警告、0 錯誤，26 項 .NET 測試通過。
- `sync_projects.ps1`：PowerShell Parser 通過；實際預覽遇到 GitHub 暫時 DNS 失敗時仍繼續掃描至第 13 個專案，已加一次短暫重試。

---

## 2026-08-28 GitHub 基準化與舊專案清理

### 目標與驗收條件

- 以各 Repository 的 GitHub 預設／追蹤分支為共同基準，重新取得所有遠端提交。
- 本機未發布內容逐案判斷：有效修改經測試後合併推送；快取、建置產物或過時副本不納入版本庫。
- 移除已由 `01_AG-MONITOR-Smart-Video-Screening` 取代的舊本機資料夾 `01_AG-Monitor-Forensics`。
- 最終中央清單內所有專案工作區乾淨，且 HEAD 與各自上游分支一致。

### 工作清單

- [x] 盤點中央清單與額外本機 Repository 的分支、origin、遠端差異及未提交檔案｜13 個中央專案無未發布程式；另發現舊 01、09 stash 與 10 的兩個已合併本機分支。
- [x] 合併或排除所有本機未發布內容，執行各專案適用驗證｜09 有效待辦併入正式計畫並推送；重複模型、stash 與 10 已合併分支已移除。
- [ ] 核對新舊 01 的追蹤內容後，以可回收方式移除舊本機專案｜新舊 HEAD 與 tree 完全相同；舊目錄已部分清除，但 Real-ESRGAN ACL 需使用者在電腦前核准 UAC 後才能完成。
- [x] 一般提交與推送需要發布的修改，禁止 force push｜09 文件已一般推送；未重寫歷史。
- [x] 執行全專案同步與最終乾淨度驗證｜中央清單 13 個 Repository 已執行 GitHub fetch／安全快轉；待 00 本紀錄推送後再做最終預覽。

### 安全邊界

- 不變更 GitHub remote URL、不重寫遠端歷史、不使用 force push。
- 刪除舊 01 前，確認解析後路徑精確位於 `D:\Development\GitHub\01_AG-Monitor-Forensics`，不得以萬用字元操作。
- 模型、快取、執行產物與使用者資料不因同步而上傳 GitHub。

### 驗證紀錄

- 舊、新 01 均為提交 `aa38553a380eb771173e89b84f37992119d58edb`，tree 均為 `14155bb136a36b7bb6842da01d65f2935304e170`。
- 舊 01 額外約 57.2 MB 為可重新下載的 YOLO／Real-ESRGAN 模型、執行檔與範例媒體，未上傳 GitHub。
- `10_Smart-Photo-Organizer` 的 `ag/dev`、`codex/dev` 均為 `main` 祖先且無獨立提交，已安全刪除本機分支。
- `09_PaperSwitch` stash 的有效待辦已合併至 `docs/plan.md` 並推送；重複 `CanvasHistoryState` 已由有測試的 `ArrangementSnapshot` 取代，stash 已移除。

### 剩餘問題

- `D:\Development\GitHub\01_AG-Monitor-Forensics\models\realesrgan` 拒絕一般帳號存取；需在電腦前接受 UAC，才能由系統管理員 PowerShell 接管該精確舊路徑並永久刪除。
