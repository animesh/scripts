@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

:: mqrun v16 — MaxQuant batch watcher for timsTOF HeLa QC runs

set MAXQUANTCMD="C:\Program Files\MaxQuant_v2.7.0.0\bin\MaxQuantCmd.exe"
set DATAROOT=F:\promec\TIMSTOF\Raw
set DATAPATTERN=*HeLa*.d
set FASTAFILE=F:\promec\FastaDB\UP000005640_9606_1protein1gene.fasta
set PARAMFILE=mqpar.xml
set TMPDIR=D:\TMPDIR
set POLL_INTERVAL=1800
set STABILITY_WAIT=60
set SEARCHTEXT=TestDir
set SEARCHTEXT2=SequencesFasta
set QCROOT=F:\promec\TIMSTOF\QC
set CPU_COUNT=64
set TLIST=%SystemRoot%\System32\tasklist.exe
set WMIC=%SystemRoot%\System32\wbem\wmic.exe
set LOGFILE=%QCROOT%\mqrun_log.txt

if not exist %MAXQUANTCMD%  ( echo ERROR: MaxQuantCmd not found: %MAXQUANTCMD%  & exit /b 1 )
if not exist "%DATAROOT%"   ( echo ERROR: DATAROOT not found: %DATAROOT%        & exit /b 1 )
if not exist "%FASTAFILE%"  ( echo ERROR: FASTA not found: %FASTAFILE%          & exit /b 1 )
if not exist "%PARAMFILE%"  ( echo ERROR: %PARAMFILE% not found in current dir  & exit /b 1 )

for %%D in ("%DATAROOT%") do set DATAROOT_LEAF=%%~nxD
for %%F in ("%FASTAFILE%") do set FASTA_LEAF=%%~nF
set SESSIONDIR=%TMPDIR%\!DATAROOT_LEAF!_!FASTA_LEAF!
if not exist "%TMPDIR%"     mkdir "%TMPDIR%"
if not exist "!SESSIONDIR!" mkdir "!SESSIONDIR!"
echo Session dir  : !SESSIONDIR!
echo Watching     : %DATAROOT%\*\*\%DATAPATTERN%
echo Poll: %POLL_INTERVAL%s  ^| Stability: %STABILITY_WAIT%s  ^| Max parallel: %CPU_COUNT%
echo.
echo [%date% %time%] ===== SESSION START  %SESSIONDIR% ===== >> "%LOGFILE%"

:: Startup: remove stale running.lock files from dead/interrupted processes
set "STALE_CLEANED=0"
for /d %%J in ("!SESSIONDIR!\*") do (
    if exist "%%~fJ\queued.lock"  ( del "%%~fJ\queued.lock"  & set /a STALE_CLEANED+=1 )
    if exist "%%~fJ\running.lock" (
        set "ST_PID="
        for /f "usebackq tokens=1" %%P in ("%%~fJ\running.lock") do set "ST_PID=%%P"
        if "!ST_PID!"=="PENDING" (
            del "%%~fJ\running.lock" & set /a STALE_CLEANED+=1
        ) else if defined ST_PID (
            %TLIST% /fi "pid eq !ST_PID!" /fo csv /nh 2>nul | findstr /i "MaxQuantCmd" >nul
            if errorlevel 1 ( del "%%~fJ\running.lock" & set /a STALE_CLEANED+=1 )
        )
    )
)
if !STALE_CLEANED! GTR 0 echo [%time%] Startup  : !STALE_CLEANED! stale running.lock file^(s^) removed

:watch_loop
set FOUND=0 & set DONE=0 & set QUEUED=0 & set LIVE=0 & set SKIPPED=0 & set ACQUIRING=0 & set RETRYING=0 & set ERRORS=0 & set UNKNOWN=0
set "MQ_LIVE=0"
for /f "tokens=1" %%P in ('%TLIST% /fi "imagename eq MaxQuantCmd.exe" /fo csv /nh 2^>nul') do set /a MQ_LIVE+=1

for /d %%U in ("%DATAROOT%\*") do (
    for /d %%V in ("%%~fU\*") do (
        for /d %%I in ("%%~fV\%DATAPATTERN%") do (
            set /a FOUND+=1
            call :CheckFolder "%%~fI"
        )
    )
)

