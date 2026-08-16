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
