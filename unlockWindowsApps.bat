@echo off
cd "%~dp0"

::echo SINCE MY INJECTOR IS GOING THROUGH FULL REWRITE, IT'S VERY UNSTABLE RIGHT NOW SO I DISABLED THE ABILITY TO USE IT FOR NOW.
::pause
::goto:EOF

cls
echo [*] This script is separate from Matject. It's used to take ownership of WindowsApps folder to list content inside.
echo.

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [41;97mYOU MUST RUN THIS AS ADMIN![0m
    pause 
)

:: Removed /r /d y from takeown and icacls as those are unnecessary

takeown /f "%ProgramFiles%\WindowsApps" 
if %errorlevel% equ 0 ( echo [%date% %time%] - This file was created to indicate that WindowsApps is already unlocked and skip the question in Matject. > ".settings\unlockedWindowsApps.txt" && timeout 2 > NUL )