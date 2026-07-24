import os

def read_text_safe(filepath):
    if not os.path.exists(filepath):
        return ""
    for enc in ["utf-8-sig", "utf-8", "cp950", "big5"]:
        try:
            with open(filepath, "r", encoding=enc) as f:
                return f.read()
        except Exception:
            continue
    return ""

def merge_constitutions(office_constitution_path):
    kit_dir = os.path.dirname(os.path.abspath(__file__))
    home_v3_path = os.path.join(kit_dir, "instructions_v3.md")
    
    home_v3_text = read_text_safe(home_v3_path)
    office_text = read_text_safe(office_constitution_path)

    merged_text = "# Agent Skill: 全域開發與 Agent 實戰憲法 (Prime Directives) v4.0 (雙源大一統版)\n\n"
    merged_text += "## 0. 雙源融合聲明\n"
    merged_text += "- 本憲法由「住家 Agent 實戰憲法 v3.0」與「辦公室公務內規」無縫融合而成，具備雙邊最高約束效力。\n\n"
    merged_text += home_v3_text.replace("# Agent Skill: 全域開發與 Agent 實戰憲法 (Prime Directives) v3.0", "")
    
    if office_text:
        merged_text += "\n\n## 6. 辦公室特有業務與安全內規 (Office Domain Rules)\n"
        merged_text += office_text

    # Write merged v4.0 to system directory
    sys_dir = os.path.expanduser(r"~\.antigravity\skills\development_constitution")
    os.makedirs(sys_dir, exist_ok=True)
    
    sys_inst = os.path.join(sys_dir, "instructions.md")
    with open(sys_inst, "w", encoding="utf-8") as f:
        f.write(merged_text)
        
    print(f"[OK] 成功將雙源憲法融合並升級為 v4.0，寫入本機系統腦區: {sys_inst}")

if __name__ == "__main__":
    office_path = input("請輸入辦公室舊憲法檔案路徑 (直接按 Enter 將自動掃描本機預設): ").strip()
    if not office_path:
        office_path = os.path.expanduser(r"~\.antigravity\skills\development_constitution\instructions.md")
    merge_constitutions(office_path)
