@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

:: ============================================================
:: Configuration — edit these paths
:: ============================================================
set MAXQUANTCMD="C:\Program Files\MaxQuant_v2.7.0.0\bin\MaxQuantCmd.exe"
set DATAROOT=F:\promec\TIMSTOF\Raw
set DATAPATTERN=*HeLa*.d
set FASTAFILE=F:\promec\FastaDB\UP000005640_9606_1protein1gene.fasta
set PARAMFILE=mqpar.xml
set TMPDIR=D:\TMPDIR
set POLL_INTERVAL=60

:: Placeholder strings to replace inside mqpar.xml
set SEARCHTEXT=TestDir
set SEARCHTEXT2=SequencesFasta

:: ============================================================
:: Validate config
:: ============================================================
if not exist %MAXQUANTCMD% (
    echo ERROR: MaxQuantCmd not found: %MAXQUANTCMD%
    exit /b 1
)
if not exist "%DATAROOT%" (
    echo ERROR: DATAROOT not found: %DATAROOT%
    exit /b 1
)
if not exist "%FASTAFILE%" (
    echo ERROR: FASTA file not found: %FASTAFILE%
    exit /b 1
)
if not exist "%PARAMFILE%" (
    echo ERROR: Parameter file not found in current directory: %PARAMFILE%
    exit /b 1
)

:: ============================================================
:: Session directory derived from DATAROOT leaf + FASTA basename
:: e.g. TMPDIR\LARS_UP000005640_9606_1protein1gene
:: ============================================================
for %%D in ("%DATAROOT%") do set DATAROOT_LEAF=%%~nxD
for %%F in ("%FASTAFILE%") do set FASTA_LEAF=%%~nF

set SESSIONDIR=%TMPDIR%\%DATAROOT_LEAF%_%FASTA_LEAF%
set PROCESSEDFILE=%SESSIONDIR%\processed_folders.txt

if not exist "%TMPDIR%" mkdir "%TMPDIR%"
if not exist "%SESSIONDIR%" mkdir "%SESSIONDIR%"
if not exist "%PROCESSEDFILE%" type nul > "%PROCESSEDFILE%"

echo Session directory : %SESSIONDIR%
echo Watching          : %DATAROOT%\*\*\%DATAPATTERN%
echo Poll interval     : %POLL_INTERVAL%s  (Ctrl+C to stop)
echo.

:: ============================================================
:: Main watch loop
:: cmd.exe does not support wildcards in intermediate path parts.
:: Two nested for /d loops expand: DATAROOT\*  then  *\*HeLa*.d
:: ============================================================
:watch_loop
for /d %%U in ("%DATAROOT%\*") do (
    for /d %%V in ("%%~fU\*") do (
        for /d %%I in ("%%~fV\%DATAPATTERN%") do (
            call :IsProcessed "%%~fI"
            if errorlevel 1 (
                call :ProcessFolder "%%~fI"
            )
        )
    )
)
timeout /t %POLL_INTERVAL% /nobreak >nul
goto :watch_loop


:: ============================================================
:: :IsProcessed  <full_folder_path>
::   exit /b 0 = already processed
::   exit /b 1 = new, needs processing
:: ============================================================
:IsProcessed
findstr /x /l /c:"%~1" "%PROCESSEDFILE%" >nul 2>&1
if %errorlevel%==0 (exit /b 0) else (exit /b 1)


:: ============================================================
:: :ProcessFolder  <full_folder_path>
:: ============================================================
:ProcessFolder
set "SRCFOLDER=%~1"
set "BASENAME=%~n1"
set "WORKDIR=%SESSIONDIR%\%BASENAME%"
set "DATADEST=%WORKDIR%\data.d"
set "RUNPARAM=%WORKDIR%\%PARAMFILE%"

echo [%time%] Processing: %BASENAME%

:: Create working directories
mkdir "%WORKDIR%" 2>nul
mkdir "%DATADEST%" 2>nul

:: -------------------------------------------------------
:: Rewrite parameter file replacing placeholder paths.
:: NOTE: for /f skips blank lines — known cmd.exe limitation.
:: Ensure mqpar.xml does not depend on blank lines being present.
:: -------------------------------------------------------
if exist "%RUNPARAM%" del "%RUNPARAM%"
for /f "usebackq tokens=* delims=" %%A in ("%PARAMFILE%") do (
    set "LINE=%%A"
    set "LINE=!LINE:%SEARCHTEXT%=%DATADEST%!"
    set "LINE=!LINE:%SEARCHTEXT2%=%FASTAFILE%!"
    echo !LINE!>> "%RUNPARAM%"
)
if not exist "%RUNPARAM%" (
    echo ERROR: Failed to write parameter file for %BASENAME%
    exit /b 1
)

:: -------------------------------------------------------
:: Folder age check — use wmic fsdir to get LastModified date
:: of the .d folder in YYYYMMDD format, compare to today.
:: wmic os get LocalDateTime gives today in same format.
:: -------------------------------------------------------
set "FOLDER_AGE=OLD"
set "TODAY_DATE="
for /f "skip=1 tokens=1" %%T in ('wmic os get LocalDateTime') do (
    if not defined TODAY_DATE set "TODAY_DATE=%%T"
)
set "TODAY_DATE=%TODAY_DATE:~0,8%"

set "FOLDER_DATE="
set "WMIC_PATH=%SRCFOLDER:\=\\%"
for /f "skip=1 tokens=1" %%Q in ('wmic fsdir where "name='%WMIC_PATH%'" get LastModified 2^>nul') do (
    if not defined FOLDER_DATE set "FOLDER_DATE=%%Q"
)
set "FOLDER_DATE=%FOLDER_DATE:~0,8%"
if "%FOLDER_DATE%"=="%TODAY_DATE%" set "FOLDER_AGE=NEW"

if "%FOLDER_AGE%"=="OLD" (
    echo [%time%] Skipping %BASENAME% ^(not modified today, FOLDER_DATE=%FOLDER_DATE% TODAY=%TODAY_DATE%^)
    echo %SRCFOLDER%>> "%PROCESSEDFILE%"
    exit /b 0
)
:: -------------------------------------------------------
:: Copy raw data folder.
:: /I tells xcopy destination is a directory — no prompt needed.
:: -------------------------------------------------------
xcopy /E /Y /Q /I "%SRCFOLDER%" "%DATADEST%" >nul
if errorlevel 1 (
    echo ERROR: xcopy failed for %SRCFOLDER%
    exit /b 1
)

echo [%time%] Starting MaxQuant for %BASENAME%
start "MQ.%DATAROOT_LEAF%.%BASENAME%" %MAXQUANTCMD% "%RUNPARAM%"

:: Mark as processed
echo %SRCFOLDER%>> "%PROCESSEDFILE%"
echo [%time%] Queued: %BASENAME%
echo.
exit /b 0

:: ============================================================
:: References
:: https://stackoverflow.com/a/16079895
:: https://stackoverflow.com/a/13805466
:: https://stackoverflow.com/a/55519158
:: https://stackoverflow.com/a/30231479
:: ============================================================
