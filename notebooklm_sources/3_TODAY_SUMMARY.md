# 📋 專案實務架構與當前維護摘要

本文件彙整所有 11 個專案的最新實務狀態與技術架構，無學術符號與無效教條，便於在 NotebookLM 中進行實務導向的對話與評估。

---

## 專案作品集清單與狀態

### 1. 手機門號定位 (Cell-Tower-Map-Locator)
- **架構模式**：純前端 Web HTML5 + Leaflet.js 地圖庫 + Vanilla CSS。
- **線上網址**：https://lianghao02.github.io/Cell-Tower-Map-Locator/
- **關鍵功能**：電信基站文字解析、座標擷取、角度扇形繪製、台灣座標界線驗證。
- **實務優勢**：資料完全不上傳雲端，保障高敏感度個資安全。

### 2. 警務影像格式轉換工具 (Police-Image-Toolkit)
- **架構模式**：純前端 Web HTML5 + Canvas + JSZip + HEIC2any。
- **線上網址**：https://lianghao02.github.io/Police-Image-Toolkit/
- **關鍵功能**：HEIC/PNG/WebP 轉 JPG、長截圖依公分重疊自動切片、3x3 卷積核影像銳化。
- **實務優勢**：針對公務報表系統格式限制優化，免安裝任何軟體即可使用。

### 3. CSV to Excel 轉檔工具 (Financial-Data-Parser)
- **架構模式**：純前端 Web HTML5 + SheetJS (xlsx.full.min.js) + Tailwind CDN。
- **線上網址**：https://lianghao02.github.io/Financial-Data-Parser/
- **關鍵功能**：金融帳號前導零保護 (t: 's')、金額 Regex 符號清理、多檔 Zip 堆疊合併。
- **實務優勢**：解決 Excel 預設開啟 CSV 導致帳號前導零消失與中文亂碼問題。

### 4. 現況照片清冊生成工具 (Photo-Report-Generator)
- **架構模式**：Web 展示 Landing Page + Excel VBA 巨集工具 (.xlsm)。
- **線上網址**：https://lianghao02.github.io/Photo-Report-Generator/
- **關鍵功能**：批次匯入現場蒐證照片、自動調整比例並依公務格式填入 Word/Excel 報表。
- **實務優勢**：將過去耗時數小時的手動照片排版縮短至數秒鐘完成。

### 5. 排班表與卡片小卡 (Calendar-Card-App)
- **架構模式**：Web HTML5 + Google Sheets API + Rate Limiting 流量防護。
- **線上網址**：https://lianghao02.github.io/Calendar-Card-App/
- **關鍵功能**：試算表排班資料視覺化、個人班表小卡匯出、API 金鑰 Token 驗證保護。
- **實務優勢**：讓同仁能用手機隨時清晰查閱個人班表。

### 6. 智慧照片整理工具 (Smart-Photo-Organizer)
- **架構模式**：Python 3.11 + EXIF 中繼資料解析 + MD5/SHA256 雜湊去重。
- **儲存庫路徑**：`C:\Users\chia-hao\Documents\GitHub\Smart-Photo-Organizer`
- **關鍵功能**：依拍攝日期與地點自動分類資料夾、重複相片自動比對與預覽清單產出。
- **實務優勢**：解決大量搜證相片與手機備份檔名混亂問題。

### 7. 檔案整理大師 (System-Optimizer-Tool)
- **架構模式**：Python 3.11 + OS 檔案系統 API。
- **儲存庫路徑**：`C:\Users\chia-hao\Documents\GitHub\System-Optimizer-Tool`
- **關鍵功能**：批量檔名自然排序重命名、系統暫存檔案清理、目錄防無窮迴圈安全控制。
- **實務優勢**：提昇本機檔案維護效率與硬碟空間回收。

### 8. AG-MONITOR 科技偵查工作站 (AG-Monitor-Forensics)
- **架構模式**：Python 3.11 + PyAV 零拷貝解碼 + YOLOv8 + ByteTrack + Eel (HTML/WebSocket UI)。
- **儲存庫路徑**：`C:\Users\chia-hao\Documents\GitHub\AG-Monitor-Forensics`
- **關鍵功能**：非標準監視器裸流 (.dav/.264/.avi) 無損播放、人車目標辨識追蹤、智慧空景快轉、鑑識日誌自動寫入。
- **實務優勢**：警務鑑識實戰利器，免長時間人工盯看監視器。

### 9. 體感切水果 (Fruit-Ninja-Motion)
- **架構模式**：Python 3.11 + OpenCV 影像處理 + 視覺軌跡辨識。
- **儲存庫路徑**：`C:\Users\chia-hao\Documents\GitHub\Fruit-Ninja-Motion`
- **關鍵功能**：視訊鏡頭動態追蹤、免手持體感遊戲互動。

### 10. 行政效能領航員 (auto-learning-bot)
- **架構模式**：Python 3.11 + PySide6 / Selenium + SQLite 本地題庫。
- **儲存庫路徑**：`C:\Users\chia-hao\Documents\GitHub\auto-learning-bot`
- **關鍵功能**：臺北E大 / eCPA / 我的E政府平台自動化研習、題庫自動作答、AI 缺題補答、問卷自動填寫。

### 11. 專案作品集門戶 (home)
- **架構模式**：純前端 Web HTML5 + CSS3 + FontAwesome + RWD 響應式排版。
- **線上網址**：https://lianghao02.github.io/
- **關鍵功能**：整合所有 11 個專案的科技感展示卡片、快速跳轉連結與說明。
