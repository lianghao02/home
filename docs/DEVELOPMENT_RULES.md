# 共用開發規則

本文件是使用 Codex 與 Antigravity 協作時的共同工程契約；它不取代各 Repository 的 `AGENTS.md` 與產品規格。

## 共用範圍

- 正式程式、測試、`scripts/`、`docs/` 與 GitHub Actions 在同一個 Repository 中維護。
- Codex 指引放在 `.agents/`；Antigravity 指引放在 `.gemini/`。兩者不得互相複製或由同步工具覆寫。
- Agent 指引只說明角色與操作入口；可重複執行的驗證流程一律實作在 Repository 的 `scripts/`。
- `.venv`、`python_embed`、快取、登入狀態與未提交修改屬於工作區本機資料，不共用也不提交。

## Worktree 協作

主工作區只承載 `main`。需要平行開發時，由 `00_home/scripts/New-AgentWorktree.ps1` 建立相鄰工作區：

```text
Smart-Photo-Organizer/        main
Smart-Photo-Organizer-codex/  codex/dev
Smart-Photo-Organizer-ag/     ag/dev
```

- 不讓兩個 Agent 同時操作同一資料夾。
- Worktree 建立前，`main` 必須沒有未提交變更，且只允許 `pull --ff-only`。
- 開發完成後先執行共用 QA、提交，再由另一個 Agent 檢視分支差異。

## 共用驗證入口

在各 Repository 根目錄執行：

```powershell
.\scripts\test.ps1
.\scripts\security-check.ps1
.\scripts\git-verify.ps1
.\scripts\qa.ps1
```

`qa.ps1` 僅串接其他腳本，不包含 Office COM、登入瀏覽器、實體裝置或使用者資料操作。這類 Windows／本機專屬檢查保留在各專案的本機驗證文件。

## 提交與 CI

- 提交前必須通過適用的本機測試、`git diff --check` 與敏感字串檢查。
- GitHub Actions 只執行可於無頭 Linux 環境重現的檢查。
- Commit 格式採 `type: 台灣繁體中文簡述`；禁止 force push。
