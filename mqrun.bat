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

:: CPU count from environment variable set by Windows
set "CPU_COUNT=%NUMBER_OF_PROCESSORS%"

echo Session dir  : !SESSIONDIR!
echo Watching     : %DATAROOT%\*\*\%DATAPATTERN%
echo Poll interval: %POLL_INTERVAL%s  (Ctrl+C to stop)
echo Max parallel : %CPU_COUNT% ^(= NUMBER_OF_PROCESSORS^)
echo.

:: ============================================================
:: Main watch loop
:: ============================================================
:watch_loop
set FOUND=0 & set SKIPPED=0 & set RUNNING=0 & set DONE=0
for /d %%U in ("%DATAROOT%\*") do (
    for /d %%V in ("%%~fU\*") do (
        for /d %%I in ("%%~fV\%DATAPATTERN%") do (
            set /a FOUND+=1
            call :CheckFolder "%%~fI"
        )
    )
)
echo [%time%] Poll: !FOUND! found  ^|  !DONE! done  ^|  !RUNNING! running  ^|  !SKIPPED! waiting/skipped
timeout /t %POLL_INTERVAL% /nobreak >nul
goto :watch_loop


:: ============================================================
:: :CheckFolder <full_folder_path>
:: ============================================================
:CheckFolder
set "SRC=%~1"
set "BN=%~n1"
set "WORKDIR=%SESSIONDIR%\%BN%"
set "DATADEST=%WORKDIR%\data.d"
set "RUNPARAM=%WORKDIR%\%PARAMFILE%"

:: --- Done ---
if exist "%WORKDIR%\combined\txt\proteinGroups.txt" (
    set /a DONE+=1
    if exist "%WORKDIR%\running.lock" (
        del "%WORKDIR%\running.lock"
        echo [%time%] Done     : %BN%
    )
    exit /b 0
)

:: --- Running: check if specific PID is still alive ---
if exist "%WORKDIR%\running.lock" (
    set /a RUNNING+=1
    set "MQ_PID="
    for /f %%P in ('type "%WORKDIR%\running.lock"') do set "MQ_PID=%%P"
    if defined MQ_PID (
        tasklist /fi "pid eq !MQ_PID!" /fi "imagename eq MaxQuantCmd.exe" /fo csv /nh 2>nul | findstr /i "MaxQuantCmd" >nul
        if errorlevel 1 (
            echo [%time%] Failed   : %BN% ^(PID !MQ_PID! gone, retrying next poll^)
            del "%WORKDIR%\running.lock"
            set /a RUNNING-=1
            if exist "%DATADEST%" rmdir /s /q "%DATADEST%"
        )
    )
    exit /b 0
)

:: --- All 3 key files must exist ---
set "F1=%SRC%\analysis.tdf"
set "F2=%SRC%\analysis.tdf_bin"
set "F3=%SRC%\chromatography-data.sqlite"
if not exist "!F1!" ( echo [%time%] Waiting  : %BN% ^(analysis.tdf missing^)              & exit /b 0 )
if not exist "!F2!" ( echo [%time%] Waiting  : %BN% ^(analysis.tdf_bin missing^)          & exit /b 0 )
if not exist "!F3!" ( echo [%time%] Waiting  : %BN% ^(chromatography-data.sqlite missing^) & exit /b 0 )

