---
name: addyosmani-perf
description: Google 前端主管 Addy Osmani 的 Agent Skills 精華。補充網頁效能指標（Core Web Vitals、LCP、CLS、INP）的量測與優化流程，適用於所有需要提升頁面速度與使用者體驗評分的專案。
---

# Addy Osmani 前端效能優化 Skill

> 來源：[addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) ⭐ Google 前端主管出品

## 核心效能指標（Core Web Vitals 2024）

| 指標 | 全名 | 目標值 | 說明 |
|:---|:---|:---|:---|
| **LCP** | Largest Contentful Paint | ≤ 2.5s | 最大內容元素載入時間 |
| **CLS** | Cumulative Layout Shift | ≤ 0.1 | 版面累積位移分數 |
| **INP** | Interaction to Next Paint | ≤ 200ms | 互動到下一次繪製延遲（取代 FID） |
| **FCP** | First Contentful Paint | ≤ 1.8s | 首次有內容繪製時間 |
| **TTFB** | Time to First Byte | ≤ 800ms | 伺服器首次回應時間 |

## 效能量測流程

### 1. Lighthouse CI 整合

```bash
# 安裝 Lighthouse CI
npm install -g @lhci/cli

# 執行效能審計
lhci autorun --upload.target=temporary-public-storage

# 自訂設定（lhci-config.json）
{
  "ci": {
    "assert": {
      "assertions": {
        "categories:performance": ["warn", {"minScore": 0.9}],
        "first-contentful-paint": ["error", {"maxNumericValue": 1800}],
        "largest-contentful-paint": ["error", {"maxNumericValue": 2500}],
        "cumulative-layout-shift": ["error", {"maxNumericValue": 0.1}]
      }
    }
  }
}
```

### 2. 常見效能問題與修法

| 問題 | 診斷方式 | 修法 |
|:---|:---|:---|
| **圖片未優化** | LCP > 2.5s | 改用 WebP/AVIF，加 `loading="lazy"` |
| **版面位移** | CLS > 0.1 | 圖片加寬高屬性，字型加 `font-display: swap` |
| **阻塞渲染的 JS** | FCP > 1.8s | `defer` / `async` 屬性，或移至 `</body>` |
| **未壓縮資源** | TTFB > 800ms | 開啟 Gzip/Brotli 壓縮 |
| **過多第三方腳本** | INP > 200ms | 審計並移除非必要第三方腳本 |

### 3. 程式碼層級優化清單

```javascript
// ✅ 圖片懶加載
<img loading="lazy" src="photo.jpg" width="400" height="300" alt="說明">

// ✅ 字型預載
<link rel="preload" href="inter.woff2" as="font" type="font/woff2" crossorigin>

// ✅ 關鍵 CSS 內嵌
<style>/* 首屏必要樣式直接內嵌 */</style>

// ✅ 非同步載入非關鍵 JS
<script defer src="analytics.js"></script>

// ✅ 圖片格式現代化（使用 <picture> 提供多格式選擇）
<picture>
  <source srcset="image.avif" type="image/avif">
  <source srcset="image.webp" type="image/webp">
  <img src="image.jpg" alt="說明">
</picture>
```

### 4. 效能預算（Performance Budget）設定

```json
{
  "resourceSizes": [
    { "resourceType": "total", "budget": 500 },
    { "resourceType": "script", "budget": 150 },
    { "resourceType": "image", "budget": 200 },
    { "resourceType": "font", "budget": 50 }
  ]
}
```

## 程式碼審查清單（Code Review Checklist）

交付前必須確認：

- [ ] LCP 元素是否有 `fetchpriority="high"` 屬性
- [ ] 所有圖片是否有明確 `width` 和 `height`（防止 CLS）
- [ ] Web Fonts 是否使用 `font-display: swap`
- [ ] 是否移除未使用的 CSS（PurgeCSS 或 tree-shaking）
- [ ] JavaScript bundle 是否有 code splitting
- [ ] 是否有 Service Worker 快取靜態資源

## 與全域憲法 v7.1 整合說明

- **§3.3 現代化 UI/UX 審美底線**：效能是使用者體驗的一部分，此 Skill 補齊效能量化標準。
- **§6.1 驗證先行**：Lighthouse CI 應整合至 §6.4 的 CI/CD 骨架中，作為 PR 合入的自動化門檻。
