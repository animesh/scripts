@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

:: ============================================================
:: Configuration
:: ============================================================
set MAXQUANTCMD="C:\Program Files\MaxQuant_v2.7.0.0\bin\MaxQuantCmd.exe"
set DATAROOT=F:\promec\TIMSTOF\Raw
set DATAPATTERN=*HeLa*.d
set FASTAFILE=F:\promec\FastaDB\UP000005640_9606_1protein1gene.fasta
set PARAMFILE=mqpar.xml
set TMPDIR=D:\TMPDIR
set POLL_INTERVAL=60
set SEARCHTEXT=TestDir
set SEARCHTEXT2=SequencesFasta

:: ============================================================
:: Validate config
:: ============================================================
if not exist %MAXQUANTCMD%  ( echo ERROR: MaxQuantCmd not found: %MAXQUANTCMD%  & exit /b 1 )
if not exist "%DATAROOT%"   ( echo ERROR: DATAROOT not found: %DATAROOT%        & exit /b 1 )
if not exist "%FASTAFILE%"  ( echo ERROR: FASTA not found: %FASTAFILE%          & exit /b 1 )
if not exist "%PARAMFILE%"  ( echo ERROR: %PARAMFILE% not found in current dir  & exit /b 1 )

:: ============================================================
:: Derive session directory
:: ============================================================
for %%D in ("%DATAROOT%") do set DATAROOT_LEAF=%%~nxD
for %%F in ("%FASTAFILE%") do set FASTA_LEAF=%%~nF
set SESSIONDIR=%TMPDIR%\!DATAROOT_LEAF!_!FASTA_LEAF!

if not exist "%TMPDIR%"     mkdir "%TMPDIR%"
if not exist "!SESSIONDIR!" mkdir "!SESSIONDIR!"

echo Session dir  : !SESSIONDIR!
echo Watching     : %DATAROOT%\*\*\%DATAPATTERN%
echo Poll interval: %POLL_INTERVAL%s  (Ctrl+C to stop)
echo.

:: ============================================================
:: Main watch loop
:: ============================================================
:watch_loop
for /d %%U in ("%DATAROOT%\*") do (
    for /d %%V in ("%%~fU\*") do (
        for /d %%I in ("%%~fV\%DATAPATTERN%") do (
            call :CheckFolder "%%~fI"
        )
    )
)
timeout /t %POLL_INTERVAL% /nobreak >nul
goto :watch_loop


:: ============================================================
:: :CheckFolder <full_folder_path>
:: Only prints when state changes or action is taken.
:: States tracked via marker files in WORKDIR:
::   running.lock              = MaxQuant launched, not done yet
::   combined\txt\proteinGroups.txt = done successfully
::   neither                   = new or failed, attempt processing
:: Old folders (not modified today) are silently skipped.
:: ============================================================
:CheckFolder
set "SRC=%~1"
set "BN=%~n1"
set "WORKDIR=%SESSIONDIR%\%BN%"

:: Done — clean up lock silently
if exist "%WORKDIR%\combined\txt\proteinGroups.txt" (
    if exist "%WORKDIR%\running.lock" (
        del "%WORKDIR%\running.lock"
        echo [%time%] Done     : %BN%
    )
    exit /b 0
)

:: Running — silent, no output each poll
if exist "%WORKDIR%\running.lock" exit /b 0

:: -------------------------------------------------------
:: Age check — silently skip old folders
:: -------------------------------------------------------
set "TODAY=" & set "FOLDERDATE="
for /f "skip=5 tokens=1" %%D in ('dir /ad /tw "%SESSIONDIR%" 2^>nul') do if not defined TODAY set "TODAY=%%D"
for /f "skip=5 tokens=1" %%D in ('dir /ad /tw "%SRC%"        2^>nul') do if not defined FOLDERDATE set "FOLDERDATE=%%D"
if not "%FOLDERDATE%"=="%TODAY%" exit /b 0

:: -------------------------------------------------------
:: Acquisition check — silent if still writing
:: -------------------------------------------------------
set "SZ1=" & set "SZ2="
for /f "tokens=3" %%S in ('dir /s /a "%SRC%" 2^>nul ^| findstr /c:" File(s)"') do set "SZ1=%%S"
timeout /t %POLL_INTERVAL% /nobreak >nul
for /f "tokens=3" %%S in ('dir /s /a "%SRC%" 2^>nul ^| findstr /c:" File(s)"') do set "SZ2=%%S"
if not "%SZ1%"=="%SZ2%" (
    echo [%time%] Acquiring: %BN%
    exit /b 0
)

:: -------------------------------------------------------
:: Copy, rewrite params, launch
:: -------------------------------------------------------
set "DATADEST=%WORKDIR%\data.d"
set "RUNPARAM=%WORKDIR%\%PARAMFILE%"

mkdir "%WORKDIR%"  2>nul
mkdir "%DATADEST%" 2>nul

echo [%time%] Copying  : %BN%
xcopy /E /Y /Q /I "%SRC%" "%DATADEST%" >nul
if errorlevel 1 (
    echo [%time%] ERROR    : xcopy failed for %BN%, will retry
    exit /b 1
)

if exist "%RUNPARAM%" del "%RUNPARAM%"
for /f "usebackq tokens=* delims=" %%A in ("%PARAMFILE%") do (
    set "LINE=%%A"
    set "LINE=!LINE:%SEARCHTEXT%=%DATADEST%!"
    set "LINE=!LINE:%SEARCHTEXT2%=%FASTAFILE%!"
    echo !LINE!>> "%RUNPARAM%"
)
if not exist "%RUNPARAM%" (
    echo [%time%] ERROR    : failed to write param file for %BN%
    exit /b 1
)

echo %time% > "%WORKDIR%\running.lock"
start "MQ.%BN%" %MAXQUANTCMD% "%RUNPARAM%"
echo [%time%] Launched : %BN%
echo.
exit /b 0