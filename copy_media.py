import os
import shutil

src = r'C:\Users\Zeynep\.gemini\antigravity-ide\brain\d7843846-f0a9-48bf-b0d4-7e92807fb403\media__1781857761304.png'
dst_dir = r'c:\Users\Zeynep\Downloads\ZaturreTespit-main (4)\ZaturreTespit-main\assets\images'
dst = os.path.join(dst_dir, 'logo.png')

os.makedirs(dst_dir, exist_ok=True)
shutil.copy(src, dst)
print('Copied successfully!')