set "ORPHAN_DONE=0"
for /d %%W in ("!SESSIONDIR!\*") do (
    if exist "%%~fW\done.lock" (
        set "BN_=%%~nxW"
        set "SRC_FOUND=0"
        for /d %%U in ("%DATAROOT%\*") do (
            for /d %%V in ("%%~fU\*") do (
                if exist "%%~fV\!BN_!.d" set "SRC_FOUND=1"
            )
        )
        if "!SRC_FOUND!"=="0" set /a ORPHAN_DONE+=1
    )
)
set /a UNKNOWN=FOUND-DONE-LIVE-QUEUED-ACQUIRING-RETRYING-ERRORS-SKIPPED
echo [%time%] Poll: !FOUND! found  ^|  !DONE! done  ^|  !ORPHAN_DONE! orphan-done  ^|  !LIVE! running  ^|  !QUEUED! queued  ^|  !ACQUIRING! acquiring  ^|  !RETRYING! retrying  ^|  !ERRORS! errors  ^|  !SKIPPED! skipped  ^|  !UNKNOWN! unknown
echo [%time%] Poll: !FOUND! found  ^|  !DONE! done  ^|  !ORPHAN_DONE! orphan-done  ^|  !LIVE! running  ^|  !QUEUED! queued  ^|  !ACQUIRING! acquiring  ^|  !RETRYING! retrying  ^|  !ERRORS! errors  ^|  !SKIPPED! skipped  ^|  !UNKNOWN! unknown >> "%LOGFILE%"
timeout /t %POLL_INTERVAL% /nobreak >nul
goto :watch_loop

