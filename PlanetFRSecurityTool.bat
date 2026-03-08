@echo off
setlocal enabledelayedexpansion
title PlanetFR Security Tool
set "logfile=PlanetFR_Log.txt"

:: Find the Defender Path automatically
set "MpPath="
if exist "%ProgramFiles%\Windows Defender\MpCmdRun.exe" set "MpPath=%ProgramFiles%\Windows Defender\MpCmdRun.exe"
if exist "%ProgramData%\Microsoft\Windows Defender\Platform" (
    for /f "delims=" %%i in ('dir /b /s "%ProgramData%\Microsoft\Windows Defender\Platform\MpCmdRun.exe"') do set "MpPath=%%i"
)

set "currentcolor=0B"

:menu
cls
color %currentcolor%
echo.
echo           ___  _                    _  _____ ____  
echo          / _ \^| ^| __ _ _ __   ___ ^| ^|_^|  ___^|  _ \ 
echo         ^| ^| ^| ^| ^|/ _` ^| '_ \ / _ \^| __^| ^|_  ^| ^|_) ^|
echo         ^| ^|_^| ^| ^| (_^| ^| ^| ^| ^|  __/^| ^|_^|  _^| ^|  _ ^< 
echo          \___/^|_^|\__,_^|_^| ^|_^|\___^| \__^|_^|   ^|_^| \_\
echo =================================================================
echo                    SYSTEM SECURITY SCANNER
echo                      Created by PlanetFR
echo =================================================================
echo.
echo  [1] Close Software         [5] View Scan History (Log)
echo  [2] Quick Scan             [6] Repair System Files (SFC)
echo  [3] Full System Scan       [7] Toggle Theme Color
echo  [4] Scan Downloads Folder
echo.
echo =================================================================
set /p userchoice="Select an option (1-7): "

if "%userchoice%"=="1" goto end
if "%userchoice%"=="2" set "stype=1" & set "sname=Quick Scan" & goto startscan
if "%userchoice%"=="3" set "stype=2" & set "sname=Full Scan" & goto startscan
if "%userchoice%"=="4" set "stype=3" & set "sname=Downloads Scan" & goto startscan
if "%userchoice%"=="5" goto viewlog
if "%userchoice%"=="6" goto repair
if "%userchoice%"=="7" goto togglecolor
goto menu

:togglecolor
if "%currentcolor%"=="0B" (set "currentcolor=0A") else (set "currentcolor=0B")
goto menu

:startscan
cls
echo [%date% %time%] Starting %sname%...
echo %date% %time% - Started %sname% >> "%logfile%"

:: Use START to run the scan in the background so the spinner can run
if "%stype%"=="3" (
    start "" /b "%MpPath%" -Scan -ScanType 3 -File "%USERPROFILE%\Downloads" >nul 2>&1
) else (
    start "" /b "%MpPath%" -Scan -ScanType %stype% >nul 2>&1
)

:: Improved Spinner Logic to prevent freezing
set "spinindex=0"
:spinloop
timeout /t 1 >nul
tasklist /fi "IMAGENAME eq MpCmdRun.exe" | find /i "MpCmdRun.exe" >nul
if %errorlevel% neq 0 goto postscan

set /a "spinindex=(spinindex+1)%%4"
if !spinindex!==0 set "char=|"
if !spinindex!==1 set "char=/"
if !spinindex!==2 set "char=-"
if !spinindex!==3 set "char=\"

cls
echo ===================================================
echo           PLANETFR SCAN IN PROGRESS
echo ===================================================
echo.
echo  Task: %sname%
echo  Status: Working... [!char!]
echo.
echo  Note: This window will change automatically 
echo  once the scan is finished.
goto spinloop

:repair
cls
echo [%date% %time%] Starting System File Repair...
echo %date% %time% - Started SFC Repair >> "%logfile%"
sfc /scannow
goto postscan

:postscan
echo %date% %time% - Task Completed. >> "%logfile%"
cls
echo ===================================================
echo   DONE! TASK COMPLETED SUCCESSFULLY
echo ===================================================
echo  
echo.
echo  [R] Return to Menu
echo  [L] View Log File
echo  [X] Exit
echo.
set /p postchoice="Selection: "
if /i "%postchoice%"=="R" goto menu
if /i "%postchoice%"=="L" start notepad.exe "%logfile%" & goto postscan
if /i "%postchoice%"=="X" goto end
goto postscan

:viewlog
if exist "%logfile%" (start notepad.exe "%logfile%") else (echo No log found. & pause)
goto menu

:end
exit