@echo off
setlocal enabledelayedexpansion
cls
cd "%~dp0"

set "murgi=KhayDhan"
set "title=Matject v3.0.1"
set "oldMinecraftVersion=.settings\oldMinecraftVersion.txt"
set "matbak=Backups\Materials (backup)"
set "exitmsg=echo. && echo Press any key to exit... && pause > NUL && exit"
set "backmsg=echo. && echo Press any key to go back... && pause > NUL && goto:EOF"
set "unlocked=.settings\unlockedWindowsApps.txt"
set "customMinecraftPath=.settings\customMinecraftPath.txt"

set useAutoAlways=".settings\useAutoAlways"
set useManualAlways=".settings\useManualAlways"
set thanksMcbegamerxx954=".settings\thanksMcbegamerxx954"
set "disableConfirmation=.settings\disableConfirmation"
set "disableInterruptionCheck=.settings\disableInterruptionCheck"
set "disableRetainOldBackups=.settings\disableRetainOldBackups"
set "disableSuccessMsg=.settings\disableSuccessMsg"
set "customMinecraftPath=.settings\customMinecraftPath.txt"
set "materialUpdaterArg=.settings\materialUpdaterArg.txt"
set "autoOpenMCPACK=.settings\autoOpenMCPACK"
set "backupDate=.settings\backupDate.txt"
set "ranOnce=.settings\ranOnce.txt"

REM TODO
REM - ADD DATETIME IN RESTORE CONSENT [DONE]
REM - DELETE MATERIALS.BAK IF EMPTY
REM - MIGRATE TO CHECK RENDERER FOLDER INSTEAD OF MANIFEST [DONE]
REM - ADD FOUND DETAILS IN GETMCDETAILS [DONE]
REM - STORE SHADER NAME FOR LATER USE
REM - MERGE UNLOCK...BAT WITH MATJECT
REM - RENAME MATBAK to Materiasls (backup) [DONE]

:: A material replacer for Minecraft.
:: Made by faizul726
:: https://faizul726.github.io/matject

:: WORK DIRECTORY SETUP
if not exist ".settings\" (mkdir .settings)
if not exist "MCPACK\" (mkdir MCPACK)
if exist "MCPACK\putMcpackHere" (del /q /s "MCPACK\putMcpackHere" > NUL)
if not exist "MATERIALS\" (mkdir MATERIALS)
if exist "MATERIALS\putMaterialsHere" (del /q /s "MATERIALS\putMaterialsHere" > NUL)
if exist "tmp" (rmdir /q /s tmp > NUL)

title %title%%

:: Load modules
call "modules\colors"

if exist %ranOnce% goto firstRunDone
echo !WHT!Welcome to %title%^^!!RST! ^(for the very first time^)
echo.
echo.
echo !ERR!=== Hol' up soldier^^! ===!RST!!YLW!
echo.
echo * Matject is not perfect, bugs may show up. Please report them in the GitHub repo.
echo * It assumes you HAVE NOT made any changes to materials, because it needs a copy of original materials to work properly.
echo !RED!* DO NOT MODIFY .settings and Backups folder.!YLW!
echo * Make sure the shader you are using SUPPORTS Windows ^(or says merged^).
echo * It may not work properly with ransomware protection and encryption.
echo * The worst thing that can happen with is material corruption.
echo   In that case you can restore materials or reinstall Minecraft.
echo * English is not my primary language. So, grammatical errors are expected.!RST!
echo.
echo.
set /p "firstRun= Type !GRN!yes!RST! to confirm:!GRN! "
echo.
if "!firstRun!" neq "yes" (
    echo !ERR![^^!] WRONG INPUT!RST!
    echo.

    echo Press any key to exit... && pause > NUL && exit
) else (
    echo !GRN![*] Confirmed.!RST!
    echo.

    echo First ran on: %date% - %time%>"!ranOnce!"

    timeout 2 > NUL
)

