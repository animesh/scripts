@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

:: diannrun v1 -- DIA-NN batch watcher for timsTOF HeLa DIA QC runs
::
:: WHAT IT DOES
:: ------------
:: Watches DATAROOT\*\*\*.d for new acquisitions whose folder name contains
:: BOTH NAMETOKEN1 and NAMETOKEN2 (default HeLa and DIA, any order).
:: For each match: copies 3 data files to TMPDIR, launches diann.exe directly
:: against the copied .d folder, tracks the job to completion, copies the
:: .report.parquet / .report-lib.parquet outputs to QCROOT, then cleans up.
::
:: STATE MODEL (per job basename BN)
:: ----------------------------------
::  DONE      SESSIONDIR\BN.done exists
::  QUEUED    SESSIONDIR\BN.queued.lock exists  (slots full, data already ready)
::  RUNNING   SESSIONDIR\BN.running.lock = PID | "PENDING"
::  NEW       no lock files at all
::
:: LAYOUT (flat, no nested WORKDIR -- unlike mqrun.bat)
:: ------------------------------------------------------
:: DIA-NN's own output naming is already "sibling files next to the .d dir"
:: (<dir>.d.report.parquet, <dir>.d.report-lib.parquet), so there is no need
:: for a separate per-job subfolder. Everything for job BN lives directly
:: under SESSIONDIR as BN.d (copied data), BN.d.report.parquet (output),
:: BN.d.report-lib.parquet (output), BN.running.lock, BN.queued.lock,
:: BN.retries, BN.done.

:: -- Configuration --------------------------------------------------------------
set DIANNCMD=C:\Program Files\DIA-NN\2.2.0\diann.exe
set DIANNDIR=C:\Program Files\DIA-NN\2.2.0\
set DATAROOT=F:\promec\TIMSTOF\Raw
set NAMETOKEN1=HeLa
set NAMETOKEN2=DIA
set SPECLIB=F:\promec\FastaDB\humanMC2V3defaults.predicted.speclib
set FASTAFILE=F:\promec\FastaDB\UP000005640_9606_1protein1gene.fasta
set FASTACONT=camprotR_240512_cRAP_20190401_full_tags.fasta
:: FASTACONT is resolved relative to DIANNDIR (DIA-NN is launched with that
:: as its working directory via "start /D", same as the manual session).
set TMPDIR=D:\TMPDIR
set QCROOT=F:\promec\TIMSTOF\QC\DIA
set LOGFILE=%QCROOT%\diannrun_log.txt
set POLL_INTERVAL=1800
set STABILITY_WAIT=60
set THREADS_PER_JOB=16
set CPU_COUNT=64
set MAX_RETRIES=3
set QVALUE=0.01
set TLIST=%SystemRoot%\System32\tasklist.exe
set WMIC=%SystemRoot%\System32\wbem\wmic.exe

:: -- Validate required paths ------------------------------------------------------
if not exist "%DIANNCMD%"  ( echo ERROR: diann.exe not found: %DIANNCMD%   & exit /b 1 )
if not exist "%DIANNDIR%"  ( echo ERROR: DIANNDIR not found: %DIANNDIR%    & exit /b 1 )
if not exist "%DATAROOT%"  ( echo ERROR: DATAROOT not found: %DATAROOT%    & exit /b 1 )
if not exist "%SPECLIB%"   ( echo ERROR: SPECLIB not found: %SPECLIB%      & exit /b 1 )
if not exist "%FASTAFILE%" ( echo ERROR: FASTA not found: %FASTAFILE%      & exit /b 1 )
if not exist "%DIANNDIR%\%FASTACONT%" (
    echo WARNING: %FASTACONT% not found under %DIANNDIR% -- DIA-NN will fail at launch
)

:: -- Derive SESSIONDIR from data root and library leaf names ----------------------
:: e.g. F:\HeLaDIA\Raw_humanMC2V3defaultspredicted
for %%D in ("%DATAROOT%") do set DATAROOT_LEAF=%%~nxD
for %%L in ("%SPECLIB%")  do set LIB_LEAF=%%~nL
set "LIB_LEAF=%LIB_LEAF:.=%"
set SESSIONDIR=%TMPDIR%\!DATAROOT_LEAF!_!LIB_LEAF!
if not exist "%TMPDIR%"     mkdir "%TMPDIR%" >nul 2>nul
if not exist "!SESSIONDIR!" mkdir "!SESSIONDIR!" >nul 2>nul
if not exist "%QCROOT%"     mkdir "%QCROOT%" >nul 2>nul