:: --- File sizes must be stable across one poll interval ---
:: Use wmic to get exact byte count without thousand-separator comma issues
set "S1A=" & set "S2A=" & set "S3A="
for /f "tokens=2 delims==" %%Z in ('wmic datafile where "name='!F1:\=\\!'" get FileSize /format:value 2^>nul ^| findstr "FileSize" ^| cmd /q /c "more"') do set "S1A=%%Z"
for /f "tokens=2 delims==" %%Z in ('wmic datafile where "name='!F2:\=\\!'" get FileSize /format:value 2^>nul ^| findstr "FileSize" ^| cmd /q /c "more"') do set "S2A=%%Z"
for /f "tokens=2 delims==" %%Z in ('wmic datafile where "name='!F3:\=\\!'" get FileSize /format:value 2^>nul ^| findstr "FileSize" ^| cmd /q /c "more"') do set "S3A=%%Z"
echo [%time%] Checking : %BN% ^(sizes: !S1A! / !S2A! / !S3A!^)
timeout /t %POLL_INTERVAL% /nobreak >nul
set "S1B=" & set "S2B=" & set "S3B="
for /f "tokens=2 delims==" %%Z in ('wmic datafile where "name='!F1:\=\\!'" get FileSize /format:value 2^>nul ^| findstr "FileSize" ^| cmd /q /c "more"') do set "S1B=%%Z"
for /f "tokens=2 delims==" %%Z in ('wmic datafile where "name='!F2:\=\\!'" get FileSize /format:value 2^>nul ^| findstr "FileSize" ^| cmd /q /c "more"') do set "S2B=%%Z"
for /f "tokens=2 delims==" %%Z in ('wmic datafile where "name='!F3:\=\\!'" get FileSize /format:value 2^>nul ^| findstr "FileSize" ^| cmd /q /c "more"') do set "S3B=%%Z"

if not "!S1A!"=="!S1B!" ( echo [%time%] Acquiring: %BN% ^(analysis.tdf changing^)              & exit /b 0 )
if not "!S2A!"=="!S2B!" ( echo [%time%] Acquiring: %BN% ^(analysis.tdf_bin changing^)          & exit /b 0 )
if not "!S3A!"=="!S3B!" ( echo [%time%] Acquiring: %BN% ^(chromatography-data.sqlite changing^) & exit /b 0 )

:: --- Copy the 3 files ---
mkdir "%WORKDIR%"  2>nul
mkdir "%DATADEST%" 2>nul
echo [%time%] Copying  : %BN%
copy /y "!F1!" "%DATADEST%\analysis.tdf"                >nul
copy /y "!F2!" "%DATADEST%\analysis.tdf_bin"            >nul
copy /y "!F3!" "%DATADEST%\chromatography-data.sqlite"  >nul
if not exist "%DATADEST%\analysis.tdf"               ( echo [%time%] ERROR    : copy failed for analysis.tdf               & exit /b 1 )
if not exist "%DATADEST%\analysis.tdf_bin"           ( echo [%time%] ERROR    : copy failed for analysis.tdf_bin           & exit /b 1 )
if not exist "%DATADEST%\chromatography-data.sqlite" ( echo [%time%] ERROR    : copy failed for chromatography-data.sqlite & exit /b 1 )

:: --- Rewrite param file ---
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

:: --- Gate on CPU slots available ---
if !RUNNING! GEQ %CPU_COUNT% (
    echo [%time%] Queued   : %BN% ^(!RUNNING!/%CPU_COUNT% slots used, waiting^)
    set /a SKIPPED+=1
    exit /b 0
)

:: --- Launch MaxQuant, store PID in lockfile ---
start "MQ.%BN%" %MAXQUANTCMD% "%RUNPARAM%"
timeout /t 2 /nobreak >nul
set "MQ_PID="
set "WMIC_PARAM=%RUNPARAM:\=\\%"
for /f "tokens=2 delims==" %%P in ('wmic process where "name='MaxQuantCmd.exe' and commandline like '%%!WMIC_PARAM!%%'" get ProcessId /format:value 2^>nul ^| findstr "ProcessId" ^| cmd /q /c "more"') do (
    set "MQ_PID=%%P"
)
echo !MQ_PID! > "%WORKDIR%\running.lock"
set /a RUNNING+=1
echo [%time%] Launched : %BN% ^(PID:!MQ_PID!, slot !RUNNING!/%CPU_COUNT%^)
echo.
exit /b 0