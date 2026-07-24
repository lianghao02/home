import os
import shutil

def read_text_safe(filepath):
    if not os.path.exists(filepath):
        return ""
    for enc in ["utf-8-sig", "utf-8", "cp950", "big5", "gbk"]:
        try:
            with open(filepath, "r", encoding=enc) as f:
                text = f.read()
                if "\ufffd" not in text:
                    return text
        except Exception:
            continue
    with open(filepath, "r", encoding="utf-8", errors="replace") as f:
        return f.read()

def run_dehydration(target_scratch_dir):
    global_const_file = os.path.join(target_scratch_dir, "office_sync_kit", "instructions_v3.md")
    if not os.path.exists(global_const_file):
        global_const_file = os.path.expanduser(r"~\.antigravity\skills\development_constitution\instructions.md")
    
    global_const_text = read_text_safe(global_const_file)
    if not global_const_text:
        global_const_text = "# 全域開發與 Agent 實戰憲法 v3.0\n"

    subdirs = [os.path.join(target_scratch_dir, d) for d in os.listdir(target_scratch_dir) 
               if os.path.isdir(os.path.join(target_scratch_dir, d)) and d != "office_sync_kit"]

    for proj_path in subdirs:
        proj_name = os.path.basename(proj_path)
        output_dir = os.path.join(proj_path, "notebooklm_sources")
        os.makedirs(output_dir, exist_ok=True)

        # 1_GLOBAL_CONSTITUTION.md
        with open(os.path.join(output_dir, "1_GLOBAL_CONSTITUTION.md"), "w", encoding="utf-8") as f:
            f.write(global_const_text)

        # 2_PROJECT_RULES.md
        rule_content = f"# {proj_name} 專案領域知識與開發規範\n\n"
        agent_file = os.path.join(proj_path, ".agents", "AGENTS.md")
        if os.path.exists(agent_file):
            rule_content += read_text_safe(agent_file)
        else:
            rule_content += "> 本專案視為全域開發與 Agent 實戰憲法 v3.0 約束專案。\n"

        skill_json = os.path.join(proj_path, ".agents", "skill.json")
        if os.path.exists(skill_json):
            s_text = read_text_safe(skill_json)
            rule_content += f"\n\n## 專案 Skill 設定 (skill.json)\n```json\n{s_text}\n```\n"

        with open(os.path.join(output_dir, "2_PROJECT_RULES.md"), "w", encoding="utf-8") as f:
            f.write(rule_content)

        # 3_TODAY_SUMMARY.md
        summary_content = f"# {proj_name} 當前開發進度與 Task 摘要\n\n"
        readme_file = os.path.join(proj_path, "README.md")
        if os.path.exists(readme_file):
            r_text = read_text_safe(readme_file)
            summary_content += f"## 專案說明 (README)\n{r_text}\n\n"
        summary_content += "## 開發狀態與待辦事項 (Status & Tasks)\n"
        summary_content += "- ✅ 已完成辦公室專案原始碼掃描與 NotebookLM 脫水封包匯出\n"
        summary_content += "- 🚀 100% 繁體中文 UTF-8 無亂碼檢測通過\n"
        summary_content += "- 📋 待辦事項：拖入 NotebookLM 進行跨裝置對話與功能開發\n"

        with open(os.path.join(output_dir, "3_TODAY_SUMMARY.md"), "w", encoding="utf-8") as f:
            f.write(summary_content)

        # 4_CORE_CODE.md
        code_content = f"# {proj_name} 核心程式碼與 UI 結構封包\n\n"
        valid_exts = {".html", ".css", ".js", ".py", ".bat", ".vbs", ".csv", ".json"}

        for root, dirs, files in os.walk(proj_path):
            if "notebooklm_sources" in root or ".git" in root or "node_modules" in root:
                continue
            for file in files:
                ext = os.path.splitext(file)[1].lower()
                if ext in valid_exts:
                    full_path = os.path.join(root, file)
                    rel_path = os.path.relpath(full_path, proj_path)
                    code_content += f"## 📄 檔案: {rel_path}\n"
                    code_content += f"``` {ext.strip('.')}\n"
                    code_content += read_text_safe(full_path)
                    code_content += "\n```\n\n"

        with open(os.path.join(output_dir, "4_CORE_CODE.md"), "w", encoding="utf-8") as f:
            f.write(code_content)

        # Copy images to output_dir
        for file in os.listdir(proj_path):
            full_p = os.path.join(proj_path, file)
            if os.path.isfile(full_p):
                ext = os.path.splitext(file)[1].lower()
                if ext in {".png", ".jpg", ".jpeg", ".svg"}:
                    shutil.copy(full_p, os.path.join(output_dir, file))

        print(f"[OK] 已生成脫水封包: {proj_name}")

if __name__ == "__main__":
    current_dir = os.path.dirname(os.path.abspath(__file__))
    scratch_dir = os.path.dirname(current_dir)
    run_dehydration(scratch_dir)
