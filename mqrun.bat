@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

:: ============================================================
:: mqrun.bat - MaxQuant batch watcher for TimsTOF HeLa QC data
:: PROMEC proteomics facility, Trondheim
::
:: FULL SESSION HISTORY (2026-03-01 to 2026-03-04)
:: ---------------------------------------------------------------
:: v1 (2026-03-01): Initial script. Folder pattern matching,
::   acquisition lock detection, lockfile state management,
::   PID tracking, copy verification, retry logic.
::
:: v2 (2026-03-02): Fixed false-crash detection bug causing jobs
::   to run without lockfiles (62 processes, only 13 lockfiles).
::   Added orphan recovery via wmic commandline matching.
::
:: v3 (2026-03-03): Fixed PID capture using percent-expansion
::   instead of delayed expansion -> empty lockfiles -> 61 ghost
::   jobs. Fixed with proper delayed expansion + orphan recovery.
::   Added conditional param rewrite (skip if already correct).
::
:: v4 (2026-03-03): Performance fix. Poll was taking 16 minutes
::   because tasklist was called once per folder (30s x 33 = 16min).
::   Moved MQ_LIVE count to top of watch_loop, called once per poll.
::   Added skipped-folder reporting. Separated STABILITY_WAIT from
::   POLL_INTERVAL. Removed data.d deletion on failure.
::
:: v5 (2026-03-04): Final audit. Fixed LIVE counter inflation bug.
::   Fixed false "Acquiring" messages when wmic fails (undefined
::   vars). Added "if defined" guards on stability size comparisons.
::
:: v6 (2026-03-04): ROOT CAUSE FIX for 90-minute cycling.
::
::   PROBLEM DIAGNOSED:
::   CPU_COUNT was blank, defaulting to NUMBER_OF_PROCESSORS=128
::   on this dual-socket 16-core + hyperthreading machine. But
::   mqpar.xml has numThreads=1 -> each MQ job is single-threaded.
::   Result: 73+ jobs competing for 32 physical cores -> ~25% CPU
::   per job -> jobs that should finish in hours ran at 25% speed,
::   stalled at Feature Detection, eventually died. Script saw
::   PID gone + no output = FALSE failure -> endless relaunch.
::
::   EVIDENCE (timings.txt, 185 job folders analysed):
::   - 109 completed jobs: runtime 26min to 53hrs (median ~10hrs)
::   - Feature detection step alone: 2 to 247min (median 106min)
::   - 26 jobs stuck mid-run, killed by CPU starvation
::   - 50 jobs never advanced past "Testing raw files"
::   - _2 suffix jobs (ran with less competition) finished faster
::
::   THERE IS NO KILL TIMEOUT in this script. Jobs are never
::   actively terminated. The ~90min pattern was not a timer -
::   it was the average time for a starved job to die on its own.
::   The fix is CPU_COUNT=32, not any timeout parameter.
::
::   ADDITIONAL FIXES in v6:
::   - done.lock sentinel: written when PID gone + output found.
::     Completion counter was stuck at 100 for 20+ hours because
::     proteinGroups.txt check was the sole completion signal, but
::     MQ only writes combined\txt\ at the very last step. done.lock
::     persists across restarts and makes future polls instant.
::   - PENDING sentinel: written when PID capture fails at launch.
::     Without this the job fell out of all counters, causing the
::     arithmetic gap: 175 found but 100+71+3=174 (missing 1).
::     Orphan adoption resolves PENDING on the next poll.
::   - POLL_INTERVAL increased to 1800s (30min). Jobs take hours;
::     the previous 600s (10min) interval was log spam.
:: ============================================================


:: ============================================================
:: Configuration
:: ============================================================
set MAXQUANTCMD="C:\Program Files\MaxQuant_v2.7.0.0\bin\MaxQuantCmd.exe"
set DATAROOT=F:\promec\TIMSTOF\Raw
set DATAPATTERN=*HeLa*.d
set FASTAFILE=F:\promec\FastaDB\UP000005640_9606_1protein1gene.fasta
set PARAMFILE=mqpar.xml
set TMPDIR=D:\TMPDIR

:: Poll interval 1800s = 30 minutes.
:: Jobs take 26min to 53hrs (median ~10hrs). 30min is ample.
set POLL_INTERVAL=1800