:: -- Derive concurrency slots from CPU budget / threads per job -------------------
set /a MAX_PARALLEL=CPU_COUNT/THREADS_PER_JOB
if %MAX_PARALLEL% LSS 1 set MAX_PARALLEL=1

echo Session dir  : !SESSIONDIR!
echo Watching     : %DATAROOT%\*\*\*.d  (name contains %NAMETOKEN1% and %NAMETOKEN2%)
echo Poll: %POLL_INTERVAL%s  ^| Stability: %STABILITY_WAIT%s  ^| Slots: %MAX_PARALLEL% (%CPU_COUNT% cores / %THREADS_PER_JOB% threads)  ^| Retries: %MAX_RETRIES%
echo.
echo [%date% %time%] ===== SESSION START  !SESSIONDIR! ===== >> "%LOGFILE%"

:: -- Startup: remove stale lock files from dead/interrupted processes -------------
:: queued.lock files are always safe to remove on startup (job not yet launched).
:: running.lock files are stale if the PID they contain is no longer alive.
:: PENDING locks (PID capture failed at launch) are also cleared -- will re-adopt or retry.
set "STALE=0"
for %%J in ("!SESSIONDIR!\*.queued.lock") do ( del /q "%%~fJ" >nul 2>nul & set /a STALE+=1 )
for %%J in ("!SESSIONDIR!\*.running.lock") do (
    set "ST_PID="
    for /f "usebackq tokens=1" %%P in ("%%~fJ") do set "ST_PID=%%P"
    if "!ST_PID!"=="PENDING" (
        del /q "%%~fJ" >nul 2>nul & set /a STALE+=1
    ) else if defined ST_PID (
        %TLIST% /fi "pid eq !ST_PID!" /fo csv /nh 2>nul | findstr /i "diann" >nul
        if errorlevel 1 ( del /q "%%~fJ" >nul 2>nul & set /a STALE+=1 )
    )
)
if !STALE! GTR 0 call :Log "Startup  : !STALE! stale lock file(s) removed"

:: -- Main poll loop -----------------------------------------------------------------
:watch_loop
set FOUND=0 & set DONE=0 & set LIVE=0 & set QUEUED=0
set ACQUIRING=0 & set RETRYING=0 & set ERRORS=0 & set SKIPPED=0

:: Count live diann.exe processes once per poll (updated locally after each launch)
set "DN_LIVE=0"
:: Count lines that contain a comma -- CSV process lines always do; the
:: 'INFO: No tasks running' line (locale-dependent) never does.
for /f "tokens=1" %%P in ('%TLIST% /fi "imagename eq diann.exe" /fo csv /nh 2^>nul ^| findstr /c:","') do set /a DN_LIVE+=1

:: Dispatch each acquisition folder whose name contains BOTH tokens (any order)
for /d %%U in ("%DATAROOT%\*") do (
    for /d %%V in ("%%~fU\*") do (
        for /d %%I in ("%%~fV\*.d") do (
            set "_CUR=%%~fI"
            set "_SKIP=!_CUR:%SESSIONDIR%=!"
            if "!_SKIP!"=="!_CUR!" (
                set "NM=%%~nxI"
                echo !NM! | findstr /i "%NAMETOKEN1%" >nul
                if not errorlevel 1 (
                    echo !NM! | findstr /i "%NAMETOKEN2%" >nul
                    if not errorlevel 1 (
                        set /a FOUND+=1
                        call :CheckFolder "%%~fI"
                    )
                )
            )
        )
    )
)

:: Cleanup pass: remove any copied .d folder whose completion sentinel exists
:: AND whose lockfile is gone (i.e. process confirmed dead). Skipping while a
:: running.lock exists avoids "Access Denied" from DIA-NN still holding handles.
for /d %%W in ("!SESSIONDIR!\*.d") do (
    set "WBN=%%~nW"
    if exist "!SESSIONDIR!\!WBN!.done" (
        if not exist "!SESSIONDIR!\!WBN!.running.lock" (
            if exist "%%~fW" rmdir /s /q "%%~fW" >nul 2>nul
        )
    )
)

:: Poll summary -- inlined because :Log cannot handle the | characters safely
set /a UNKNOWN=FOUND-DONE-LIVE-QUEUED-ACQUIRING-RETRYING-ERRORS-SKIPPED
echo [%time%] Poll: !FOUND! found  ^|  !DONE! done  ^|  !LIVE! running  ^|  !QUEUED! queued  ^|  !ACQUIRING! acquiring  ^|  !RETRYING! retrying  ^|  !ERRORS! errors  ^|  !SKIPPED! skipped  ^|  !UNKNOWN! unknown
echo [%time%] Poll: !FOUND! found  ^|  !DONE! done  ^|  !LIVE! running  ^|  !QUEUED! queued  ^|  !ACQUIRING! acquiring  ^|  !RETRYING! retrying  ^|  !ERRORS! errors  ^|  !SKIPPED! skipped  ^|  !UNKNOWN! unknown >> "%LOGFILE%"
timeout /t %POLL_INTERVAL% /nobreak >nul
goto :watch_loop