:firstRunDone
if not exist "%ProgramFiles(x86)%\IObit\IObit Unlocker\IObitUnlocker.exe" (
    echo !RED![^^!] You don't have IObit Unlocker installed.!RST!
    echo     It's required to use Matject.
    echo.

    echo !YLW![?] Would you like to download now?!RST!
    echo.

    echo [Y] Yes, open the site for me !CYN!^(www.iobit.com/en/iobit-unlocker.php^)!RST!
    echo [N] No, I will download later ^(exit^)
    REM - Add quitting message for N
    REM - Move IObit check to first
    REM - Add :BYE
    echo.

    choice /c yn /n

    if !errorlevel! equ 1 (
        start https://www.iobit.com/en/iobit-unlocker.php
        exit
    ) else (
        exit
    )
)


if exist "%customMinecraftPath%" (
    set /p MCLOCATION=<%customMinecraftPath%
    if not exist "!MCLOCATION!\AppxManifest.xml" (
        echo !ERR![^^!] Custom Minecraft path DOES NOT exist.!RST!
        echo.
        call "modules\getMinecraftDetails"
        if exist %materialUpdaterArg% del /q /s %materialUpdaterArg% > NUL
        echo.
        echo !GRN!TIP: You may disable custom Minecraft path in settings to remove this error.!RST!
        echo.
        pause
    ) else (
        if exist %oldMinecraftVersion% (
            set /p CURRENTVERSION=<%oldMinecraftVersion%
            set /p OLDVERSION=<%oldMinecraftVersion%
        ) else (
            for /f "tokens=*" %%i in ('powershell -command "Get-AppxPackage -Name Microsoft.MinecraftUWP | Select-Object -ExpandProperty Version"') do set "CURRENTVERSION=%%i && set "OLDVERSION=%%i"
        )
    )
) else (
    call "modules\getMinecraftDetails"
    cls
)

if /i "%MCLOCATION:~0,28%" neq "C:\Program Files\WindowsApps" (
    echo [%date% %time%] - This file was created to indicate that WindowsApps is already unlocked and skip the question in Matject.>"%unlocked%"
)

if not exist "%unlocked%" (
    cls 
    echo !YLW![*] You don't have "%ProgramFiles%\WindowsApps" folder unlocked.!RST!
    echo    !RED! Without unlocking Matject CANNOT backup materials.!RST!
    echo.
    echo.
    echo !YLW![?] Do you want to unlock?!RST!
    echo.
    echo [Y] Yes, ^(requires admin privilege^)
    echo [N] No ^(exit^)
    echo.
    choice /c yn /n
    echo.
    if "!errorlevel!" equ "1" (
        cls
        title %title% ^(unlocking WindowsApps^)
        echo !YLW![*] Unlocking...
        powershell -command start-process -file "modules\unlockWindowsApps.bat" -verb runas -Wait
        echo.
        if not exist %unlocked% (title %title% && echo !ERR![^^!] FAILED.!RST! && %exitmsg%) else (echo !GRN![*] Unlocked.!RST!)
        echo.
        ) else (if "!errorlevel!" equ "2" exit)
)

:DELETEOLDBACKUP
if exist "%matbak%\" (
    if "!CURRENTVERSION!" neq "!OLDVERSION!" (
    cls
    echo !RED![^^!] OLD SHADER BACKUP DETECTED!RST!
    echo.
    echo !YLW![*] Current version: v!CURRENTVERSION!, old version: v!OLDVERSION!.!RST!
    echo.
    if exist %disableRetainOldBackups% (
        echo !YLW![*] Deleting old backup...!RST!
        echo.
        rmdir /q /s "%matbak%"
    ) else (
        echo !YLW![*] Renaming old backup...!RST!
        echo.
        rename "%matbak%" "Old Materials Backup (v!OLDVERSION!)"
    )
    if exist %materialUpdaterArg% del /q /s %materialUpdaterArg% > NUL
    echo !CURRENTVERSION!>%oldMinecraftVersion%
    call "modules\backupMaterials"
    timeout 2 > NUL
    )
) else (call "modules\backupMaterials")

