:INITGPT
CLS
ECHO Prepare Hard Disk for WinNTSetup3 (GPT)
ECHO --------------------------------------------
ECHO.
ECHO list disk >> list.txt
diskpart /s list.txt
DEL list.txt>nul
ECHO.
SET /p disk="Which disk number would you like to prepare? (e.g. 0): "
IF [%disk%] == [] GOTO INITGPT
ECHO.
ECHO --WARNING-- This will FORMAT the selected disk and ERASE ALL DATA
ECHO.
ECHO You selected disk ---^> %disk%
ECHO.
CHOICE /C YN /M "Is this correct "
IF %ERRORLEVEL% == 1 GOTO INITGPT2
CLS
ECHO Preperation Aborted, No changes have been made...
ECHO.
PAUSE
EXIT
:INITGPT2
SET "b="
FOR %%b IN (Q P O N M L K J I) DO (
IF NOT EXIST "%%b:" SET BOOTDRV=%%b
)
SET "c="
FOR %%c IN (Z Y X W V U T S R) DO (
IF NOT EXIST "%%c:" SET DATADRV=%%c
)
ECHO select disk %disk% >> initgpt.txt
ECHO clean >> initgpt.txt
ECHO convert gpt >> initgpt.txt
ECHO cre par efi size=100 >> initgpt.txt
ECHO for quick fs=fat32 label="System" >> initgpt.txt
ECHO assign letter %BOOTDRV% >> initgpt.txt
ECHO cre par msr size=16 >> initgpt.txt
ECHO cre par pri >> initgpt.txt
ECHO shrink minimum=450 >> initgpt.txt
ECHO for quick fs=ntfs label="Windows" >> initgpt.txt
ECHO assign letter %DATADRV% >> initgpt.txt
ECHO cre par pri >> initgpt.txt
ECHO for quick fs=ntfs label="WinRE" >> initgpt.txt
ECHO set id="de94bba4-06d1-4d40-a16a-bfd50179d6ac" >> initgpt.txt
:RUNGPT
CLS
diskpart /s initgpt.txt
DEL initgpt.txt >nul
ECHO.
ECHO This drive is now prepared for WinNTSetup4 - GPT\UEFI
ECHO.
ECHO The following drive letters have been assigned, and
ECHO will be automatically loaded into WinNTSetup4
ECHO.
ECHO Boot Drive----------: %BOOTDRV%
ECHO Installation Drive--: %DATADRV% 
ECHO.
PAUSE
ECHO.
ECHO Please wait while WinNTSetup4 loads...
CD %~dp0
powershell -Command "(gc template.ini) -replace 'BootDest=changeme', 'BootDest=%BOOTDRV%:' | Out-File tempgpt.ini"
powershell -Command "(gc tempgpt.ini) -replace 'TempDest=changeme', 'TempDest=%DATADRV%:' | Out-File GPT.ini"
CD ..
START winntsetup_x64.exe /cfg:prep\GPT.ini
EXIT
rem
:Deploy
rem
rem Deploy Windows
rem
echo off
echo.
for /f %%X in ('wmic volume get DriveLetter ^, Label ^| find "W10USB"') do DISM /Apply-Image /ImageFile:%%X\Sources\install.wim /index:1 /ApplyDir:W:\
rem
rem Create boot entry
rem
W:\Windows\System32\bcdboot W:\Windows /s S:
rem
rem Create necessary folders, 
rem copy answer file to Panther folder,
rem copy recovery environment to WinRE partition
rem
md W:\Windows\Panther
md R:\Recovery\WinRE
copy X:\Scripts\unattend.xml W:\Windows\Panther\
xcopy /h W:\Windows\System32\Recovery\Winre.wim R:\Recovery\WinRE\
rem
rem Set recovery image location
rem
W:\Windows\System32\Reagentc /Setreimage /Path R:\Recovery\WinRE /Target W:\Windows
cls
echo.
rem
rem Restart to OOBE
rem
echo Computer will restart to OOBE in a few seconds...
W:\Windows\System32\shutdown -r -t 5
