@echo OFF
setlocal
ECHO.
ECHO =============================
ECHO Running Admin shell
ECHO =============================

:init
setlocal DisableDelayedExpansion
set "batchPath=%~0"
for %%k in (%0) do set batchName=%%~nk
set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
setlocal EnableDelayedExpansion

:checkPrivileges
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
ECHO.
ECHO **************************************
ECHO Invoking UAC for Privilege Escalation
ECHO **************************************

ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
ECHO args = "ELEV " >> "%vbsGetPrivileges%"
ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
ECHO Next >> "%vbsGetPrivileges%"
ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
"%SystemRoot%\System32\WScript.exe" "%vbsGetPrivileges%" %*
exit /B

:gotPrivileges
setlocal & pushd .
cd /d %~dp0
if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)


::========================================================================================================================================

:BACKUP_CONFIG
color 0f
mode con cols=98 lines=32
title  BACKUP MAIN MENU
cls

echo:
echo:
echo                  ^|===============================================================^|
echo                  ^|                                                               ^| 
echo                  ^|                                                               ^|
echo                  ^|      [1] BACKUP WIFI CONFIGURATION                            ^|
echo                  ^|                                                               ^|
echo                  ^|      [2] RESTORE WIFI CONFIGURATION                           ^|
echo                  ^|                                                               ^|
echo                  ^|                                                               ^|
echo                  ^|      [3] NETWORK INTERFACES CONFIGURATION BACKUP              ^|
echo                  ^|                                                               ^|
echo                  ^|      [4] NETWORK INTERFACES CONFIGURATION RESTORE             ^|
echo                  ^|                                                               ^|
echo                  ^|                                                               ^|
echo                  ^|      [5] BACKUP DRIVERS                                       ^|
echo                  ^|                                                               ^|
echo                  ^|      [6] RESTORE DRIVERS                                      ^|
echo                  ^|                                                               ^|
echo                  ^|      [7] USER DATA BACKUP                                     ^|
echo                  ^|                                                               ^|
echo                  ^|                                                 [8] Go back   ^|
echo                  ^|                                                               ^|
echo                  ^|===============================================================^|
echo:          
choice /C:12345678 /N /M ">                   Enter Your Choice in the Keyboard [1,2,3,4,5,6,7,8] : "

if errorlevel  8 goto:end_COMPUTER_CONFIGURATION
if errorlevel  7 goto:USER_DATA
if errorlevel  6 goto:RESTORE_DRIVERS
if errorlevel  5 goto:BACHUP_DRIVERS
if errorlevel  4 goto:RESTORE_IP
if errorlevel  3 goto:Backup_IP
if errorlevel  2 goto:RESTORE_WIFI
if errorlevel  1 goto:BACKUP_WIFI
cls

::========================================================================================================================================

:BACKUP_WIFI
color 0f
Title WIFI BACKUP
mode con cols=98 lines=32
cls
echo
md C:\BACKUP\NETWORK\WIFI
cd C:\BACKUP\NETWORK\WIFI
echo This will backup the WiFi config to C:\BACKUP\NETWORK\WIFI
netsh wlan export profile key=clear folder=C:\BACKUP\NETWORK\WIFI
start .
pause & goto BACKUP_CONFIG

::========================================================================================================================================

:RESTORE_WIFI
color 0f
Title WIFI RESTORE
mode con cols=98 lines=32
cls
echo
cd C:\BACKUP\NETWORK\WIFI
dir
netsh wlan add profile filename="C:\BACKUP\NETWORK\WIFI\%WIFINAME%.xml" user=all
echo Enter complete file name excluding .xml
echo exapmle: WIFI-TSUNAMI
echo the .xml will be added automatically
Set /P %WIFINAME%=ENTER PEVIEWED WIFI NAME TO ADD WIFI BACK:
pause & goto BACKUP_CONFIG

::========================================================================================================================================

:Backup_IP
color 0f
Title NETWORK INTERFACES CONFIGURATION BACKUP
mode con cols=98 lines=32
cls
echo
md C:\BACKUP\NETWORK\Interfaces
cd C:\BACKUP\NETWORK\Interfaces
echo This section will backupp all the network interfaces confiuration to C:\BACKUP\NETWORK\Interfaces
netsh interface dump > C:\BACKUP\NETWORK\Interfaces\netcfg.txt
start .
pause & goto BACKUP_CONFIG

