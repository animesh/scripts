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

set TLIST=%SystemRoot%\System32\tasklist.exe
set WMIC=%SystemRoot%\System32\wbem\wmic.exe

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

set "CPU_COUNT=%NUMBER_OF_PROCESSORS%"
echo Session dir  : !SESSIONDIR!
echo Watching     : %DATAROOT%\*\*\%DATAPATTERN%
echo Poll interval: %POLL_INTERVAL%s  (Ctrl+C to stop)
echo Max parallel : %CPU_COUNT%
echo.

:: ============================================================
:: Main watch loop
:: ============================================================
:watch_loop
set FOUND=0 & set DONE=0 & set QUEUED=0 & set LIVE=0

set "MQ_LIVE=0"
for /f "tokens=1" %%P in ('%TLIST% /fi "imagename eq MaxQuantCmd.exe" /fo csv /nh 2^>nul') do set /a MQ_LIVE+=1
echo [%time%] MaxQuant running: !MQ_LIVE!/%CPU_COUNT%

for /d %%U in ("%DATAROOT%\*") do (
    for /d %%V in ("%%~fU\*") do (
        for /d %%I in ("%%~fV\%DATAPATTERN%") do (
            set /a FOUND+=1
            call :CheckFolder "%%~fI"
        )
    )
)
echo [%time%] Poll: !FOUND! found  ^|  !DONE! done  ^|  !LIVE! running  ^|  !QUEUED! queued
timeout /t %POLL_INTERVAL% /nobreak >nul
goto :watch_loop


:: ============================================================
:: :GetSize <file_path> <var_name>
:: ============================================================
:GetSize
set "%~2="
set "_GS_PATH=%~1"
set "_GS_PATH=!_GS_PATH:\=\\!"
for /f "tokens=2 delims==" %%Z in ('%WMIC% datafile where "name=^'!_GS_PATH!^'" get FileSize /format:value 2^>nul ^| more') do for /f "tokens=1" %%V in ("%%Z") do set "%~2=%%V"
exit /b 0


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
    if exist "%WORKDIR%\running.lock" del "%WORKDIR%\running.lock"
    exit /b 0
)

:: --- Running via lockfile ---
if exist "%WORKDIR%\running.lock" (
    set /a LIVE+=1
    set "MQ_PID="
    for /f "usebackq tokens=1" %%P in ("%WORKDIR%\running.lock") do set "MQ_PID=%%P"
    if defined MQ_PID (
        %TLIST% /fi "pid eq !MQ_PID!" /fo csv /nh 2>nul | findstr /i "MaxQuantCmd" >nul
        if errorlevel 1 (
            echo [%time%] Failed   : %BN% ^(PID !MQ_PID! gone, retrying^)
            del "%WORKDIR%\running.lock"
            set /a LIVE-=1
            if exist "%DATADEST%" rmdir /s /q "%DATADEST%" 2>nul
        )
    )
    exit /b 0
)

:: --- Running without lockfile (launched by previous script version) ---
:: Check if MaxQuant is already processing this runparam before doing anything
set "WMIC_PARAM=!RUNPARAM:\=\\!"
set "ALREADY_RUNNING=0"
set "ADOPT_PID="
for /f "tokens=2 delims==" %%P in ('%WMIC% process where "name=^'MaxQuantCmd.exe^' and commandline like ^'%%!WMIC_PARAM!%%^'" get ProcessId /format:value 2^>nul ^| more') do for /f "tokens=1" %%V in ("%%P") do if not defined ADOPT_PID set "ADOPT_PID=%%V"
if defined ADOPT_PID (
    echo !ADOPT_PID!> "%WORKDIR%\running.lock"
    set "ALREADY_RUNNING=1"
    set /a LIVE+=1
    echo [%time%] Adopted  : %BN% ^(PID:!ADOPT_PID!, recovering lock^)
)
if !ALREADY_RUNNING! EQU 1 exit /b 0

:: --- Source files must exist ---
set "F1=%SRC%\analysis.tdf"
set "F2=%SRC%\analysis.tdf_bin"
set "F3=%SRC%\chromatography-data.sqlite"
if not exist "!F1!" ( echo [%time%] Waiting  : %BN% ^(analysis.tdf missing^)               & exit /b 0 )
if not exist "!F2!" ( echo [%time%] Waiting  : %BN% ^(analysis.tdf_bin missing^)           & exit /b 0 )
if not exist "!F3!" ( echo [%time%] Waiting  : %BN% ^(chromatography-data.sqlite missing^) & exit /b 0 )

:: --- Get source sizes ---
call :GetSize "!F1!" SZ1
call :GetSize "!F2!" SZ2
call :GetSize "!F3!" SZ3