:: ── :MarkDone ────────────────────────────────────────────────────────────────
:: Called when proteinGroups.txt is found. Runs QC copy, writes done.lock,
:: deletes temp files. Gate 3 ensures the MQ process is dead before any cleanup.
:MarkDone
set "MD_WORKDIR=%~1"
set "MD_BN=%~2"
set "MD_PID=%~3"
set "DONE_FLAG=0"
if not exist "%MD_WORKDIR%\combined\txt\proteinGroups.txt"    exit /b 0
if not exist "%MD_WORKDIR%\combined\proc\#runningTimes.txt"   exit /b 0
findstr /i "Finish writing tables" "%MD_WORKDIR%\combined\proc\#runningTimes.txt" >nul 2>nul
if errorlevel 1 exit /b 0
:: Gate 3: confirm MQ process is dead before touching files.
if not defined MD_PID set "MD_PID="
if /i "!MD_PID!"=="PENDING" (
    echo [%time%] WaitPID  : %MD_BN% ^(PENDING - deferring^)
    echo [%time%] WaitPID  : %MD_BN% ^(PENDING - deferring^) >> "%LOGFILE%"
    exit /b 0
)
if "!MD_PID!"=="" (
    set "MD_WMIC_PARAM=!MD_WORKDIR:\=\\!\\mqpar.xml"
    set "MD_ORPHAN="
    for /f "tokens=2 delims==" %%P in ('%WMIC% process where "name='MaxQuantCmd.exe' and commandline like '%%!MD_WMIC_PARAM!%%'" get ProcessId /format:value 2^>nul ^| more') do (
        for /f "tokens=1" %%V in ("%%P") do if not defined MD_ORPHAN set "MD_ORPHAN=%%V"
    )
    if defined MD_ORPHAN (
        echo [%time%] WaitPID  : %MD_BN% ^(orphan PID !MD_ORPHAN! - deferring^)
        echo [%time%] WaitPID  : %MD_BN% ^(orphan PID !MD_ORPHAN! - deferring^) >> "%LOGFILE%"
        exit /b 0
    )
    goto :md_pid_ok
)
%TLIST% /fi "pid eq !MD_PID!" /fo csv /nh 2>nul | findstr /i "MaxQuantCmd" >nul
if not errorlevel 1 (
    echo [%time%] WaitPID  : %MD_BN% ^(PID !MD_PID! alive - deferring^)
    echo [%time%] WaitPID  : %MD_BN% ^(PID !MD_PID! alive - deferring^) >> "%LOGFILE%"
    exit /b 0
)
:md_pid_ok
if not "%QCROOT%"=="" (
    if not exist "%QCROOT%\" (
        echo [%time%] WARNING  : %MD_BN% QCROOT not reachable - will retry next poll
        echo [%time%] WARNING  : %MD_BN% QCROOT not reachable - will retry next poll >> "%LOGFILE%"
        exit /b 0
    )
    if not exist "%QCROOT%\%MD_BN%\combined\txt" mkdir "%QCROOT%\%MD_BN%\combined\txt"
    robocopy "%MD_WORKDIR%\combined\txt" "%QCROOT%\%MD_BN%\combined\txt" /E /XO /R:3 /W:10 /NFL /NDL /NJH /NJS /LOG+:"%QCROOT%\copy_log.txt" >nul
    if errorlevel 8 (
        echo [%time%] ERROR    : %MD_BN% QC copy failed - skipping cleanup to preserve results
        echo [%time%] ERROR    : %MD_BN% QC copy failed - skipping cleanup to preserve results >> "%LOGFILE%"
        exit /b 0
    )
    echo [%time%] QC copy  : %MD_BN% -> %QCROOT%\%MD_BN%\combined\txt
    echo [%time%] QC copy  : %MD_BN% -> %QCROOT%\%MD_BN%\combined\txt >> "%LOGFILE%"
    echo 1> "%MD_WORKDIR%\done.lock"
    set "DONE_FLAG=1"
    if exist "%MD_WORKDIR%\combined\txt" rmdir /s /q "%MD_WORKDIR%\combined\txt"
    echo [%time%] TxtClean : %MD_BN% combined\txt removed
    echo [%time%] TxtClean : %MD_BN% combined\txt removed >> "%LOGFILE%"
)
if "!DONE_FLAG!"=="0" (
    echo 1> "%MD_WORKDIR%\done.lock"
    set "DONE_FLAG=1"
)
echo [%time%] Cleanup  : %MD_BN%
echo [%time%] Cleanup  : %MD_BN% >> "%LOGFILE%"
if exist "%MD_WORKDIR%\data.d"                    rmdir /s /q "%MD_WORKDIR%\data.d"
if exist "%MD_WORKDIR%\data"                      rmdir /s /q "%MD_WORKDIR%\data"
if exist "%MD_WORKDIR%\combined\andromeda"        rmdir /s /q "%MD_WORKDIR%\combined\andromeda"
if exist "%MD_WORKDIR%\combined\search"           rmdir /s /q "%MD_WORKDIR%\combined\search"
if exist "%MD_WORKDIR%\combined\sdrf"             rmdir /s /q "%MD_WORKDIR%\combined\sdrf"
if exist "%MD_WORKDIR%\combined\combinedRunInfo"  rmdir /s /q "%MD_WORKDIR%\combined\combinedRunInfo"
if exist "%MD_WORKDIR%\mqpar.xml"                 del /f /q "%MD_WORKDIR%\mqpar.xml"
if exist "%MD_WORKDIR%\data.index"                del /f /q "%MD_WORKDIR%\data.index"
if exist "%MD_WORKDIR%\running.lock"              del /f /q "%MD_WORKDIR%\running.lock"
exit /b 0

:: ── :GetSize ─────────────────────────────────────────────────────────────────
:: Returns file size in bytes via WMIC (handles >2 GB; %%~z overflows on large files)
:GetSize
set "%~2="
set "_P=%~1"
set "_P=!_P:\=\\!"
for /f "tokens=2 delims==" %%Z in ('%WMIC% datafile where "name=^'!_P!^'" get FileSize /format:value 2^>nul ^| more') do for /f "tokens=1" %%V in ("%%Z") do set "%~2=%%V"
exit /b 0

