<#

TOPIC 
    check_disk.exe

SHORT DESCRIPTION

Nagios check_memory script what show how much disk is used


PARAMETER

check_disk.exe


[CmdletBinding()]
param(
[ValidateRange(0,100)][string]$warn,
[ValidateRange(0,100)][string]$crit
)

#>

#Parametrit jotka määrittävät milloin merkitään kriittiseksi tai annetaan varoitus. Tämä näkyy Nagioksessa / Icinga2:ssa eri väreinä.

#$warn = 80
#$crit = 95

# - No not edit below this line!

if( [string]::IsNullOrEmpty($crit) -or [string]::IsNullOrEmpty($warn) ) {
Write-Host "check_disk.exe - Nagios plugin"
Write-Host "" 
Write-Host "Usage:"
Write-Host ""
Write-host "check_disk.exe -Arguments -warn 80 -crit 95"
Write-Host ""
exit
}

    $output = ""
    $perfdata = ""
    
    #Luetaan kaikkien levyjen tiedot
    $disks = Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType = 3"| select *;

    foreach($disk in $disks) {

    $used = $disk.Size - $disk.FreeSpace
    $free = $disk.FreeSpace
    $size = $disk.Size
    $deviceID = $disk.DeviceID;

    $percentFree = [Math]::Round(($free / $size) * 100, 2);
    $percentUsed = [Math]::Round(($used / $size) * 100, 2);
    $freeGB = [Math]::Round(($free / 1GB))
    $usedGB = [Math]::Round(($used / 1GB))
    $sizeGB = [Math]::Round(($size / 1GB))

    $warning = $size*("0.$warn")
    $critical = $size*("0.$crit")

    $pctFree = [math]::Round(($used/$size)*100,0)

    if ($exitcode -lt 1) {
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
    }
    else {
        if ($exitcode -eq 2) {
              $status = "CRITICAL"
         }
         elseif ($exitcode -eq 1) {
            $status = "WARNING"
         }
         else {
            $status = "UNKNOWN"
         }

    }

    

    $output += "$($deviceID) Used $($usedGB)GB  $($percentUsed)%;; Free $($freeGB)GB $($percentFree)%;; "
    $perfdata += "$($deviceID)\Used=$($used)B;$warning;$critical;0;$size "

    }


    Write-Host -NoNewline "DISK $status -  $output | $perfdata"



exit $exitcode
