---
name: webapp-testing
description: Toolkit for interacting with and testing local web applications using Playwright. Use when verifying frontend functionality, debugging UI behavior, or capturing browser screenshots.
---

# Web Application Testing with Playwright

This skill provides a standardized workflow for AI coding agents to perform end-to-end (E2E) testing, frontend verification, and UI debugging on local web applications.

## Workflow & Capabilities

### 1. Server Management
- Use helper scripts (e.g., `scripts/with_server.py`) to handle local server lifecycles (frontend/backend).
- Ensure clean shutdown of processes after test runs.

### 2. Reconnaissance & Navigation
- Navigate to local `http://` or `file://` URLs.
- Wait for `networkidle` or specific DOM state before assertion.

### 3. Element Discovery
- Prefer resilient selectors (`data-testid`, accessible role/label).
- Avoid brittle CSS selectors that break on minor style changes.

### 4. Execution & Debugging
- Execute Playwright scripts to simulate user interactions (click, fill, hover, keyboard).
- Capture DOM snapshots, screenshots, and browser console logs for reporting.
- Log all `console.error` and uncaught exceptions automatically.

### 5. Assertion Standards
- Assert element presence, text content, URL state, and responsive breakpoints.
- Report all failures with exact selector, expected vs. actual values, and screenshot path.

## Usage Pattern

```python
# 標準 Playwright 驗證流程（台灣繁體中文標注版）
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch()
    page = browser.new_page()

    # 1. 導航至目標頁面
    page.goto("http://localhost:3000")
    page.wait_for_load_state("networkidle")

    # 2. 捕捉 Console 錯誤
    errors = []
    page.on("console", lambda msg: errors.append(msg.text) if msg.type == "error" else None)

    # 3. 驗證關鍵元素
    assert page.locator("[data-testid='submit-btn']").is_visible()

    # 4. 截圖留存
    page.screenshot(path="test_result.png")

    browser.close()

    # 5. 報告錯誤
    if errors:
        print(f"⚠️ Console 錯誤數量：{len(errors)}")
        for e in errors:
            print(f"  ❌ {e}")
```

## 與全域憲法 v7.1 整合說明

- **§6.1 驗證先行**：此 Skill 補齊「瀏覽器端」的驗證層，與憲法的「提交前必須跑驗證」原則完全吻合。
- **安裝依賴**：`pip install playwright && playwright install chromium`
- **DRY_RUN 相容**：測試腳本預設不修改任何資料，符合 §4.5 防禦性設計。
