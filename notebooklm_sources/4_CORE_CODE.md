# home 核心程式碼與 UI 結構封包

## 📄 檔案: index.html
``` html
<!DOCTYPE html>

<html lang="zh-TW">

<head>

    <meta charset="UTF-8">

    <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">

    <meta name="mobile-web-app-capable" content="yes">

    <meta name="description" content="LiangHao's Projects Portal - 探索我開發的 11 個實用 AI、警務與自動化專案。">

    <meta name="author" content="LiangHao (梁巡官)">

    <title>LiangHao's Projects | 專案作品集儀表板</title>



    <!-- Fonts -->

    <link rel="preconnect" href="https://fonts.googleapis.com">

    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=Noto+Sans+TC:wght@400;500;700;900&display=swap" rel="stylesheet">

    

    <!-- FontAwesome -->

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">



    <style>

        :root {

            --bg: #060b18;

            --surface: rgba(15, 23, 42, 0.75);

            --surface-card: rgba(15, 23, 42, 0.85);

            --border: rgba(148, 163, 184, 0.15);

            --border-glow: rgba(56, 189, 248, 0.4);

            --text: #f8fafc;

            --text-muted: #94a3b8;

            --accent: #38bdf8;

            --accent-purple: #818cf8;

            --radius-card: 1.25rem;

            --transition: 0.35s cubic-bezier(0.4, 0, 0.2, 1);

            --font: 'Inter', 'Noto Sans TC', sans-serif;

        }



        *, *::before, *::after {

            box-sizing: border-box;

            margin: 0;

            padding: 0;

        }



        body {

            background-color: var(--bg);

            color: var(--text);

            font-family: var(--font);

            min-height: 100vh;

            overflow-x: hidden;

            background-image: 

                radial-gradient(circle at 15% 15%, rgba(56, 189, 248, 0.08) 0%, transparent 40%),

                radial-gradient(circle at 85% 75%, rgba(129, 140, 248, 0.08) 0%, transparent 40%);

        }



        #particle-canvas {

            position: fixed;

            inset: 0;

            pointer-events: none;

            z-index: 0;

        }



        /* ===== Header ===== */

        header {

            position: sticky;

            top: 0;

            z-index: 100;

            backdrop-filter: blur(16px);

            -webkit-backdrop-filter: blur(16px);

            background: rgba(6, 11, 24, 0.75);

            border-bottom: 1px solid var(--border);

        }

        .header-inner {

            max-width: 1320px;

            margin: 0 auto;

            padding: 1.1rem 1.5rem;

            display: flex;

            align-items: center;

            justify-content: space-between;

        }

        .brand {

            display: flex;

            align-items: center;

            gap: 0.75rem;

            text-decoration: none;

            color: var(--text);

        }

        .brand-icon {

            width: 40px;

            height: 40px;

            border-radius: 12px;

            background: linear-gradient(135deg, #38bdf8, #818cf8);

            display: flex;

            align-items: center;

            justify-content: center;

            font-size: 1.2rem;

            color: #fff;

            box-shadow: 0 0 15px rgba(56, 189, 248, 0.4);

        }

        .brand-title {

            font-size: 1.25rem;

            font-weight: 800;

            letter-spacing: -0.02em;

            background: linear-gradient(135deg, #fff, #94a3b8);

            -webkit-background-clip: text;

            -webkit-text-fill-color: transparent;

        }



        /* ===== Hero Section ===== */

        .hero {

            position: relative;

            z-index: 1;

            max-width: 1320px;

            margin: 0 auto;

            padding: 4rem 1.5rem 2rem;

            text-align: center;

        }

        .hero-badge {

            display: inline-flex;

            align-items: center;

            gap: 0.5rem;

            padding: 0.4rem 1rem;

            border-radius: 999px;

            background: rgba(56, 189, 248, 0.1);

            border: 1px solid rgba(56, 189, 248, 0.3);

            color: var(--accent);

            font-size: 0.85rem;

            font-weight: 600;

            margin-bottom: 1.5rem;

        }

        .hero h1 {

            font-size: clamp(2.2rem, 5vw, 3.5rem);

            font-weight: 900;

            line-height: 1.2;

            margin-bottom: 1.2rem;

            background: linear-gradient(135deg, #ffffff 30%, #38bdf8 70%, #818cf8 100%);

            -webkit-background-clip: text;

            -webkit-text-fill-color: transparent;

        }

        .hero p {

            font-size: 1.1rem;

            color: var(--text-muted);

            max-width: 700px;

            margin: 0 auto 2.5rem;

            line-height: 1.7;

        }



        /* ===== Grid Layout ===== */

        .main-container {

            position: relative;

            z-index: 1;

            max-width: 1320px;

            margin: 0 auto;

            padding: 1rem 1.5rem 5rem;

        }



        .projects-grid {

            display: grid;

            grid-template-columns: repeat(auto-fill, minmax(360px, 1fr));

            gap: 2rem;

        }



        /* ===== Project Card ===== */

        .card {

            background: var(--surface-card);

            border: 1px solid var(--border);

            border-radius: var(--radius-card);

            overflow: hidden;

            text-decoration: none;

            color: var(--text);

            display: flex;

            flex-direction: column;

            transition: transform var(--transition), border-color var(--transition), box-shadow var(--transition);

            backdrop-filter: blur(12px);

        }



        .card:hover {

            transform: translateY(-8px);

            border-color: var(--border-glow);

            box-shadow: 0 12px 35px -10px rgba(0, 0, 0, 0.7), 0 0 25px -5px rgba(56, 189, 248, 0.3);

        }



        .card-banner {

            width: 100%;

            aspect-ratio: 16 / 9;

            overflow: hidden;

            position: relative;

            background: #020617;

        }



        .card-banner img {

            width: 100%;

            height: 100%;

            object-fit: cover;

            transition: transform 0.6s cubic-bezier(0.4, 0, 0.2, 1);

        }



        .card:hover .card-banner img {

            transform: scale(1.08);

        }



        .card-body {

            padding: 1.5rem;

            display: flex;

            flex-direction: column;

            flex-grow: 1;

        }



        .card-header {

            display: flex;

            align-items: center;

            justify-content: space-between;

            margin-bottom: 0.75rem;

        }



        .card-title {

            font-size: 1.25rem;

            font-weight: 700;

            color: #fff;

            display: flex;

            align-items: center;

            gap: 0.6rem;

        }



        .badge {

            font-size: 0.72rem;

            font-weight: 700;

            padding: 0.2rem 0.6rem;

            border-radius: 999px;

            background: rgba(56, 189, 248, 0.15);

            color: var(--accent);

            border: 1px solid rgba(56, 189, 248, 0.3);

        }



        .card-desc {

            font-size: 0.92rem;

            color: var(--text-muted);

            line-height: 1.65;

            margin-bottom: 1.25rem;

            flex-grow: 1;

        }



        .card-footer {

            display: flex;

            align-items: center;

            justify-content: space-between;

            padding-top: 1rem;

            border-top: 1px solid rgba(255, 255, 255, 0.06);

        }



        .tags {

            display: flex;

            gap: 0.4rem;

            flex-wrap: wrap;

        }



        .tag {

            font-size: 0.72rem;

            padding: 0.2rem 0.5rem;

            border-radius: 6px;

            background: rgba(255, 255, 255, 0.05);

            color: #cbd5e1;

            border: 1px solid rgba(255, 255, 255, 0.08);

        }



        .btn-link {

            font-size: 0.85rem;

            font-weight: 600;

            color: var(--accent);

            display: flex;

            align-items: center;

            gap: 0.4rem;

            transition: gap var(--transition);

        }



        .card:hover .btn-link {

            gap: 0.7rem;

        }



        /* ===== Footer ===== */

        footer {

            border-top: 1px solid var(--border);

            padding: 2.5rem 1.5rem;

            text-align: center;

            background: rgba(4, 8, 18, 0.9);

            color: var(--text-muted);

            font-size: 0.9rem;

        }



        @media (max-width: 768px) {

            .projects-grid {

                grid-template-columns: 1fr;

            }

        }

    </style>

</head>

<body>



    <canvas id="particle-canvas"></canvas>



    <!-- Header -->

    <header>

        <div class="header-inner">

            <a href="#" class="brand">

                <div class="brand-icon"><i class="fa-solid fa-code"></i></div>

                <span class="brand-title">LiangHao's Projects</span>

            </a>

            <a href="https://github.com/lianghao02" target="_blank" class="brand" style="font-size: 1.3rem; color: var(--text-muted);">

                <i class="fa-brands fa-github"></i>

            </a>

        </div>

    </header>



    <!-- Hero -->

    <section class="hero">

        <div class="hero-badge"><i class="fa-solid fa-shield-halved"></i> 全域開發與 Agent 實戰憲法 v3.0 驅動</div>

        <h1>AI、警務與自動化專案儀表板</h1>

        <p>歡迎探索我開發的 11 個專業工具與應用程式。涵蓋 AI 視訊過濾、基地台地圖定位、金融資料解析與系統清理優化。</p>

    </section>



    <!-- Main Content Grid -->

    <main class="main-container">

        <div class="projects-grid">



            <!-- 1. System Optimizer Tool -->

            <a href="https://github.com/lianghao02/System-Optimizer-Tool" target="_blank" class="card">

                <div class="card-banner">

                    <img src="images/banner_System-Optimizer-Tool.jpg" alt="清理" loading="lazy">

                </div>

                <div class="card-body">

                    <div class="card-header">

                        <h2 class="card-title"><i class="fa-solid fa-broom" style="color:#38bdf8;"></i> 系統清理與記憶體優化</h2>

                        <span class="badge">v1.0</span>

                    </div>

                    <p class="card-desc">Windows 系統暫存與 RAM 記憶體釋放工具，CustomTkinter 深色 UI，100% 絕不更動系統設定，附帶安全過濾白名單。</p>

                    <div class="card-footer">

                        <div class="tags"><span class="tag">Python</span><span class="tag">CustomTkinter</span><span class="tag">RAM 釋放</span></div>

                        <span class="btn-link">查看專案 <i class="fa-solid fa-arrow-right"></i></span>

                    </div>

                </div>

            </a>



            <!-- 2. Monitor Filter Tool -->

            <a href="https://github.com/lianghao02/Monitor-Filter-Tool" target="_blank" class="card">

                <div class="card-banner">

                    <img src="images/banner_Monitor-Filter-Tool.jpg" alt="監控" loading="lazy">

                </div>

                <div class="card-body">

                    <div class="card-header">

                        <h2 class="card-title"><i class="fa-solid fa-video" style="color:#34d399;"></i> AG-MONITOR 科技偵查</h2>

                        <span class="badge">v1.0</span>

                    </div>

                    <p class="card-desc">萬用 AI 戰術播放器與數位鑑識超解析工作站，專為警務實戰設計的自動化 YOLO 影像過濾與證物強化神器。</p>

                    <div class="card-footer">

                        <div class="tags"><span class="tag">Python</span><span class="tag">YOLOv8</span><span class="tag">AI 鑑識</span></div>

                        <span class="btn-link">查看專案 <i class="fa-solid fa-arrow-right"></i></span>

                    </div>

                </div>

            </a>



            <!-- 3. Calendar Card App -->

            <a href="https://lianghao02.github.io/Calendar-Card-App/" target="_blank" class="card">

                <div class="card-banner">

                    <img src="images/banner_Calendar-Card-App.jpg" alt="行事曆" loading="lazy">

                </div>

                <div class="card-body">

                    <div class="card-header">

                        <h2 class="card-title"><i class="fa-solid fa-calendar-days" style="color:#a78bfa;"></i> 卡片式行事曆 App</h2>

                        <span class="badge">v1.0</span>

                    </div>

                    <p class="card-desc">Mobile-First Split View 卡片式日程管理，內建 Smart NLP 自然語言自動解析時間與地點，搭配 Google Sheets 儲存。</p>

                    <div class="card-footer">

                        <div class="tags"><span class="tag">JavaScript</span><span class="tag">Smart NLP</span><span class="tag">Google Sheets</span></div>

                        <span class="btn-link">開啟應用 <i class="fa-solid fa-arrow-right"></i></span>

                    </div>

                </div>

            </a>



            <!-- 4. Cell Tower Map Locator -->

            <a href="https://lianghao02.github.io/Cell-Tower-Map-Locator/" target="_blank" class="card">

                <div class="card-banner">

                    <img src="images/banner_Cell-Tower-Map-Locator.jpg" alt="基地台" loading="lazy">

                </div>

                <div class="card-body">

                    <div class="card-header">

                        <h2 class="card-title"><i class="fa-solid fa-tower-cell" style="color:#fb923c;"></i> 基地台地圖即時定位</h2>

                        <span class="badge">v1.0</span>

                    </div>

                    <p class="card-desc">警務門號即時定位工具，離線運算與 Leaflet 扇形涵蓋區域繪製，支援台灣邊界驗證與 XSS 防衛。</p>

                    <div class="card-footer">

                        <div class="tags"><span class="tag">Leaflet</span><span class="tag">地圖定位</span><span class="tag">離線安全</span></div>

                        <span class="btn-link">開啟應用 <i class="fa-solid fa-arrow-right"></i></span>

                    </div>

                </div>

            </a>



            <!-- 5. Financial Data Parser -->

            <a href="https://lianghao02.github.io/Financial-Data-Parser/" target="_blank" class="card">

                <div class="card-banner">

                    <img src="images/banner_Financial-Data-Parser.jpg" alt="金融" loading="lazy">

                </div>

                <div class="card-body">

                    <div class="card-header">

                        <h2 class="card-title"><i class="fa-solid fa-file-csv" style="color:#10b981;"></i> 金融資料 CSV 轉 Excel</h2>

                        <span class="badge">v1.0</span>

                    </div>

                    <p class="card-desc">高容錯金融數據轉換器，SheetJS 帳號字串強型別保護 (前導零防護)、智慧金額清理與 ZIP 遞迴解壓縮。</p>

                    <div class="card-footer">

                        <div class="tags"><span class="tag">SheetJS</span><span class="tag">金融轉檔</span><span class="tag">ZIP 解壓</span></div>

                        <span class="btn-link">開啟應用 <i class="fa-solid fa-arrow-right"></i></span>

                    </div>

                </div>

            </a>



            <!-- 6. Photo Report Generator -->

            <a href="https://lianghao02.github.io/Photo-Report-Generator/" target="_blank" class="card">

                <div class="card-banner">

                    <img src="images/banner_Photo-Report-Generator.jpg" alt="清冊" loading="lazy">

                </div>

                <div class="card-body">

                    <div class="card-header">

                        <h2 class="card-title"><i class="fa-solid fa-file-word" style="color:#f59e0b;"></i> 現況照片清冊生成器</h2>

                        <span class="badge">v1.1</span>

                    </div>

                    <p class="card-desc">現況照片清冊自動整理與套印工具，結合 Excel VBA 自動將相片嵌入 Word 範本，大幅提升報告製作效率。</p>

                    <div class="card-footer">

                        <div class="tags"><span class="tag">Excel VBA</span><span class="tag">Word 巨集</span><span class="tag">清冊套印</span></div>

                        <span class="btn-link">開啟應用 <i class="fa-solid fa-arrow-right"></i></span>

                    </div>

                </div>

            </a>



            <!-- 7. Image Format Converter -->

            <a href="https://lianghao02.github.io/Image-Format-Converter/" target="_blank" class="card">

                <div class="card-banner">

                    <img src="images/banner_Image-Format-Converter.jpg" alt="轉檔" loading="lazy">

                </div>

                <div class="card-body">

                    <div class="card-header">

                        <h2 class="card-title"><i class="fa-solid fa-file-image" style="color:#ec4899;"></i> 警務影像轉檔與銳化器</h2>

                        <span class="badge">v4.0</span>

                    </div>

                    <p class="card-desc">100% 瀏覽器本機離線運算，支援 HEIC 轉檔、長截圖智慧分段切片、3x3 卷積核銳化與 JSZip 壓縮打包。</p>

                    <div class="card-footer">

                        <div class="tags"><span class="tag">Canvas</span><span class="tag">HEIC 轉檔</span><span class="tag">卷積濾鏡</span></div>

                        <span class="btn-link">開啟應用 <i class="fa-solid fa-arrow-right"></i></span>

                    </div>

                </div>

            </a>



            <!-- 8. Smart Photo Organizer -->

            <a href="https://github.com/lianghao02/Smart-Photo-Organizer" target="_blank" class="card">

                <div class="card-banner">

                    <img src="images/banner_Smart-Photo-Organizer.jpg" alt="分類" loading="lazy">

                </div>

                <div class="card-body">

                    <div class="card-header">

                        <h2 class="card-title"><i class="fa-solid fa-images" style="color:#6366f1;"></i> 智慧相片自動分類助手</h2>

                        <span class="badge">v2.7</span>

                    </div>

                    <p class="card-desc">Python 智慧相片分類與整理助手，依拍攝日期、地點 EXIF 或自訂邏輯進行批次排序與安全重命名。</p>

                    <div class="card-footer">

                        <div class="tags"><span class="tag">Python</span><span class="tag">EXIF 解析</span><span class="tag">相片歸檔</span></div>

                        <span class="btn-link">查看專案 <i class="fa-solid fa-arrow-right"></i></span>

                    </div>

                </div>

            </a>



            <!-- 9. Fruit Ninja Motion -->

            <a href="https://lianghao02.github.io/Fruit-Ninja-Motion/" target="_blank" class="card">

                <div class="card-banner">

                    <img src="images/banner_Fruit-Ninja-Motion.jpg" alt="切水果" loading="lazy">

                </div>

                <div class="card-body">

                    <div class="card-header">

                        <h2 class="card-title"><i class="fa-solid fa-gamepad" style="color:#ef4444;"></i> 體感切水果遊戲</h2>

                        <span class="badge">v1.0</span>

                    </div>

                    <p class="card-desc">Web 體感手勢互動遊戲，結合視訊鏡頭與即時動作追蹤，輕鬆在瀏覽器體驗切水果斬擊快感。</p>

                    <div class="card-footer">

                        <div class="tags"><span class="tag">HTML5</span><span class="tag">Canvas</span><span class="tag">手勢追蹤</span></div>

                        <span class="btn-link">開啟遊戲 <i class="fa-solid fa-arrow-right"></i></span>

                    </div>

                </div>

            </a>



            <!-- 10. Auto Learning Bot -->

            <a href="https://github.com/lianghao02/auto-learning-bot" target="_blank" class="card">

                <div class="card-banner">

                    <img src="images/banner_auto-learning-bot.jpg" alt="機器人" loading="lazy">

                </div>

                <div class="card-body">

                    <div class="card-header">

                        <h2 class="card-title"><i class="fa-solid fa-robot" style="color:#8b5cf6;"></i> 自動學習機器人</h2>

                        <span class="badge">v1.0</span>

                    </div>

                    <p class="card-desc">自動化學習測驗與題庫解析 Bot，具備智慧題庫分析、答案匹配與學習歷程追蹤邏輯。</p>

                    <div class="card-footer">

                        <div class="tags"><span class="tag">Python</span><span class="tag">自動化 Bot</span><span class="tag">題庫解析</span></div>

                        <span class="btn-link">查看專案 <i class="fa-solid fa-arrow-right"></i></span>

                    </div>

                </div>

            </a>



            <!-- 11. Home Portal -->

            <a href="https://lianghao02.github.io/home/" target="_blank" class="card">

                <div class="card-banner">

                    <img src="images/banner_home.jpg" alt="首頁" loading="lazy">

                </div>

                <div class="card-body">

                    <div class="card-header">

                        <h2 class="card-title"><i class="fa-solid fa-house" style="color:#3b82f6;"></i> LiangHao 首頁門戶</h2>

                        <span class="badge">v2.0</span>

                    </div>

                    <p class="card-desc">個人作品集與專案儀表板入口，整合全域憲法 v3.0 規範、粒子動畫背景與動態響應式卡片。</p>

                    <div class="card-footer">

                        <div class="tags"><span class="tag">HTML5</span><span class="tag">CSS3</span><span class="tag">儀表板</span></div>

                        <span class="btn-link">當前頁面 <i class="fa-solid fa-arrow-right"></i></span>

                    </div>

                </div>

            </a>



        </div>

    </main>



    <!-- Footer -->

    <footer>

        <p>© <span id="year"></span> LiangHao (梁巡官). All rights reserved.</p>

        <p style="font-size:0.8rem; margin-top:0.5rem; opacity:0.6;">全域開發與 Agent 實戰憲法 v3.0 | 專案總計：11 個獨立工具與應用</p>

    </footer>



    <script>

        document.getElementById('year').textContent = new Date().getFullYear();



        // Canvas Particle Background

        (function() {

            const canvas = document.getElementById("particle-canvas");

            const ctx = canvas.getContext("2d");

            let W, H, particles = [];

            const COUNT = 60;

            const COLORS = ["rgba(56,189,248,", "rgba(129,140,248,", "rgba(167,139,250,"];



            function resize() {

                W = canvas.width = window.innerWidth;

                H = canvas.height = window.innerHeight;

            }



            function createParticle() {

                return {

                    x: Math.random() * W,

                    y: Math.random() * H,

                    r: Math.random() * 1.8 + 0.5,

                    vx: (Math.random() - 0.5) * 0.4,

                    vy: (Math.random() - 0.5) * 0.4,

                    alpha: Math.random() * 0.4 + 0.1,

                    color: COLORS[Math.floor(Math.random() * COLORS.length)]

                };

            }



            function init() {

                resize();

                particles = Array.from({ length: COUNT }, createParticle);

                loop();

            }



            function loop() {

                ctx.clearRect(0, 0, W, H);

                for (const p of particles) {

                    p.x += p.vx;

                    p.y += p.vy;

                    if (p.x < 0) p.x = W;

                    if (p.x > W) p.x = 0;

                    if (p.y < 0) p.y = H;

                    if (p.y > H) p.y = 0;



                    ctx.beginPath();

                    ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);

                    ctx.fillStyle = p.color + p.alpha + ")";

                    ctx.fill();

                }

                requestAnimationFrame(loop);

            }



            window.addEventListener('resize', resize);

            init();

        })();

    </script>

</body>

</html>


```

