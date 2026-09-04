# 開發環境與 C 槽搬至 D 槽架構備忘錄

> 本機 GitHub 開發專案的實體資料位於 D 槽；C 槽舊路徑保留 NTFS Junction，供既有工具與腳本相容使用。

## 1. 路徑對照

- 實體路徑：`D:\Development\GitHub`
- 相容路徑：`C:\Users\chia-hao\Documents\GitHub`
- 連接類型：NTFS Junction（目錄連接點）

後續開啟 Codex 專案時，優先直接選擇 `D:\Development\GitHub`。程式碼不得寫死使用者目錄或磁碟機路徑，應依語言採用下列方式取得執行位置：

- Python：`Path(__file__).resolve().parent`
- PowerShell：`$PSScriptRoot`
- Batch：`%~dp0`
- VBA：`ThisWorkbook.Path`

## 2. Python 虛擬環境搬遷規範

`.venv` 可能包含建立當時的絕對路徑，不應將既有虛擬環境視為可直接搬移的成品。專案搬遷後應依 `requirements.txt`、`pyproject.toml` 或套件鎖定檔重新建立。

處理順序：

1. 確認系統 Python 可正常執行。
2. 確認專案具備完整依賴清單。
3. 在暫存名稱下建立新虛擬環境並安裝依賴。
4. 驗證新環境可啟動且必要套件可匯入。
5. 驗證成功後才替換失效環境；不得使用忽略錯誤的批次刪除。

啟動腳本若偵測到 `.venv` 失效，應清楚提示並停止，或在取得使用者確認後重建，不得只修改 `pyvenv.cfg` 後假設環境已修復。

## 3. 專案目錄

```text
D:\Development\GitHub\
├── 00_Dev-Control-Center/
├── 01_AG-MONITOR-Smart-Video-Screening/
├── 02_Cell-Tower-Map-Locator/
├── 03_Police-Image-Toolkit/
├── 04_Photo-Report-Generator/
├── 06_System-Optimizer-Tool/
├── 07_auto-learning-bot/
├── 08_Financial-Data-Parser/
├── 09_PaperSwitch/
├── 10_Smart-Photo-Organizer/
├── 11_Calendar-Card-App/
├── 12_ClipMask-AI/
└── 13_Project-Hub/
```

## 4. 2026-08-11 實測結果

- C 槽相容路徑類型：`Junction`
- Junction 目標：`D:\Development\GitHub`
- D 槽實體路徑：存在
- 12 個編號專案：全部存在，且各自包含 Git Repository
- `10_Smart-Photo-Organizer\.venv`：已依 `requirements.txt` 重新建立，核心依賴匯入成功；137 項測試通過、1 項略過
- 其餘編號專案：未發現根目錄 `.venv`

另有 `auto-learning-bot_Release` 發布成品資料夾，不列入 12 個原始碼 Repository。