for /f "tokens=2 delims==" %%a in ('"wmic os get localdatetime /value"') do (
    set "deiteu=%%a"
    set /a "imy=!deiteu:~2,2!-21"
    set "deiteu=!deiteu:~4,4!"
)


if exist %useAutoAlways% (
    set mode=1
    set "userMode=Auto mode"
    goto userMode
) else (
    if exist %useManualAlways% (
        set mode=2
        set "userMode=Manual mode"
        goto userMode
    ) else (
        goto INTRODUCTION
    )
)
:userMode
echo !YLW![*] Opening !userMode! in 2 seconds...!RST!
echo !YLW!    Press [S] to open settings directly...!RST!
echo.

choice /c s0 /t 2 /d 0 /n > NUL

if !errorlevel! equ 1 goto option6
cls
goto option!mode!


:INTRODUCTION
cls
if exist "%customMinecraftPath%" (
    echo !YLW![*] Using custom Minecraft path: "!MCLOCATION!"!RST!
    echo.
)
if "%deiteu%" equ "0726" echo !BLU!Happy birthday rwxrw-r-- U+1F337 ^(%imy%^)!RST!
set RESTORETYPE=
if %time:~0,2% geq 00 if %time:~0,2% lss 05 echo !WHT!You should sleep now.
if %time:~0,2% geq 05 if %time:~0,2% lss 12 echo !WHT!Good morning
if %time:~0,2% geq 12 if %time:~0,2% lss 18 echo !WHT!Good afternoon
if %time:~0,2% geq 18 if %time:~0,2% lss 22 echo !WHT!Good evening
if %time:~0,2% geq 22 if %time:~0,2% lss 24 echo !WHT!Good night
echo Welcome to %title%^^!!RST!
echo.
echo !CYN!faizul726.github.io/matject!RST!
echo.
echo.

echo !YLW![?] Which method would you like to use?!RST!
echo.

echo !GRN![1] Auto!RST!
echo Put shader.mcpack/zip in the MCPACK folder.
echo Matject will extract the its materials and ask to inject.
echo.
echo !BLU![2] Manual!RST!
echo Put .material.bin files in the MATERIALS folder.
echo Matject will ask to inject provided materials. 
echo.

if defined matjectNEXT (
    echo [3] matjectNEXT Auto
    echo Dhan
    echo.
)

echo.
echo !WHT![H] Help    [A] About    [S] Settings    [O] Others!RST!
echo.
echo.
echo !RED![B] Exit!RST!
echo.
echo !YLW!Press corresponding key to confirm your choice...!RST!
echo.
choice /c 123hasob /n

goto option!errorlevel!

cls

:option8
exit

:option7
cls
echo !RED!^< [B] Back!RST!
echo !WHT!
echo [1] Restore default materials
echo [2] Open Minecraft app folder
echo [3] Open Minecraft data folder
echo !RST!
echo !YLW!Press corresponding key to confirm your choice...!RST!
echo.
choice /c 123b /n
goto others!errorlevel!

:others4
goto INTRODUCTION

:others3
explorer "%localAppData%\packages\Microsoft.MinecraftUWP_8wekyb3d8bbwe\LocalState\games\com.mojang"
goto option7 

:others2
explorer "!MCLOCATION!"
goto option7

:others1
call "modules\restoreMaterials"
goto option7

:option6
call "modules\settings"
title %title%
goto INTRODUCTION

:option5
call "modules\about"
title %title%
goto INTRODUCTION

:option4
call "modules\help"
title %title%
goto INTRODUCTION

:option3
if not defined matjectNEXT goto INTRODUCTION

:option1
cls
set MCPACKCOUNT=
echo !YLW![AUTO METHOD SELECTED]!RST!
echo.
echo.
echo.

echo !YLW![^^!] Please add a mcpack/zip in the MCPACK folder.!RST!
echo.
echo.

explorer "%cd%\MCPACK"

echo After adding,
pause



