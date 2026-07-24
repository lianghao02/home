import os
import sys
import subprocess

def main():
    print("=" * 65)
    print("🚀 辦公室 Antigravity 一鍵同步、NotebookLM 脫水與憲法融合工具包 (v3.0 -> v4.0)")
    print("=" * 65)
    print(" [1] 一鍵將「全域憲法 v3.0」寫入辦公室 Antigravity 系統腦區")
    print(" [2] 一鍵掃描辦公室所有專案，生成 NotebookLM 脫水封包 (notebooklm_sources/)")
    print(" [3] 一鍵雙源憲法大融合 (融合辦公室舊內規與住家 v3.0，升級至 v4.0)")
    print(" [4] 執行離場防呆自動 Git Commit & Push")
    print(" [0] 離開")
    print("=" * 65)
    
    choice = input("請選擇操作項目 (0-4): ").strip()
    kit_dir = os.path.dirname(os.path.abspath(__file__))
    scratch_dir = os.path.dirname(kit_dir)

    if choice == "1":
        sys_dir = os.path.expanduser(r"~\.antigravity\skills\development_constitution")
        os.makedirs(sys_dir, exist_ok=True)
        shutil.copy(os.path.join(kit_dir, "instructions_v3.md"), os.path.join(sys_dir, "instructions.md"))
        shutil.copy(os.path.join(kit_dir, "skill_v3.json"), os.path.join(sys_dir, "skill.json"))
        print(f"✅ 全域憲法 v3.0 已成功寫入辦公室 Antigravity 系統目錄: {sys_dir}")

    elif choice == "2":
        from generate_sources import run_dehydration
        run_dehydration(scratch_dir)
        print("✅ 辦公室所有專案之 NotebookLM 脫水封包匯出完成！")

    elif choice == "3":
        office_path = input("請輸入辦公室舊憲法/內規檔案路徑 (直接 Enter 自動讀取預設): ").strip()
        if not office_path:
            office_path = os.path.expanduser(r"~\.antigravity\skills\development_constitution\instructions.md")
        from merge_constitution import merge_constitutions
        merge_constitutions(office_path)
        from generate_sources import run_dehydration
        run_dehydration(scratch_dir)

    elif choice == "4":
        print("🚀 執行離場防呆 Git Commit & Push...")
        subdirs = [os.path.join(scratch_dir, d) for d in os.listdir(scratch_dir) if os.path.isdir(os.path.join(scratch_dir, d))]
        for pd in subdirs:
            if os.path.exists(os.path.join(pd, ".git")):
                try:
                    subprocess.run(["git", "add", "-A"], cwd=pd, check=True)
                    subprocess.run(["git", "commit", "-m", "WIP: 辦公室離場進度暫存"], cwd=pd, check=True)
                    subprocess.run(["git", "push", "origin", "main"], cwd=pd, check=True)
                    print(f"✅ 成功 Push 專案: {os.path.basename(pd)}")
                except Exception as e:
                    print(f"ℹ️ {os.path.basename(pd)} 無變更或已是最新的")

    print("\n🎉 操作完成！")

if __name__ == "__main__":
    main()