## 📄 檔案: photo_report.html
``` html
<!DOCTYPE html>

<html lang="zh-TW">



<head>

  <meta charset="UTF-8">

  <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">

  <meta name="description" content="Photo Report 相片整理自動套印工具 — 批次匯入照片、自動排版輸出，專為警務需求設計。">

  <meta name="author" content="LiangHao">

  <title>Photo Report 自動套印工具 | LiangHao Dev</title>



  <meta property="og:title" content="Photo Report 自動套印工具 | LiangHao Dev">

  <meta property="og:description" content="快速將照片整理並套印至指定的表格格式中，大幅節省人工排版的時間。">

  <meta property="og:type" content="website">

  <meta property="og:url" content="https://lianghao02.github.io/photo_report.html">



  <!-- Fonts -->

  <link rel="preconnect" href="https://fonts.googleapis.com">

  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=Noto+Sans+TC:wght@400;500;700&display=swap" rel="stylesheet">



  <!-- FontAwesome -->

  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">



  <style>

    /* =========================================================

       Design System — CSS Custom Properties

    ========================================================= */

    :root {

      --bg:          #080d1a;

      --surface:     rgba(15, 23, 42, 0.85);

      --surface-2:   rgba(30, 41, 59, 0.55);

      --surface-3:   rgba(30, 41, 59, 0.35);

      --border:      rgba(148, 163, 184, 0.12);

      --border-glow: rgba(251, 146, 60, 0.4);

      --text:        #f1f5f9;

      --text-muted:  #94a3b8;

      --text-dim:    #64748b;

      --accent:      #fb923c;   /* orange — matches index.html accent-4 */

      --accent-alt:  #fbbf24;

      --accent-soft: rgba(251, 146, 60, 0.12);

      --accent-border: rgba(251, 146, 60, 0.28);

      --success:     #34d399;

      --radius:      1.25rem;

      --radius-sm:   0.65rem;

      --transition:  0.3s cubic-bezier(0.4, 0, 0.2, 1);

      --font:        'Inter', 'Noto Sans TC', sans-serif;

    }



    /* =========================================================

       Reset & Base

    ========================================================= */

    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    html { scroll-behavior: smooth; }



    body {

      font-family: var(--font);

      background-color: var(--bg);

      color: var(--text);

      line-height: 1.7;

      min-height: 100vh;

      display: flex;

      flex-direction: column;

      overflow-x: hidden;

    }



    a { text-decoration: none; color: inherit; }



    /* =========================================================

       Background

    ========================================================= */

    .bg-orbs {

      position: fixed;

      inset: 0;

      z-index: 0;

      pointer-events: none;

      overflow: hidden;

    }

    .bg-orbs::before {

      content: '';

      position: absolute;

      top: -15%;

      right: -10%;

      width: 650px; height: 650px;

      background: radial-gradient(circle, rgba(124,45,18,0.4) 0%, transparent 65%);

      border-radius: 50%;

      animation: orbFloat 20s ease-in-out infinite alternate;

    }

    .bg-orbs::after {

      content: '';

      position: absolute;

      bottom: -10%;

      left: -10%;

      width: 550px; height: 550px;

      background: radial-gradient(circle, rgba(30,58,138,0.3) 0%, transparent 65%);

      border-radius: 50%;

      animation: orbFloat 26s ease-in-out infinite alternate-reverse;

    }

    @keyframes orbFloat {

      0%   { transform: translate(0,0) scale(1); }

      100% { transform: translate(30px,-30px) scale(1.06); }

    }



    /* =========================================================

       Header / Nav

    ========================================================= */

    header {

      position: sticky;

      top: 0;

      z-index: 100;

      padding: 1.1rem 5%;

      transition: background var(--transition), box-shadow var(--transition);

    }

    header.scrolled {

      background: rgba(8,13,26,0.82);

      backdrop-filter: blur(20px);

      -webkit-backdrop-filter: blur(20px);

      box-shadow: 0 1px 0 var(--border), 0 4px 20px rgba(0,0,0,0.4);

    }



    nav {

      display: flex;

      justify-content: space-between;

      align-items: center;

      max-width: 1200px;

      margin: 0 auto;

    }



    .logo {

      font-size: 1.35rem;

      font-weight: 800;

      letter-spacing: -0.02em;

      background: linear-gradient(135deg, #38bdf8, #818cf8);

      -webkit-background-clip: text;

      -webkit-text-fill-color: transparent;

      background-clip: text;

    }



    .nav-links { display: flex; align-items: center; gap: 1.5rem; }



    .nav-link {

      font-size: 0.9rem;

      font-weight: 500;

      color: var(--text-muted);

      display: flex;

      align-items: center;

      gap: 0.4rem;

      transition: color var(--transition);

    }

    .nav-link:hover { color: var(--text); }



    .nav-back {

      font-size: 0.88rem;

      font-weight: 500;

      color: var(--text-dim);

      display: flex;

      align-items: center;

      gap: 0.45rem;

      transition: color var(--transition);

    }

    .nav-back:hover { color: var(--accent); }



    /* =========================================================

       Main

    ========================================================= */

    main {

      flex: 1;

      max-width: 860px;

      margin: 0 auto;

      padding: 3.5rem 5% 6rem;

      width: 100%;

      position: relative;

      z-index: 1;

    }



    /* =========================================================

       Page Hero

    ========================================================= */

    .page-hero {

      text-align: center;

      margin-bottom: 3.5rem;

      opacity: 0;

      animation: fadeInDown 0.7s ease-out 0.1s forwards;

    }



    .page-hero-icon {

      width: 72px; height: 72px;

      border-radius: 20px;

      background: var(--accent-soft);

      border: 1px solid var(--accent-border);

      display: inline-flex;

      align-items: center;

      justify-content: center;

      font-size: 2rem;

      color: var(--accent);

      margin-bottom: 1.5rem;

    }



    .page-hero h1 {

      font-size: clamp(2rem, 5vw, 3rem);

      font-weight: 800;

      letter-spacing: -0.03em;

      background: linear-gradient(160deg, #fff 0%, #cbd5e1 60%, #94a3b8 100%);

      -webkit-background-clip: text;

      -webkit-text-fill-color: transparent;

      background-clip: text;

      margin-bottom: 0.75rem;

    }



    .page-hero-sub {

      font-size: 1.05rem;

      color: var(--text-muted);

    }



    .version-chip {

      display: inline-block;

      font-size: 0.75rem;

      font-weight: 600;

      padding: 0.2rem 0.65rem;

      border-radius: 999px;

      background: var(--accent-soft);

      color: var(--accent);

      border: 1px solid var(--accent-border);

      margin-left: 0.5rem;

      vertical-align: middle;

    }



    /* =========================================================

       Download Card

    ========================================================= */

    .download-card {

      background: var(--surface-2);

      border: 1px solid var(--accent-border);

      border-radius: var(--radius);

      padding: 2.25rem 2.5rem;

      margin-bottom: 2rem;

      position: relative;

      overflow: hidden;

      opacity: 0;

      animation: fadeInUp 0.7s ease-out 0.25s forwards;

    }

    .download-card::before {

      content: '';

      position: absolute;

      top: 0; left: 0; right: 0;

      height: 2px;

      background: linear-gradient(to right, var(--accent), var(--accent-alt), transparent);

      border-radius: var(--radius) var(--radius) 0 0;

    }

    .download-card-inner {

      display: flex;

      align-items: center;

      gap: 2.5rem;

      flex-wrap: wrap;

    }



    .dl-info { flex: 1; min-width: 220px; }

    .dl-label {

      font-size: 0.75rem;

      font-weight: 600;

      letter-spacing: 0.08em;

      text-transform: uppercase;

      color: var(--accent);

      margin-bottom: 0.4rem;

    }

    .dl-title {

      font-size: 1.3rem;

      font-weight: 700;

      margin-bottom: 0.35rem;

    }

    .dl-desc {

      font-size: 0.88rem;

      color: var(--text-muted);

    }



    .dl-actions { display: flex; flex-direction: column; align-items: flex-end; gap: 0.6rem; }



    .download-btn {

      display: inline-flex;

      align-items: center;

      gap: 0.6rem;

      background: linear-gradient(135deg, var(--accent), var(--accent-alt));

      color: #fff;

      font-weight: 700;

      font-size: 0.95rem;

      padding: 0.8rem 1.75rem;

      border-radius: var(--radius-sm);

      transition: transform var(--transition), box-shadow var(--transition), filter var(--transition);

      white-space: nowrap;

      box-shadow: 0 4px 20px rgba(251,146,60,0.3);

    }

    .download-btn:hover {

      transform: translateY(-2px);

      filter: brightness(1.1);

      box-shadow: 0 6px 28px rgba(251,146,60,0.45);

    }



    .dl-note {

      font-size: 0.78rem;

      color: var(--text-dim);

      display: flex;

      align-items: center;

      gap: 0.35rem;

    }



    /* =========================================================

       Feature List (inside download card)

    ========================================================= */

    .feature-list {

      list-style: none;

      display: grid;

      grid-template-columns: 1fr 1fr;

      gap: 0.5rem 1.5rem;

      margin-top: 1.25rem;

    }

    .feature-list li {

      font-size: 0.88rem;

      color: var(--text-muted);

      display: flex;

      align-items: center;

      gap: 0.5rem;

    }

    .feature-list li i {

      color: var(--success);

      font-size: 0.75rem;

      flex-shrink: 0;

    }



    /* =========================================================

       Steps Flow

    ========================================================= */

    .steps-section {

      margin-bottom: 2rem;

      opacity: 0;

      animation: fadeInUp 0.7s ease-out 0.4s forwards;

    }



    .section-label {

      font-size: 0.75rem;

      font-weight: 600;

      letter-spacing: 0.08em;

      text-transform: uppercase;

      color: var(--text-dim);

      margin-bottom: 1.25rem;

      display: flex;

      align-items: center;

      gap: 0.75rem;

    }

    .section-label::after {

      content: '';

      flex: 1;

      height: 1px;

      background: linear-gradient(to right, var(--border), transparent);

    }



    .steps-flow {

      display: flex;

      align-items: stretch;

      gap: 0;

    }



    .step-item {

      flex: 1;

      background: var(--surface-3);

      border: 1px solid var(--border);

      border-radius: var(--radius-sm);

      padding: 1.4rem 1.25rem;

      text-align: center;

      position: relative;

      transition: border-color var(--transition), background var(--transition);

    }

    .step-item:hover {

      border-color: var(--accent-border);

      background: var(--accent-soft);

    }



    .step-num {

      font-size: 0.68rem;

      font-weight: 700;

      letter-spacing: 0.06em;

      color: var(--accent);

      margin-bottom: 0.6rem;

    }



    .step-icon-wrap {

      width: 44px; height: 44px;

      border-radius: 12px;

      background: var(--accent-soft);

      border: 1px solid var(--accent-border);

      display: inline-flex;

      align-items: center;

      justify-content: center;

      font-size: 1.1rem;

      color: var(--accent);

      margin-bottom: 0.7rem;

    }



    .step-name {

      font-size: 0.88rem;

      font-weight: 600;

      color: var(--text);

    }



    .step-arrow {

      display: flex;

      align-items: center;

      padding: 0 0.5rem;

      color: var(--text-dim);

      font-size: 0.75rem;

      flex-shrink: 0;

    }



    /* =========================================================

       Content Sections (README)

    ========================================================= */

    .content-area {

      display: flex;

      flex-direction: column;

      gap: 1.25rem;

      opacity: 0;

      animation: fadeInUp 0.7s ease-out 0.55s forwards;

    }



    .content-block {

      background: var(--surface-3);

      border: 1px solid var(--border);

      border-radius: var(--radius);

      overflow: hidden;

    }



    /* Accordion-style block header */

    .block-header {

      display: flex;

      align-items: center;

      gap: 0.85rem;

      padding: 1.1rem 1.5rem;

      cursor: pointer;

      user-select: none;

      transition: background var(--transition);

    }

    .block-header:hover { background: rgba(148,163,184,0.04); }



    .block-header-icon {

      width: 34px; height: 34px;

      border-radius: 9px;

      background: var(--accent-soft);

      border: 1px solid var(--accent-border);

      display: flex;

      align-items: center;

      justify-content: center;

      font-size: 0.85rem;

      color: var(--accent);

      flex-shrink: 0;

    }



    .block-header-title {

      font-size: 0.97rem;

      font-weight: 700;

      flex: 1;

    }



    .block-toggle {

      color: var(--text-dim);

      font-size: 0.75rem;

      transition: transform var(--transition);

    }

    .content-block.open .block-toggle { transform: rotate(180deg); }



    .block-body {

      padding: 0 1.5rem 1.4rem;

      display: none;

      border-top: 1px solid var(--border);

    }

    .block-body.open {

      display: block;

      animation: fadeInUp 0.25s ease-out forwards;

    }



    /* Typography inside block-body */

    .block-body p {

      font-size: 0.9rem;

      color: var(--text-muted);

      margin-top: 1rem;

      line-height: 1.75;

    }



    .block-body ul {

      list-style: none;

      margin-top: 1rem;

      display: flex;

      flex-direction: column;

      gap: 0.55rem;

    }



    .block-body ul li {

      font-size: 0.9rem;

      color: var(--text-muted);

      display: flex;

      align-items: flex-start;

      gap: 0.6rem;

      line-height: 1.65;

    }



    .block-body ul li::before {

      content: '▸';

      color: var(--accent);

      flex-shrink: 0;

      margin-top: 0.05rem;

    }



    .block-body strong { color: var(--text); font-weight: 600; }



    .block-body a {

      color: var(--accent);

      text-decoration: underline;

      text-underline-offset: 3px;

      transition: opacity var(--transition);

    }

    .block-body a:hover { opacity: 0.8; }



    .block-body code {

      background: rgba(148,163,184,0.1);

      border: 1px solid var(--border);

      padding: 0.15rem 0.45rem;

      border-radius: 5px;

      font-family: 'Consolas', 'Menlo', monospace;

      font-size: 0.85em;

      color: var(--accent-alt);

    }



    /* Step sub-items inside block-body */

    .sub-step {

      margin-top: 1rem;

    }

    .sub-step-title {

      font-size: 0.82rem;

      font-weight: 700;

      color: var(--accent);

      letter-spacing: 0.04em;

      margin-bottom: 0.5rem;

      display: flex;

      align-items: center;

      gap: 0.5rem;

    }



    /* FAQ */

    .faq-item {

      margin-top: 1.1rem;

      padding-top: 1.1rem;

      border-top: 1px solid var(--border);

    }

    .faq-item:first-child { border-top: none; margin-top: 0.8rem; padding-top: 0; }



    .faq-q {

      font-size: 0.9rem;

      font-weight: 600;

      color: var(--text);

      margin-bottom: 0.4rem;

      display: flex;

      gap: 0.5rem;

      align-items: flex-start;

    }

    .faq-q::before {

      content: 'Q';

      color: var(--accent);

      font-weight: 800;

      font-size: 0.8rem;

      background: var(--accent-soft);

      border: 1px solid var(--accent-border);

      width: 20px; height: 20px;

      border-radius: 5px;

      display: inline-flex;

      align-items: center;

      justify-content: center;

      flex-shrink: 0;

      margin-top: 1px;

    }



    .faq-a {

      font-size: 0.88rem;

      color: var(--text-muted);

      padding-left: 1.6rem;

      line-height: 1.65;

    }



    /* =========================================================

       Back Link

    ========================================================= */

    .back-wrap {

      text-align: center;

      margin-top: 3rem;

      opacity: 0;

      animation: fadeInUp 0.7s ease-out 0.7s forwards;

    }



    .back-btn {

      display: inline-flex;

      align-items: center;

      gap: 0.5rem;

      font-size: 0.88rem;

      font-weight: 600;

      color: var(--text-dim);

      padding: 0.65rem 1.4rem;

      border: 1px solid var(--border);

      border-radius: 999px;

      transition: color var(--transition), border-color var(--transition), background var(--transition);

    }

    .back-btn:hover {

      color: var(--accent);

      border-color: var(--accent-border);

      background: var(--accent-soft);

    }



    /* =========================================================

       Footer

    ========================================================= */

    footer {

      position: relative;

      z-index: 1;

      text-align: center;

      padding: 2rem 5%;

      border-top: 1px solid var(--border);

    }

    .footer-inner {

      max-width: 1200px;

      margin: 0 auto;

      display: flex;

      flex-direction: column;

      align-items: center;

      gap: 0.75rem;

    }

    .footer-links { display: flex; gap: 1.25rem; }

    .footer-link {

      color: var(--text-dim);

      font-size: 1.05rem;

      transition: color var(--transition), transform var(--transition);

    }

    .footer-link:hover { color: var(--accent); transform: translateY(-2px); }

    .footer-copy { font-size: 0.8rem; color: var(--text-dim); }



    /* =========================================================

       Keyframes

    ========================================================= */

    @keyframes fadeInDown {

      from { opacity: 0; transform: translateY(-16px); }

      to   { opacity: 1; transform: translateY(0);     }

    }

    @keyframes fadeInUp {

      from { opacity: 0; transform: translateY(16px); }

      to   { opacity: 1; transform: translateY(0);    }

    }



    /* =========================================================

       Responsive

    ========================================================= */

    @media (max-width: 640px) {

      .download-card-inner { flex-direction: column; gap: 1.5rem; }

      .dl-actions { align-items: flex-start; }

      .steps-flow { flex-direction: column; }

      .step-arrow { transform: rotate(90deg); padding: 0.25rem 0; align-self: center; }

      .feature-list { grid-template-columns: 1fr; }

      main { padding: 2rem 5% 4rem; }

    }

  </style>

</head>



<body>

  <!-- Background Orbs -->

  <div class="bg-orbs" aria-hidden="true"></div>



  <!-- ===== Header ===== -->

  <header id="site-header">

    <nav>

      <a href="index.html" class="logo">LiangHao.Dev</a>

      <div class="nav-links">

        <a href="https://github.com/lianghao02" target="_blank" rel="noopener noreferrer" class="nav-link">

          <i class="fa-brands fa-github"></i> GitHub

        </a>

      </div>

    </nav>

  </header>



  <!-- ===== Main ===== -->

  <main>



    <!-- Page Hero -->

    <section class="page-hero" aria-label="工具簡介">

      <div class="page-hero-icon" aria-hidden="true">

        <i class="fa-solid fa-file-zipper"></i>

      </div>

      <h1>Photo Report <span class="version-chip">v1.1</span></h1>

      <p class="page-hero-sub">現況照片清冊整理與自動套印工具</p>

    </section>



    <!-- Download Card -->

    <div class="download-card" aria-label="下載區">

      <div class="download-card-inner">

        <div class="dl-info">

          <div class="dl-label"><i class="fa-solid fa-download"></i> &nbsp;立即下載</div>

          <div class="dl-title">Photo_Report.rar</div>

          <p class="dl-desc">包含 Excel VBA 自動化工具與完整使用說明</p>

          <ul class="feature-list">

            <li><i class="fa-solid fa-check"></i> 一鍵匯入大量照片</li>

            <li><i class="fa-solid fa-check"></i> 自動調整大小與排版</li>

            <li><i class="fa-solid fa-check"></i> 支援 PDF 輸出與列印</li>

            <li><i class="fa-solid fa-check"></i> 完全離線執行，安全可靠</li>

          </ul>

        </div>

        <div class="dl-actions">

          <a href="downloads/Photo_Report.rar" class="download-btn" download>

            <i class="fa-solid fa-download"></i> 下載工具包 (.rar)

          </a>

          <span class="dl-note"><i class="fa-brands fa-windows"></i> 適用於 Windows / Excel 環境</span>

        </div>

      </div>

    </div>



    <!-- Steps Flow -->

    <section class="steps-section" aria-label="使用流程">

      <div class="section-label">使用流程</div>

      <div class="steps-flow">

        <div class="step-item">

          <div class="step-num">STEP 01</div>

          <div class="step-icon-wrap" aria-hidden="true"><i class="fa-solid fa-images"></i></div>

          <div class="step-name">準備照片</div>

        </div>

        <div class="step-arrow" aria-hidden="true"><i class="fa-solid fa-chevron-right"></i></div>

        <div class="step-item">

          <div class="step-num">STEP 02</div>

          <div class="step-icon-wrap" aria-hidden="true"><i class="fa-solid fa-file-excel"></i></div>

          <div class="step-name">開啟工具</div>

        </div>

        <div class="step-arrow" aria-hidden="true"><i class="fa-solid fa-chevron-right"></i></div>

        <div class="step-item">

          <div class="step-num">STEP 03</div>

          <div class="step-icon-wrap" aria-hidden="true"><i class="fa-solid fa-upload"></i></div>

          <div class="step-name">匯入照片</div>

        </div>

        <div class="step-arrow" aria-hidden="true"><i class="fa-solid fa-chevron-right"></i></div>

        <div class="step-item">

          <div class="step-num">STEP 04</div>

          <div class="step-icon-wrap" aria-hidden="true"><i class="fa-solid fa-print"></i></div>

          <div class="step-name">輸出報告</div>

        </div>

      </div>

    </section>



    <!-- Content Accordion -->

    <div class="content-area" aria-label="說明文件">



      <!-- 簡介 -->

      <div class="content-block open" id="block-intro">

        <div class="block-header" onclick="toggleBlock('block-intro')" role="button" tabindex="0" aria-expanded="true">

          <div class="block-header-icon" aria-hidden="true"><i class="fa-solid fa-circle-info"></i></div>

          <span class="block-header-title">簡介</span>

          <i class="fa-solid fa-chevron-down block-toggle"></i>

        </div>

        <div class="block-body open" id="block-intro-body">

          <p>這是一個專為警務工作設計的 Excel VBA 自動化工具，能夠快速將照片整理並套印至指定的表格格式中，大幅節省人工排版的時間。完全在本機離線執行，資料不上傳，安全可靠。</p>

        </div>

      </div>



      <!-- 功能特色 -->

      <div class="content-block open" id="block-features">

        <div class="block-header" onclick="toggleBlock('block-features')" role="button" tabindex="0" aria-expanded="true">

          <div class="block-header-icon" aria-hidden="true"><i class="fa-solid fa-star"></i></div>

          <span class="block-header-title">功能特色</span>

          <i class="fa-solid fa-chevron-down block-toggle"></i>

        </div>

        <div class="block-body open" id="block-features-body">

          <ul>

            <li><span><strong>自動匯入：</strong>批量匯入資料夾內的照片，無需逐一操作。</span></li>

            <li><span><strong>自動排版：</strong>依照預設格式自動調整照片大小與位置，版面整齊一致。</span></li>

            <li><span><strong>快速輸出：</strong>支援直接列印或另存為 PDF，一鍵完成報告。</span></li>

            <li><span><strong>離線執行：</strong>完全不需網路，資料安全不外傳。</span></li>

          </ul>

        </div>

      </div>



      <!-- 系統需求 -->

      <div class="content-block open" id="block-sysreq">

        <div class="block-header" onclick="toggleBlock('block-sysreq')" role="button" tabindex="0" aria-expanded="true">

          <div class="block-header-icon" aria-hidden="true"><i class="fa-brands fa-windows"></i></div>

          <span class="block-header-title">系統需求</span>

          <i class="fa-solid fa-chevron-down block-toggle"></i>

        </div>

        <div class="block-body open" id="block-sysreq-body">

          <ul>

            <li><span>作業系統：<strong>Windows 10 / 11</strong></span></li>

            <li><span>軟體需求：<strong>Microsoft Excel</strong>（需啟用巨集功能）</span></li>

            <li><span>照片格式：<strong>JPG</strong> 或 <strong>PNG</strong>（HEIC 需先轉檔）</span></li>

          </ul>

        </div>

      </div>



      <!-- 使用步驟 -->

      <div class="content-block open" id="block-steps">

        <div class="block-header" onclick="toggleBlock('block-steps')" role="button" tabindex="0" aria-expanded="true">

          <div class="block-header-icon" aria-hidden="true"><i class="fa-solid fa-list-ol"></i></div>

          <span class="block-header-title">詳細使用步驟</span>

          <i class="fa-solid fa-chevron-down block-toggle"></i>

        </div>

        <div class="block-body open" id="block-steps-body">



          <div class="sub-step">

            <div class="sub-step-title"><i class="fa-solid fa-images"></i> 1. 準備照片</div>

            <ul>

              <li><span>將需要製作報告的照片整理在同一個資料夾中。</span></li>

              <li><span>本工具僅支援 <strong>JPG</strong> 或 <strong>PNG</strong> 格式。</span></li>

              <li><span>若照片為 <strong>HEIC</strong> 格式（iPhone 預設），請先使用 <a href="https://lianghao02.github.io/Image-Format-Converter/" target="_blank">Image Converter</a> 進行轉檔。</span></li>

            </ul>

          </div>



          <div class="sub-step">

            <div class="sub-step-title"><i class="fa-solid fa-file-excel"></i> 2. 開啟工具</div>

            <ul>

              <li><span>點擊 <code>Photo_Report.xlsm</code> 開啟檔案。</span></li>

              <li><span>若 Excel 上方出現「安全性警告」，請點擊 <strong>[啟用內容]</strong> 以允許巨集執行。</span></li>

            </ul>

          </div>



          <div class="sub-step">

            <div class="sub-step-title"><i class="fa-solid fa-upload"></i> 3. 執行匯入</div>

            <ul>

              <li><span>點擊工具介面上的 <strong>[匯入照片]</strong> 按鈕。</span></li>

              <li><span>選擇您存放照片的資料夾。</span></li>

              <li><span>系統將自動讀取並完成排版。</span></li>

            </ul>

          </div>



          <div class="sub-step">

            <div class="sub-step-title"><i class="fa-solid fa-print"></i> 4. 輸出報告</div>

            <ul>

              <li><span>確認排版無誤後，可直接列印或儲存檔案。</span></li>

            </ul>

          </div>



        </div>

      </div>



      <!-- 常見問題 -->

      <div class="content-block open" id="block-faq">

        <div class="block-header" onclick="toggleBlock('block-faq')" role="button" tabindex="0" aria-expanded="true">

          <div class="block-header-icon" aria-hidden="true"><i class="fa-solid fa-circle-question"></i></div>

          <span class="block-header-title">常見問題 FAQ</span>

          <i class="fa-solid fa-chevron-down block-toggle"></i>

        </div>

        <div class="block-body open" id="block-faq-body">

          <div class="faq-item">

            <div class="faq-q">為什麼照片無法匯入？</div>

            <p class="faq-a">請確認照片檔名是否包含特殊字元，或格式是否為 JPG / PNG。</p>

          </div>

          <div class="faq-item">

            <div class="faq-q">執行時出現錯誤訊息？</div>

            <p class="faq-a">請確認您已啟用 Excel 的巨集權限（點擊上方黃色安全性警告列並選擇「啟用內容」）。</p>

          </div>

          <div class="faq-item">

            <div class="faq-q">照片排版順序如何決定？</div>

            <p class="faq-a">預設依照檔名的字母順序排序，建議在匯入前先將照片檔名以流水號命名（如 01.jpg、02.jpg⋯）。</p>

          </div>

        </div>

      </div>



    </div>



    <!-- Back Link -->

    <div class="back-wrap">

      <a href="index.html" class="back-btn">

        <i class="fa-solid fa-arrow-left"></i> 返回作品集首頁

      </a>

    </div>



  </main>



  <!-- ===== Footer ===== -->

  <footer>

    <div class="footer-inner">

      <div class="footer-links">

        <a href="https://github.com/lianghao02" target="_blank" rel="noopener noreferrer"

           class="footer-link" aria-label="GitHub">

          <i class="fa-brands fa-github"></i>

        </a>

      </div>

      <p class="footer-copy">© <span id="footer-year"></span> LiangHao. All rights reserved.</p>

    </div>

  </footer>



  <!-- ===== Scripts ===== -->

  <script>

    /* ---- Footer Year ---- */

    document.getElementById('footer-year').textContent = new Date().getFullYear();



    /* ---- Sticky Header ---- */

    const header = document.getElementById('site-header');

    window.addEventListener('scroll', () => {

      header.classList.toggle('scrolled', window.scrollY > 20);

    }, { passive: true });



    /* ---- Accordion Toggle ---- */

    function toggleBlock(id) {

      const block = document.getElementById(id);

      const body = document.getElementById(id + '-body');

      const isOpen = block.classList.toggle('open');

      if (isOpen) {

        body.classList.add('open');

      } else {

        body.classList.remove('open');

      }

      const header = block.querySelector('.block-header');

      header.setAttribute('aria-expanded', isOpen);

    }



    /* ---- Keyboard support for accordion ---- */

    document.querySelectorAll('.block-header').forEach(h => {

      h.addEventListener('keydown', e => {

        if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); h.click(); }

      });

    });

  </script>

</body>



</html>
```

