---
name: document-to-markdown
description: 將本機 PDF、Word、Excel、PowerPoint、HTML、CSV、JSON、XML、圖片及其他支援格式轉成適合 AI 分析的 Markdown。適用於文字擷取、批次分析前處理與建立可搜尋語料；不適用於需要保留高擬真版面、正式編輯原始 Office 檔案或未經 OCR 的掃描文件。
---

# 文件轉 Markdown

使用 Microsoft MarkItDown 將異質文件轉成保留標題、清單、表格及連結結構的 Markdown，再交由 Codex 或 Antigravity 分析。

## 路由判斷

- 需要從文件擷取結構化文字供分析：使用本 Skill。
- 需要建立、修改或保留 Word、Excel、PowerPoint、PDF 版面：改用平台的格式專屬工具或 Skill。
- 掃描 PDF 或圖片沒有可擷取文字：先使用可信任的 OCR 流程，並標示辨識限制。
- 只處理單一純文字檔：直接讀取，不啟動轉換流程。

## 初次安裝

MarkItDown 尚未安裝時執行：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts\install.ps1
```

安裝程式會建立使用者層級的獨立虛擬環境，不修改專案 `.venv`。

## 轉換文件

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts\convert.ps1 `
  -InputPath "C:\path\report.pdf" `
  -OutputPath "C:\path\report.md"
```

省略 `OutputPath` 時，在來源檔旁建立同名 `.md`。既有輸出檔只有在明確傳入 `-Force` 時才覆寫。

## 安全與品質規則

- 僅接受已解析的本機檔案路徑，不把不受信任的 URL 直接交給轉換器。
- 使用處理程序目前權限讀取檔案；轉換敏感文件前確認存取範圍與輸出位置。
- 轉換後確認輸出非空，抽查標題、表格、清單與關鍵欄位。
- 不把文字擷取結果視為原始文件的視覺等價副本。
- 對掃描件、複雜表格、公式及內嵌圖片明確標示可能遺失的內容。
- 不自動啟用第三方 MarkItDown Plugin、雲端 OCR 或付費 Azure 服務。

## 建議工作流

```text
本機文件
→ MarkItDown 擷取
→ 檢查 Markdown 品質
→ AI 分析／欄位解析
→ 依需求輸出 Word、Excel、JSON 或摘要
```
