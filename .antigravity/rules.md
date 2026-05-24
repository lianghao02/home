# 專案特定細則：個人作品集首頁 (Projects Portal Rules)

> [!IMPORTANT]
> 本專案嚴格遵循「全域大腦 v2.1.0 (Tech Lead)」。作為展示所有開發成果的門面，美學與效能是首要考量。溝通與註解請 100% 使用台灣繁體中文，並保持專業的 Tech Lead 口吻。

## 1. 核心開發準則 (Technical Standards)
- **單檔維護 (Single File Portal)**：首頁必須維持在 `index.html` 內獨立運作，CSS 與 JavaScript 內聯或使用 CDN，確保載入速度極大化與部署的極度簡便。
- **純粹原生 (Vanilla Mastery)**：嚴禁在此 Landing Page 引入 React/Vue 等繁重的框架。必須使用乾淨的原生 HTML/CSS/JS 來達成所有動態效果。

## 2. 視覺與極致美學 (Aesthetics & Design System)
作為技術火力的展示櫥窗，介面必須體現極致美學：
- **動態背景與深度**：善用 CSS 粒子動畫 (Particle Canvas)、漸層光暈 (Gradient Orbs) 與模糊背景 (Backdrop-filter)，營造科技感與空間深度。
- **卡片式設計 (Card Layout)**：
  - 各專案展示必須採用卡片設計，並支援精緻的 Hover 浮動效果與邊框發光 (Border Glow)。
  - 每張卡片必須分配專屬的主題色 (Accent Color)，並透過 CSS 變數動態套用至卡片的圖示與發光效果。
- **響應式排版 (Responsive Design)**：使用 CSS Grid，確保在桌面版 (3 欄)、平板 (2 欄) 與手機版 (1 欄) 皆有完美的版面比例。

## 3. 專案擴充規範 (Scaling Rules)
當有新專案需要加入清單時，必須：
1. 建立對應的 `<a class="project-card accent-X">`。
2. 填寫統一的標題、版本號 Badge、簡短描述與三個 Tag 標籤。
3. 確保 `href` 正確指向 GitHub Pages 網址。

## 4. 效能與可及性 (Performance & Accessibility)
- **動畫優化**：所有過渡動畫 (Transitions) 必須綁定在 `opacity` 與 `transform` 屬性上，避免觸發瀏覽器重排 (Reflow)。
- **SEO 與 Meta**：必須完整設定 Open Graph 標籤與 `description`，確保網頁分享至通訊軟體時具備高質感的預覽畫面。
