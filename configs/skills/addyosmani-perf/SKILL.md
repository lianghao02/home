---
name: addyosmani-perf
description: Google 前端主管 Addy Osmani 的 Agent Skills 精華。補充網頁效能指標（Core Web Vitals、LCP、CLS、INP）的量測與優化流程。適用於 Web 前端效能量測與體驗評分提升。
---

# Addy Osmani 前端效能優化 Skill

> 來源：[addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) ⭐ Google 前端主管出品

## 核心效能指標（Core Web Vitals 2024）

| 指標 | 全名 | 目標值 | 說明 |
|:---|:---|:---|:---|
| **LCP** | Largest Contentful Paint | ≤ 2.5s | 最大內容元素載入時間 |
| **CLS** | Cumulative Layout Shift | ≤ 0.1 | 版面累積位移分數 |
| **INP** | Interaction to Next Paint | ≤ 200ms | 互動到下一次繪製延遲 |
| **FCP** | First Contentful Paint | ≤ 1.8s | 首次有內容繪製時間 |
| **TTFB** | Time to First Byte | ≤ 800ms | 伺服器首次回應時間 |

---

## 效能量測與實作準則

⚠️ **架構適當原則**：依專案實際架構（如單檔 HTML、SPA 框架或多頁面 Web）按需採納相關優化技術。不為了符合清單而強制引入與專案需求無關的套件、Service Worker 或複雜建置工具。

### 1. 常見效能問題與建議作法

| 問題 | 診斷方式 | 修法與處理方式 |
|:---|:---|:---|
| **圖片未優化** | LCP > 2.5s | 改用 WebP/AVIF，非首屏圖片加 `loading="lazy"` |
| **版面位移** | CLS > 0.1 | 圖片與容器設定明確寬高/比例，關鍵字型加 `font-display: swap` |
| **阻塞渲染的 JS** | FCP > 1.8s | 腳本使用 `defer` / `async` 屬性或置於底部 |
| **未壓縮資源** | TTFB > 800ms | 開啟伺服器端 Gzip/Brotli 壓縮（若有後端） |
| **過多第三方腳本** | INP > 200ms | 審計並延遲/移除非必要第三方腳本 |

### 2. 程式碼層級優化範例

```html
<!-- ✅ 圖片延遲載入與明確尺寸 -->
<img loading="lazy" src="photo.jpg" width="400" height="300" alt="說明">

<!-- ✅ 關鍵樣式內嵌（適合單 HTML 頁面） -->
<style>/* 首屏必要樣式直接內嵌 */</style>

<!-- ✅ 非同步載入非關鍵 JS -->
<script defer src="app.js"></script>

<!-- ✅ 現代化圖片格式 -->
<picture>
  <source srcset="image.avif" type="image/avif">
  <source srcset="image.webp" type="image/webp">
  <img src="image.jpg" width="800" height="600" alt="說明">
</picture>
```

---

## 程式碼審查檢查項（按專案需要選用）

進行 Web 效能審查時，按專案架構選擇適用項目：

- [ ] LCP 關鍵圖片/元素是否有優先載入機制
- [ ] 圖片與影音容器是否具備明確寬高屬性（防 CLS）
- [ ] 系統字型或 Web Fonts 是否具備適當渲染策略
- [ ] 是否清理未使用的 CSS 與冗餘 JavaScript
- [ ] 大型單頁應用或框架專案是否進行 Bundle 拆分（Code Splitting）
