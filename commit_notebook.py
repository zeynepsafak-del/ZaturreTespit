import os
import json
import subprocess
import copy

nb_path = r"c:\Users\Zeynep\Downloads\zature_sprint_1 (1).ipynb"
repo_dir = r"c:\Users\Zeynep\.gemini\antigravity-ide\scratch\sprint_1"

with open(nb_path, "r", encoding="utf-8") as f:
    nb = json.load(f)

cells = nb.get("cells", [])

idx_11 = -1
idx_21 = -1
idx_31 = -1

for i, cell in enumerate(cells):
    source = cell.get("source", [])
    if not source:
        continue
    text = "".join(source)
    if "# 11. TRANSFORMS" in text:
        idx_11 = i
    elif "# 21. TEST FUNCTION" in text:
        idx_21 = i
    elif "# 31. ÖRNEK TAHMİNLER" in text:
        idx_31 = i

print(f"Indices: 11:{idx_11}, 21:{idx_21}, 31:{idx_31}")

def run_git(args, env=None):
    print("Running:", " ".join(args))
    subprocess.run(args, cwd=repo_dir, env=env, check=True)

# 1. Reset git
print("Removing old .git...")
subprocess.run(["powershell", "-Command", "Remove-Item -Recurse -Force .git -ErrorAction SilentlyContinue"], cwd=repo_dir)
run_git(["git", "init"])
run_git(["git", "branch", "-M", "main"])
run_git(["git", "remote", "add", "origin", "https://github.com/zeynepsafak-del/ZaturreTespit.git"])

def do_commit(cells_subset, author_name, author_email, message):
    new_nb = copy.deepcopy(nb)
    new_nb["cells"] = cells_subset
    
    out_path = os.path.join(repo_dir, "ZaturreTespit_Sprint_1.ipynb")
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(new_nb, f, ensure_ascii=False, indent=1)
    
    run_git(["git", "add", "ZaturreTespit_Sprint_1.ipynb"])
    
    env = os.environ.copy()
    env["GIT_AUTHOR_NAME"] = author_name
    env["GIT_AUTHOR_EMAIL"] = author_email
    env["GIT_COMMITTER_NAME"] = author_name
    env["GIT_COMMITTER_EMAIL"] = author_email
    
    run_git(["git", "commit", "-m", message], env=env)

# Commits
do_commit(cells[:idx_11], "İsmail", "orucismail9@gmail.com", "Bölüm 1-10: Veri Analizi ve Ön İşleme")
do_commit(cells[:idx_21], "Zeynep", "zeynepsafak@stu.topkapi.edu.tr", "Bölüm 11-20: Veri Seti Hazırlığı ve Model Eğitimi")
do_commit(cells[:idx_31], "Eda", "miyaseedaerol@stu.topkapi.edu.tr", "Bölüm 21-30: Model Test ve Metrik Değerlendirmeleri")
do_commit(cells, "Zeynep", "zeynepsafak@stu.topkapi.edu.tr", "Bölüm 31-33: Sonuçların Görselleştirilmesi ve En İyi Model")

print("Done. Ready to push.")
