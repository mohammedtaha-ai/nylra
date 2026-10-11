# Run only with the user's current consent to sleep/wake this workstation.
$ErrorActionPreference='Stop'
$probe=Join-Path (Get-Location) 'docs/evidence/probes/2026-10-10-n0'
. (Join-Path $probe 'windows-support.ps1')
$out=Join-Path $probe 'artifacts/2026-10-11-release'
$env:N0_LOG=Join-Path $out 'runtime-suspend.jsonl';$env:N0_CONTROL=Join-Path $out 'suspend-control.txt'
if(Test-Path $env:N0_LOG){throw 'Preserve evidence; use a new output path for another run'}
Add-Type @'
using System;using System.Runtime.InteropServices;using System.Diagnostics;
public class N0Power {
 [StructLayout(LayoutKind.Sequential)] public struct Luid {public uint Low;public int High;}
 [StructLayout(LayoutKind.Sequential)] public struct Privileges {public uint Count;public Luid Id;public uint Attributes;}
 [DllImport("advapi32.dll",SetLastError=true)] public static extern bool OpenProcessToken(IntPtr p,uint access,out IntPtr token);
 [DllImport("advapi32.dll",CharSet=CharSet.Unicode,SetLastError=true)] public static extern bool LookupPrivilegeValue(string system,string name,out Luid id);
 [DllImport("advapi32.dll",SetLastError=true)] public static extern bool AdjustTokenPrivileges(IntPtr token,bool disable,ref Privileges state,uint length,IntPtr previous,IntPtr returned);
 [DllImport("kernel32.dll")] public static extern bool CloseHandle(IntPtr token);
 [DllImport("powrprof.dll",SetLastError=true)] [return:MarshalAs(UnmanagedType.U1)] public static extern bool SetSuspendState([MarshalAs(UnmanagedType.U1)] bool hibernate,[MarshalAs(UnmanagedType.U1)] bool force,[MarshalAs(UnmanagedType.U1)] bool disableWake);
 public static int Enable() {IntPtr t; if(!OpenProcessToken(Process.GetCurrentProcess().Handle,0x28,out t))return Marshal.GetLastWin32Error();try{Luid l;if(!LookupPrivilegeValue(null,"SeShutdownPrivilege",out l))return Marshal.GetLastWin32Error();Privileges p=new Privileges{Count=1,Id=l,Attributes=2};if(!AdjustTokenPrivileges(t,false,ref p,0,IntPtr.Zero,IntPtr.Zero))return Marshal.GetLastWin32Error();return Marshal.GetLastWin32Error();}finally{CloseHandle(t);}}
}
'@
$p=Start-Process (Join-Path $probe 'target/release/nylra-n0-probe.exe') -PassThru -WindowStyle Hidden
try {
 Start-Sleep -Seconds 3;Send-N0Control 'normalize';Send-N0Control 'active';Send-N0Control 'focus-main';Start-Sleep -Seconds 6
 $before=Get-N0Rect 'N0 Synthetic Companion';$begin=Get-Date
 $privilege=[N0Power]::Enable();$called=$false;$errorCode=$privilege
 if($privilege -eq 0){$called=[N0Power]::SetSuspendState($false,$false,$false);if(!$called){$errorCode=[Runtime.InteropServices.Marshal]::GetLastWin32Error()}}
 $end=Get-Date
 Start-Sleep -Seconds 6;Send-N0Control 'snapshot';$after=Get-N0Rect 'N0 Synthetic Companion'
 $events=@(Get-WinEvent -FilterHashtable @{LogName='System';ProviderName='Microsoft-Windows-Kernel-Power';Id=42,107;StartTime=$begin.AddSeconds(-1)} -ErrorAction SilentlyContinue | Select-Object TimeCreated,Id,ProviderName)
 [pscustomobject]@{Begin=$begin.ToString('o');End=$end.ToString('o');ElapsedSeconds=($end-$begin).TotalSeconds;PrivilegeError=$privilege;SuspendCallSucceeded=$called;Win32Error=$errorCode;Before=$before;After=$after;OwnedProcessAlive=!$p.HasExited;KernelPowerEvents=$events}|ConvertTo-Json -Depth 6|Set-Content (Join-Path $out 'suspend-observations.json')
} finally {Send-N0Control 'exit';$p.WaitForExit(5000)|Out-Null}