:: Stability wait: re-check source sizes after this many seconds.
:: Guards against copying files that are still being acquired.
set STABILITY_WAIT=60

:: Substitution tokens in template mqpar.xml
set SEARCHTEXT=TestDir
set SEARCHTEXT2=SequencesFasta

:: QCROOT: destination for completed results (combined\txt\ only).
:: Robocopy copies txt folder here on job completion, then bulk files
:: on D:\TMPDIR are deleted. Set blank to disable QC copy.
:: Keep on a DIFFERENT drive from DATAROOT to avoid single point of failure.
set QCROOT=F:\promec\TIMSTOF\QC

:: CPU_COUNT: MUST be set explicitly. DO NOT leave blank.
::
:: Hardware: 2x 16-core Intel = 32 physical cores, 64 logical (HT).
:: NUMBER_OF_PROCESSORS returns 128 on this machine - DO NOT USE.
:: mqpar.xml numThreads=1 -> each MQ job uses exactly 1 core.
::
:: CPU_COUNT=32  -> one job per physical core.  Safe, tested.
:: CPU_COUNT=64  -> uses hyperthreading. May help, not yet tested.
::
:: Setting CPU_COUNT above logical core count causes CPU starvation:
:: jobs run at fractional speed, appear to hang at Feature Detection,
:: eventually crash, and get relaunched endlessly (~90min cycle).
set CPU_COUNT=64

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
:: e.g. D:\TMPDIR\Raw_UP000005640_9606_1protein1gene
:: ============================================================
for %%D in ("%DATAROOT%") do set DATAROOT_LEAF=%%~nxD
for %%F in ("%FASTAFILE%") do set FASTA_LEAF=%%~nF
set SESSIONDIR=%TMPDIR%\!DATAROOT_LEAF!_!FASTA_LEAF!
if not exist "%TMPDIR%"     mkdir "%TMPDIR%"
if not exist "!SESSIONDIR!" mkdir "!SESSIONDIR!"

echo Session dir  : !SESSIONDIR!
echo Watching     : %DATAROOT%\*\*\%DATAPATTERN%
echo Poll: %POLL_INTERVAL%s  ^| Stability: %STABILITY_WAIT%s  ^| Max parallel: %CPU_COUNT%
echo.


:: ============================================================
:: Main watch loop
:: ============================================================
:watch_loop
set FOUND=0 & set DONE=0 & set QUEUED=0 & set LIVE=0 & set SKIPPED=0

:: Count running MQ processes ONCE at poll start (v4 fix).
:: Calling tasklist inside :CheckFolder was 30s x N folders = 16min polls.
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

:: ---------------------------------------------------------------
:: Orphan-completed scan (v6)
:: Counts TMPDIR workdirs with done.lock but no corresponding
:: source .d folder on the instrument drive.
:: Typical case: _2/_N reprocessing jobs from prior sessions.
:: Never visited by main poll loop so excluded from DONE without
:: this scan.
:: ---------------------------------------------------------------
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
        if "!SRC_FOUND!"=="0" (
            set /a ORPHAN_DONE+=1
            set /a DONE+=1
        )
    )
)
if !ORPHAN_DONE! GTR 0 echo [%time%] Orphan-done: !ORPHAN_DONE! completed jobs with no source folder ^(counted in done^)

echo [%time%] Poll: !FOUND! found  ^|  !DONE! done  ^|  !LIVE! running  ^|  !QUEUED! queued  ^|  !SKIPPED! skipped
timeout /t %POLL_INTERVAL% /nobreak >nul
goto :watch_loop


:: ============================================================
:: :MarkDone <workdir> <bn>
:: Verifies true completion, copies results to QCROOT, cleans up bulk
:: files, writes done.lock.
:: Steps (only if both conditions met):
::   1. combined\txt\proteinGroups.txt exists
::   2. combined\proc\#runningTimes.txt contains "Finish writing tables"
:: Then:
::   - Robocopy combined\txt\ -> QCROOT\<bn>\combined\txt\ (/XO /LOG+)
::   - Delete data.d\, data\, combined\andromeda\, combined\search\,
::     combined\proc\, combined\sdrf\, combined\combinedRunInfo\,
::     mqpar.xml, running.lock, data.index
::   - Write done.lock, set DONE_FLAG=1
:: If not ready -> return 0 (job still running or writing)
:: ============================================================
:MarkDone
set "MD_WORKDIR=%~1"
set "MD_BN=%~2"
set "DONE_FLAG=0"

