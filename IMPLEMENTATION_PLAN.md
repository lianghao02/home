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
