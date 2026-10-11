# NON-PRODUCT synthetic icon; no artwork imported.
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$dir=Join-Path $PSScriptRoot 'native/icons';New-Item -ItemType Directory -Force $dir|Out-Null
$bitmap=New-Object Drawing.Bitmap 32,32;$graphics=[Drawing.Graphics]::FromImage($bitmap);$graphics.Clear([Drawing.Color]::Purple)
$icon=[Drawing.Icon]::FromHandle($bitmap.GetHicon());$stream=[IO.File]::Create((Join-Path $dir 'icon.ico'));$icon.Save($stream)
$stream.Dispose();$graphics.Dispose();$bitmap.Dispose()