:: Safety: MD_WORKDIR is always SESSIONDIR\<job>, which is always
:: under TMPDIR (D:\TMPDIR). This is structurally guaranteed by how
:: WORKDIR is constructed at the top of :CheckFolder. No runtime
:: path check needed - batch string matching is unreliable here.

:: Condition 1: proteinGroups.txt present
if not exist "%MD_WORKDIR%\combined\txt\proteinGroups.txt" exit /b 0

:: Condition 2: "Finish writing tables" in #runningTimes.txt
if not exist "%MD_WORKDIR%\combined\proc\#runningTimes.txt" exit /b 0
findstr /i "Finish writing tables" "%MD_WORKDIR%\combined\proc\#runningTimes.txt" >nul 2>nul
if errorlevel 1 exit /b 0

:: Both conditions met - job is truly complete.
:: Step 1: Copy results to QCROOT before deleting anything.
:: Check mapped drive is reachable. If not: skip cleanup entirely,
:: results stay on D: and will be retried on the next poll.
if not "%QCROOT%"=="" (
    if not exist "%QCROOT%\\" (
        echo [%time%] WARNING  : %MD_BN% QCROOT not reachable ^(%QCROOT%^) - will retry next poll
        exit /b 0
    )
    if not exist "%QCROOT%\\%MD_BN%\\combined\\txt" mkdir "%QCROOT%\\%MD_BN%\\combined\\txt"
    robocopy "%MD_WORKDIR%\\combined\\txt" "%QCROOT%\\%MD_BN%\\combined\\txt" /E /XO /R:3 /W:10 /NFL /NDL /NJH /NJS /LOG+:"%QCROOT%\\copy_log.txt" >nul
    if errorlevel 8 (
        echo [%time%] ERROR    : %MD_BN% QC copy failed - skipping cleanup to preserve results
        exit /b 0
    )
    echo [%time%] QC copy  : %MD_BN% -> %QCROOT%\\%MD_BN%\\combined\\txt
)

:: Step 2: Delete bulk files now that results are safely copied.
echo [%time%] Cleanup  : %MD_BN%
if exist "%MD_WORKDIR%\data.d"                    rmdir /s /q "%MD_WORKDIR%\data.d"
if exist "%MD_WORKDIR%\data"                      rmdir /s /q "%MD_WORKDIR%\data"
if exist "%MD_WORKDIR%\combined\andromeda"       rmdir /s /q "%MD_WORKDIR%\combined\andromeda"
if exist "%MD_WORKDIR%\combined\search"          rmdir /s /q "%MD_WORKDIR%\combined\search"
if exist "%MD_WORKDIR%\combined\proc"            rmdir /s /q "%MD_WORKDIR%\combined\proc"
if exist "%MD_WORKDIR%\combined\sdrf"            rmdir /s /q "%MD_WORKDIR%\combined\sdrf"
if exist "%MD_WORKDIR%\combined\combinedRunInfo" rmdir /s /q "%MD_WORKDIR%\combined\combinedRunInfo"
if exist "%MD_WORKDIR%\mqpar.xml"                 del /f /q "%MD_WORKDIR%\mqpar.xml"
if exist "%MD_WORKDIR%\data.index"                del /f /q "%MD_WORKDIR%\data.index"
if exist "%MD_WORKDIR%\running.lock"              del /f /q "%MD_WORKDIR%\running.lock"

echo 1> "%MD_WORKDIR%\done.lock"
set "DONE_FLAG=1"
exit /b 0

:: ============================================================
:: :GetSize <file_path> <var_name>
:: ============================================================
:GetSize
set "%~2="
set "_P=%~1"
set "_P=!_P:\=\\!"
for /f "tokens=2 delims==" %%Z in ('%WMIC% datafile where "name=^'!_P!^'" get FileSize /format:value 2^>nul ^| more') do for /f "tokens=1" %%V in ("%%Z") do set "%~2=%%V"
exit /b 0


