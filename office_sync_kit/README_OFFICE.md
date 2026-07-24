# 🚀 辦公室 Antigravity 一鍵同步、NotebookLM 脫水與憲法融合工具包 (office_sync_kit)

> **資安承諾**：本工具包 100% 採用「唯讀掃描 (Read-Only) + 增量備份 (Add Folder)」機制。**絕對不會刪除、覆蓋或變更您辦公室電腦裡的任何既有原始碼與專案檔案**！

---

## 📋 工具包 7 大檔案中文用途明細

| 檔案名稱 | 中文用途說明 | 檔案性質 |
| :--- | :--- | :--- |
| **`RUN_OFFICE_SETUP.bat`** | **辦公室雙擊啟動檔**：方便您在 Windows 環境下直接雙擊滑鼠左鍵，開啟選單操作視窗。 | 啟動批次檔 |
| **`office_master_setup.py`** | **互動選單總控主程式**：提供 `[1] [2] [3] [4] [0]` 數字選單，由您決定要執行的動作。 | 主程式 |
| **`generate_sources.py`** | **NotebookLM 脫水封包產生器**：自動將專案整理成 4 份專供 NotebookLM 使用的純文字 Markdown 檔。 | 輔助工具 |
| **`merge_constitution.py`** | **雙源憲法自動融合工具**：將「辦公室舊內規」與「住家 v3.0 憲法」合併成全新的 v4.0 憲法。 | 輔助工具 |
| **`instructions_v3.md`** | **全域憲法 v3.0 條文資料檔**：收錄最新討論出來的全域開發憲法完整文字。 | 純資料檔 |
| **`skill_v3.json`** | **系統腦區描述檔**：宣告此全域憲法為 Antigravity 系統最高優先級。 | 純資料檔 |
| **`README_OFFICE.md`** | **辦公室說明與資安手冊**：即本說明文件，收錄完整的資安承諾與操作指引。 | 純說明檔 |

---

## ⚡ 雙擊 `RUN_OFFICE_SETUP.bat` 執行後的安全過程說明

當您雙擊 `RUN_OFFICE_SETUP.bat` 時，畫面上會彈出一個 CMD 命令列控制視窗，顯示選單：

```text
=================================================================
🚀 辦公室 Antigravity 一鍵同步、NotebookLM 脫水與憲法融合工具包
=================================================================
 [1] 一鍵將「全域憲法 v3.0」寫入辦公室 Antigravity 系統腦區
 [2] 一鍵掃描辦公室所有專案，生成 NotebookLM 脫水封包
 [3] 一鍵雙源憲法大融合 (升級至 v4.0)
 [4] 執行離場防呆自動 Git Commit & Push
 [0] 離開
=================================================================
```

### 選單數字代表的安全動作：
* **輸入 `1` (一鍵寫入憲法 v3.0)**：
  僅將 `instructions_v3.md` 複製到辦公室系統腦區 `~/.antigravity/skills/`，讓辦公室 AI 遵循最新台灣繁體中文與四步驟工作流。**（既有專案代碼 0 變動）**
* **輸入 `2` (生成 NotebookLM 脫水封包)**：
  掃描專案代碼與說明，並在專案目錄下**建立一個全新的獨立資料夾 `notebooklm_sources/`**，將 4 份純淨 UTF-8 Markdown 檔案放進去。**（既有專案檔案 0 刪除）**
* **輸入 `3` (雙源憲法大融合升級 v4.0)**：
  讀取辦公室舊憲法與住家 v3.0 憲法文字，合成最新的 v4.0 憲法並覆寫至系統腦區。**（既有專案代碼 0 變動）**
* **輸入 `4` (離場防呆 Commit & Push)**：
  為辦公室修改過的程式碼執行 `git add .` 與 `git commit` 並推上 GitHub 備份，防止住家/公司版本衝突。**（純備份、0 刪除）**
* **輸入 `0` (離開)**：
  直接關閉選單視窗，不進行任何變更。

---

## 💡 辦公室對話直接複製 Prompt (不開批次檔的替代方案)

若您在辦公室電腦不想跑批次檔，可以直接複製以下 Prompt 貼給辦公室的 Antigravity AI：

```markdown
請身為 Tech Lead 依據《全域開發與 Agent 實戰憲法 v3.0》，幫我執行以下任務：

1.【NotebookLM 脫水封包生成】：
  掃描當前辦公室專案，在專案根目錄下建立 `notebooklm_sources/` 資料夾，產出純淨 UTF-8 無亂碼的 4 份 Markdown 檔案 (1_GLOBAL_CONSTITUTION.md, 2_PROJECT_RULES.md, 3_TODAY_SUMMARY.md, 4_CORE_CODE.md)。

2.【雙源憲法大融合】：
  若本機有辦公室舊內規/憲法，請與住家的 v3.0 憲法進行「雙源比對與融合」，升級為《全域開發與 Agent 實戰憲法 v4.0 (雙源大一統版)》並覆寫至系統腦區 `C:\Users\<帳號>\.antigravity\skills\development_constitution\`。

3.【離場防呆與衝突預防】：
  下班或離場前，請自動檢查代碼變更，執行 `git add .`、`git commit -m "WIP: 辦公室離場進度暫存"` 並強制 `git push`！
```

---

## 🛠️ 辦公室極速對接 SOP (2 步驟)

1. **取得工具包**：在辦公室電腦執行 `git pull`（或 `git clone https://github.com/lianghao02/home.git`）。
2. **啟動選單**：進入 `home/office_sync_kit/` 資料夾，雙擊 `RUN_OFFICE_SETUP.bat` 按選單提示執行即可！