:AUTOLIST
for %%f in ("MCPACK\*.mcpack" "MCPACK\*.zip") do (
    set /a MCPACKCOUNT+=1
    set "MCPACK=%%f"
    set "MCPACKNAME=%%~nxf"
)

if not defined MCPACKCOUNT (
    cls
    echo !ERR![^^!] NO MCPACK/ZIP FOUND.!RST!
    echo.

    echo !YLW![*] Please add mcpack/zip in the MCPACK folder and try again.!RST!
    %backmsg:~0,56%
    cls
    goto INTRODUCTION
)

if %MCPACKCOUNT% gtr 1 (
    cls
    echo !ERR![^^!] MULTIPLE MCPACK/ZIP FOUND.!RST!
    echo.

    echo !YLW![*] Please keep only one mcpack/zip in MCPACK and try again.!RST!
    %backmsg:~0,56%
    cls
    goto INTRODUCTION
)

cls
echo !GRN![*] Found MCPACK/ZIP: "!MCPACKNAME!"!RST!
echo.
if exist %disableConfirmation% goto AUTOEXTRACT

echo !YLW![?] Would you like to use it for injecting? [Y/N]!RST!
echo.

choice /c yn /n

if !errorlevel! neq 1 (
    cls
    goto INTRODUCTION
)



:AUTOEXTRACT
set MCPACKDIR=
if not exist "tmp\" mkdir tmp
copy "!MCPACK!" "tmp\mcpack.zip" > NUL
echo.
echo.
echo.

echo !YLW![*] Extracting MCPACK/ZIP to temporary folder...!RST!
echo.

powershell -command "Expand-Archive -LiteralPath 'tmp\mcpack.zip' -DestinationPath 'tmp'"

for /r "tmp" %%f in (manifest.json) do (
    if exist "%%f" (
        if exist "%%~dpfrenderer\" (
            set "MCPACKDIR=%%~dpf"
            set "MCPACKDIR=!MCPACKDIR:~0,-1!"
        ) else (
            echo !ERR![^^!] Not a RenderDragon shader.!RST!
            echo.
            echo !YLW![*] Please add a valid mcpack/zip in the MCPACK folder and try again.!RST!
            %backmsg:~0,56%
            rmdir /q /s "tmp"
            cls
            goto INTRODUCTION
        )
    )
)

if not defined MCPACKDIR (
    echo !ERR![^^!] NOT A VALID MCPACK.!RST!
    echo.
    echo !YLW![*] Please add a valid mcpack/zip in the MCPACK folder and try again.!RST!
    %backmsg:~0,56%
    rmdir /q /s "tmp"
    cls
    goto INTRODUCTION
)

move /Y "!MCPACKDIR!\renderer\materials\*" "MATERIALS\" > NUL
goto SEARCH



:option2
cls
echo !YLW![MANUAL METHOD SELECTED]!RST!
echo.
echo.
echo.

echo !YLW!Please add ".material.bin" files in the "MATERIALS" folder.!RST!
echo.
echo.

explorer "%cd%\MATERIALS"

echo After adding,
pause



:SEARCH
cls
set SRCLIST=
set REPLACELISTEXPORT=
set BINS=
set SRCCOUNT=

echo !YLW![*] Looking for .bin files in the "MATERIALS" folder...!RST!
echo.

for %%f in (MATERIALS\*.material.bin) do (
    set "MTBIN=%%~nf"
    set "SRCLIST=!SRCLIST!,"%cd%\%%f""
    set "BINS=!BINS!"!MTBIN:~0,-9!-" "
    set "REPLACELISTEXPORT=!REPLACELISTEXPORT!,"_!MTBIN:~0,-9!-""
    set /a SRCCOUNT+=1
)

if not defined SRCLIST (
    echo !ERR![^^!] NO MATERIALS FOUND.!RST!
    echo.

    echo !YLW![*] Please add .bin files the MATERIALS folder and try again.!RST!
    %backmsg:~0,56%
    cls
    goto INTRODUCTION
)