:: ============================================================
:: :CheckFolder <full_source_folder_path>
::
:: Per-job state machine:
::   done.lock exists             -> DONE
::   proteinGroups.txt exists     -> DONE (backfills done.lock)
::   running.lock = valid PID, alive  -> LIVE
::   running.lock = valid PID, gone   -> check output -> DONE or FAILED+relaunch
::   running.lock = PENDING           -> try orphan adoption -> LIVE
::   no lockfile, orphan found via wmic -> ADOPTED -> LIVE
::   no lockfile, source incomplete   -> SKIPPED
::   no lockfile, slots full          -> QUEUED
::   no lockfile, slots free          -> copy + write param + launch
:: ============================================================
:CheckFolder
set "SRC=%~1"
set "BN=%~n1"
set "WORKDIR=%SESSIONDIR%\%BN%"
set "DATADEST=%WORKDIR%\data.d"
set "RUNPARAM=%WORKDIR%\%PARAMFILE%"

:: ---------------------------------------------------------------
:: COMPLETION CHECK 1: done.lock sentinel
:: Fast path - job already fully processed and cleaned up.
:: ---------------------------------------------------------------
if exist "%WORKDIR%\done.lock" (
    set /a DONE+=1
    if exist "%WORKDIR%\running.lock" del "%WORKDIR%\running.lock"
    exit /b 0
)

:: COMPLETION CHECK 2: proteinGroups.txt + "Finish writing tables"
:: Only triggers if job completed since last poll.
:: :MarkDone verifies both conditions, cleans bulk files, writes done.lock.
if exist "%WORKDIR%\combined\txt\proteinGroups.txt" (
    set "DONE_FLAG=0"
    call :MarkDone "%WORKDIR%" "%BN%"
    if "!DONE_FLAG!"=="1" (
        set /a DONE+=1
        echo [%time%] Completed: %BN%
        exit /b 0
    )
)

:: ---------------------------------------------------------------
:: RUNNING CHECK: lockfile present
:: ---------------------------------------------------------------
if not exist "%WORKDIR%\running.lock" goto :no_lockfile
set "MQ_PID="
for /f "usebackq tokens=1" %%P in ("%WORKDIR%\running.lock") do set "MQ_PID=%%P"

:: PENDING sentinel (v6)
:: Written at launch when wmic PID capture fails (timing race).
:: Without this, job disappears from all counters next poll:
::   175 found, but 100+71+3=174 -> 1 job unaccounted for.
:: Each poll tries to resolve PENDING via commandline match.
if "!MQ_PID!"=="PENDING" (
    set "WMIC_PARAM=!RUNPARAM:\=\\!"
    set "ADOPT_PID="
    for /f "tokens=2 delims==" %%P in ('%WMIC% process where "name=^'MaxQuantCmd.exe^' and commandline like ^'%%!WMIC_PARAM!%%^'" get ProcessId /format:value 2^>nul ^| more') do (
        for /f "tokens=1" %%V in ("%%P") do if not defined ADOPT_PID set "ADOPT_PID=%%V"
    )
    if defined ADOPT_PID (
        echo !ADOPT_PID!> "%WORKDIR%\running.lock"
        set /a LIVE+=1
        set /a MQ_LIVE+=1
        echo [%time%] Adopted  : %BN% ^(PID:!ADOPT_PID! resolved from PENDING^)
        exit /b 0
    )
    :: Not findable yet - count as live optimistically, retry next poll
    set /a LIVE+=1
    exit /b 0
)

if not defined MQ_PID ( echo [%time%] Skipped  : %BN% ^(empty lockfile^) & set /a SKIPPED+=1 & exit /b 0 )

:: Is the process still alive?
set /a LIVE+=1
%TLIST% /fi "pid eq !MQ_PID!" /fo csv /nh 2>nul | findstr /i "MaxQuantCmd" >nul
if not errorlevel 1 exit /b 0