:: ===================================================================================
:: SUBROUTINES
:: ===================================================================================

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

:: :AdoptPID -- searches for a live diann.exe whose commandline contains the
:: given DATADEST path (passed via --f). Sets ADOPT_PID if found, clears otherwise.
:: Arg1: full path to the copied .d folder (DATADEST)
:AdoptPID
set "ADOPT_PID="
set "_AP=%~1"
set "_AP=!_AP:\=\\!"
for /f "tokens=2 delims==" %%P in ('%WMIC% process where "name=^'diann.exe^' and commandline like ^'%%!_AP!%%^'" get ProcessId /format:value 2^>nul ^| more') do (
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
::   1. OUT_REPORT (BN.d.report.parquet) exists
::   2. diann.exe for this job is confirmed dead
:: On success: copies ALL job output files (wildcard %MD_BN%.d.*) to QCROOT,
:: writes .done sentinel, deletes the copied .d raw data and local output copies.
:: Sets DONE_FLAG=1 on success so caller can update counters.
:: Arg1: DATADEST (.d folder)   Arg2: basename   Arg3: PID (or "PENDING" or "")
:MarkDone
set "MD_D=%~1"
set "MD_BN=%~2"
set "MD_PID=%~3"
set "MD_REPORT=!SESSIONDIR!\%MD_BN%.d.report.parquet"

set "DONE_FLAG=0"
:: Gate 1: output report must exist
if not exist "!MD_REPORT!" exit /b 0
:: Gate 2: process must be dead before we clean up
if /i "!MD_PID!"=="PENDING" ( call :Log "WaitPID  : %MD_BN% (PENDING -- deferring)" & exit /b 0 )
if "!MD_PID!"=="" (
    :: No PID recorded -- check if any live diann.exe is using this DATADEST
    call :AdoptPID "%MD_D%"
    if defined ADOPT_PID ( call :Log "WaitPID  : %MD_BN% (orphan PID !ADOPT_PID! alive -- deferring)" & exit /b 0 )
    goto :md_proceed
)
%TLIST% /fi "pid eq !MD_PID!" /fo csv /nh 2>nul | findstr /i "diann" >nul
if not errorlevel 1 ( call :Log "WaitPID  : %MD_BN% (PID !MD_PID! alive -- deferring)" & exit /b 0 )
:md_proceed
:: Copy results to QC share before deleting local copies
if not exist "%QCROOT%\" ( call :Log "WARNING  : %MD_BN% QCROOT not reachable -- will retry" & exit /b 0 )
if not exist "%QCROOT%\%MD_BN%" mkdir "%QCROOT%\%MD_BN%" >nul 2>nul
:: Wildcard catches every DIA-NN output sibling file for this job in one shot
:: (report.parquet, report-lib.parquet, *_matrix.tsv, UniMod_*.tsv, .quant,
:: log.txt, manifest.txt, stats.tsv, site_report.parquet, protein_description.tsv,
:: etc.) -- future-proof against DIA-NN adding/renaming output types.
:: /NP suppresses live progress/retry console writes that bypass simple >nul
:: redirection -- this is what was leaking bare "Access is denied." to console.
robocopy "!SESSIONDIR!" "%QCROOT%\%MD_BN%" "%MD_BN%.d.*" /NP /R:3 /W:10 /NFL /NDL /NJH /NJS /LOG+:"%QCROOT%\copy_log.txt" >nul 2>nul
if errorlevel 8 ( call :Log "ERROR    : %MD_BN% QC copy failed -- skipping cleanup" & exit /b 0 )
call :Log "QC copy  : %MD_BN% -> %QCROOT%\%MD_BN%"
:: Write sentinel so cleanup pass can rmdir the copied .d folder entirely
echo 1> "!SESSIONDIR!\%MD_BN%.done"
set "DONE_FLAG=1"
call :Log "Cleanup  : %MD_BN%"
:: >nul 2>nul on rmdir: cmd.exe built-ins (rmdir/del) write "Access is denied"
:: to STDOUT, not STDERR, so 2>nul alone never suppresses it -- this is the
:: second independent source of the bare console message.
rmdir /s /q "%MD_D%" >nul 2>nul
:: Delete all local copies of this job output now that they are on QCROOT
del /q "!SESSIONDIR!\%MD_BN%.d.*" >nul 2>nul
:: Clean up retry counter if it exists
if exist "!SESSIONDIR!\%MD_BN%.retries" del /q "!SESSIONDIR!\%MD_BN%.retries" >nul 2>nul
exit /b 0

:: :CheckFolder -- per-job state machine. Called for every matching source .d folder.
:: Arg1: full path to source .d folder
:CheckFolder
set "SRC=%~1"
set "BN=%~n1"
set "DATADEST=!SESSIONDIR!\%BN%.d"
set "LOCKFILE=!SESSIONDIR!\%BN%.running.lock"
set "QUEUEFILE=!SESSIONDIR!\%BN%.queued.lock"
set "DONEFILE=!SESSIONDIR!\%BN%.done"
set "RETRYFILE=!SESSIONDIR!\%BN%.retries"

:: -- STATE: DONE -------------------------------------------------------------------
if exist "!DONEFILE!" ( set /a DONE+=1 & exit /b 0 )

:: -- STATE: QUEUED -------------------------------------------------------------------
:: queued.lock = data is ready, waiting for a slot.
:: If a slot is now free, delete the lock and fall through to launch.
if exist "!QUEUEFILE!" (
    if !DN_LIVE! GEQ %MAX_PARALLEL% ( set /a QUEUED+=1 & exit /b 0 )
    del /q "!QUEUEFILE!" >nul 2>nul
)

:: -- STATE: COMPLETING ---------------------------------------------------------------
:: report.parquet exists but .done not yet written.
:: This handles the case where job completes between polls regardless of lock state.
if exist "!SESSIONDIR!\%BN%.d.report.parquet" (
    set "CK_PID="
    if exist "!LOCKFILE!" for /f "usebackq tokens=1" %%P in ("!LOCKFILE!") do set "CK_PID=%%P"
    call :MarkDone "!DATADEST!" "%BN%" "!CK_PID!"
    if "!DONE_FLAG!"=="1" ( set /a DONE+=1 & call :Log "Completed: %BN%" & exit /b 0 )
)

:: -- STATE: RUNNING -------------------------------------------------------------------
if not exist "!LOCKFILE!" goto :no_lockfile

set "DN_PID="
for /f "usebackq tokens=1" %%P in ("!LOCKFILE!") do set "DN_PID=%%P"

:: Empty lockfile should not happen -- flag as error rather than silently looping
if not defined DN_PID ( set /a ERRORS+=1 & call :Log "ERROR    : %BN% (empty running.lock)" & exit /b 0 )

:: PENDING = launch succeeded but PID capture failed. Try to adopt via WMIC.
if "!DN_PID!"=="PENDING" (
    call :AdoptPID "!DATADEST!"
    if defined ADOPT_PID (
        echo !ADOPT_PID!> "!LOCKFILE!"
        set /a LIVE+=1
        call :Log "Adopted  : %BN% (PID:!ADOPT_PID! resolved from PENDING)"
        exit /b 0
    )
    :: No live diann found for this job -- it crashed before PID was captured
    call :CheckRetry "!RETRYFILE!" "%BN%"
    if "!RC_GAVE_UP!"=="1" ( set /a ERRORS+=1 & exit /b 0 )
    call :Log "CrashWipe: %BN% (PENDING, no live diann -- retry !RC!/%MAX_RETRIES%)"
    rmdir /s /q "!DATADEST!" >nul 2>nul
    if exist "!LOCKFILE!" del /q "!LOCKFILE!" >nul 2>nul
    set /a RETRYING+=1
    exit /b 0
)

:: Normal running state -- verify PID is still alive
set /a LIVE+=1
%TLIST% /fi "pid eq !DN_PID!" /fo csv /nh 2>nul | findstr /i "diann" >nul
if not errorlevel 1 exit /b 0
:: PID not found -- wait 5 s and check once more to avoid false positives from tasklist lag
timeout /t 5 /nobreak >nul
%TLIST% /fi "pid eq !DN_PID!" /fo csv /nh 2>nul | findstr /i "diann" >nul
if not errorlevel 1 exit /b 0

:: PID confirmed dead
del /q "!LOCKFILE!" >nul 2>nul
set /a LIVE-=1
call :MarkDone "!DATADEST!" "%BN%" "!DN_PID!"
if "!DONE_FLAG!"=="1" ( set /a DONE+=1 & call :Log "Completed: %BN% (PID !DN_PID! exited)" & exit /b 0 )

:: No report.parquet at all -- job failed. Retry up to MAX_RETRIES.
set /a RETRYING+=1
call :Log "Failed   : %BN% (PID !DN_PID! gone, no report.parquet -- retrying)"
call :CheckRetry "!RETRYFILE!" "%BN%"
if "!RC_GAVE_UP!"=="1" ( set /a RETRYING-=1 & set /a ERRORS+=1 )
exit /b 0

:: :no_lockfile -- new job or recovered job with no lock
:no_lockfile

:: Try to adopt an already-running diann that has no lock (e.g. script restarted)
call :AdoptPID "!DATADEST!"
if defined ADOPT_PID (
    echo !ADOPT_PID!> "!LOCKFILE!"
    set /a LIVE+=1
    call :Log "Adopted  : %BN% (PID:!ADOPT_PID!)"
    exit /b 0
)

:: Source files must all exist before we do anything
:: NOTE: same 3 files as the MaxQuant watcher -- assumed sufficient for DIA-NN's
:: Bruker .d reader too. If DIA-NN needs additional files, extend this list and
:: the robocopy file list below together.
if not exist "%SRC%\analysis.tdf"               ( set /a SKIPPED+=1 & call :Log "Skipped  : %BN% (analysis.tdf missing)"               & exit /b 0 )
if not exist "%SRC%\analysis.tdf_bin"           ( set /a SKIPPED+=1 & call :Log "Skipped  : %BN% (analysis.tdf_bin missing)"           & exit /b 0 )
if not exist "%SRC%\chromatography-data.sqlite" ( set /a SKIPPED+=1 & call :Log "Skipped  : %BN% (chromatography-data.sqlite missing)" & exit /b 0 )

:: -- Stability check ------------------------------------------------------------------
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

:: -- Copy or verify --------------------------------------------------------------------
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
    mkdir "!DATADEST!" >nul 2>nul
    call :Log "Copying  : %BN%"
    robocopy "%SRC%" "!DATADEST!" analysis.tdf analysis.tdf_bin chromatography-data.sqlite /J /R:1 /W:5 /NP /NFL /NDL /NJH /NJS >nul 2>nul
    if errorlevel 8 ( set /a ERRORS+=1 & call :Log "ERROR    : %BN% robocopy failed" & exit /b 0 )
    call :Log "Copied   : %BN%"
)