## 📄 檔案: update_home_html.py
``` py
import os

home_dir = r"C:\Users\tpc09\.gemini\antigravity\scratch\home"
index_html_path = os.path.join(home_dir, "index.html")

html_code = """<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
    <meta name="mobile-web-app-capable" content="yes">
    <meta name="description" content="LiangHao's Projects Portal - 探索我開發的 11 個實用 AI、警務與自動化專案。">
    <meta name="author" content="LiangHao (梁巡官)">
    <title>LiangHao's Projects | 專案作品集儀表板</title>

    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=Noto+Sans+TC:wght@400;500;700;900&display=swap" rel="stylesheet">
    
    <!-- FontAwesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        :root {
            --bg: #060b18;
            --surface: rgba(15, 23, 42, 0.75);
            --surface-card: rgba(15, 23, 42, 0.85);
            --border: rgba(148, 163, 184, 0.15);
            --border-glow: rgba(56, 189, 248, 0.4);
            --text: #f8fafc;
            --text-muted: #94a3b8;
            --accent: #38bdf8;
            --accent-purple: #818cf8;
            --radius-card: 1.25rem;
            --transition: 0.35s cubic-bezier(0.4, 0, 0.2, 1);
            --font: 'Inter', 'Noto Sans TC', sans-serif;
        }

        *, *::before, *::after {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            background-color: var(--bg);
            color: var(--text);
            font-family: var(--font);
            min-height: 100vh;
            overflow-x: hidden;
            background-image: 
                radial-gradient(circle at 15% 15%, rgba(56, 189, 248, 0.08) 0%, transparent 40%),
                radial-gradient(circle at 85% 75%, rgba(129, 140, 248, 0.08) 0%, transparent 40%);
        }

        #particle-canvas {
            position: fixed;
            inset: 0;
            pointer-events: none;
            z-index: 0;
        }

        /* ===== Header ===== */
        header {
            position: sticky;
            top: 0;
            z-index: 100;
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            background: rgba(6, 11, 24, 0.75);
            border-bottom: 1px solid var(--border);
        }
        .header-inner {
            max-width: 1320px;
            margin: 0 auto;
            padding: 1.1rem 1.5rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .brand {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            text-decoration: none;
            color: var(--text);
        }
        .brand-icon {
            width: 40px;
            height: 40px;
            border-radius: 12px;
            background: linear-gradient(135deg, #38bdf8, #818cf8);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
            color: #fff;
            box-shadow: 0 0 15px rgba(56, 189, 248, 0.4);
        }
        .brand-title {
            font-size: 1.25rem;
            font-weight: 800;
            letter-spacing: -0.02em;
            background: linear-gradient(135deg, #fff, #94a3b8);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        /* ===== Hero Section ===== */
        .hero {
            position: relative;
            z-index: 1;
            max-width: 1320px;
            margin: 0 auto;
            padding: 4rem 1.5rem 2rem;
            text-align: center;
        }
        .hero-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.4rem 1rem;
            border-radius: 999px;
            background: rgba(56, 189, 248, 0.1);
            border: 1px solid rgba(56, 189, 248, 0.3);
            color: var(--accent);
            font-size: 0.85rem;
            font-weight: 600;
            margin-bottom: 1.5rem;
        }
        .hero h1 {
            font-size: clamp(2.2rem, 5vw, 3.5rem);
            font-weight: 900;
            line-height: 1.2;
            margin-bottom: 1.2rem;
            background: linear-gradient(135deg, #ffffff 30%, #38bdf8 70%, #818cf8 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .hero p {
            font-size: 1.1rem;
            color: var(--text-muted);
            max-width: 700px;
            margin: 0 auto 2.5rem;
            line-height: 1.7;
        }

        /* ===== Grid Layout ===== */
        .main-container {
            position: relative;
            z-index: 1;
            max-width: 1320px;
            margin: 0 auto;
            padding: 1rem 1.5rem 5rem;
        }

        .projects-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(360px, 1fr));
            gap: 2rem;
        }

        /* ===== Project Card ===== */
        .card {
            background: var(--surface-card);
            border: 1px solid var(--border);
            border-radius: var(--radius-card);
            overflow: hidden;
            text-decoration: none;
            color: var(--text);
            display: flex;
            flex-direction: column;
            transition: transform var(--transition), border-color var(--transition), box-shadow var(--transition);
            backdrop-filter: blur(12px);
        }

        .card:hover {
            transform: translateY(-8px);
            border-color: var(--border-glow);
            box-shadow: 0 12px 35px -10px rgba(0, 0, 0, 0.7), 0 0 25px -5px rgba(56, 189, 248, 0.3);
        }

        .card-banner {
            width: 100%;
            aspect-ratio: 16 / 9;
            overflow: hidden;
            position: relative;
            background: #020617;
        }

        .card-banner img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.6s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .card:hover .card-banner img {
            transform: scale(1.08);
        }

        .card-body {
            padding: 1.5rem;
            display: flex;
            flex-direction: column;
            flex-grow: 1;
        }

        .card-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 0.75rem;
        }

        .card-title {
            font-size: 1.25rem;
            font-weight: 700;
            color: #fff;
            display: flex;
            align-items: center;
            gap: 0.6rem;
        }

        .badge {
            font-size: 0.72rem;
            font-weight: 700;
            padding: 0.2rem 0.6rem;
            border-radius: 999px;
            background: rgba(56, 189, 248, 0.15);
            color: var(--accent);
            border: 1px solid rgba(56, 189, 248, 0.3);
        }

        .card-desc {
            font-size: 0.92rem;
            color: var(--text-muted);
            line-height: 1.65;
            margin-bottom: 1.25rem;
            flex-grow: 1;
        }

        .card-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding-top: 1rem;
            border-top: 1px solid rgba(255, 255, 255, 0.06);
        }

        .tags {
            display: flex;
            gap: 0.4rem;
            flex-wrap: wrap;
        }

        .tag {
            font-size: 0.72rem;
            padding: 0.2rem 0.5rem;
            border-radius: 6px;
            background: rgba(255, 255, 255, 0.05);
            color: #cbd5e1;
            border: 1px solid rgba(255, 255, 255, 0.08);
        }

        .btn-link {
            font-size: 0.85rem;
            font-weight: 600;
            color: var(--accent);
            display: flex;
            align-items: center;
            gap: 0.4rem;
            transition: gap var(--transition);
        }

        .card:hover .btn-link {
            gap: 0.7rem;
        }

        /* ===== Footer ===== */
        footer {
            border-top: 1px solid var(--border);
            padding: 2.5rem 1.5rem;
            text-align: center;
            background: rgba(4, 8, 18, 0.9);
            color: var(--text-muted);
            font-size: 0.9rem;
        }

        @media (max-width: 768px) {
            .projects-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>

    <canvas id="particle-canvas"></canvas>

    <!-- Header -->
    <header>
        <div class="header-inner">
            <a href="#" class="brand">
                <div class="brand-icon"><i class="fa-solid fa-code"></i></div>
                <span class="brand-title">LiangHao's Projects</span>
            </a>
            <a href="https://github.com/lianghao02" target="_blank" class="brand" style="font-size: 1.3rem; color: var(--text-muted);">
                <i class="fa-brands fa-github"></i>
            </a>
        </div>
    </header>

    <!-- Hero -->
    <section class="hero">
        <div class="hero-badge"><i class="fa-solid fa-shield-halved"></i> 全域開發與 Agent 實戰憲法 v3.0 驅動</div>
        <h1>AI、警務與自動化專案儀表板</h1>
        <p>歡迎探索我開發的 11 個專業工具與應用程式。涵蓋 AI 視訊過濾、基地台地圖定位、金融資料解析與系統清理優化。</p>
    </section>

    <!-- Main Content Grid -->
    <main class="main-container">
        <div class="projects-grid">

            <!-- 1. System Optimizer Tool -->
            <a href="https://github.com/lianghao02/System-Optimizer-Tool" target="_blank" class="card">
                <div class="card-banner">
                    <img src="images/banner_System-Optimizer-Tool.jpg" alt="清理" loading="lazy">
                </div>
                <div class="card-body">
                    <div class="card-header">
                        <h2 class="card-title"><i class="fa-solid fa-broom" style="color:#38bdf8;"></i> 系統清理與記憶體優化</h2>
                        <span class="badge">v1.0</span>
                    </div>
                    <p class="card-desc">Windows 系統暫存與 RAM 記憶體釋放工具，CustomTkinter 深色 UI，100% 絕不更動系統設定，附帶安全過濾白名單。</p>
                    <div class="card-footer">
                        <div class="tags"><span class="tag">Python</span><span class="tag">CustomTkinter</span><span class="tag">RAM 釋放</span></div>
                        <span class="btn-link">查看專案 <i class="fa-solid fa-arrow-right"></i></span>
                    </div>
                </div>
            </a>

            <!-- 2. Monitor Filter Tool -->
            <a href="https://github.com/lianghao02/Monitor-Filter-Tool" target="_blank" class="card">
                <div class="card-banner">
                    <img src="images/banner_Monitor-Filter-Tool.jpg" alt="監控" loading="lazy">
                </div>
                <div class="card-body">
                    <div class="card-header">
                        <h2 class="card-title"><i class="fa-solid fa-video" style="color:#34d399;"></i> AG-MONITOR 科技偵查</h2>
                        <span class="badge">v1.0</span>
                    </div>
                    <p class="card-desc">萬用 AI 戰術播放器與數位鑑識超解析工作站，專為警務實戰設計的自動化 YOLO 影像過濾與證物強化神器。</p>
                    <div class="card-footer">
                        <div class="tags"><span class="tag">Python</span><span class="tag">YOLOv8</span><span class="tag">AI 鑑識</span></div>
                        <span class="btn-link">查看專案 <i class="fa-solid fa-arrow-right"></i></span>
                    </div>
                </div>
            </a>

            <!-- 3. Calendar Card App -->
            <a href="https://lianghao02.github.io/Calendar-Card-App/" target="_blank" class="card">
                <div class="card-banner">
                    <img src="images/banner_Calendar-Card-App.jpg" alt="行事曆" loading="lazy">
                </div>
                <div class="card-body">
                    <div class="card-header">
                        <h2 class="card-title"><i class="fa-solid fa-calendar-days" style="color:#a78bfa;"></i> 卡片式行事曆 App</h2>
                        <span class="badge">v1.0</span>
                    </div>
                    <p class="card-desc">Mobile-First Split View 卡片式日程管理，內建 Smart NLP 自然語言自動解析時間與地點，搭配 Google Sheets 儲存。</p>
                    <div class="card-footer">
                        <div class="tags"><span class="tag">JavaScript</span><span class="tag">Smart NLP</span><span class="tag">Google Sheets</span></div>
                        <span class="btn-link">開啟應用 <i class="fa-solid fa-arrow-right"></i></span>
                    </div>
                </div>
            </a>

            <!-- 4. Cell Tower Map Locator -->
            <a href="https://lianghao02.github.io/Cell-Tower-Map-Locator/" target="_blank" class="card">
                <div class="card-banner">
                    <img src="images/banner_Cell-Tower-Map-Locator.jpg" alt="基地台" loading="lazy">
                </div>
                <div class="card-body">
                    <div class="card-header">
                        <h2 class="card-title"><i class="fa-solid fa-tower-cell" style="color:#fb923c;"></i> 基地台地圖即時定位</h2>
                        <span class="badge">v1.0</span>
                    </div>
                    <p class="card-desc">警務門號即時定位工具，離線運算與 Leaflet 扇形涵蓋區域繪製，支援台灣邊界驗證與 XSS 防衛。</p>
                    <div class="card-footer">
                        <div class="tags"><span class="tag">Leaflet</span><span class="tag">地圖定位</span><span class="tag">離線安全</span></div>
                        <span class="btn-link">開啟應用 <i class="fa-solid fa-arrow-right"></i></span>
                    </div>
                </div>
            </a>

            <!-- 5. Financial Data Parser -->
            <a href="https://lianghao02.github.io/Financial-Data-Parser/" target="_blank" class="card">
                <div class="card-banner">
                    <img src="images/banner_Financial-Data-Parser.jpg" alt="金融" loading="lazy">
                </div>
                <div class="card-body">
                    <div class="card-header">
                        <h2 class="card-title"><i class="fa-solid fa-file-csv" style="color:#10b981;"></i> 金融資料 CSV 轉 Excel</h2>
                        <span class="badge">v1.0</span>
                    </div>
                    <p class="card-desc">高容錯金融數據轉換器，SheetJS 帳號字串強型別保護 (前導零防護)、智慧金額清理與 ZIP 遞迴解壓縮。</p>
                    <div class="card-footer">
                        <div class="tags"><span class="tag">SheetJS</span><span class="tag">金融轉檔</span><span class="tag">ZIP 解壓</span></div>
                        <span class="btn-link">開啟應用 <i class="fa-solid fa-arrow-right"></i></span>
                    </div>
                </div>
            </a>

            <!-- 6. Photo Report Generator -->
            <a href="https://lianghao02.github.io/Photo-Report-Generator/" target="_blank" class="card">
                <div class="card-banner">
                    <img src="images/banner_Photo-Report-Generator.jpg" alt="清冊" loading="lazy">
                </div>
                <div class="card-body">
                    <div class="card-header">
                        <h2 class="card-title"><i class="fa-solid fa-file-word" style="color:#f59e0b;"></i> 現況照片清冊生成器</h2>
                        <span class="badge">v1.1</span>
                    </div>
                    <p class="card-desc">現況照片清冊自動整理與套印工具，結合 Excel VBA 自動將相片嵌入 Word 範本，大幅提升報告製作效率。</p>
                    <div class="card-footer">
                        <div class="tags"><span class="tag">Excel VBA</span><span class="tag">Word 巨集</span><span class="tag">清冊套印</span></div>
                        <span class="btn-link">開啟應用 <i class="fa-solid fa-arrow-right"></i></span>
                    </div>
                </div>
            </a>

            <!-- 7. Image Format Converter -->
            <a href="https://lianghao02.github.io/Image-Format-Converter/" target="_blank" class="card">
                <div class="card-banner">
                    <img src="images/banner_Image-Format-Converter.jpg" alt="轉檔" loading="lazy">
                </div>
                <div class="card-body">
                    <div class="card-header">
                        <h2 class="card-title"><i class="fa-solid fa-file-image" style="color:#ec4899;"></i> 警務影像轉檔與銳化器</h2>
                        <span class="badge">v4.0</span>
                    </div>
                    <p class="card-desc">100% 瀏覽器本機離線運算，支援 HEIC 轉檔、長截圖智慧分段切片、3x3 卷積核銳化與 JSZip 壓縮打包。</p>
                    <div class="card-footer">
                        <div class="tags"><span class="tag">Canvas</span><span class="tag">HEIC 轉檔</span><span class="tag">卷積濾鏡</span></div>
                        <span class="btn-link">開啟應用 <i class="fa-solid fa-arrow-right"></i></span>
                    </div>
                </div>
            </a>

            <!-- 8. Smart Photo Organizer -->
            <a href="https://github.com/lianghao02/Smart-Photo-Organizer" target="_blank" class="card">
                <div class="card-banner">
                    <img src="images/banner_Smart-Photo-Organizer.jpg" alt="分類" loading="lazy">
                </div>
                <div class="card-body">
                    <div class="card-header">
                        <h2 class="card-title"><i class="fa-solid fa-images" style="color:#6366f1;"></i> 智慧相片自動分類助手</h2>
                        <span class="badge">v2.7</span>
                    </div>
                    <p class="card-desc">Python 智慧相片分類與整理助手，依拍攝日期、地點 EXIF 或自訂邏輯進行批次排序與安全重命名。</p>
                    <div class="card-footer">
                        <div class="tags"><span class="tag">Python</span><span class="tag">EXIF 解析</span><span class="tag">相片歸檔</span></div>
                        <span class="btn-link">查看專案 <i class="fa-solid fa-arrow-right"></i></span>
                    </div>
                </div>
            </a>

            <!-- 9. Fruit Ninja Motion -->
            <a href="https://lianghao02.github.io/Fruit-Ninja-Motion/" target="_blank" class="card">
                <div class="card-banner">
                    <img src="images/banner_Fruit-Ninja-Motion.jpg" alt="切水果" loading="lazy">
                </div>
                <div class="card-body">
                    <div class="card-header">
                        <h2 class="card-title"><i class="fa-solid fa-gamepad" style="color:#ef4444;"></i> 體感切水果遊戲</h2>
                        <span class="badge">v1.0</span>
                    </div>
                    <p class="card-desc">Web 體感手勢互動遊戲，結合視訊鏡頭與即時動作追蹤，輕鬆在瀏覽器體驗切水果斬擊快感。</p>
                    <div class="card-footer">
                        <div class="tags"><span class="tag">HTML5</span><span class="tag">Canvas</span><span class="tag">手勢追蹤</span></div>
                        <span class="btn-link">開啟遊戲 <i class="fa-solid fa-arrow-right"></i></span>
                    </div>
                </div>
            </a>

            <!-- 10. Auto Learning Bot -->
            <a href="https://github.com/lianghao02/auto-learning-bot" target="_blank" class="card">
                <div class="card-banner">
                    <img src="images/banner_auto-learning-bot.jpg" alt="機器人" loading="lazy">
                </div>
                <div class="card-body">
                    <div class="card-header">
                        <h2 class="card-title"><i class="fa-solid fa-robot" style="color:#8b5cf6;"></i> 自動學習機器人</h2>
                        <span class="badge">v1.0</span>
                    </div>
                    <p class="card-desc">自動化學習測驗與題庫解析 Bot，具備智慧題庫分析、答案匹配與學習歷程追蹤邏輯。</p>
                    <div class="card-footer">
                        <div class="tags"><span class="tag">Python</span><span class="tag">自動化 Bot</span><span class="tag">題庫解析</span></div>
                        <span class="btn-link">查看專案 <i class="fa-solid fa-arrow-right"></i></span>
                    </div>
                </div>
            </a>

            <!-- 11. Home Portal -->
            <a href="https://lianghao02.github.io/home/" target="_blank" class="card">
                <div class="card-banner">
                    <img src="images/banner_home.jpg" alt="首頁" loading="lazy">
                </div>
                <div class="card-body">
                    <div class="card-header">
                        <h2 class="card-title"><i class="fa-solid fa-house" style="color:#3b82f6;"></i> LiangHao 首頁門戶</h2>
                        <span class="badge">v2.0</span>
                    </div>
                    <p class="card-desc">個人作品集與專案儀表板入口，整合全域憲法 v3.0 規範、粒子動畫背景與動態響應式卡片。</p>
                    <div class="card-footer">
                        <div class="tags"><span class="tag">HTML5</span><span class="tag">CSS3</span><span class="tag">儀表板</span></div>
                        <span class="btn-link">當前頁面 <i class="fa-solid fa-arrow-right"></i></span>
                    </div>
                </div>
            </a>

        </div>
    </main>

    <!-- Footer -->
    <footer>
        <p>© <span id="year"></span> LiangHao (梁巡官). All rights reserved.</p>
        <p style="font-size:0.8rem; margin-top:0.5rem; opacity:0.6;">全域開發與 Agent 實戰憲法 v3.0 | 專案總計：11 個獨立工具與應用</p>
    </footer>

    <script>
        document.getElementById('year').textContent = new Date().getFullYear();

        // Canvas Particle Background
        (function() {
            const canvas = document.getElementById("particle-canvas");
            const ctx = canvas.getContext("2d");
            let W, H, particles = [];
            const COUNT = 60;
            const COLORS = ["rgba(56,189,248,", "rgba(129,140,248,", "rgba(167,139,250,"];

            function resize() {
                W = canvas.width = window.innerWidth;
                H = canvas.height = window.innerHeight;
            }

            function createParticle() {
                return {
                    x: Math.random() * W,
                    y: Math.random() * H,
                    r: Math.random() * 1.8 + 0.5,
                    vx: (Math.random() - 0.5) * 0.4,
                    vy: (Math.random() - 0.5) * 0.4,
                    alpha: Math.random() * 0.4 + 0.1,
                    color: COLORS[Math.floor(Math.random() * COLORS.length)]
                };
            }

            function init() {
                resize();
                particles = Array.from({ length: COUNT }, createParticle);
                loop();
            }

            function loop() {
                ctx.clearRect(0, 0, W, H);
                for (const p of particles) {
                    p.x += p.vx;
                    p.y += p.vy;
                    if (p.x < 0) p.x = W;
                    if (p.x > W) p.x = 0;
                    if (p.y < 0) p.y = H;
                    if (p.y > H) p.y = 0;

                    ctx.beginPath();
                    ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
                    ctx.fillStyle = p.color + p.alpha + ")";
                    ctx.fill();
                }
                requestAnimationFrame(loop);
            }

            window.addEventListener('resize', resize);
            init();
        })();
    </script>
</body>
</html>
"""

with open(index_html_path, "w", encoding="utf-8") as f:
    f.write(html_code)

print("[OK] Rebuilt home/index.html with all 11 project cards and 16:9 banner images!")

```

