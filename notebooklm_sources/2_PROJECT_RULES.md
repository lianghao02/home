# home 專案領域知識與開發規範

> [!IMPORTANT]
> **本專案受 全域開發憲法 v5.0 最高規範約束**
> 1. **預設啟用**：現代化 UI/UX 審美底線、驗證先行 (Verification First)。
> 2. **進階調度**：支援 NotebookLM 條件觸發與 Subagent (子代理) 背景分工機制。
> ---
> 以下為專屬本專案之業務領域知識與技術細則：

# Home (入口網站) 專案領域知識 (Local Rules)

## 1. 核心定位
* **作品集 Landing Page**：這是所有警務工具與轉換工具的導航樞紐（Hub）。
* **靜態為王**：本專案依賴 GitHub Pages 部署，**嚴禁**引入任何後端伺服器語言 (如 PHP/Node.js) 或複雜的狀態管理 (如 Redux)。

## 2. UI/UX 視覺要求
* **頂級美學標準**：此專案代表了您的門面，所有的按鈕、卡片、過渡動畫 (Transitions) 都必須採用最精緻的微互動 (Micro-interactions) 設計。
* **RWD 響應式佈局**：所有版面必須完美支援從 iPhone SE 到 4K 螢幕的流暢縮放。

## 3. 超連結管理
* **跨專案導航**：確保所有指向子專案（如 `/PoliceLocate`, `/CSV_to_Excel`）的連結皆使用相對路徑或正確的 GitHub Pages 根目錄設定。