:: ── :CheckFolder ─────────────────────────────────────────────────────────────
:CheckFolder
set "SRC=%~1"
set "BN=%~n1"
set "WORKDIR=%SESSIONDIR%\%BN%"
set "DATADEST=%WORKDIR%\data.d"
set "RUNPARAM=%WORKDIR%\%PARAMFILE%"
if exist "%WORKDIR%\done.lock" (
    set /a DONE+=1
    if exist "%WORKDIR%\running.lock" del "%WORKDIR%\running.lock"
    if exist "%WORKDIR%\queued.lock"  del "%WORKDIR%\queued.lock"
    exit /b 0
)
if exist "%WORKDIR%\queued.lock" (
    if !MQ_LIVE! GEQ %CPU_COUNT% ( set /a QUEUED+=1 & exit /b 0 )
    del "%WORKDIR%\queued.lock"
)
if exist "%WORKDIR%\combined\txt\proteinGroups.txt" (
    set "DONE_FLAG=0"
    set "CK_PID="
    if exist "%WORKDIR%\running.lock" (
        for /f "usebackq tokens=1" %%P in ("%WORKDIR%\running.lock") do set "CK_PID=%%P"
    )
    call :MarkDone "%WORKDIR%" "%BN%" "!CK_PID!"
    if "!DONE_FLAG!"=="1" (
        set /a DONE+=1
        echo [%time%] Completed: %BN%
        echo [%time%] Completed: %BN% >> "%LOGFILE%"
        exit /b 0
    )
)
if not exist "%WORKDIR%\running.lock" goto :no_lockfile
set "MQ_PID="
for /f "usebackq tokens=1" %%P in ("%WORKDIR%\running.lock") do set "MQ_PID=%%P"
if "!MQ_PID!"=="PENDING" (
    set "WMIC_PARAM=!RUNPARAM:\=\\!"
    set "ADOPT_PID="
    for /f "tokens=2 delims==" %%P in ('%WMIC% process where "name=^'MaxQuantCmd.exe^' and commandline like ^'%%!WMIC_PARAM!%%^'" get ProcessId /format:value 2^>nul ^| more') do (
        for /f "tokens=1" %%V in ("%%P") do if not defined ADOPT_PID set "ADOPT_PID=%%V"
    )
    if defined ADOPT_PID (
        echo !ADOPT_PID!> "%WORKDIR%\running.lock"
        set /a LIVE+=1
        :: Do NOT increment MQ_LIVE — process already counted in initial tasklist scan
        echo [%time%] Adopted  : %BN% ^(PID:!ADOPT_PID! from PENDING^)
        echo [%time%] Adopted  : %BN% ^(PID:!ADOPT_PID! from PENDING^) >> "%LOGFILE%"
        exit /b 0
    )
    set /a LIVE+=1
    exit /b 0
)
if not defined MQ_PID ( set /a SKIPPED+=1 & echo [%time%] Skipped  : %BN% ^(empty lockfile^) & exit /b 0 )
set /a LIVE+=1
%TLIST% /fi "pid eq !MQ_PID!" /fo csv /nh 2>nul | findstr /i "MaxQuantCmd" >nul
if not errorlevel 1 exit /b 0
:: Double-check: tasklist can transiently return empty during WMI recycle
timeout /t 5 /nobreak >nul
%TLIST% /fi "pid eq !MQ_PID!" /fo csv /nh 2>nul | findstr /i "MaxQuantCmd" >nul
if not errorlevel 1 exit /b 0
del "%WORKDIR%\running.lock"
set /a LIVE-=1
set "DONE_FLAG=0"
call :MarkDone "%WORKDIR%" "%BN%" "!MQ_PID!"
if "!DONE_FLAG!"=="1" (
    set /a DONE+=1
    echo [%time%] Completed: %BN% ^(PID !MQ_PID! exited^)
    echo [%time%] Completed: %BN% ^(PID !MQ_PID! exited^) >> "%LOGFILE%"
    exit /b 0
)
:: Fallback: any *.txt output = accept as done (handles MQ version variants)
set "FOUND_OUTPUT=0"
for %%F in ("%WORKDIR%\combined\txt\*.txt") do set "FOUND_OUTPUT=1"
if !FOUND_OUTPUT! EQU 1 (
    echo 1> "%WORKDIR%\done.lock"
    set /a DONE+=1
    echo [%time%] Completed: %BN% ^(fallback - txt found, no proteinGroups.txt^)
    echo [%time%] Completed: %BN% ^(fallback - txt found, no proteinGroups.txt^) >> "%LOGFILE%"
    echo [%time%] WARNING  : %BN% QC copy + TMPDIR cleanup skipped - check manually
    echo [%time%] WARNING  : %BN% QC copy + TMPDIR cleanup skipped - check manually >> "%LOGFILE%"
    exit /b 0
)
set /a RETRYING+=1
echo [%time%] Failed   : %BN% ^(PID !MQ_PID! gone, no output, retrying^)
echo [%time%] Failed   : %BN% ^(PID !MQ_PID! gone, no output, retrying^) >> "%LOGFILE%"
exit /b 0

