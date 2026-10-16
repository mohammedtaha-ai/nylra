param([string]$RunName='independent-companion',[switch]$Profile,[switch]$WebViewOnly)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'windows-support.ps1')
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
Add-Type @'
using System;using System.Runtime.InteropServices;
public class CompanionWin {
 [StructLayout(LayoutKind.Sequential)] public struct Rect {public int L,T,R,B;}
 [DllImport("user32.dll")]public static extern bool GetClientRect(IntPtr h,out Rect r);
 [DllImport("user32.dll")]public static extern bool IsWindowVisible(IntPtr h);
 [DllImport("user32.dll")]public static extern bool PostMessageW(IntPtr h,uint m,IntPtr w,IntPtr l);
 [DllImport("user32.dll")]public static extern bool SetForegroundWindow(IntPtr h);
 [DllImport("user32.dll")]public static extern uint GetWindowThreadProcessId(IntPtr h,out uint p);
 [DllImport("user32.dll")]public static extern int GetWindowLongW(IntPtr h,int n);
}
'@
$out=New-NylraRunDir $RunName
if(Test-Path (Join-Path $out 'native.json')){throw 'Use a fresh RunName'}
$observations=[Collections.Generic.List[object]]::new()
function FindOwnedElement([string]$name,[Windows.Automation.ControlType]$type){
 $a=[Windows.Automation.PropertyCondition]::new([Windows.Automation.AutomationElement]::NameProperty,$name)
 $b=[Windows.Automation.PropertyCondition]::new([Windows.Automation.AutomationElement]::ControlTypeProperty,$type)
 [Windows.Automation.AutomationElement]::RootElement.FindFirst([Windows.Automation.TreeScope]::Descendants,[Windows.Automation.AndCondition]::new($a,$b))
}
function TrayItem([string]$name){
 $icon=FindOwnedElement 'NYLRA' ([Windows.Automation.ControlType]::Button)
 if(!$icon){$overflow=FindOwnedElement 'Show Hidden Icons' ([Windows.Automation.ControlType]::Button);if(!$overflow){throw 'Owned tray overflow unavailable'};$r=$overflow.Current.BoundingRectangle;Click-N0 ([int]($r.Left+$r.Width/2)) ([int]($r.Top+$r.Height/2));$icon=FindOwnedElement 'NYLRA' ([Windows.Automation.ControlType]::Button)}
 if(!$icon){throw 'Owned NYLRA icon unavailable'}
 $r=$icon.Current.BoundingRectangle;[N0Win]::SetCursorPos([int]($r.Left+$r.Width/2),[int]($r.Top+$r.Height/2))|Out-Null
 [N0Win]::mouse_event(8,0,0,0,[UIntPtr]::Zero);[N0Win]::mouse_event(16,0,0,0,[UIntPtr]::Zero);Start-Sleep -Milliseconds 300
 $item=FindOwnedElement $name ([Windows.Automation.ControlType]::MenuItem);if(!$item){throw "Missing tray item $name"};$r=$item.Current.BoundingRectangle;Click-N0 ([int]($r.Left+$r.Width/2)) ([int]($r.Top+$r.Height/2))
}
$oldArgs=$env:WEBVIEW2_ADDITIONAL_BROWSER_ARGUMENTS
$port=9335
$listener=[Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback,$port);$listener.Start();$listener.Stop()
$env:WEBVIEW2_ADDITIONAL_BROWSER_ARGUMENTS="--remote-debugging-port=$port"
$exe=Join-Path (Get-NylraTarget) 'debug/nylra-desktop.exe'
$process=Start-Process $exe -PassThru -WindowStyle Hidden
$env:WEBVIEW2_ADDITIONAL_BROWSER_ARGUMENTS=$oldArgs
$form=$null
try {
 Start-Sleep -Seconds 4
 $main=Get-N0Rect 'NYLRA';$character=Get-N0Rect 'AYLUL';$mainH=[IntPtr]$main.Handle;$charH=[IntPtr]$character.Handle
 foreach($handle in @($mainH,$charH)){$ownerId=0;[CompanionWin]::GetWindowThreadProcessId($handle,[ref]$ownerId)|Out-Null;if($ownerId -ne $process.Id){throw 'Window is not owned by this test process'}}
 if(![CompanionWin]::IsWindowVisible($charH)){throw 'Companion did not become visible'}
 $style=[CompanionWin]::GetWindowLongW($charH,-16);$extended=[CompanionWin]::GetWindowLongW($charH,-20)
 $observations.Add(@{Scenario='native-window-style';Window=$character;Style=$style;ExtendedStyle=$extended})
 # Tao keeps style bits and removes non-client chrome through WM_NCCALCSIZE.
 $client=[CompanionWin+Rect]::new();if(![CompanionWin]::GetClientRect($charH,[ref]$client)){throw 'Client rectangle unavailable'}
 if(($client.R-$client.L) -ne $character.Width -or ($client.B-$client.T) -ne $character.Height -or ($extended -band 8) -eq 0){throw 'Companion has non-client frame or is not topmost'}
 $observations.Add(@{Scenario='native-companion-start';Passed=$true;Window=$character;Style=$style;ExtendedStyle=$extended;Binary=(Get-FileHash $exe).Hash})
 [CompanionWin]::PostMessageW($mainH,0x10,[IntPtr]::Zero,[IntPtr]::Zero)|Out-Null;Start-Sleep -Milliseconds 300
 if([CompanionWin]::IsWindowVisible($mainH) -or ![CompanionWin]::IsWindowVisible($charH)){throw 'Closing main affected companion'}
 $observations.Add(@{Scenario='close-main-independence';Passed=$true})
 if(!$WebViewOnly){
 $x=$character.Left+[int]($character.Width/2);$y=$character.Top+[int]($character.Height/2)
 [N0Win]::SetCursorPos($x,$y)|Out-Null;[N0Win]::mouse_event(2,0,0,0,[UIntPtr]::Zero)
 foreach($offset in 1..12){[N0Win]::SetCursorPos(($x-10*$offset),($y-4*$offset))|Out-Null;Start-Sleep -Milliseconds 50}
 [N0Win]::mouse_event(4,0,0,0,[UIntPtr]::Zero);Start-Sleep -Milliseconds 400
 $moved=Get-N0Rect 'AYLUL'
 if($moved.Left -eq $character.Left -and $moved.Top -eq $character.Top){throw 'Real native drag did not move companion'}
 if([CompanionWin]::IsWindowVisible($mainH)){throw 'Drag incorrectly opened main'}
 $observations.Add(@{Scenario='actual-native-drag';Passed=$true;Before=$character;After=$moved})
 Click-N0 ($moved.Left+[int]($moved.Width/2)) ($moved.Top+[int]($moved.Height/2));Start-Sleep -Milliseconds 300
 if(![CompanionWin]::IsWindowVisible($mainH)){throw 'Short character click did not open main'}
 $observations.Add(@{Scenario='actual-character-click';Passed=$true})
 TrayItem 'Hide AYLUL';foreach($attempt in 1..20){if(![CompanionWin]::IsWindowVisible($charH)){break};Start-Sleep -Milliseconds 100};if([CompanionWin]::IsWindowVisible($charH)){throw 'Tray hide failed'}
 TrayItem 'Show AYLUL';foreach($attempt in 1..20){if([CompanionWin]::IsWindowVisible($charH)){break};Start-Sleep -Milliseconds 100};if(![CompanionWin]::IsWindowVisible($charH)){throw 'Tray show failed'}
 $observations.Add(@{Scenario='actual-tray-companion-toggle';Passed=$true})
 }
 $form=[Windows.Forms.Form]::new();$form.Text='NYLRA owned focus witness';$form.Width=340;$form.Height=100;$form.Show();[Windows.Forms.Application]::DoEvents();[CompanionWin]::SetForegroundWindow($form.Handle)|Out-Null
 $nodeArgs=@((Join-Path $PSScriptRoot 'companion-native.mjs'),'--port',"$port",'--output',(Join-Path $out 'native.json'),'--foreground',"$($form.Handle.ToInt64())",'--pid',"$($process.Id)",'--profile',"$($Profile.IsPresent.ToString().ToLower())")
 & node @nodeArgs
 if($LASTEXITCODE -ne 0){throw 'Native WebView checks failed; inspect native.json'}
 $observations.Add(@{Scenario='native-webview-state-focus-recovery';Passed=$true})
 TrayItem 'Quit NYLRA';if(!$process.WaitForExit(5000)){throw 'Quit did not exit owned application'}
 $observations.Add(@{Scenario='actual-tray-quit';Passed=$true})
}finally{
 $observations|ConvertTo-Json -Depth 7|Set-Content (Join-Path $out 'windows.json')
 if($form){$form.Close();$form.Dispose()}
 if(!$process.HasExited){Stop-Process -Id $process.Id;$process.WaitForExit(5000)|Out-Null}
}
