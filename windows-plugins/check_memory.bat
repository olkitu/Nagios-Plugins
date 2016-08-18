:: check_memory.bat plugin to icinga and nagios 
::
::
:: 
::
:: 

@echo off


set /a Warning=90%
set /a Critical=95%


for /f "skip=1" %%p in ('wmic os get freephysicalmemory') do ( 
  set FreeMemory=%%p
  goto :done
)
:done
for /f "skip=1" %%s in ('wmic os get TotalVisibleMemorySize') do ( 
  set TotalMemory=%%s
  goto :done
)
:done


set /a UsedMemory=%TotalMemory% - %FreeMemory%
set /a UsedMemoryPct=%UsedMemory% * 100 / %TotalMemory%

set /a Warn=%TotalMemory% / 100 * %Warning%
set /a Crit=%TotalMemory% / 100 * %Critical%

set perf_data=used=%UsedMemory%KB;%Warn%;%Crit%;;%TotalMemory% free=%FreeMemory%KB;;;; total=%TotalMemory%KB;;;;


if %UsedMemoryPct% geq %Critical% goto critical
if %UsedMemoryPct% geq %Warning% goto warning
if %UsedMemoryPct% lss %Warning% goto ok
goto unknown





:warning
echo MEMORY WARNING - %UsedMemoryPct%%% Used - Free: %FreeMemory%KB;; Used: %UsedMemory%KB;; Total: %TotalMemory%KB;; ^| %perf_data%
exit /b 1

:critical
echo MEMORY CRITICAL - %UsedMemoryPct%%% Used - Free: %FreeMemory%KB;;Used: %UsedMemory%KB;; Total: %TotalMemory%KB;; ^| %perf_data%
exit /b 2

:ok
echo MEMORY OK - %UsedMemoryPct%%% Used - Free: %FreeMemory%KB;; Used: %UsedMemory%KB;; Total: %TotalMemory%KB;; ^| %perf_data%
exit /b 0
:unknown
echo MEMORY UNKNOWN - %UsedMemoryPct%%% Used - Free: %FreeMemory%KB;; Used: %UsedMemory%KB;; Total: %TotalMemory%KB;; ^| %perf_data%
exit /b 3