:: -- Launch gate ------------------------------------------------------------------------
:: If no slot available, save queued.lock and exit. Next poll will resume here
:: (queued.lock check at top of :CheckFolder). Data is already copied.
if !DN_LIVE! GEQ %MAX_PARALLEL% (
    echo QUEUED> "!QUEUEFILE!"
    set /a QUEUED+=1
    call :Log "Queued   : %BN% (!DN_LIVE!/%MAX_PARALLEL% slots used)"
    exit /b 0
)
if exist "!QUEUEFILE!" del /q "!QUEUEFILE!" >nul 2>nul

:: -- Launch -------------------------------------------------------------------------------
:: /D sets the working directory for the spawned process only (so the relative
:: FASTACONT path resolves against DIANNDIR, exactly as in the manual session)
:: without changing this script's own current directory.
start "DN.%BN%" /D "%DIANNDIR%" "%DIANNCMD%" --f "!DATADEST!" --lib "%SPECLIB%" --threads %THREADS_PER_JOB% --verbose 1 --out "!SESSIONDIR!\%BN%.d.report.parquet" --qvalue %QVALUE% --matrices --out-lib "!SESSIONDIR!\%BN%.d.report-lib.parquet" --gen-spec-lib --reannotate --fasta "%FASTACONT%" --cont-quant-exclude cRAP- --fasta "%FASTAFILE%" --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --individual-mass-acc --individual-windows --peptidoforms --rt-profiling --direct-quant --original-mods --export-quant
:: Wait briefly then capture PID via window title (fast, no WMIC overhead)
timeout /t 3 /nobreak >nul
set "DN_PID="
for /f "skip=1 tokens=2 delims=," %%P in ('%TLIST% /fi "windowtitle eq DN.%BN%" /fi "imagename eq diann.exe" /fo csv 2^>nul') do set "DN_PID=%%~P"
if not defined DN_PID (
    :: PID capture failed but job was launched -- mark PENDING for next poll to resolve
    echo PENDING> "!LOCKFILE!"
    set /a LIVE+=1 & set /a DN_LIVE+=1
    call :Log "PENDING  : %BN% (launched, PID capture failed -- will resolve next poll)"
    echo.
    exit /b 0
)
echo !DN_PID!> "!LOCKFILE!"
set /a LIVE+=1 & set /a DN_LIVE+=1
call :Log "Launched : %BN% (PID:!DN_PID! slot !DN_LIVE!/%MAX_PARALLEL%)"
echo.
exit /b 0
