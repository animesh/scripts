@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

:: Configuration
:: v7 (2026-03-06): Three production bug fixes from 178-job log analysis.
::
::   FIX 1 - queued.lock sentinel: 9 jobs stuck "queued" forever.
::   FIX 2 - Double-check PID: 50+ mass failures from WMI recycle.
::   FIX 3 - Fast PID capture: 3-5 min launch delays eliminated.
::
:: v8 (2026-03-06): Improvements from full session history audit.
::
:: v10 (2026-03-07): Logging + post-copy txt cleanup.
::
::   IMP E - Persistent log file: all poll summaries and job events written
::     to %%QCROOT%%\mqrun_log.txt alongside screen output. Log is appended
::     across restarts. Startup writes session-start marker with timestamp.
::
::   IMP F - Delete combined\txt after successful QC robocopy: frees disk
::     space on D: automatically after each job completes. done.lock kept.
::
:: v11 (2026-03-07): Ghost-folder / "Access is denied" fix.
::
:: v12 (2026-03-07): Harden all PID-dead gate edge cases in :MarkDone.
::
::   FIX I2 - PENDING in running.lock treated as "alive": if running.lock
::     contains PENDING we cannot check the PID, but the process is likely
::     still running. Defer cleanup until lock resolves or is removed.
::
::   FIX I3 - No running.lock: WMIC scan before allowing cleanup. If
::     running.lock is absent or empty, scan for any live MaxQuantCmd.exe
::     using this job's mqpar.xml. If found, defer. Covers orphaned processes
::     that lost their lock (startup cleanup, crash, manual deletion).
::
::   FIX I4 - done.lock written BEFORE any file deletion. Previously
::     done.lock was the last action; a crash after deleting combined\txt
::     but before writing done.lock left the job unrecoverable (no output
::     files, no done.lock, no data). Now done.lock is written immediately
::     after QC robocopy succeeds, before TxtClean and other cleanup.
::
::   LOG I6 - *.txt fallback path logs warning: when PID dies but
::     proteinGroups.txt is absent, done.lock is written via fallback
::     without QC copy or cleanup. Now logged so operator can recover.
::
::
::   FIX - PID-dead gate in :MarkDone: after "Finish writing tables" is
::     confirmed in #runningTimes.txt, verify the MaxQuant PID from
::     running.lock is no longer alive before touching any files.
::     Without this, the script called rmdir /s /q while MaxQuant still
::     held open file handles (pasefMsmsScans written 5 min after the
::     "Finish writing tables" string). Result: ghost folders with
::     "Access is denied" errors that survived cleanup.
::
::   IMP - combined\proc is no longer deleted: it is tiny (text only),
::     contains #runningTimes.txt (our completion signal), and its
::     deletion was itself a potential source of locked-handle errors.
::
:: v9 (2026-03-06): Counter arithmetic fixes - numbers now always add up.
::   found = done + running + queued + acquiring + retrying + errors + skipped
::
::   FIX 1 - Orphan-done shown separately: orphan jobs (source .d gone
::     from instrument) were added to DONE but NOT to FOUND, making the
::     summary look like sum > found. Now: found = done + running + queued
::     + skipped exactly. orphan-done shown as its own column.
::
::   FIX 2 - PENDING adopt no longer double-counts MQ_LIVE: resolving a
::     PENDING lockfile via WMIC was incrementing MQ_LIVE even though that
::     process was already counted in the initial tasklist scan. Removed.
::
::   FIX 3 - Poll summary uses MQ_LIVE for "running" (not LIVE): LIVE is
::     a lockfile-visit counter that can drift ±1 from timing. MQ_LIVE is
::     the authoritative process count and matches the slot display.
::
::   FIX 4 - ACQUIRING counter: jobs whose source files are still being
::     written by the instrument exited silently with no counter. Now
::     counted and shown so: found = done + running + queued + acquiring
::     + skipped exactly. orphan-done is shown but excluded from sum.
::
::   IMP A - *.txt fallback completion: if proteinGroups.txt absent but
::     any *.txt output exists in combined\txt, mark as complete. Handles
::     MaxQuant version path variants; prevents infinite relaunch.
::
::   IMP B - Stale lockfile cleanup on startup: scans SESSIONDIR on
::     launch, deletes running.lock files whose PID is no longer alive.
::     Prevents the 35-slot blockage seen in production (2026-03-05).
::
::   IMP C - Startup echo: shows session dir, watch pattern, config.
::
::   IMP D - Early gate writes queued.lock: consistent with late gate,
::     avoids redundant size checks on already-copied jobs each poll.
::
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

