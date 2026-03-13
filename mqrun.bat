@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
:: mqrun v28 -- MaxQuant batch watcher for timsTOF HeLa QC runs
::
:: WHAT IT DOES
:: ------------
:: Watches DATAROOT\*\*\*HeLa*.d for new acquisitions.
:: For each folder: copies 3 data files to TMPDIR, writes mqpar.xml,
:: launches MaxQuantCmd.exe, tracks the job to completion, copies
:: results to QCROOT, then cleans up temp data.
::
:: STATE MODEL (per job basename BN)
:: ----------------------------------
::  DONE      SESSIONDIR\BN.done exists
::  QUEUED    WORKDIR\queued.lock exists  (slots full, data already ready)
::  RUNNING   WORKDIR\running.lock = PID | "PENDING"
::  NEW       no lock files at all
::
:: COMPLETION SENTINEL
:: -------------------
:: BN.done lives in SESSIONDIR (not inside WORKDIR).
:: This allows full rmdir /s /q WORKDIR on completion.
:: -- Configuration ------------------------------------------------------------
set MAXQUANTCMD=C:\Program Files\MaxQuant_v2.7.0.0\bin\MaxQuantCmd.exe
set DATAROOT=F:\promec\TIMSTOF\Raw
set DATAPATTERN=*HeLa*.d
set FASTAFILE=F:\promec\FastaDB\UP000005640_9606_1protein1gene.fasta
set PARAMFILE=mqpar.xml
set TMPDIR=D:\TMPDIR
set QCROOT=F:\promec\TIMSTOF\QC
set LOGFILE=%QCROOT%\mqrun_log.txt
set POLL_INTERVAL=1800
set STABILITY_WAIT=60
set CPU_COUNT=64
set MAX_RETRIES=3
set SEARCHTEXT=TestDir
set SEARCHTEXT2=SequencesFasta
set TLIST=%SystemRoot%\System32\tasklist.exe
set WMIC=%SystemRoot%\System32\wbem\wmic.exe
:: -- Validate required paths --------------------------------------------------
if not exist "%MAXQUANTCMD%" ( echo ERROR: MaxQuantCmd not found: %MAXQUANTCMD% & exit /b 1 )
if not exist "%DATAROOT%"    ( echo ERROR: DATAROOT not found: %DATAROOT%        & exit /b 1 )
if not exist "%FASTAFILE%"   ( echo ERROR: FASTA not found: %FASTAFILE%          & exit /b 1 )
if not exist "%PARAMFILE%"   ( echo ERROR: %PARAMFILE% not found in current dir  & exit /b 1 )
:: -- Derive SESSIONDIR from data root and fasta leaf names -------------------
:: e.g. D:\TMPDIR\Raw_UP000005640_9606_1protein1gene
for %%D in ("%DATAROOT%") do set DATAROOT_LEAF=%%~nxD
for %%F in ("%FASTAFILE%") do set FASTA_LEAF=%%~nF
set SESSIONDIR=%TMPDIR%\!DATAROOT_LEAF!_!FASTA_LEAF!
if not exist "%TMPDIR%"     mkdir "%TMPDIR%"
if not exist "!SESSIONDIR!" mkdir "!SESSIONDIR!"
echo Session dir  : !SESSIONDIR!
echo Watching     : %DATAROOT%\*\*\%DATAPATTERN%
echo Poll: %POLL_INTERVAL%s  ^| Stability: %STABILITY_WAIT%s  ^| Slots: %CPU_COUNT%  ^| Retries: %MAX_RETRIES%
echo.
echo [%date% %time%] ===== SESSION START  !SESSIONDIR! ===== >> "%LOGFILE%"
:: -- Startup: remove stale lock files from dead/interrupted processes ---------
:: queued.lock files are always safe to remove on startup (job not yet launched).
:: running.lock files are stale if the PID they contain is no longer alive.
:: PENDING locks (PID capture failed at launch) are also cleared -- will re-adopt or retry.
set "STALE=0"
for /d %%J in ("!SESSIONDIR!\*") do (
    if exist "%%~fJ\queued.lock" ( del /q "%%~fJ\queued.lock" & set /a STALE+=1 )
    if exist "%%~fJ\running.lock" (
        set "ST_PID="
        for /f "usebackq tokens=1" %%P in ("%%~fJ\running.lock") do set "ST_PID=%%P"
        if "!ST_PID!"=="PENDING" (
            del /q "%%~fJ\running.lock" & set /a STALE+=1
        ) else if defined ST_PID (
            %TLIST% /fi "pid eq !ST_PID!" /fo csv /nh 2>nul | findstr /i "MaxQuantCmd" >nul
            if errorlevel 1 ( del /q "%%~fJ\running.lock" & set /a STALE+=1 )
        )
    )
)
if !STALE! GTR 0 call :Log "Startup  : !STALE! stale lock file(s) removed"
:: -- Main poll loop -----------------------------------------------------------
:watch_loop
set FOUND=0 & set DONE=0 & set LIVE=0 & set QUEUED=0
set ACQUIRING=0 & set RETRYING=0 & set ERRORS=0 & set SKIPPED=0
:: Count live MaxQuant processes once per poll (updated locally after each launch)
set "MQ_LIVE=0"
for /f "tokens=1" %%P in ('%TLIST% /fi "imagename eq MaxQuantCmd.exe" /fo csv /nh 2^>nul') do set /a MQ_LIVE+=1
:: Dispatch each acquisition folder
for /d %%U in ("%DATAROOT%\*") do (
    for /d %%V in ("%%~fU\*") do (
        for /d %%I in ("%%~fV\%DATAPATTERN%") do (
            set /a FOUND+=1
            call :CheckFolder "%%~fI"
        )
    )
)
:: Cleanup pass: remove any WORKDIR whose completion sentinel exists.
:: This runs every poll so it self-heals if rmdir failed previously (file handles).
for /d %%W in ("!SESSIONDIR!\*") do (
    if exist "!SESSIONDIR!\%%~nxW.done" (
        if exist "%%~fW" rmdir /s /q "%%~fW" 2>nul
    )
)
:: Poll summary -- inlined because :Log cannot handle the | characters safely
set /a UNKNOWN=FOUND-DONE-LIVE-QUEUED-ACQUIRING-RETRYING-ERRORS-SKIPPED
echo [%time%] Poll: !FOUND! found  ^|  !DONE! done  ^|  !LIVE! running  ^|  !QUEUED! queued  ^|  !ACQUIRING! acquiring  ^|  !RETRYING! retrying  ^|  !ERRORS! errors  ^|  !SKIPPED! skipped  ^|  !UNKNOWN! unknown
echo [%time%] Poll: !FOUND! found  ^|  !DONE! done  ^|  !LIVE! running  ^|  !QUEUED! queued  ^|  !ACQUIRING! acquiring  ^|  !RETRYING! retrying  ^|  !ERRORS! errors  ^|  !SKIPPED! skipped  ^|  !UNKNOWN! unknown >> "%LOGFILE%"
timeout /t %POLL_INTERVAL% /nobreak >nul
goto :watch_loop
:: ---------------------------------------------------------------------------
:: SUBROUTINES
:: ---------------------------------------------------------------------------
:: :Log -- echo to screen and log file. Do NOT pass strings containing | > < &
:Log
echo [%time%] %~1
echo [%time%] %~1 >> "%LOGFILE%"
exit /b 0
:: :GetSize -- sets %~2 to file size in bytes via WMIC (handles >2 GB correctly)
:GetSize
set "%~2="
set "_GP=%~1"
set "_GP=!_GP:\=\\!"
for /f "tokens=2 delims==" %%Z in ('%WMIC% datafile where "name=^'!_GP!^'" get FileSize /format:value 2^>nul ^| more') do (
    for /f "tokens=1" %%V in ("%%Z") do set "%~2=%%V"
)
exit /b 0
:: :AdoptPID -- searches for a live MaxQuantCmd.exe whose commandline contains
:: the given mqpar.xml path. Sets ADOPT_PID if found, clears it otherwise.
:: Arg1: full path to mqpar.xml
:AdoptPID
set "ADOPT_PID="
set "_AP=%~1"
set "_AP=!_AP:\=\\!"
for /f "tokens=2 delims==" %%P in ('%WMIC% process where "name=^'MaxQuantCmd.exe^' and commandline like ^'%%!_AP!%%^'" get ProcessId /format:value 2^>nul ^| more') do (
    for /f "tokens=1" %%V in ("%%P") do if not defined ADOPT_PID set "ADOPT_PID=%%V"
)
exit /b 0
:: :CheckRetry -- reads/increments SESSIONDIR\BN.retries counter.
:: Sets RC_GAVE_UP=1 if MAX_RETRIES exhausted, otherwise increments.
:: Arg1: full path to .retries file   Arg2: basename for log message
:CheckRetry
set "RC_GAVE_UP=0"
set "RC=0"
if exist "%~1" for /f "usebackq tokens=1" %%N in ("%~1") do set "RC=%%N"
if !RC! GEQ %MAX_RETRIES% (
    call :Log "GaveUp   : %~2 (!RC!/%MAX_RETRIES% retries -- needs manual review)"
    set "RC_GAVE_UP=1"
) else (
    set /a RC+=1
    echo !RC!> "%~1"
)
exit /b 0
:: :MarkDone -- completion gate and cleanup.
:: Only proceeds when:
::   1. combined\txt\proteinGroups.txt exists
::   2. combined\proc\#runningTimes.txt contains "Finish writing tables"
::   3. MaxQuantCmd.exe for this job is confirmed dead
:: On success: copies results to QCROOT, writes .done sentinel, rmdirs WORKDIR.
:: Sets DONE_FLAG=1 on success so caller can update counters.
:: Arg1: WORKDIR   Arg2: basename   Arg3: PID (or "PENDING" or "")
:MarkDone
set "MD_W=%~1"
set "MD_BN=%~2"
set "MD_PID=%~3"
set "DONE_FLAG=0"
:: Gate 1: output files must exist and be complete
if not exist "%MD_W%\combined\txt\proteinGroups.txt"  exit /b 0
if not exist "%MD_W%\combined\proc\#runningTimes.txt" exit /b 0
findstr /i "Finish writing tables" "%MD_W%\combined\proc\#runningTimes.txt" >nul 2>nul
if errorlevel 1 exit /b 0
:: Gate 2: process must be dead before we clean up
if /i "!MD_PID!"=="PENDING" ( call :Log "WaitPID  : %MD_BN% (PENDING -- deferring)" & exit /b 0 )
if "!MD_PID!"=="" (
    :: No PID recorded -- check if any live MQ is using this mqpar.xml
    call :AdoptPID "%MD_W%\%PARAMFILE%"
    if defined ADOPT_PID ( call :Log "WaitPID  : %MD_BN% (orphan PID !ADOPT_PID! alive -- deferring)" & exit /b 0 )
    goto :md_proceed
)
%TLIST% /fi "pid eq !MD_PID!" /fo csv /nh 2>nul | findstr /i "MaxQuantCmd" >nul
if not errorlevel 1 ( call :Log "WaitPID  : %MD_BN% (PID !MD_PID! alive -- deferring)" & exit /b 0 )
:md_proceed
:: Copy results to QC share before deleting WORKDIR
if not "%QCROOT%"=="" (
    if not exist "%QCROOT%\" ( call :Log "WARNING  : %MD_BN% QCROOT not reachable -- will retry" & exit /b 0 )
    if not exist "%QCROOT%\%MD_BN%\combined\txt" mkdir "%QCROOT%\%MD_BN%\combined\txt"
    robocopy "%MD_W%\combined\txt" "%QCROOT%\%MD_BN%\combined\txt" /E /XO /R:3 /W:10 /NFL /NDL /NJH /NJS /LOG+:"%QCROOT%\copy_log.txt" >nul
    if errorlevel 8 ( call :Log "ERROR    : %MD_BN% QC copy failed -- skipping cleanup" & exit /b 0 )
    call :Log "QC copy  : %MD_BN% -> %QCROOT%\%MD_BN%\combined\txt"
)
:: Write sentinel at SESSIONDIR level so cleanup pass can rmdir WORKDIR entirely
echo 1> "!SESSIONDIR!\%MD_BN%.done"
set "DONE_FLAG=1"
call :Log "Cleanup  : %MD_BN%"
rmdir /s /q "%MD_W%" 2>nul
:: Clean up retry counter if it exists
if exist "!SESSIONDIR!\%MD_BN%.retries" del /q "!SESSIONDIR!\%MD_BN%.retries"
exit /b 0
:: :WriteParam -- rewrites template mqpar.xml with job-specific paths.
:: Uses %~1/%~2/%~3 (subroutine args, plain strings) to avoid !var! nesting
:: inside substitution expressions -- a fundamental batch parser limitation.
:: Arg1: DATADEST path   Arg2: FASTAFILE path   Arg3: destination mqpar.xml path
:WriteParam
for /f "usebackq tokens=* delims=" %%A in ("%PARAMFILE%") do (
    set "LINE=%%A"
    set "LINE=!LINE:%SEARCHTEXT%=%~1!"
    set "LINE=!LINE:%SEARCHTEXT2%=%~2!"
    echo !LINE!>> "%~3"
)
exit /b 0
:: :CheckFolder -- per-job state machine. Called for every *.d source folder.
:: Arg1: full path to source .d folder
:CheckFolder
set "SRC=%~1"
set "BN=%~n1"
set "WORKDIR=!SESSIONDIR!\%BN%"
set "DATADEST=!WORKDIR!\data.d"
set "RUNPARAM=!WORKDIR!\%PARAMFILE%"
:: -- STATE: DONE -------------------------------------------------------------
if exist "!SESSIONDIR!\%BN%.done" ( set /a DONE+=1 & exit /b 0 )
:: -- STATE: QUEUED ------------------------------------------------------------
:: queued.lock = data is ready, waiting for a CPU slot.
:: If a slot is now free, delete the lock and fall through to launch.
if exist "!WORKDIR!\queued.lock" (
    if !MQ_LIVE! GEQ %CPU_COUNT% ( set /a QUEUED+=1 & exit /b 0 )
    del /q "!WORKDIR!\queued.lock"
)
:: -- STATE: COMPLETING --------------------------------------------------------
:: proteinGroups.txt exists but .done not yet written.
:: This handles the case where job completes between polls regardless of lock state.
if exist "!WORKDIR!\combined\txt\proteinGroups.txt" (
    set "CK_PID="
    if exist "!WORKDIR!\running.lock" for /f "usebackq tokens=1" %%P in ("!WORKDIR!\running.lock") do set "CK_PID=%%P"
    call :MarkDone "!WORKDIR!" "%BN%" "!CK_PID!"
    if "!DONE_FLAG!"=="1" ( set /a DONE+=1 & call :Log "Completed: %BN%" & exit /b 0 )
)
:: -- STATE: RUNNING -----------------------------------------------------------
if not exist "!WORKDIR!\running.lock" goto :no_lockfile
set "MQ_PID="
for /f "usebackq tokens=1" %%P in ("!WORKDIR!\running.lock") do set "MQ_PID=%%P"
:: Empty lockfile should not happen -- flag as error rather than silently looping
if not defined MQ_PID ( set /a ERRORS+=1 & call :Log "ERROR    : %BN% (empty running.lock)" & exit /b 0 )
:: PENDING = launch succeeded but PID capture failed. Try to adopt via WMIC.
if "!MQ_PID!"=="PENDING" (
    call :AdoptPID "!RUNPARAM!"
    if defined ADOPT_PID (
        echo !ADOPT_PID!> "!WORKDIR!\running.lock"
        set /a LIVE+=1
        call :Log "Adopted  : %BN% (PID:!ADOPT_PID! resolved from PENDING)"
        exit /b 0
    )
    :: No live MQ found for this job -- it crashed before PID was captured
    set "_RC=!SESSIONDIR!\%BN%.retries"
    call :CheckRetry "!_RC!" "%BN%"
    if "!RC_GAVE_UP!"=="1" ( set /a ERRORS+=1 & exit /b 0 )
    call :Log "CrashWipe: %BN% (PENDING, no live MQ -- retry !RC!/%MAX_RETRIES%)"
    rmdir /s /q "!WORKDIR!" 2>nul
    set /a RETRYING+=1
    exit /b 0
)
:: Normal running state -- verify PID is still alive
set /a LIVE+=1
%TLIST% /fi "pid eq !MQ_PID!" /fo csv /nh 2>nul | findstr /i "MaxQuantCmd" >nul
if not errorlevel 1 exit /b 0
:: PID not found -- wait 5 s and check once more to avoid false positives from tasklist lag
timeout /t 5 /nobreak >nul
%TLIST% /fi "pid eq !MQ_PID!" /fo csv /nh 2>nul | findstr /i "MaxQuantCmd" >nul
if not errorlevel 1 exit /b 0
:: PID confirmed dead
del /q "!WORKDIR!\running.lock"
set /a LIVE-=1
call :MarkDone "!WORKDIR!" "%BN%" "!MQ_PID!"
if "!DONE_FLAG!"=="1" ( set /a DONE+=1 & call :Log "Completed: %BN% (PID !MQ_PID! exited)" & exit /b 0 )
:: proteinGroups.txt missing -- check for any .txt output (fallback; skips QC copy)
set "FOUND_OUTPUT=0"
for %%F in ("!WORKDIR!\combined\txt\*.txt") do set "FOUND_OUTPUT=1"
if !FOUND_OUTPUT! EQU 1 (
    echo 1> "!SESSIONDIR!\%BN%.done"
    set /a DONE+=1
    call :Log "Completed: %BN% (fallback .txt found -- QC copy skipped)"
    exit /b 0
)
:: No output at all -- job failed. Retry up to MAX_RETRIES.
set /a RETRYING+=1
call :Log "Failed   : %BN% (PID !MQ_PID! gone, no output -- retrying)"
set "_RC=!SESSIONDIR!\%BN%.retries"
call :CheckRetry "!_RC!" "%BN%"
if "!RC_GAVE_UP!"=="1" ( set /a RETRYING-=1 & set /a ERRORS+=1 )
exit /b 0
:: :no_lockfile -- new job or recovered job with no lock
:no_lockfile
:: Try to adopt an already-running MQ that has no lock (e.g. from previous script version)
call :AdoptPID "!RUNPARAM!"
if defined ADOPT_PID (
    if not exist "!WORKDIR!" mkdir "!WORKDIR!"
    echo !ADOPT_PID!> "!WORKDIR!\running.lock"
    set /a LIVE+=1
    call :Log "Adopted  : %BN% (PID:!ADOPT_PID!)"
    exit /b 0
)
:: Source files must all exist before we do anything
if not exist "%SRC%\analysis.tdf"               ( set /a SKIPPED+=1 & call :Log "Skipped  : %BN% (analysis.tdf missing)"               & exit /b 0 )
if not exist "%SRC%\analysis.tdf_bin"           ( set /a SKIPPED+=1 & call :Log "Skipped  : %BN% (analysis.tdf_bin missing)"           & exit /b 0 )
if not exist "%SRC%\chromatography-data.sqlite" ( set /a SKIPPED+=1 & call :Log "Skipped  : %BN% (chromatography-data.sqlite missing)" & exit /b 0 )
:: -- Stability check ----------------------------------------------------------
:: Measure source file sizes, wait STABILITY_WAIT, measure again.
:: If any size changed the instrument is still writing -- defer to next poll.
call :GetSize "%SRC%\analysis.tdf"               SZ1
call :GetSize "%SRC%\analysis.tdf_bin"           SZ2
call :GetSize "%SRC%\chromatography-data.sqlite" SZ3
timeout /t %STABILITY_WAIT% /nobreak >nul
set "SZ1B=" & set "SZ2B=" & set "SZ3B="
call :GetSize "%SRC%\analysis.tdf"               SZ1B
call :GetSize "%SRC%\analysis.tdf_bin"           SZ2B
call :GetSize "%SRC%\chromatography-data.sqlite" SZ3B
if defined SZ1B if not "!SZ1!"=="!SZ1B!" ( set /a ACQUIRING+=1 & call :Log "Acquiring: %BN% (analysis.tdf changing)"               & exit /b 0 )
if defined SZ2B if not "!SZ2!"=="!SZ2B!" ( set /a ACQUIRING+=1 & call :Log "Acquiring: %BN% (analysis.tdf_bin changing)"           & exit /b 0 )
if defined SZ3B if not "!SZ3!"=="!SZ3B!" ( set /a ACQUIRING+=1 & call :Log "Acquiring: %BN% (chromatography-data.sqlite changing)" & exit /b 0 )
:: -- Copy or verify -----------------------------------------------------------
:: If dest already has files matching the post-stability source sizes, skip copy.
:: This handles restarts mid-copy and jobs that were previously queued.
set "NEED_COPY=1"
if exist "!DATADEST!\analysis.tdf" if exist "!DATADEST!\analysis.tdf_bin" if exist "!DATADEST!\chromatography-data.sqlite" (
    set "DS1=" & set "DS2=" & set "DS3="
    call :GetSize "!DATADEST!\analysis.tdf"               DS1
    call :GetSize "!DATADEST!\analysis.tdf_bin"           DS2
    call :GetSize "!DATADEST!\chromatography-data.sqlite" DS3
    if "!DS1!"=="!SZ1B!" if "!DS2!"=="!SZ2B!" if "!DS3!"=="!SZ3B!" (
        call :Log "Verified : %BN% (dest matches source, skipping copy)"
        set "NEED_COPY=0"
    )
)
if !NEED_COPY! EQU 1 (
    mkdir "!WORKDIR!"  2>nul
    mkdir "!DATADEST!" 2>nul
    call :Log "Copying  : %BN%"
    robocopy "%SRC%" "!DATADEST!" analysis.tdf analysis.tdf_bin chromatography-data.sqlite /J /R:1 /W:5 /NP /NFL /NDL /NJH /NJS >nul
    if errorlevel 8 ( set /a ERRORS+=1 & call :Log "ERROR    : %BN% robocopy failed" & exit /b 0 )
    call :Log "Copied   : %BN%"
)
:: -- Write mqpar.xml -----------------------------------------------------------
:: Check if RUNPARAM already contains this job's basename (i.e. has correct paths).
:: If yes, skip rewrite. This is safe because BN is part of DATADEST path.
set "NEED_PARAM=1"
if exist "!RUNPARAM!" (
    findstr /i "%BN%" "!RUNPARAM!" >nul 2>nul
    if not errorlevel 1 set "NEED_PARAM=0"
)
if !NEED_PARAM! EQU 1 (
    if exist "!RUNPARAM!" del /q "!RUNPARAM!"
    if not exist "!WORKDIR!" mkdir "!WORKDIR!"
    call :WriteParam "!DATADEST!" "%FASTAFILE%" "!RUNPARAM!"
    if not exist "!RUNPARAM!" ( set /a ERRORS+=1 & call :Log "ERROR    : %BN% mqpar.xml write failed" & exit /b 0 )
)
:: -- Launch gate --------------------------------------------------------------
:: If no slot available, save queued.lock and exit. Next poll will resume here
:: (queued.lock check at top of :CheckFolder). Data and mqpar.xml are already ready.
if !MQ_LIVE! GEQ %CPU_COUNT% (
    if not exist "!WORKDIR!" mkdir "!WORKDIR!"
    echo QUEUED> "!WORKDIR!\queued.lock"
    set /a QUEUED+=1
    call :Log "Queued   : %BN% (!MQ_LIVE!/%CPU_COUNT% slots used)"
    exit /b 0
)
if exist "!WORKDIR!\queued.lock" del /q "!WORKDIR!\queued.lock"
:: -- Launch -------------------------------------------------------------------
start "MQ.%BN%" "%MAXQUANTCMD%" "!RUNPARAM!"
:: Wait briefly then capture PID via window title (fast, no WMIC overhead)
timeout /t 3 /nobreak >nul
set "MQ_PID="
for /f "skip=1 tokens=2 delims=," %%P in ('%TLIST% /fi "windowtitle eq MQ.%BN%" /fi "imagename eq MaxQuantCmd.exe" /fo csv 2^>nul') do set "MQ_PID=%%~P"
if not exist "!WORKDIR!" mkdir "!WORKDIR!"
if not defined MQ_PID (
    :: PID capture failed but job was launched -- mark PENDING for next poll to resolve
    echo PENDING> "!WORKDIR!\running.lock"
    set /a LIVE+=1 & set /a MQ_LIVE+=1
    call :Log "PENDING  : %BN% (launched, PID capture failed -- will resolve next poll)"
    echo.
    exit /b 0
)
echo !MQ_PID!> "!WORKDIR!\running.lock"
set /a LIVE+=1 & set /a MQ_LIVE+=1
call :Log "Launched : %BN% (PID:!MQ_PID! slot !MQ_LIVE!/%CPU_COUNT%)"
echo.
exit /b 0