set "SRCLIST=%SRCLIST:~1%"
set "REPLACELISTEXPORT=%REPLACELISTEXPORT:~1%"
set "REPLACELIST=%REPLACELISTEXPORT:-=.material.bin%"
set "REPLACELIST=%REPLACELIST:_=!MCLOCATION!\data\renderer\materials\%"

echo !GRN![*] Found !SRCCOUNT! material(s) in the "MATERIALS" folder.!RST!
echo.

echo !WHT!Minecraft location:!RST! !MCLOCATION!
echo !WHT!Minecraft version:!RST!  v!CURRENTVERSION!
echo.

echo !CYN![TIP] You can add subpack materials from "tmp\subpacks" and ^(R^)efresh the list to use them.!RST!
echo.

echo -------- Material list --------
for %%f in (MATERIALS\*) do (
    echo * %%~nxf
)
echo -------------------------------
echo.



:INJECTCONSENT
if exist %disableConfirmation% goto INJECTIONCONFIRMED
echo !YLW![?] Do you want to proceed with injecting? [Y/R/N]!RST!
echo.

choice /c yrn /n

if !errorlevel! equ 1 goto INJECTIONCONFIRMED
if !errorlevel! equ 2 goto SEARCH
if !errorlevel! equ 3 cls && pause && goto:EOF



:INJECTIONCONFIRMED
cls
echo !YLW![INJECTION CONFIRMED]!YLW!
echo.

if exist %thanksMcbegamerxx954% call "modules\updateMaterials"
if exist "tmp\" (rmdir /q /s tmp)
echo.
echo.
if exist ".settings\.bins.log" (
    set "RESTORETYPE=partial"
    call "modules\restoreMaterials"
)



:STEP1
echo !YLW![*] Deleting vanilla materials... ^(Step 1/2^)!RST!
echo.

"%ProgramFiles(x86)%\IObit\IObit Unlocker\IObitUnlocker" /advanced /delete !REPLACELIST!

if !errorlevel! neq 0 (
    cls
    echo !ERR![^^!] Please accept UAC.!RST!
    echo.
    echo Press any key to try again...
    pause > NUL
    goto STEP1
)



echo !GRN![*] Step 1/2 succeed.!RST!
echo.
echo.



:STEP2
echo !YLW![*] Replacing with provided materials... ^(Step 2/2^)!RST!
echo.

"%ProgramFiles(x86)%\IObit\IObit Unlocker\IObitUnlocker" /advanced /move !SRCLIST! "!MCLOCATION!\data\renderer\materials"

if !errorlevel! neq 0 (
    cls
    echo !ERR![^^!] Please accept UAC.!RST!
    echo.
    echo Press any key to try again...
    pause > NUL
    goto STEP2
)

echo !GRN![*] Step 2/2 succeed.!RST!
if exist "%matbak%\" echo !REPLACELISTEXPORT!>".settings\.restoreList.log" && echo !BINS!>".settings\.bins.log"

if exist "tmp" (rmdir /q /s tmp)

:SUCCESS
cls
echo !GRN![*] INJECTION SUCCEED.!RST!
echo.

if exist %autoOpenMCPACK% (
    if "!MCPACKNAME:~-7,7!" equ ".mcpack" "MCPACK\!MCPACKNAME!"
) 
if not exist %autoOpenMCPACK% (
    if "!MCPACKNAME:~-7,7!" neq ".mcpack" goto skip
    echo !YLW![?] Do you want to import the MCPACK for full experience?!RST!
    echo.
    echo [Y] Yes    [N] No
    echo.
    choice /c yn /n
    if "!errorlevel!" equ "2" goto skip

    echo !GRN![TIP] You can enable Auto open MCPACK from settings.!RST!
    "MCPACK\!MCPACKNAME!"
)

:skip
echo !GRN![TIP] Activate the shader resource pack for full experience.!RST!
if exist %disableSuccessMsg% (
    timeout 1 > NUL
    exit
)

echo.
echo.

echo !CYN!Thanks for using Matject, have a good day.!RST!
%exitmsg%