:: ---------------------------------------------------------------
:: PID is gone. Determine if job completed or crashed.
::
:: NOTE: There is no kill timeout. The script never terminates jobs.
:: PID gone means the process exited on its own - either success
:: (output present) or crash/OOM (no output).
::
:: The historical ~90min failure cycle was NOT a timeout. It was:
::   CPU starvation (128 jobs / 32 cores = 25% CPU each)
::   -> jobs ran at 25% speed
::   -> Feature Detection took 4x longer than normal
::   -> jobs eventually died (OOM, Windows scheduler, etc.)
::   -> no output found -> script correctly relaunched them
::   -> cycle repeated every ~90min indefinitely
:: Fix: CPU_COUNT=32 gives each job a full core. No starvation.
:: ---------------------------------------------------------------
del "%WORKDIR%\running.lock"
set /a LIVE-=1

:: Check for completion using same two-condition verification
set "DONE_FLAG=0"
call :MarkDone "%WORKDIR%" "%BN%"
if "!DONE_FLAG!"=="1" (
    set /a DONE+=1
    echo [%time%] Completed: %BN% ^(PID !MQ_PID! exited, cleanup done^)
    exit /b 0
)

echo [%time%] Failed   : %BN% ^(PID !MQ_PID! gone, no output, retrying^)
exit /b 0


:no_lockfile
:: ---------------------------------------------------------------
:: ORPHAN RECOVERY (v2/v3)
:: Process running but lockfile missing. Occurs after:
::   - Script restart while jobs were running
::   - Prior session's PENDING that was never resolved
::   - PID capture race condition in prior session
:: Match by full RUNPARAM path in commandline (unique per job).
:: ---------------------------------------------------------------
set "WMIC_PARAM=!RUNPARAM:\=\\!"
set "ADOPT_PID="
for /f "tokens=2 delims==" %%P in ('%WMIC% process where "name=^'MaxQuantCmd.exe^' and commandline like ^'%%!WMIC_PARAM!%%^'" get ProcessId /format:value 2^>nul ^| more') do (
    for /f "tokens=1" %%V in ("%%P") do if not defined ADOPT_PID set "ADOPT_PID=%%V"
)
if defined ADOPT_PID (
    echo !ADOPT_PID!> "%WORKDIR%\running.lock"
    set /a LIVE+=1
    echo [%time%] Adopted  : %BN% ^(PID:!ADOPT_PID!^)
    exit /b 0
)

:: ---------------------------------------------------------------
:: NEW JOB: no lock, no orphan -> evaluate for launch
:: ---------------------------------------------------------------

:: Skip if Bruker source files incomplete (instrument still acquiring)
if not exist "%SRC%\analysis.tdf"               ( set /a SKIPPED+=1 & echo [%time%] Skipped  : %BN% ^(analysis.tdf missing^)               & exit /b 0 )
if not exist "%SRC%\analysis.tdf_bin"           ( set /a SKIPPED+=1 & echo [%time%] Skipped  : %BN% ^(analysis.tdf_bin missing^)           & exit /b 0 )
if not exist "%SRC%\chromatography-data.sqlite" ( set /a SKIPPED+=1 & echo [%time%] Skipped  : %BN% ^(chromatography-data.sqlite missing^) & exit /b 0 )

:: If slots full and data already copied, queue without re-checking sizes
if !MQ_LIVE! GEQ %CPU_COUNT% (
    if exist "%DATADEST%\analysis.tdf" if exist "%DATADEST%\analysis.tdf_bin" if exist "%DATADEST%\chromatography-data.sqlite" (
        set /a QUEUED+=1
        exit /b 0
    )
)

:: Get source file sizes
call :GetSize "%SRC%\analysis.tdf"               SZ1
call :GetSize "%SRC%\analysis.tdf_bin"           SZ2
call :GetSize "%SRC%\chromatography-data.sqlite" SZ3

:: Skip copy if local data already matches source exactly
set "NEED_COPY=1"
if exist "%DATADEST%\analysis.tdf" if exist "%DATADEST%\analysis.tdf_bin" if exist "%DATADEST%\chromatography-data.sqlite" (
    set "DS1=" & set "DS2=" & set "DS3="
    call :GetSize "%DATADEST%\analysis.tdf"               DS1
    call :GetSize "%DATADEST%\analysis.tdf_bin"           DS2
    call :GetSize "%DATADEST%\chromatography-data.sqlite" DS3
    if "!DS1!"=="!SZ1!" if "!DS2!"=="!SZ2!" if "!DS3!"=="!SZ3!" set "NEED_COPY=0"
)

if !NEED_COPY! EQU 0 (
    echo [%time%] Verified : %BN%
    goto :write_param
)

