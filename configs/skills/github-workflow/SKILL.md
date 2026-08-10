---
name: github-workflow
description: >
  GitHub 整合作業規範。涵蓋：動態搜尋 GitHub Repository、
  外部程式碼引用標記、upstream/origin 同步與衝突處理、
  PR / Release 工作流程、GitHub Actions CI 骨架與 CHANGELOG 發布。
  觸發情境：GitHub 搜尋、版本控制、同步上游、PR、Release CI/CD、外部 repo 研究。
---

# 🔧 GitHub 整合作業規範 (GitHub Workflow Skill)

> **觸發情境**：GitHub 搜尋、版本控制、upstream 同步、PR、Release 發布、外部 Repository 研究。

---

## 1. 動態搜尋策略 (Reference Search)

當需要參考 GitHub 上開源專案或設計模式時，主動進行搜尋與評估：

- **搜尋時間區間**：依查詢當日動態採最近 6～12 個月內有更新（`pushed:>YYYY-MM-DD`）的專案。
- **評估標準**：優先選擇近期有 commit/release、Issue/PR 討論活躍且具備足夠社群採用度的專案。Stars 門檻視領域彈性調整（作為排序參考訊號，而非唯一門檻）。
- **引用標註格式**（附於程式碼頂部或專案文件）：
  ```markdown
  來源：[專案名稱](https://github.com/...) ⭐<星數>
  借鏡模式：<具體設計模式或架構概念>
  擷取日期：YYYY-MM-DD
  ```

---

## 2. 外部程式碼引用 (Pull & Patch)

從 GitHub 複製或借鑑程式碼片段時，遵循以下步驟：

1. **檔案頂部標註**：
   ```python
   # ============================================================
   # 來源：https://github.com/<owner>/<repo>/blob/<commit>/path/to/file
   # 擷取日期：YYYY-MM-DD
   # 本地修改摘要：<繁體中文說明本地做了哪些改動>
   # ============================================================
   ```

2. **技術決策記錄**：若異動涉及核心邏輯，於專案 `MEMORY.md`（若存在）記錄來源、目的與改動說明。

---

## 3. 上游專案同步 (Upstream Sync Protocol)

採用 `upstream` / `origin` 雙遠端標準模型：

```bash
# 1. 設定上游遠端
git remote add upstream <來源倉庫 URL>

# 2. 拉取上游變更
git fetch upstream

# 3. 合併或 Rebase (遵循 Conventional Commits 小寫格式)
git merge upstream/main --no-ff -m "sync: 同步上游變更"
# 或
git rebase upstream/main
```

**衝突處理原則**：
- 衝突時先分析雙方修改目的，禁止盲目直接使用 `ours` 或 `theirs`。
- 以「完整保留本地客製功能，並順利整合上游必要修補與安全更新」為原則進行手動解衝突。

---

## 4. GitHub Actions CI 骨架

**Python 專案**：
```yaml
# .github/workflows/ci.yml
name: CI 自動化測試

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - name: 安裝依賴套件
        run: pip install -r requirements.txt
      - name: 執行單元測試
        run: pytest --tb=short -v
```

**Node.js 專案**（僅在有測試腳本時新增測試步驟）：
```yaml
# .github/workflows/ci.yml
name: CI 自動化測試

on: [push, pull_request]

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - run: npm ci
      - run: npm run build
      - name: 執行測試
        run: npm test
```

---

## 5. GitHub Release 自動發布

當推送版本標籤（`v*.*.*`）時，從既有 `CHANGELOG.md` 擷取對應版本說明並建立 GitHub Release：

```yaml
# .github/workflows/release.yml
name: 自動發布 Release

on:
  push:
    tags:
      - 'v*.*.*'

jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - name: 擷取 CHANGELOG 對應版本內容
        id: changelog
        run: |
          python3 - <<'PYEOF'
          import os, re
          version = os.environ.get('GITHUB_REF_NAME', '')
          content = open('CHANGELOG.md', encoding='utf-8').read()
          pattern = rf'(## 🏆 {re.escape(version)}.*?)(?=^## 🏆 v|\Z)'
          match = re.search(pattern, content, re.DOTALL | re.MULTILINE)
          notes = match.group(1).strip() if match else f'版本 {version} 更新'
          with open(os.environ['GITHUB_OUTPUT'], 'a', encoding='utf-8') as f:
              f.write(f'notes<<EOF\n{notes}\nEOF\n')
          PYEOF
        env:
          GITHUB_REF_NAME: ${{ github.ref_name }}
      - uses: softprops/action-gh-release@v2
        with:
          body: ${{ steps.changelog.outputs.notes }}
          draft: false
          prerelease: false
```
