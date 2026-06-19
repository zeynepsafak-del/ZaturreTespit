$target = "c:\Users\Zeynep\Downloads\ZaturreTespit-main (4)\ZaturreTespit-main\assets\images\logo.png"
$source = "C:\Users\Zeynep\.gemini\antigravity-ide\brain\d7843846-f0a9-48bf-b0d4-7e92807fb403\media__1781857761304.png"
[System.IO.Directory]::CreateDirectory("c:\Users\Zeynep\Downloads\ZaturreTespit-main (4)\ZaturreTespit-main\assets\images")
[System.IO.File]::Copy($source, $target, $true)
