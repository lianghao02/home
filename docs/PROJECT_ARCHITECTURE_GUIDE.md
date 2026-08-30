# 工作區全專案架構現況、選型演進與資料夾配置規範

> **核心準則**：模板是新建專案或重大重構的預設起點；既有可運作專案只在效益可量測、引用已更新、測試通過且回退方案存在時，才漸進調整。

## 全 12 專案架構現況與演進矩陣

| 專案 | 現行技術棧 | 狀態與後續策略 | 優先級 | 工程邊界 |
|---|---|---|---|---|
| `00_home` | PowerShell／Batch／靜態入口 | 維持現狀 | — | 維護雙 Agent 設定同步、批次推送與全域 Skills 唯一來源。 |
| `01_AG-MONITOR-Smart-Video-Screening` | Python 3.13／PyAV／YOLO11／12／OpenCV | 維持 Python 主架構 | 完整 CPU 可攜 ZIP | 維護監視器解碼、智慧快篩與離線發行環境。 |
| `02_Cell-Tower-Map-Locator` | HTML／Leaflet／外部 CDN | 體驗優化 | P2 | 依賴本地化、無底圖的座標／扇形備援、標記叢集或 Canvas 圖層；底圖與地址搜尋仍需網路或合法離線圖資。 |
| `03_Police-Image-Toolkit` | C# 12／.NET 8／WPF | 效能與相容性強化 | P1 | 維持 C#／WPF 主力，不改回 Web/Tauri；驗證 HEIC/HEIF 與既有格式、批次效能及發行。RAW 須通過格式矩陣測試才承諾支援。 |
| `04_Photo-Report-Generator` | 純 Web SPA | 主重構已完成 | P2 | 維護所見即所得排版與 `docx.js` 匯出；僅在需要桌面檔案整合時選配 Tauri。 |
| `05_tw-formal-writing` | Markdown 規範／Python 腳本 | 維持現狀 | — | 維護公文格式知識庫、法規標準庫與解析工具。 |
| `06_System-Optimizer-Tool` | C# 12／.NET 8／WPF | 維持現狀 | — | 維護 0.30 MB Framework-dependent 單檔 Exe（目標電腦需 .NET 8 Desktop Runtime）、系統匣與 Win32 核心。 |
| `07_auto-learning-bot` | Python 3.13／Selenium／PySide6 | 維持現狀 | — | 維護 Selenium 自動化、題庫 SQLite 與驗證機制。 |
| `08_Financial-Data-Parser` | HTML／SheetJS／本地函式庫 | 串流防護與桌面化 | P1 | Web Streams 降低大型 CSV 峰值記憶體；ZIP/XLSX 以實測設定上限與失敗提示；金融欄位一律字串型態；Tauri 為選配。 |
| `09_PaperSwitch` | C# 12／.NET 8／WPF | 重構升級完成 (v4.0.0) | — | 具備 .NET 8 原生單檔、WinRT 超高清 PDF 縮圖、STA 執行緒 Office COM 隔離轉檔與向量無損裝訂。 |
| `10_Smart-Photo-Organizer` | Python 3.13／pywebview／Pillow／SQLite | 基準測試與局部加速 | P1 | 先建立 Benchmark；僅在證實 dHash 或 ZIP 串流是瓶頸時，以 Rust/Rayon、PyO3 等實作局部核心。 |
| `11_Calendar-Card-App` | HTML／ES Modules／Google Apps Script | 儲存防禦與本機體驗 | P2 | 新增 `RUN.bat` 啟動本機伺服器；IndexedDB 必須有配額估算、例外處理與資料匯出備份。 |

## 資料夾模板（預設起點）

### 純 Web 前端

適用於 `02`、`04`、`08`、`11`：保留 `index.html`、`css/`、`js/` 與選用的 `js/libs/`、`worker.js`；重大桌面化才新增 `src-tauri/`。`RUN.bat` 僅在需要本機伺服器時提供。`docs/` 與 `scripts/` 只在確有文件或維護腳本時建立。

### C#／.NET 專案

適用於 `03`、`06`、`09`：以 `.sln`、`src/`、`tests/`、`scripts/` 與 gitignored 的 `publish/` 為目標結構。WPF 預設採一般 .NET 發行；Native AOT 必須先完成相容性驗證。既有 `legacy_web/`、`legacy-python/` 等語意清楚的目錄不強制改名。

### Python 原生／AI 應用

適用於 `01`、`07`、`10`：入口可維持 `main.py` 或 `app.py`；依需要使用 `src/`、`tests/`、`docs/`、`scripts/`、`python_embed/`、`requirements.txt` 與可選但推薦的 `pyproject.toml`。`RUN.bat` 是終端除錯入口。

## 工程落地邊界與防禦準則

1. **Tauri 體積與離線部署**：約 3–5 MB 是不含大型前端資產、離線圖資、模型與資料檔的基礎體積，且以前置存在 WebView2 Runtime 為前提。無網、未預裝環境須另計約 127 MB 以上的離線安裝包或約 180 MB 的 Fixed Version Runtime。
2. **儲存與串流防禦**：IndexedDB 寫入須捕捉 `QuotaExceededError`、使用 `navigator.storage.estimate()`，並提供 JSON/ICS 匯出備份。串流可降低讀取峰值，但大檔解壓與多格式匯出仍要有檔案上限與失敗提示。
3. **遷移與命名**：不得為一致性強制重命名既有 `app.py` 或搬動語意明確的歷史資料夾。CI 與自動化以 ASCII 檔名（如 `RUN.bat`、`build.ps1`）為主要入口；Emoji 檔名只作使用者捷徑。
4. **實際落地**：僅在某專案確實啟動新功能或重大重構時，才將本規範的對應模板寫入該專案工作清單或架構文件，並以可量測效益、測試與回退方案作為驗收條件。