::========================================================================================================================================

:RESTORE_IP
color 0f
Title NETWORK INTERFACES CONFIGURATION RESTORE
mode con cols=98 lines=32
cls
echo
cd C:\BACKUP\NETWORK\Interfaces
dir
echo This section will restore all the network interfaces confiuration from C:\BACKUP\NETWORK\Interfaces
netsh exec C:\BACKUP\NETWORK\Interfaces\netcfg.txt
start .
pause & goto BACKUP_CONFIG

::========================================================================================================================================

:BACHUP_DRIVERS
color 0f
Title DRIVERS BACKUP
mode con cols=98 lines=32
cls
echo
md C:\BACKUP\DRIVERS_EXPORT
cd C:\BACKUP\DRIVERS_EXPORT
powershell.exe Dism /Online /Export-Driver /Destination:C:\BACKUP\DRIVERS_EXPORT
echo.The operation completed successfully.
pause & goto BACKUP_CONFIG

::========================================================================================================================================

:RESTORE_DRIVERS
color 0f
Title DRIVERS RESTORE
mode con cols=98 lines=32
cls
echo
cd C:\BACKUP\DRIVERS_EXPORT
dir
powershell.exe Dism /Online /Add-Driver /Driver:C:\BACKUP\DRIVERS_EXPORT
echo.The operation completed successfully.
pause & goto BACKUP_CONFIG

::========================================================================================================================================

:USER_DATA
color 0f
Title USER DATA BACKUP AND RESTORE
mode con cols=98 lines=32
cls
echo
echo This section is still a work in progress, STAY TUNED!
echo:
echo Important data that will be backed up are:
echo C:\User\Your username - Various folders including Desktop,
echo Documents, Downloads, Music, Pictures, Videos, and more.
echo:   
echo C:\ProgramData - Folders containing some settings and
echo logs for many of your programs.
echo:
echo To optimize overall performance it is recommended to backup data to an external 
echo location, to prevent the loss or coruption of data if the computer is turned off.
pause
cls
:Userlocation
color 0f
Title Selecting user profile
mode con cols=98 lines=32
echo Selecting user profile
SET "PScommand="POWERSHELL Add-Type -AssemblyName System.Windows.Forms; $FolderBrowse = New-Object System.Windows.Forms.OpenFileDialog -Property @{ValidateNames = $false;CheckFileExists = $false;RestoreDirectory = $true;FileName = 'Selected Folder';};$null = $FolderBrowse.ShowDialog();$FolderName = Split-Path -Path $FolderBrowse.FileName;Write-Output $FolderName""
FOR /F "usebackq tokens=*" %%Q in (`%PScommand%`) DO (
    ECHO %%Q
) > C:\userlocation.txt

for /f "tokens=*" %%x in ( C:\userlocation.txt) do (
set loc[]=%%x
)
echo %loc[]%
echo User profile location Selected
cls
Title Select where to save user profile
echo Saving user profile
SET "PScommand="POWERSHELL Add-Type -AssemblyName System.Windows.Forms; $FolderBrowse = New-Object System.Windows.Forms.OpenFileDialog -Property @{ValidateNames = $false;CheckFileExists = $false;RestoreDirectory = $true;FileName = 'Selected Folder';};$null = $FolderBrowse.ShowDialog();$FolderName = Split-Path -Path $FolderBrowse.FileName;Write-Output $FolderName""
FOR /F "usebackq tokens=*" %%Q in (`%PScommand%`) DO (
    ECHO %%Q
) > C:\userdestunation.txt

for /f "tokens=*" %%x in ( C:\userdestunation.txt) do (
set des[]=%%x
)
echo %des[]%
echo User profile destination Selected
cls
echo You are now about to copy %loc[]% to %des[]%
pause & goto progress
cls

:progress
Title Progress
mode con cols=98 lines=32
Robocopy "%loc[]%" "%des[]%" /MIR /XA:SH /XD AppData /XJD /R:5 /W:15 /MT:32
pause

echo.The operation completed successfully.
echo For restoration just rerun this section again.
pause & goto BACKUP_CONFIG
::========================================================================================================================================