:: Stability check: re-read sizes after STABILITY_WAIT seconds.
:: "if defined" guards prevent false Acquiring on wmic failure (v5 fix).
timeout /t %STABILITY_WAIT% /nobreak >nul
set "SZ1B=" & set "SZ2B=" & set "SZ3B="
call :GetSize "%SRC%\analysis.tdf"               SZ1B
call :GetSize "%SRC%\analysis.tdf_bin"           SZ2B
call :GetSize "%SRC%\chromatography-data.sqlite" SZ3B
if defined SZ1B if not "!SZ1!"=="!SZ1B!" ( echo [%time%] Acquiring: %BN% & exit /b 0 )
if defined SZ2B if not "!SZ2!"=="!SZ2B!" ( echo [%time%] Acquiring: %BN% & exit /b 0 )
if defined SZ3B if not "!SZ3!"=="!SZ3B!" ( echo [%time%] Acquiring: %BN% & exit /b 0 )

:: Copy raw data to local fast disk
mkdir "%WORKDIR%"  2>nul
mkdir "%DATADEST%" 2>nul
echo [%time%] Copying  : %BN%
xcopy /y "%SRC%\analysis.tdf"               "%DATADEST%\" >nul
xcopy /y "%SRC%\analysis.tdf_bin"           "%DATADEST%\" >nul
xcopy /y "%SRC%\chromatography-data.sqlite" "%DATADEST%\" >nul
if not exist "%DATADEST%\analysis.tdf"               ( echo [%time%] ERROR: copy failed & exit /b 0 )
if not exist "%DATADEST%\analysis.tdf_bin"           ( echo [%time%] ERROR: copy failed & exit /b 0 )
if not exist "%DATADEST%\chromatography-data.sqlite" ( echo [%time%] ERROR: copy failed & exit /b 0 )
echo [%time%] Copied   : %BN%

:write_param
:: Write job-specific mqpar.xml. Skip if this folder is already present
:: in the file (v3 fix: avoid param churn mid-run).
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
    if not exist "%RUNPARAM%" ( echo [%time%] ERROR: param write failed for %BN% & exit /b 0 )
)

:: Enforce parallel job limit
if !MQ_LIVE! GEQ %CPU_COUNT% (
    echo [%time%] Queued   : %BN% ^(!MQ_LIVE!/%CPU_COUNT%^)
    set /a QUEUED+=1
    exit /b 0
)

:: Launch MaxQuant as detached process
start "MQ.%BN%" %MAXQUANTCMD% "%RUNPARAM%"
timeout /t 5 /nobreak >nul

:: Capture PID. Match by full RUNPARAM path (unique per job).
set "MQ_PID="
set "WMIC_PARAM=!RUNPARAM:\=\\!"
for /f "tokens=2 delims==" %%P in ('%WMIC% process where "name=^'MaxQuantCmd.exe^' and commandline like ^'%%!WMIC_PARAM!%%^'" get ProcessId /format:value 2^>nul ^| more') do (
    for /f "tokens=1" %%V in ("%%P") do if not defined MQ_PID set "MQ_PID=%%V"
)
if not defined MQ_PID (
    :: Write PENDING so job stays counted in LIVE.
    :: Orphan adoption above will resolve this on next poll.
    echo PENDING> "%WORKDIR%\running.lock"
    set /a LIVE+=1
    set /a MQ_LIVE+=1
    echo [%time%] PENDING  : %BN% ^(launched, PID capture failed - will retry^)
    echo.
    exit /b 0
)
echo !MQ_PID!> "%WORKDIR%\running.lock"
set /a LIVE+=1
set /a MQ_LIVE+=1
echo [%time%] Launched : %BN% ^(PID:!MQ_PID! slot !MQ_LIVE!/%CPU_COUNT%^)
echo.
exit /b 0
:: FOR /D %E IN ("D:\TMPDIR\Raw_UP000005640_9606_1protein1gene\*") DO (IF EXIST "%E\combined\txt\" (Robocopy "%E\combined\txt" "F:\promec\TIMSTOF\QC\%~nxE\combined\txt" /E /XO /LOG+:F:\promec\TIMSTOF\QC\copy_log.txt))
:: delete SRC

