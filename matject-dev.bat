@echo off
setlocal enabledelayedexpansion

rem IDEAS
rem Migrate colors to variable
rem Migrate Y/N to variable

echo SINCE MY INJECTOR IS GOING THROUGH FULL REWRITE, IT'S VERY UNSTABLE RIGHT NOW SO I DISABLED THE ABILITY TO USE IT FOR NOW.
pause
goto:EOF

title Matject - A material replacer for Minecraft (v1.0)
cls
cd "%~dp0"
if exist "tmp" rmdir /s /q "tmp"
if exist "MATERIALS\putMaterialsHere" del "MATERIALS\putMaterialsHere"
if exist "MCPACK\putMCPACKHere" del "MCPACK\putMCPACKHere"
if exist ".settings\.disableCooldown.txt" (set cooldown=0) else (set cooldown=2)
if not exist "MATERIALS\" mkdir "MATERIALS"
if not exist "MCPACK\" mkdir "MCPACK"

set "oldVer=.settings\.versionOld.txt"
set "skipIntro=.settings\.skipIntroduction.txt"
set "skipConfirmation=.settings\.skipConfirmation.txt"
set "useAutoAlways=.settings\.useAutoAlways.txt"
set "useManualAlways=.settings\.useManualAlways.txt"

:INTRO
timeout %cooldown% > NUL
if exist %skipIntro% goto GETMCLOC
echo Matject v1.0
echo A batch script to replace shader files in Minecraft. && echo.
echo [91m[^^!] May not work for large number of materials.[0m && echo.
echo Source: [4;96mgithub.com/faizul726/matject[0m && echo.
pause
cls

:GETMCLOC
echo [93m[*] Getting Minecraft installation location...[0m
echo.
for /f "tokens=*" %%i in ('powershell -command "Get-AppxPackage -Name Microsoft.MinecraftUWP | Select-Object -ExpandProperty InstallLocation"') do set "mcLocation=%%i"
if not defined mcLocation (
    echo [41;97m[^^!] Couldn't find Minecraft installation location.[0m
    echo.
    pause
    goto:EOF
)
echo [93m[*] Getting Minecraft version...[0m
echo.
for /f "tokens=*" %%i in ('powershell -command "Get-AppxPackage -Name Microsoft.MinecraftUWP | Select-Object -ExpandProperty Version"') do set "mcVer=%%i"

:MATCHVER
if not exist ".settings\" mkdir .settings
if not exist %oldVer% echo !mcVer! > %oldVer%
set /p mcVerOld=< %oldVer%
set mcVerOld=%mcVerOld: =%

:USERMEETSREQ
if exist "%ProgramFiles(x86)%\IObit\IObit Unlocker\IObitUnlocker.exe" (
    if exist ".settings\unlockedWindowsApps.txt" (
        cls
        echo [97m[*] IObit Unlocked installed and WindowsApps unlocked.
        echo [92m[*] Skipping to injection...[0m
        timeout %cooldown% > NUL
        cls && goto DLTOLDBAK
    )
)

:IOBITUNLOCKER
cls
echo [93m[?] Do you have "IObit Unlocker" installed? [0m[[92mY=Yes[0m, [91mN=No[0m] && echo.
echo [97m(Pressing N will open up download page)[0m && echo.
choice /c yn /n
if !errorlevel! equ 1 (
    cls
    if not exist "%ProgramFiles(x86)%\IObit\IObit Unlocker\IObitUnlocker.exe" (
        echo [91m[^^!] IObit Unlocker not installed in "%ProgramFiles%". Please reinstall.[0m && echo. && pause && goto:EOF
    ) else goto UNLOCKWINDOWSAPPS
) else echo [93mOpening IObit Unlocker page...[0m && echo. && start https://www.iobit.com/en/iobit-unlocker.php && pause && goto:EOF

:UNLOCKWINDOWSAPPS
echo [93m[?] Have you unlocked the "WindowsApps" folder? [0m[[92mY=Yes[0m, [91mN=No/not sure[0m] && echo.
echo [97m(Pressing N will ask to unlock)[0m && echo.
choice /c yn /n
if !errorlevel! equ 1 (
    if not exist ".settings\unlockedWindowsApps.txt" (
        echo [%date% %time%] - This file was created to indicate that WindowsApps is already unlocked and to skip the questions in Matject. > ".settings\unlockedWindowsApps.txt"
        ) 
        goto DLTOLDBAK
) else (
    goto UNLOCKCONSENT
)



:DLTOLDBAK
if exist "materials.bak\" if "!mcVer!" neq "%mcVerOld%" (
    cls
    echo [91m[^^!] Current version ^(v!mcVer!^) is not same as old version ^(v%mcVerOld%^). && echo.
    echo [93m[?] Do you want to remove old backup to avoid inconsistencies? [0m[[92mY=Yes[0m, [91mN=No[0m] && echo.
    choice /c yn /n
    if !errorlevel! equ 1 ( goto DLTOLDBAKCONFIRMED ) else ( goto DLTOLDBAKSKIPPED )
)

:DLTOLDBAKCONFIRMED
echo pause && pause
del %oldver% && echo !mcVer! > %oldVer%
rmdir /q /s "materials.bak\" && cls && echo [92m[*] Deleted old backup.[0m && echo.
goto BACKUPCONSENT

:DLTOLDBAKSKIPPED
echo [91m[^^!] This may cause inconsistency among shader files.[0m && echo.
pause
cls
echo [91m[^^!] Backup skipped. Because an older backup already exists. && echo.
goto INJECTION

:UNLOCKED
if exist "materials.bak\" (
    echo [93m[?] You already have a backup would you like to restore? [0m[[92mY=Yes[0m, [91mN=No[0m] [41;97m[WIP][0m && echo.
    choice /c yn /n
    if !errorlevel! equ 1 (
        set restoreType=full
        call restoreVanillaShaders
    ) else (
        cls
        echo [93m[^^!] Skipping backup because a backup already exists.[0m && echo.
        goto INJECTION        
    )
)

:BACKUPCONSENT
echo [93m[?] Do you want to backup vanilla materials? [0m[[92mY=Yes[0m, [91mN=No[0m] && echo.
choice /c yn /n
if !errorlevel! equ 1 (
    goto BACKUP
) else (
    cls
    echo [91m[^^!] Backup skipped.[0m && echo.
    goto INJECTION
)

:BACKUP
xcopy "!mcLocation!\data\renderer\materials" "materials.bak" /e /i /h /y && echo.
echo [92m[^^!] Backup done.[0m && echo.
pause
cls

:INJECTION
echo [93m[?] Which approach would you like to try?[0m && echo. && echo.
echo [92m[1] Auto approach[0m
echo Put shader.mcpack/zip in the [93mMCPACK[0m folder. Matject will extract the its materials to the [93mMaterials [0mfolder, and ask to inject.[97m && echo.
echo [94m[2] Manual approach[0m
echo Put [93m.material.bin[0m files in [93mmaterials[0m folder. Matject will ask to inject provided materials. && echo. && echo.
echo ^(Press 1 or 2 to confirm your choice^) && echo.
choice /c 12 /n
if !errorlevel! equ 1 (
    goto AUTO
) else (
    goto MANUAL
)

:AUTO
cls
set /a mcpackCount=0
set mcpackzip="tmp\mcpack.zip"
echo [92m[*] Auto approach selected[0m && echo.
echo [97mPlease add a [93mmcpack/zip[97m file in the [93m"MCPACK" [97mfolder.[0m && echo. && echo.
timeout 5 > NUL
explorer %cd%\MCPACK
echo After adding,
pause
cls

:AUTOLIST
set mcpackCount=0
set mcpack=
set mcpackName=
for %%f in ("MCPACK\*.mcpack" "MCPACK\*.zip") do (
    set /a mcpackCount+=1
    set "mcpack="%%f""
    set "mcpackName="%%~nxf""
)
if %mcpackCount% gtr 1 (
    echo [41;97m[^^!] Multiple MCPACK/ZIPs found. Please keep only one MCPACK/ZIP in MCPACK.[0m && echo.
    pause && cls && goto INJECTION
) else if %mcpackCount% equ 0 (
    echo [41;97m[^^!] No MCPACK/ZIP found.[0m && echo.
    echo [97m[*] Please add mcpack or zip in the [93mMCPACK[97m folder and try again.[0m && echo.
    pause && cls && goto INJECTION
)

:AUTOCONFIRM
echo [92m[*] Found MCPACK/ZIP:[97m %mcpackName%[0m && echo.
echo [93m[?] Would you like to use it for injecting? [0m[[92mY=Yes[0m, [91mN=Not now, later[0m] && echo.
choice /c yn /n
if !errorlevel! equ 2 (
    echo Okay, see you later. && echo.
    pause
    goto:EOF
)

:AUTOEXTRACT
if not exist "tmp\" mkdir tmp
copy %mcpack% "tmp\mcpack.zip" > NUL && echo. && echo. && echo.
echo [93m[*] Extracting shader to temporary folder...[0m && echo.
powershell -command "Expand-Archive -LiteralPath %mcpackzip% -DestinationPath tmp"

:AUTOFIND
for /r "tmp" %%f in (manifest.json) do (
    if exist "%%f" (
        set "matPath=%%~dpf"
        set "matPath=!matPath:~0,-1!"
    )
)
if not defined matPath (
    if exist "%cd%\tmp\" rmdir /s /q "%cd%\tmp"
    echo [41;97m[^^!] Not a valid MCPACK.[0m 
    echo.
    echo [97m[*] Please add a valid mcpack or zip in the [93mMCPACK[97m folder and try again.[0m
    pause
    goto INJECTION
)
move /Y "!matPath!\renderer\materials\*" "materials" > NUL
goto SEARCH

:MANUAL
cls
echo [94m[*] Manual approach selected[0m && echo.
echo [97m[*] Please add [93m.material.bin[97m files in the [93m"MATERIALS" [97mfolder.[0m && echo. && echo.
echo After adding,
pause

:SEARCH
cls
set srcList=
set replaceList=
set bins=
set srcCount=0
echo [93m[*] Looking for .bin files in "materials" folder...[0m && echo.
for %%f in (materials\*) do (
    set srcList=!srcList!,"%cd%\%%f"
    set "bins=!bins!"%%~nxF" "
    set replaceList=!replaceList!,"%mcLocation%\data\renderer\%%f"
    set /a srcCount+=1
)
if defined srcList (
    set "srcList=%srcList:~1%"
    set "replaceList=%replaceList:~1%"
) else (
    echo [41;97m[!] No materials found.[0m
    echo [97m[*] Please add .bin files the [93mMATERIALS[97m folder and try again.[0m && echo.
    pause
    cls
    goto INJECTION
)
echo [92mFound !srcCount! .bin file^(s^) in materials folder^^![0m && echo.
echo [97mMinecraft location:[0m !mcLocation!
echo [97mVersion:[0m !mcVer! && echo.
echo [92m[TIP] [97mYou can add subpack materials from [93m"!matPath!\subpacks" [97mand refresh the list. && echo.
echo [97m-------- Material list --------[0m
for %%f in (materials\*) do (
    echo * %%~nxf
)
echo [97m-------------------------------[0m && echo.

:INJECTCONSENT
echo [93m[?] Do you want to proceed with injecting? [0m[[92mY=Yes[0m, [93mR=Refresh list[0m, [91mN=No/not now[0m] && echo.
choice /c yrn /n
if !errorlevel! equ 1 (
    goto INJECTING
) else if !errorlevel! equ 2 (
    goto SEARCH
) else if !errorlevel! equ 3 (
    cls && pause
    goto:EOF
)

:INJECTING
cls
echo [93m[^^!] Injection confirmed[93m && echo.
if exist ".settings\.replaceList.log" (
    set "restoreType=partial"
    call restoreVanillaShaders
)

echo [93m[*] Deleting vanilla materials... ^(Step 1/2^)[0m && echo.

:INJECTING1
"%ProgramFiles(x86)%\IObit\IObit Unlocker\IObitUnlocker" /advanced /delete !replaceList!
if not !errorlevel! equ 0 (
    echo [41;97mPlease accept UAC.[0m && echo.
    echo [93mTrying again...[0m
    goto INJECTING1
) else (
    echo [92mStep 1/2 succeed^^![0m
)
echo. && echo.

echo [93m[*] Replacing with provided materials... ^(Step 2/2^)[0m && echo.

:INJECTING2
"%ProgramFiles(x86)%\IObit\IObit Unlocker\IObitUnlocker" /advanced /move !srcList! "!mcLocation!\data\renderer\materials"
if not !errorlevel! equ 0 (
    echo [41;97mPlease accept UAC.[0m && echo.
    echo [93mTrying again...[0m
    goto INJECTING2
) else (
    echo [92mStep 2/2 succeed^^![0m
    if exist "materials.bak\" echo !bins! > ".settings\.bins.log" && echo !srcList! > ".settings\.srcList.log" && echo !replaceList! > ".settings\.replaceList.log"
)

timeout %cooldown% > NUL
if exist "tmp\" rmdir /s /q tmp
cls
echo [42;97m [*] INJECTION SUCCEED^^! [0m && echo.
echo [92m[TIP] [97mImport and activate the shader resource pack for optimal experience. && echo. && echo.
echo Thanks for using [96mMatJect[97m, have a good day.[0m && echo.
pause
goto:EOF