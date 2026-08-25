# 跨專案決策記憶

本檔只保存需要隨 `00_home` Git Repository 跨電腦同步的長期技術決策；各專案的實作細節、Bug 與工作紀錄仍應保存於各自的 `MEMORY.md`、架構文件或工作清單。

## 學習歷史

- **2026-08-25｜全專案架構演進與資料夾配置規範確立**：建立 12 個專案的選型矩陣、漸進調整原則與三類資料夾模板。完整規範見 [`docs/PROJECT_ARCHITECTURE_GUIDE.md`](docs/PROJECT_ARCHITECTURE_GUIDE.md)。既有專案不進行全面搬移，只在效益可量測、引用已更新、測試通過且具回退方案時調整。
- **2026-08-25｜發行與離線邊界收斂**：Tauri 的低體積以既有 WebView2 Runtime 為前提；無網且未預裝的環境必須將 WebView2 離線安裝包納入發行體積。`06_System-Optimizer-Tool` 的 0.30 MB 單檔採 Framework-dependent 發行，目標電腦需 .NET 8 Desktop Runtime。
- **2026-08-25｜優先順序確認**：`03`、`04`、`06` 維持既有主力架構；`08` 先做 CSV 串流與輸出記憶體防禦；`10` 先建立效能基準，再考慮 Rust 局部核心；`11` 補足本機伺服器與儲存防禦。
