# NON-PRODUCT Windows probe helpers. Capture only owned windows, never the full desktop.
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms
Add-Type @'
using System;
using System.Runtime.InteropServices;
public class N0Win {
 [StructLayout(LayoutKind.Sequential)] public struct Rect {public int L,T,R,B;}
 [DllImport("user32.dll",CharSet=CharSet.Unicode)] public static extern IntPtr FindWindow(IntPtr cls,string title);
 [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h,out Rect r);
 [DllImport("user32.dll")] public static extern uint GetDpiForWindow(IntPtr h);
 [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
 [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h,int cmd);
 [DllImport("user32.dll")] public static extern bool SetCursorPos(int x,int y);
 [DllImport("user32.dll")] public static extern void mouse_event(uint flags,uint x,uint y,uint data,UIntPtr extra);
 [DllImport("user32.dll")] public static extern void keybd_event(byte key,byte scan,uint flags,UIntPtr extra);
 [DllImport("user32.dll")] public static extern bool SetProcessDpiAwarenessContext(IntPtr context);
}
'@
[N0Win]::SetProcessDpiAwarenessContext([IntPtr](-4)) | Out-Null
function Send-N0Control([string]$Command) {Set-Content -LiteralPath $env:N0_CONTROL -Value $Command -NoNewline; Start-Sleep -Milliseconds 450}
function Get-N0Rect([string]$Title) {
 $h=[N0Win]::FindWindow([IntPtr]::Zero,$Title);if($h -eq [IntPtr]::Zero){throw "Window missing: $Title"}
 $rect=New-Object N0Win+Rect;[N0Win]::GetWindowRect($h,[ref]$rect)|Out-Null
 [PSCustomObject]@{Title=$Title;Handle=$h.ToInt64();Left=$rect.L;Top=$rect.T;Width=$rect.R-$rect.L;Height=$rect.B-$rect.T;DPI=[N0Win]::GetDpiForWindow($h)}
}
function Save-N0Window([string]$Title,[string]$Path) {
 $r=Get-N0Rect $Title;$bmp=New-Object Drawing.Bitmap $r.Width,$r.Height;$g=[Drawing.Graphics]::FromImage($bmp)
 $g.CopyFromScreen($r.Left,$r.Top,0,0,$bmp.Size);$bmp.Save($Path,[Drawing.Imaging.ImageFormat]::Png);$g.Dispose();$bmp.Dispose();$r
}
function Click-N0([int]$X,[int]$Y) {
 [N0Win]::SetCursorPos($X,$Y)|Out-Null;Start-Sleep -Milliseconds 500
 [N0Win]::mouse_event(2,0,0,0,[UIntPtr]::Zero);Start-Sleep -Milliseconds 60;[N0Win]::mouse_event(4,0,0,0,[UIntPtr]::Zero);Start-Sleep -Milliseconds 200
}