:no_lockfile
set "WMIC_PARAM=!RUNPARAM:\=\\!"
set "ADOPT_PID="
for /f "tokens=2 delims==" %%P in ('%WMIC% process where "name=^'MaxQuantCmd.exe^' and commandline like ^'%%!WMIC_PARAM!%%^'" get ProcessId /format:value 2^>nul ^| more') do (
    for /f "tokens=1" %%V in ("%%P") do if not defined ADOPT_PID set "ADOPT_PID=%%V"
)
if defined ADOPT_PID (
    echo !ADOPT_PID!> "%WORKDIR%\running.lock"
    set /a LIVE+=1
    echo [%time%] Adopted  : %BN% ^(PID:!ADOPT_PID!^)
    echo [%time%] Adopted  : %BN% ^(PID:!ADOPT_PID!^) >> "%LOGFILE%"
    exit /b 0
)
if not exist "%SRC%\analysis.tdf"               ( set /a SKIPPED+=1 & echo [%time%] Skipped  : %BN% ^(analysis.tdf missing^)               & exit /b 0 )
if not exist "%SRC%\analysis.tdf_bin"           ( set /a SKIPPED+=1 & echo [%time%] Skipped  : %BN% ^(analysis.tdf_bin missing^)           & exit /b 0 )
if not exist "%SRC%\chromatography-data.sqlite" ( set /a SKIPPED+=1 & echo [%time%] Skipped  : %BN% ^(chromatography-data.sqlite missing^) & exit /b 0 )
if !MQ_LIVE! GEQ %CPU_COUNT% (
    if exist "%DATADEST%\analysis.tdf" if exist "%DATADEST%\analysis.tdf_bin" if exist "%DATADEST%\chromatography-data.sqlite" (
        set /a QUEUED+=1
        echo QUEUED > "%WORKDIR%\queued.lock"
        exit /b 0
    )
)
:: Stability check: two size snapshots 60s apart — instrument must not be writing
call :GetSize "%SRC%\analysis.tdf"               SZ1
call :GetSize "%SRC%\analysis.tdf_bin"           SZ2
call :GetSize "%SRC%\chromatography-data.sqlite" SZ3
timeout /t %STABILITY_WAIT% /nobreak >nul
set "SZ1B=" & set "SZ2B=" & set "SZ3B="
call :GetSize "%SRC%\analysis.tdf"               SZ1B
call :GetSize "%SRC%\analysis.tdf_bin"           SZ2B
call :GetSize "%SRC%\chromatography-data.sqlite" SZ3B
if defined SZ1B if not "!SZ1!"=="!SZ1B!" ( echo [%time%] Acquiring: %BN% & echo [%time%] Acquiring: %BN% >> "%LOGFILE%" & set /a ACQUIRING+=1 & exit /b 0 )
if defined SZ2B if not "!SZ2!"=="!SZ2B!" ( echo [%time%] Acquiring: %BN% & echo [%time%] Acquiring: %BN% >> "%LOGFILE%" & set /a ACQUIRING+=1 & exit /b 0 )
if defined SZ3B if not "!SZ3!"=="!SZ3B!" ( echo [%time%] Acquiring: %BN% & echo [%time%] Acquiring: %BN% >> "%LOGFILE%" & set /a ACQUIRING+=1 & exit /b 0 )
:: Source stable — skip copy if destination already matches
if exist "%DATADEST%\analysis.tdf" if exist "%DATADEST%\analysis.tdf_bin" if exist "%DATADEST%\chromatography-data.sqlite" (
    set "DS1=" & set "DS2=" & set "DS3="
    call :GetSize "%DATADEST%\analysis.tdf"               DS1
    call :GetSize "%DATADEST%\analysis.tdf_bin"           DS2
    call :GetSize "%DATADEST%\chromatography-data.sqlite" DS3
    if "!DS1!"=="!SZ1B!" if "!DS2!"=="!SZ2B!" if "!DS3!"=="!SZ3B!" (
        echo [%time%] Verified : %BN%
        echo [%time%] Verified : %BN% >> "%LOGFILE%"
        goto :write_param
    )
)
mkdir "%WORKDIR%"  2>nul
mkdir "%DATADEST%" 2>nul
echo [%time%] Copying  : %BN%
echo [%time%] Copying  : %BN% >> "%LOGFILE%"
robocopy "%SRC%" "%DATADEST%" analysis.tdf analysis.tdf_bin chromatography-data.sqlite /J /R:1 /W:5 /NP /NFL /NDL /NJH /NJS >nul
if errorlevel 8 (
    set /a ERRORS+=1
    echo [%time%] ERROR    : %BN% robocopy failed ^(exit !errorlevel!^)
    echo [%time%] ERROR    : %BN% robocopy failed ^(exit !errorlevel!^) >> "%LOGFILE%"
    exit /b 0
)
echo [%time%] Copied   : %BN%
echo [%time%] Copied   : %BN% >> "%LOGFILE%"
:write_param
set "NEED_PARAM=1"
findstr /i "%BN%" "%RUNPARAM%" >nul 2>nul
if not errorlevel 1 set "NEED_PARAM=0"
if !NEED_PARAM! EQU 1 (
    if exist "%RUNPARAM%" del "%RUNPARAM%" 2>nul
    for /f "usebackq tokens=* delims=" %%A in ("%PARAMFILE%") do (
        set "LINE=%%A"
        set "LINE=!LINE:%SEARCHTEXT%=%DATADEST%!"
        set "LINE=!LINE:%SEARCHTEXT2%=%FASTAFILE%!"
        echo !LINE!>> "%RUNPARAM%"
    )
    if not exist "%RUNPARAM%" ( set /a ERRORS+=1 & echo [%time%] ERROR: param write failed for %BN% & exit /b 0 )
)
if !MQ_LIVE! GEQ %CPU_COUNT% (
    echo [%time%] Queued   : %BN% ^(!MQ_LIVE!/%CPU_COUNT%^)
    echo [%time%] Queued   : %BN% ^(!MQ_LIVE!/%CPU_COUNT%^) >> "%LOGFILE%"
    set /a QUEUED+=1
    if not exist "%WORKDIR%" mkdir "%WORKDIR%"
    echo QUEUED > "%WORKDIR%\queued.lock"
    exit /b 0
)
if exist "%WORKDIR%\queued.lock" del "%WORKDIR%\queued.lock"
start "MQ.%BN%" %MAXQUANTCMD% "%RUNPARAM%"
timeout /t 3 /nobreak >nul
:: Capture PID by window title — avoids slow WMIC scan under heavy load
set "MQ_PID="
for /f "skip=1 tokens=2 delims=," %%P in ('%TLIST% /fi "windowtitle eq MQ.%BN%" /fi "imagename eq MaxQuantCmd.exe" /fo csv 2^>nul') do set "MQ_PID=%%~P"
if not defined MQ_PID (
    echo PENDING> "%WORKDIR%\running.lock"
    set /a LIVE+=1
    set /a MQ_LIVE+=1
    echo [%time%] PENDING  : %BN% ^(launched, PID capture failed - will retry^)
    echo [%time%] PENDING  : %BN% ^(launched, PID capture failed - will retry^) >> "%LOGFILE%"
    echo.
    exit /b 0
)
echo !MQ_PID!> "%WORKDIR%\running.lock"
set /a LIVE+=1
set /a MQ_LIVE+=1
echo [%time%] Launched : %BN% ^(PID:!MQ_PID! slot !MQ_LIVE!/%CPU_COUNT%^)
echo [%time%] Launched : %BN% ^(PID:!MQ_PID! slot !MQ_LIVE!/%CPU_COUNT%^) >> "%LOGFILE%"
echo.
exit /b 0

