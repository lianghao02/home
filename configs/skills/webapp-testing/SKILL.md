---
name: webapp-testing
description: 使用 Codex 內建 Browser 或專案既有 Playwright 設定，驗證本機網頁功能、除錯 UI 行為與擷取證據。適用於前端功能驗證、互動除錯、視覺檢查與交付前 Web 實測；不得為此臨時安裝 Python Playwright 或改動專案相依套件。
---

# 網頁應用程式測試

## 執行順序

1. 先讀取專案的測試與啟動設定；沿用既有 `package.json`、Playwright 設定、測試指令或本機伺服器。
2. 優先使用 Codex 內建 Browser 開啟 `http://localhost` 或安全的 `file://` 靜態頁面；等待可驗證的 DOM 狀態，不只依賴固定等待時間。
3. 專案已具備 Node.js Playwright 時，才執行它既有的測試指令。不得為單次驗證執行 `pip install playwright`、下載瀏覽器或新增測試框架。
4. 優先使用 `data-testid`、accessible role、label 選擇器；驗證主要流程、網址狀態、關鍵文字與錯誤訊息。
5. 記錄必要的截圖、console error、未捕捉例外與實際操作結果；測試資料不得影響正式資料。

## 回報

- 清楚標示通過、失敗或略過，以及實際測試情境。
- 失敗時提供可重現步驟、預期與實際結果、相關選擇器或畫面證據。
- 沒有可用伺服器、既有測試或 Browser 存取權限時，如實標示限制，不宣稱已完成 UI 驗證。
