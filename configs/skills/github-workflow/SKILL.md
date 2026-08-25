---
name: github-workflow
description: 處理 GitHub 搜尋、外部程式碼引用、upstream/origin 同步、PR、Release 與 CI 問題。使用於明確的 GitHub、遠端同步、PR、Release、Actions 或外部 Repository 研究；一般本機 Git 操作不必啟用。
---

# GitHub 工作流程

## 外部 Repository 與程式碼引用

- 研究外部專案時，優先確認近期維護、授權、文件與實際相容性；不只以星數判斷。
- 借鑑程式碼時，記錄來源 URL、固定 commit 或版本、擷取日期與本地修改摘要。
- 核心技術決策在專案有 `MEMORY.md` 時記錄原因與來源。

## 上游同步

1. 先確認 `origin`、`upstream`、目前分支與工作目錄是否乾淨。
2. 有未提交變更時，不直接 pull、merge 或 rebase；先回報狀態。
3. 同步前先 `fetch`，檢視差異與衝突風險；衝突時分析雙方意圖，不盲目採用 `ours` 或 `theirs`。
4. commit、push、遠端設定、PR 建立與 Release 均須使用者當次明確同意。

## CI、Release 與 PR

- 先讀專案既有 GitHub Actions、`CHANGELOG.md`、發布流程與 CI 結果；優先修正既有設定。
- 只有使用者或專案明確需要時，才新增 CI 或 Release 工作流程；先說明權限、第三方 Action 與部署影響。
- 不將任何特定第三方 Action、Python／Node 版本或 Release YAML 視為全域預設範本。
- PR 回報需包含變更範圍、驗證結果、已知限制與 CI 狀態。
