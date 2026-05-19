::C:\Users\animeshs>reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "PROMEC_Launcher" /t REG_SZ /d "\"C:\Users\animeshs\OneDrive\Desktop\Scripts\launcherPROMEC.bat\"" /f
::taskkill /f /im launcherPROMEC.bat
::taskkill /f /im max*
::taskkill /f /im dot*
::taskkill /f /im python.exe
::taskkill /f /im duckdb.exe
::taskkill /f /im launcherPROMEC.bat
::taskkill /f /im cmd.exe
@echo off

set "BASE=C:\Users\animeshs\OneDrive\Desktop\Scripts"
set "LOGFILE=%BASE%\logPROMEC.txt"

REM ------------------------------------------------------------
REM CONCURRENCY GUARD: Check if the dashboard is already running
REM ------------------------------------------------------------
tasklist /V /FI "WINDOWTITLE eq PROMEC DASHBOARD" 2>nul | findstr /I "PROMEC" >nul
if %ERRORLEVEL% equ 0 (
    echo [%date% %time%] RDP/Logon detected, but PROMEC scripts are already running in another session. Exiting launcher safely. >> "%LOGFILE%"
    exit
)

REM Safe background delay for Task Scheduler
ping 127.0.0.1 -n 6 > nul

set "CMD=C:\Windows\System32\cmd.exe"
set "PYTHON=C:\Program Files\Python39\python.exe"

echo =========================================================== >> "%LOGFILE%"
echo [%date% %time%] PROMEC launcher started (New Session initialized) >> "%LOGFILE%"

REM ------------------------------------------------------------
REM START DASHBOARD
REM ------------------------------------------------------------
echo [%date% %time%] Launching mqrunDash.py >> "%LOGFILE%"
start "PROMEC DASHBOARD" /d "%BASE%" "%CMD%" /k "%PYTHON%" mqrunDash.py

REM ------------------------------------------------------------
REM START MQRUN
REM ------------------------------------------------------------
echo [%date% %time%] Launching mqrun.bat >> "%LOGFILE%"
start "PROMEC MQ RUN" /d "%BASE%" "%CMD%" /k mqrun.bat
ping 127.0.0.1 -n 3 > nul

REM ------------------------------------------------------------
REM START MQRUNDB
REM ------------------------------------------------------------
echo [%date% %time%] Launching mqrunDB.bat >> "%LOGFILE%"
start "PROMEC MQ DB RUN" /d "%BASE%" "%CMD%" /k mqrunDB.bat
ping 127.0.0.1 -n 3 > nul

echo [%date% %time%] All jobs launched successfully >> "%LOGFILE%"
echo =========================================================== >> "%LOGFILE%"

exit
