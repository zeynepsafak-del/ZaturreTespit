import os
import shutil

os.makedirs('assets/images', exist_ok=True)
src = r'C:\Users\Zeynep\.gemini\antigravity-ide\brain\d7843846-f0a9-48bf-b0d4-7e92807fb403\logo_1781857958295.png'
dst = r'assets/images/logo.png'

if os.path.exists(src):
    shutil.copy(src, dst)
    print("Copied successfully!")
else:
    print("Source image not found!")
