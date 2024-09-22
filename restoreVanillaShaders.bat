@echo off
setlocal enabledelayedexpansion

cd %~dp0
cls
if not defined mcLocation ( for /f "tokens=*" %%i in ('powershell -command "Get-AppxPackage -Name Microsoft.MinecraftUWP | Select-Object -ExpandProperty InstallLocation"') do set "mcLocation=%%i" )
if not defined mcLocation (
    echo [41;97m[^^!] Couldn't find Minecraft installation location.[0m
    echo.
    pause
    goto:EOF
)

if exist "tmp\" (
    rmdir /s /q tmp
    mkdir "tmp"
) else (
    mkdir "tmp"
)

if "%restoreType%" equ "full" (
    echo [93m[*] Restore type: Full[0m && echo.
    goto fullRestore
) else if "%restoreType%"=="partial" (
    goto partialRestore
)

if not exist "materials.bak\" (
    echo [41;97mNo previous backup found.[0m && echo.
    pause
    goto:EOF
)

set rstrCount=
for %%f in ("materials.bak\*") do set /a rstrCount+=1
if not defined rstrCount (
    echo [41;97mmaterials.bak folder is empty.[0m && echo.
    pause
    goto:EOF
)

echo [93m[?] How would you like to restore?[0m
echo.
echo [1] Full restore (restore all materials)
echo [2] Partial restore (only restore the ones modified in previous injection)
echo [3] Exit
echo.
choice /c 123 /n 
if !errorlevel! equ 1 (
    cls
    echo [93m[*] Restore type: Full[0m && echo.
    goto fullRestore
)
if !errorlevel! equ 2 (
    cls
    echo [93m[*] Restore type: Partial[0m && echo.
    echo WORK IN PROGRESS
    pause && goto:EOF
    goto partialRestore
)
if !errorlevel! equ 3 goto:EOF

:fullRestore
set splitCount=
for %%f in ("materials.bak\*") do (
    set /a splitCount+=1
    if !splitCount! leq 20 (
        move /y "%%f" "tmp\" > NUL
    )
)
if defined splitCount (
    set /a stepCount+=1
    goto fullRestore
) else (
    move "tmp\*" "materials.bak" > NUL
    set /a stepCount=stepCount+2
)

echo [92mFound !rstrCount! materials(s).[0m

echo [91m[^^!] Please accept all UAC prompts or it will fail.[0m && echo. && echo.

timeout 5 > NUL && cls

echo [93m[*] Running step 1/%stepCount%: Deleting game materials...[0m && echo.

:fr-delete
if exist "!mcLocation!\data\renderer\materials\" (
    "%ProgramFiles(x86)%\IObit\IObit Unlocker\IObitUnlocker" /advanced /delete "!mcLocation!\data\renderer\materials"
) else (
    echo [92m[*] Done[0m && echo. && echo.
    echo [93m[*] Running step 2/%stepCount%: Creating materials folder...[0m && echo.
    if not exist "tmp\materials" mkdir "tmp\materials"
    goto fr-mkdir
)
cls
if !errorlevel! neq 0 (
    echo [93m[*] Running step 1/%stepCount%: Deleting game materials...[0m && echo.
    echo [41;97mPlease accept UAC.[0m
    echo.
    echo [93mTrying again...[0m
    echo.
    goto fr-delete
)


:fr-mkdir
"%ProgramFiles(x86)%\IObit\IObit Unlocker\IObitUnlocker" /advanced /move "%cd%\tmp\materials\" "!mcLocation!\data\renderer\"

if !errorlevel! neq 0 (
    cls
    echo [93m[*] Running step 2/%stepCount%: Creating materials folder...[0m && echo.
    echo [41;97mPlease accept UAC.[0m
    echo.
    echo [93mTrying again...[0m
    echo.
    goto fr-mkdir
) 

echo [92m[*] Done[0m && echo. && echo. 
timeout 3 > NUL
set currentStep=3

:fr-split
cls
echo [93m[*] Running step %currentStep%/%stepCount%: Moving materials...[0m && echo.
set splitCount=
for %%f in ("materials.bak\*") do (
    set /a splitCount+=1
    if !splitCount! leq 20 (
        move /y "%%f" "tmp\" > NUL
    )
)
if not defined splitCount (
    if exist "materials.bak\" (
        rmdir /s /q materials.bak
    )
    if exist "tmp\" (
        rmdir /s /q "tmp"
    )
    goto completed
)

:fr-move
set srcList=
for %%f in (tmp\*) do (
    set srcList=!srcList!,"%cd%\%%f"
    echo [93m[Moving] [0m%%~nxf
)
if defined srcList set "srcList=%srcList:~1%" 

"%ProgramFiles(x86)%\IObit\IObit Unlocker\IObitUnlocker" /advanced /move !srcList! "!mcLocation!\data\renderer\materials"
if !errorlevel! equ 0 (
    cls
    set /a currentStep+=1
    goto fr-split
) else (
    cls
    echo [93m[*] Running step %currentStep%/%stepCount%: Moving materials...[0m && echo.
    echo [41;97mPlease accept UAC.[0m
    echo.
    echo [93mTrying again...[0m
    echo.
    goto fr-move
)

:partialRestore
echo WIP && pause && goto:EOF
if exist ".settings\.replaceList.log" (
    move ".settings\*.log" "tmp\"
    set /p bins=< "tmp\.bins.log"
    set /p srcList=< "tmp\.srcList.log"
    set /p replaceList=< "tmp\.replaceList.log"
    goto restore1
) else (
    echo [41;97mNo logs found for previous injection.[0m
)


:restore1
"%ProgramFiles(x86)%\IObit\IObit Unlocker\IObitUnlocker" /advanced /delete %replaceList%
if not !errorlevel! equ 0 (
    echo [41;97mPlease accept UAC next time^^![0m
    echo.
    pause
    cls
    goto restore1
) else (
    echo [92mStep 1/2 succeed^^![0m
)

echo.
echo.

:restore2
"%ProgramFiles(x86)%\IObit\IObit Unlocker\IObitUnlocker" /advanced /move !srcList! "!mcLocation!\data\renderer\materials"
if not !errorlevel! equ 0 (
    echo [41;97mPlease accept UAC next time^^![0m
    echo.
    pause
    cls
    goto restore2
) else (
    echo [92mStep 2/2 succeed^^![0m
    timeout 2 > NUL
    goto: EOF
)

:completed
cls
echo [92m[*] Done[0m
pause
goto:EOF
