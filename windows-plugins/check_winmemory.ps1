<#

TOPIC 
    check_memory

SHORT DESCRIPTION

Nagios check_memory script what show how much memory windows computer use


PARAMETER

check_memory.exe -Arguments -warn 80 -crit 90

#>

[CmdletBinding()]
param(
[ValidateRange(0,100)][string]$warn,
[ValidateRange(0,100)][string]$crit,
)

#---- Do not edit below! ------

if( [string]::IsNullOrEmpty($crit) -or [string]::IsNullOrEmpty($warn) ) {
Write-Host "check_memory.exe - Nagios plugin"
Write-Host "" 
Write-Host "Usage:"
Write-Host ""
Write-host "check_memory.exe -Arguments -warn 80 -crit 95"
Write-Host ""
exit
}

$version = $PSVersionTable.PSVersion.Major


#Check Powershell-version.
if ($version -ge "4") {
  $os = Get-Ciminstance Win32_OperatingSystem
}
elseif ($version -le "3") {
  $os = Get-WmiObject win32_OperatingSystem
}

$freememoryprosent = [math]::Round(($os.FreePhysicalMemory/$os.TotalVisibleMemorySize))
$usedmemory = $os.TotalVisibleMemorySize-$os.FreePhysicalMemory
$freememory = $os.FreePhysicalMemory
$maxmemory = $os.TotalVisibleMemorySize
$pctFree = [math]::Round(($usedmemory/$os.TotalVisibleMemorySize)*100,0)

#Calculating presentage from value
$warning = $maxmemory*("0.$warn")
$critical = $maxmemory*("0.$crit")

#Channge memory values to gigabytes
$freememoryGB = [Math]::Round(($freememory / 1KB))
$usedmemoryGB = [Math]::Round(($usedmemory / 1KB))
$maxmemoryGB = [Math]::Round(($maxmemory / 1KB))

if ($pctFree -ge $crit) {
    $status = "CRITICAL"
    $exitcode = 2
}
elseif ($pctFree -ge $warn) {
    $status = "WARNING"
    $exitcode = 1
}
elseif ($pctFree -le $warn) {
    $status = "OK"
    $exitcode = 0
}
else {
    $status = "UNKNOWN"
    $exitcode = 3
}

Write-Host -NoNewline "MEMORY $status - Used $($pctFree)% - Used:$($usedmemory)KB;; Free:$($freememory)KB;; Max:$($maxmemory)KB;; | used=$($usedmemory)KB;$warning;$critical;0;$maxmemory free=$($freememory)KB;;;; total=$($maxmemory)KB;;;;"

exit $exitcode