:: ── Startup: clean up stale running.lock files ─────────────────────────────
:: If the script was restarted after a crash, old running.lock files from dead
:: processes will block CPU slots forever. Scan and purge them once at startup.
:: PENDING/QUEUED sentinels are always stale on startup and are also removed.
set "STALE_CLEANED=0"
for /d %%J in ("!SESSIONDIR!\*") do (
    if exist "%%~fJ\running.lock" (
        set "ST_PID="
        for /f "usebackq tokens=1" %%P in ("%%~fJ\running.lock") do set "ST_PID=%%P"
        if "!ST_PID!"=="PENDING" (
            del "%%~fJ\running.lock"
            set /a STALE_CLEANED+=1
        ) else if "!ST_PID!"=="QUEUED" (
            del "%%~fJ\running.lock"
            set /a STALE_CLEANED+=1
        ) else if defined ST_PID (
            %TLIST% /fi "pid eq !ST_PID!" /fo csv /nh 2>nul | findstr /i "MaxQuantCmd" >nul
            if errorlevel 1 (
                del "%%~fJ\running.lock"
                set /a STALE_CLEANED+=1
            )
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
        if "!SRC_FOUND!"=="0" (
            set /a ORPHAN_DONE+=1
        )
    )
)
set /a UNKNOWN=FOUND-DONE-LIVE-QUEUED-ACQUIRING-RETRYING-ERRORS-SKIPPED
echo [%time%] Poll: !FOUND! found  ^|  !DONE! done  ^|  !ORPHAN_DONE! orphan-done  ^|  !LIVE! running  ^|  !QUEUED! queued  ^|  !ACQUIRING! acquiring  ^|  !RETRYING! retrying  ^|  !ERRORS! errors  ^|  !SKIPPED! skipped  ^|  !UNKNOWN! unknown
echo [%time%] Poll: !FOUND! found  ^|  !DONE! done  ^|  !ORPHAN_DONE! orphan-done  ^|  !LIVE! running  ^|  !QUEUED! queued  ^|  !ACQUIRING! acquiring  ^|  !RETRYING! retrying  ^|  !ERRORS! errors  ^|  !SKIPPED! skipped  ^|  !UNKNOWN! unknown >> "%LOGFILE%"
:: ARITHMETIC: found = done + running + queued + acquiring + retrying + errors + skipped + unknown
:: unknown should always be 0 - if not, a path is missing a counter (investigate)
::   orphan-done: source .d folder gone (not in found, shown separately).
::   acquiring:   instrument still writing, waiting for stable size.
::   retrying:    PID gone, no output yet; will relaunch next poll.
::   errors:      copy or param write failed; investigate manually.
timeout /t %POLL_INTERVAL% /nobreak >nul
goto :watch_loop

:MarkDone
set "MD_WORKDIR=%~1"
set "MD_BN=%~2"
set "MD_PID=%~3"
set "DONE_FLAG=0"
if not exist "%MD_WORKDIR%\combined\txt\proteinGroups.txt" exit /b 0
if not exist "%MD_WORKDIR%\combined\proc\#runningTimes.txt" exit /b 0
findstr /i "Finish writing tables" "%MD_WORKDIR%\combined\proc\#runningTimes.txt" >nul 2>nul
if errorlevel 1 exit /b 0
:: Gate 3: verify MaxQuant is dead before touching any files.
:: Three sub-cases based on what we know about the PID.
if not defined MD_PID set "MD_PID="
:: Case A — PENDING: process was launched but PID capture failed. Treat as alive (FIX I2).
if /i "!MD_PID!"=="PENDING" (
    echo [%time%] WaitPID  : %MD_BN% ^(running.lock=PENDING, PID unknown - deferring^)
    echo [%time%] WaitPID  : %MD_BN% ^(running.lock=PENDING, PID unknown - deferring^) >> "%LOGFILE%"
    exit /b 0
)
:: Case B — empty: no running.lock or malformed. WMIC scan for orphaned process (FIX I3).
if "!MD_PID!"=="" (
    set "MD_WMIC_PARAM=!MD_WORKDIR:\=\\!\\mqpar.xml"
    set "MD_ORPHAN="
    for /f "tokens=2 delims==" %%P in ('%WMIC% process where "name='MaxQuantCmd.exe' and commandline like '%%!MD_WMIC_PARAM!%%'" get ProcessId /format:value 2^>nul ^| more') do (
        for /f "tokens=1" %%V in ("%%P") do if not defined MD_ORPHAN set "MD_ORPHAN=%%V"
    )
    if defined MD_ORPHAN (
        echo [%time%] WaitPID  : %MD_BN% ^(no lock, orphan PID !MD_ORPHAN! found - deferring^)
        echo [%time%] WaitPID  : %MD_BN% ^(no lock, orphan PID !MD_ORPHAN! found - deferring^) >> "%LOGFILE%"
        exit /b 0
    )
    echo [%time%] WaitPID  : %MD_BN% ^(no lock, no live MQ found via WMIC - proceeding^)
    echo [%time%] WaitPID  : %MD_BN% ^(no lock, no live MQ found via WMIC - proceeding^) >> "%LOGFILE%"
    goto :md_pid_ok
)
:: Case C — numeric PID: direct tasklist check (FIX from v11).
%TLIST% /fi "pid eq !MD_PID!" /fo csv /nh 2>nul | findstr /i "MaxQuantCmd" >nul
if not errorlevel 1 (
    echo [%time%] WaitPID  : %MD_BN% ^(PID !MD_PID! still alive - will cleanup next poll^)
    echo [%time%] WaitPID  : %MD_BN% ^(PID !MD_PID! still alive - will cleanup next poll^) >> "%LOGFILE%"
    exit /b 0
)
:md_pid_ok
if not "%QCROOT%"=="" (
    if not exist "%QCROOT%\" (
        echo [%time%] WARNING  : %MD_BN% QCROOT not reachable ^(%QCROOT%^) - will retry next poll
        echo [%time%] WARNING  : %MD_BN% QCROOT not reachable ^(%QCROOT%^) - will retry next poll >> "%LOGFILE%"
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
    :: Write done.lock now — before any deletion. Crash after this = job counted done. (FIX I4)
    echo 1> "%MD_WORKDIR%\done.lock"
    set "DONE_FLAG=1"
    if exist "%MD_WORKDIR%\combined\txt" rmdir /s /q "%MD_WORKDIR%\combined\txt"
    echo [%time%] TxtClean : %MD_BN% combined\txt removed from TMPDIR
    echo [%time%] TxtClean : %MD_BN% combined\txt removed from TMPDIR >> "%LOGFILE%"
)
:: No QCROOT path: write done.lock before cleanup if not already written. (FIX I4)
if "!DONE_FLAG!"=="0" (
    echo 1> "%MD_WORKDIR%\done.lock"
    set "DONE_FLAG=1"
)
echo [%time%] Cleanup  : %MD_BN%
echo [%time%] Cleanup  : %MD_BN% >> "%LOGFILE%"
if exist "%MD_WORKDIR%\data.d"                    rmdir /s /q "%MD_WORKDIR%\data.d"
if exist "%MD_WORKDIR%\data"                      rmdir /s /q "%MD_WORKDIR%\data"
if exist "%MD_WORKDIR%\combined\andromeda"       rmdir /s /q "%MD_WORKDIR%\combined\andromeda"
if exist "%MD_WORKDIR%\combined\search"          rmdir /s /q "%MD_WORKDIR%\combined\search"
:: combined\proc kept: contains #runningTimes.txt (completion signal). Cost: <1 MB.
if exist "%MD_WORKDIR%\combined\sdrf"            rmdir /s /q "%MD_WORKDIR%\combined\sdrf"
if exist "%MD_WORKDIR%\combined\combinedRunInfo" rmdir /s /q "%MD_WORKDIR%\combined\combinedRunInfo"
if exist "%MD_WORKDIR%\mqpar.xml"                 del /f /q "%MD_WORKDIR%\mqpar.xml"
if exist "%MD_WORKDIR%\data.index"                del /f /q "%MD_WORKDIR%\data.index"
if exist "%MD_WORKDIR%\running.lock"              del /f /q "%MD_WORKDIR%\running.lock"
exit /b 0

:GetSize
set "%~2="
set "_P=%~1"
set "_P=!_P:\=\\!"
for /f "tokens=2 delims==" %%Z in ('%WMIC% datafile where "name=^'!_P!^'" get FileSize /format:value 2^>nul ^| more') do for /f "tokens=1" %%V in ("%%Z") do set "%~2=%%V"
exit /b 0

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
:: Queued: data already copied/verified, waiting for a free slot.
if exist "%WORKDIR%\queued.lock" (
    set /a QUEUED+=1
    exit /b 0
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
        :: Do NOT increment MQ_LIVE - process was already counted in initial tasklist scan.
        echo [%time%] Adopted  : %BN% ^(PID:!ADOPT_PID! resolved from PENDING^)
        echo [%time%] Adopted  : %BN% ^(PID:!ADOPT_PID! resolved from PENDING^) >> "%LOGFILE%"
        exit /b 0
    )
    set /a LIVE+=1
    exit /b 0
)
if not defined MQ_PID ( echo [%time%] Skipped  : %BN% ^(empty lockfile^) & set /a SKIPPED+=1 & exit /b 0 )
set /a LIVE+=1
%TLIST% /fi "pid eq !MQ_PID!" /fo csv /nh 2>nul | findstr /i "MaxQuantCmd" >nul
if not errorlevel 1 exit /b 0
:: Double-check: tasklist can transiently return empty (WMI recycle every few hours).
:: Real process death is persistent; a transient glitch recovers in <1s.
timeout /t 5 /nobreak >nul
%TLIST% /fi "pid eq !MQ_PID!" /fo csv /nh 2>nul | findstr /i "MaxQuantCmd" >nul
if not errorlevel 1 exit /b 0
del "%WORKDIR%\running.lock"
set /a LIVE-=1
set "DONE_FLAG=0"
call :MarkDone "%WORKDIR%" "%BN%" "!MQ_PID!"
if "!DONE_FLAG!"=="1" (
    set /a DONE+=1
    echo [%time%] Completed: %BN% ^(PID !MQ_PID! exited, cleanup done^)
    echo [%time%] Completed: %BN% ^(PID !MQ_PID! exited, cleanup done^) >> "%LOGFILE%"
    exit /b 0
)
:: *.txt fallback: if any output exists in combined\txt, accept as complete.
:: Handles MaxQuant version path variants where proteinGroups.txt may differ.
set "FOUND_OUTPUT=0"
for %%F in ("%WORKDIR%\combined\txt\*.txt") do set "FOUND_OUTPUT=1"
if !FOUND_OUTPUT! EQU 1 (
    echo 1> "%WORKDIR%\done.lock"
    set /a DONE+=1
    echo [%time%] Completed: %BN% ^(PID !MQ_PID! exited, txt output found^)
    echo [%time%] Completed: %BN% ^(PID !MQ_PID! exited, txt output found^) >> "%LOGFILE%"
    :: LOG I6: fallback path — proteinGroups.txt absent (MQ version variant).
    :: QC copy and TMPDIR cleanup were NOT performed. Manual recovery may be needed.
    echo [%time%] WARNING  : %BN% fallback-done: no proteinGroups.txt - QC copy + TMPDIR cleanup skipped
    echo [%time%] WARNING  : %BN% fallback-done: no proteinGroups.txt - QC copy + TMPDIR cleanup skipped >> "%LOGFILE%"
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
call :GetSize "%SRC%\analysis.tdf"               SZ1
call :GetSize "%SRC%\analysis.tdf_bin"           SZ2
call :GetSize "%SRC%\chromatography-data.sqlite" SZ3
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
    echo [%time%] Verified : %BN% >> "%LOGFILE%"
    goto :write_param
)
timeout /t %STABILITY_WAIT% /nobreak >nul
set "SZ1B=" & set "SZ2B=" & set "SZ3B="
call :GetSize "%SRC%\analysis.tdf"               SZ1B
call :GetSize "%SRC%\analysis.tdf_bin"           SZ2B
call :GetSize "%SRC%\chromatography-data.sqlite" SZ3B
if defined SZ1B if not "!SZ1!"=="!SZ1B!" ( echo [%time%] Acquiring: %BN% & set /a ACQUIRING+=1 & exit /b 0 )
if defined SZ2B if not "!SZ2!"=="!SZ2B!" ( echo [%time%] Acquiring: %BN% & set /a ACQUIRING+=1 & exit /b 0 )
if defined SZ3B if not "!SZ3!"=="!SZ3B!" ( echo [%time%] Acquiring: %BN% & set /a ACQUIRING+=1 & exit /b 0 )
mkdir "%WORKDIR%"  2>nul
mkdir "%DATADEST%" 2>nul
echo [%time%] Copying  : %BN%
echo [%time%] Copying  : %BN% >> "%LOGFILE%"
xcopy /y "%SRC%\analysis.tdf"               "%DATADEST%\" >nul
xcopy /y "%SRC%\analysis.tdf_bin"           "%DATADEST%\" >nul
xcopy /y "%SRC%\chromatography-data.sqlite" "%DATADEST%\" >nul
if not exist "%DATADEST%\analysis.tdf"               ( set /a ERRORS+=1 & echo [%time%] ERROR: copy failed analysis.tdf               & exit /b 0 )
if not exist "%DATADEST%\analysis.tdf_bin"           ( set /a ERRORS+=1 & echo [%time%] ERROR: copy failed analysis.tdf_bin           & exit /b 0 )
if not exist "%DATADEST%\chromatography-data.sqlite" ( set /a ERRORS+=1 & echo [%time%] ERROR: copy failed chromatography-data.sqlite & exit /b 0 )
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

:: Capture PID via window title (instant). start sets the window title to
:: "MQ.<BN>" which is unique per job. Avoids slow WMIC commandline scan
:: (~30-60s per job under load of 64 jobs).
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
