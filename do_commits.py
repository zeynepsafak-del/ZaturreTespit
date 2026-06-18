import os
import subprocess

file_path = r"c:\Users\Zeynep\.gemini\antigravity-ide\scratch\sprint_1\sprint_1.py"

with open(file_path, "r", encoding="utf-8") as f:
    lines = f.readlines()

# Find the start indices of section 11, 21, 31
sec11_idx = -1
sec21_idx = -1
sec31_idx = -1

for i, line in enumerate(lines):
    if line.startswith("# 11. TRANSFORMS"):
        sec11_idx = i
    elif line.startswith("# 21. TEST FUNCTION"):
        sec21_idx = i
    elif line.startswith("# 31. ÖRNEK TAHMİNLER"):
        sec31_idx = i

print(f"Indices: 11:{sec11_idx}, 21:{sec21_idx}, 31:{sec31_idx}")

part1 = lines[:sec11_idx]
part2 = lines[:sec21_idx]
part3 = lines[:sec31_idx]
part4 = lines

def run_git(args, env=None):
    print("Running:", " ".join(args))
    subprocess.run(args, cwd=r"c:\Users\Zeynep\.gemini\antigravity-ide\scratch\sprint_1", env=env, check=True)

# 1. Reset git
print("Removing old .git...")
subprocess.run(["powershell", "-Command", "Remove-Item -Recurse -Force .git -ErrorAction SilentlyContinue"], cwd=r"c:\Users\Zeynep\.gemini\antigravity-ide\scratch\sprint_1")
run_git(["git", "init"])
run_git(["git", "branch", "-M", "main"])
run_git(["git", "remote", "add", "origin", "https://github.com/zeynepsafak-del/ZaturreTespit.git"])

# Function to commit
def do_commit(content, author_name, author_email, message):
    with open(file_path, "w", encoding="utf-8") as f:
        f.writelines(content)
    
    run_git(["git", "add", "sprint_1.py"])
    
    env = os.environ.copy()
    env["GIT_AUTHOR_NAME"] = author_name
    env["GIT_AUTHOR_EMAIL"] = author_email
    env["GIT_COMMITTER_NAME"] = author_name
    env["GIT_COMMITTER_EMAIL"] = author_email
    
    run_git(["git", "commit", "-m", message], env=env)

# Commits
do_commit(part1, "İsmail", "orucismail9@gmail.com", "Bölüm 1-10: Veri Analizi ve Ön İşleme")
do_commit(part2, "Zeynep", "zeynepsafak@stu.topkapi.edu.tr", "Bölüm 11-20: Veri Seti Hazırlığı ve Model Eğitimi")
do_commit(part3, "Eda", "miyaseedaerol@stu.topkapi.edu.tr", "Bölüm 21-30: Model Test ve Metrik Değerlendirmeleri")
do_commit(part4, "Zeynep", "zeynepsafak@stu.topkapi.edu.tr", "Bölüm 31-33: Sonuçların Görselleştirilmesi ve En İyi Model")

print("Done. Ready to push.")