:: --- Check destination: if sizes match source, skip stability wait ---
set "NEED_COPY=1"
if exist "%DATADEST%\analysis.tdf" if exist "%DATADEST%\analysis.tdf_bin" if exist "%DATADEST%\chromatography-data.sqlite" (
    set "DS1=" & set "DS2=" & set "DS3="
    call :GetSize "%DATADEST%\analysis.tdf"               DS1
    call :GetSize "%DATADEST%\analysis.tdf_bin"           DS2
    call :GetSize "%DATADEST%\chromatography-data.sqlite" DS3
    if "!DS1!"=="!SZ1!" if "!DS2!"=="!SZ2!" if "!DS3!"=="!SZ3!" (
        echo [%time%] Verified : %BN% ^(!SZ1! / !SZ2! / !SZ3!^)
        set "NEED_COPY=0"
    ) else (
        echo [%time%] Mismatch : %BN% ^(dst !DS1!/!DS2!/!DS3! vs src !SZ1!/!SZ2!/!SZ3!^)
    )
)

:: --- Stability check then copy ---
if !NEED_COPY! EQU 1 (
    echo [%time%] Checking : %BN% ^(!SZ1! / !SZ2! / !SZ3!^)
    timeout /t %POLL_INTERVAL% /nobreak >nul
    set "SZ1B=" & set "SZ2B=" & set "SZ3B="
    call :GetSize "!F1!" SZ1B
    call :GetSize "!F2!" SZ2B
    call :GetSize "!F3!" SZ3B
)
if !NEED_COPY! EQU 1 if not "!SZ1!"=="!SZ1B!" ( echo [%time%] Acquiring: %BN% ^(analysis.tdf changing^)               & exit /b 0 )
if !NEED_COPY! EQU 1 if not "!SZ2!"=="!SZ2B!" ( echo [%time%] Acquiring: %BN% ^(analysis.tdf_bin changing^)           & exit /b 0 )
if !NEED_COPY! EQU 1 if not "!SZ3!"=="!SZ3B!" ( echo [%time%] Acquiring: %BN% ^(chromatography-data.sqlite changing^) & exit /b 0 )
if !NEED_COPY! EQU 1 (
    mkdir "%WORKDIR%"  2>nul
    mkdir "%DATADEST%" 2>nul
    echo [%time%] Copying  : %BN% ^(!SZ1B! / !SZ2B! / !SZ3B! bytes^)
    xcopy /y "!F1!" "%DATADEST%\"
    xcopy /y "!F2!" "%DATADEST%\"
    xcopy /y "!F3!" "%DATADEST%\"
    if not exist "%DATADEST%\analysis.tdf"               ( echo [%time%] ERROR: copy failed analysis.tdf               & exit /b 0 )
    if not exist "%DATADEST%\analysis.tdf_bin"           ( echo [%time%] ERROR: copy failed analysis.tdf_bin           & exit /b 0 )
    if not exist "%DATADEST%\chromatography-data.sqlite" ( echo [%time%] ERROR: copy failed chromatography-data.sqlite & exit /b 0 )
    echo [%time%] Copied   : %BN%
)

:: --- Write mqpar.xml only if it doesn't already have the correct data path ---
set "NEED_PARAM=1"
if exist "%RUNPARAM%" (
    findstr /i "%DATADEST%" "%RUNPARAM%" >nul 2>nul
    if not errorlevel 1 set "NEED_PARAM=0"
)
if !NEED_PARAM! EQU 1 (
    if exist "%RUNPARAM%" del "%RUNPARAM%" 2>nul
    for /f "usebackq tokens=* delims=" %%A in ("%PARAMFILE%") do (
        set "LINE=%%A"
        set "LINE=!LINE:%SEARCHTEXT%=%DATADEST%!"
        set "LINE=!LINE:%SEARCHTEXT2%=%FASTAFILE%!"
        echo !LINE!>> "%RUNPARAM%"
    )
    if not exist "%RUNPARAM%" ( echo [%time%] ERROR: param write failed for %BN% & exit /b 0 )
)

:: --- Gate: re-count before launch ---
set "MQ_LIVE=0"
for /f "tokens=1" %%P in ('%TLIST% /fi "imagename eq MaxQuantCmd.exe" /fo csv /nh 2^>nul') do set /a MQ_LIVE+=1
if !MQ_LIVE! GEQ %CPU_COUNT% (
    echo [%time%] Queued   : %BN% ^(!MQ_LIVE!/%CPU_COUNT% slots used^)
    set /a QUEUED+=1
    exit /b 0
)

:: --- Launch ---
start "MQ.%BN%" %MAXQUANTCMD% "%RUNPARAM%"
timeout /t 5 /nobreak >nul
set "MQ_PID="
set "WMIC_PARAM=!RUNPARAM:\=\\!"
for /f "tokens=2 delims==" %%P in ('%WMIC% process where "name=^'MaxQuantCmd.exe^' and commandline like ^'%%!WMIC_PARAM!%%^'" get ProcessId /format:value 2^>nul ^| more') do for /f "tokens=1" %%V in ("%%P") do set "MQ_PID=%%V"
if not defined MQ_PID (
    echo [%time%] ERROR    : PID capture failed for %BN%, retrying next poll
    exit /b 0
)
echo !MQ_PID!> "%WORKDIR%\running.lock"
set /a LIVE+=1
echo [%time%] Launched : %BN% ^(PID:!MQ_PID! slot !MQ_LIVE!+1/%CPU_COUNT%^)
echo.
exit /b 0
