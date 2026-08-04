---
name: accesslint
description: 自動化無障礙 (a11y) 掃描工具。針對 WCAG 2.1 / 2.2 標準驗證 HTML 頁面，適用於公務系統、警政工具、政府網頁等有公部門合規要求的場景。
---

# AccessLint — 無障礙規範自動化掃描

## 核心能力

- `accesslint:scan`：掃描整個頁面或 HTML 片段，對照 WCAG 2.1 / 2.2 指引找出違規項目。
- `accesslint:diff`：與基準版本比對，僅回報**新增**或**已修復**的違規，適合 CI 整合。

## WCAG 主要檢查項目

| 分類 | 具體檢查項目 |
|:---|:---|
| **對比度** | 文字與背景色彩對比度 ≥ 4.5:1（正文）/ 3:1（大文字） |
| **語意 HTML** | 標題層級（`<h1>` → `<h6>`）是否正確、語意標籤是否適當 |
| **表單標籤** | 每個 `<input>` 是否有對應的 `<label>` 或 `aria-label` |
| **圖片替代文字** | `<img>` 是否有有意義的 `alt` 屬性 |
| **鍵盤可及性** | 所有互動元素是否可用 Tab 鍵操作與觸發 |
| **焦點管理** | 焦點指示器是否清晰可見（`:focus` 樣式） |
| **ARIA 使用** | `aria-*` 屬性是否正確使用，無多餘或衝突的角色宣告 |

## 掃描方式（整合 axe-core）

```python
# 使用 Playwright + axe-core 掃描無障礙問題
from playwright.sync_api import sync_playwright

def scan_accessibility(url: str) -> dict:
    """
    掃描指定 URL 的 WCAG 無障礙問題。
    
    Args:
        url: 目標頁面網址（本機 http://localhost 或線上）
    
    Returns:
        包含違規項目清單的字典
    """
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page()
        page.goto(url)
        page.wait_for_load_state("networkidle")

        # 注入 axe-core 掃描引擎
        page.add_script_tag(url="https://cdn.jsdelivr.net/npm/axe-core/axe.min.js")

        # 執行掃描
        results = page.evaluate("""
            async () => {
                const results = await axe.run();
                return {
                    violations: results.violations.map(v => ({
                        id: v.id,
                        impact: v.impact,
                        description: v.description,
                        helpUrl: v.helpUrl,
                        nodes: v.nodes.length
                    })),
                    passes: results.passes.length
                };
            }
        """)

        browser.close()
        return results
```

## 輸出格式（標準違規回報）

```
🔍 無障礙掃描報告
==================
❌ 嚴重 (critical): color-contrast — 3 個元素對比度不足
  → 詳細說明：https://dequeuniversity.com/rules/axe/4.x/color-contrast
❌ 重大 (serious): label — 2 個表單欄位缺少標籤
  → 詳細說明：https://dequeuniversity.com/rules/axe/4.x/label
⚠️ 中等 (moderate): heading-order — 標題層級跳躍

✅ 通過檢查：47 項規則
```

## 與全域憲法 v7.1 整合說明

- **§3.3 現代化 UI/UX 審美底線**：增補無障礙合規層，是公部門場景的隱性要求。
- **§6.1 驗證先行**：掃描應在部署前的 CI/CD 流程中自動執行。
- **安裝依賴**：`pip install playwright && playwright install chromium`
