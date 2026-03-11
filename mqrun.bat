@echo off

SETLOCAL ENABLEDELAYEDEXPANSION

:: mqrun v27 — MaxQuant batch watcher for timsTOF HeLa QC runs

:: Completion sentinel: SESSIONDIR\<BN>.done  (not inside WORKDIR)

:: This allows full rmdir of WORKDIR after job completes.

set MAXQUANTCMD=C:\Program Files\MaxQuant_v2.7.0.0\bin\MaxQuantCmd.exe

set DATAROOT=F:\promec\TIMSTOF\Raw

set DATAPATTERN=*HeLa*.d

set FASTAFILE=F:\promec\FastaDB\UP000005640_9606_1protein1gene.fasta

set PARAMFILE=mqpar.xml

set TMPDIR=D:\TMPDIR

set QCROOT=F:\promec\TIMSTOF\QC

set POLL_INTERVAL=1800

set STABILITY_WAIT=60

set SEARCHTEXT=TestDir

set SEARCHTEXT2=SequencesFasta

set CPU_COUNT=64

set MAX_RETRIES=3

set TLIST=%SystemRoot%\System32\tasklist.exe

set WMIC=%SystemRoot%\System32\wbem\wmic.exe

set LOGFILE=%QCROOT%\mqrun_log.txt

if not exist "%MAXQUANTCMD%" ( echo ERROR: MaxQuantCmd not found: %MAXQUANTCMD% & exit /b 1 )

if not exist "%DATAROOT%"    ( echo ERROR: DATAROOT not found: %DATAROOT%        & exit /b 1 )

if not exist "%FASTAFILE%"   ( echo ERROR: FASTA not found: %FASTAFILE%          & exit /b 1 )

if not exist "%PARAMFILE%"   ( echo ERROR: %PARAMFILE% not found in current dir  & exit /b 1 )

for %%D in ("%DATAROOT%") do set DATAROOT_LEAF=%%~nxD

for %%F in ("%FASTAFILE%") do set FASTA_LEAF=%%~nF

set SESSIONDIR=%TMPDIR%\!DATAROOT_LEAF!_!FASTA_LEAF!

if not exist "%TMPDIR%"     mkdir "%TMPDIR%"

if not exist "!SESSIONDIR!" mkdir "!SESSIONDIR!"

echo Session dir  : !SESSIONDIR!

echo Watching     : %DATAROOT%\*\*\%DATAPATTERN%

echo Poll: %POLL_INTERVAL%s  ^| Stability: %STABILITY_WAIT%s  ^| Max parallel: %CPU_COUNT%

echo.

echo [%date% %time%] ===== SESSION START  !SESSIONDIR! ===== >> "%LOGFILE%"

:: Migrate v23 done.lock files -> SESSIONDIR\<BN>.done  (one-time, safe to re-run)

set "MIG=0"

for /d %%J in ("!SESSIONDIR!\*") do (

    if exist "%%~fJ\done.lock" (

        echo 1> "!SESSIONDIR!\%%~nxJ.done"

        del /f /q "%%~fJ\done.lock"

        set /a MIG+=1

    )

)

if !MIG! GTR 0 call :Log "Migrate  : !MIG! done.lock file(s) moved to SESSIONDIR level"

:: Remove stale lock files from dead/interrupted processes

set "STALE=0"

for /d %%J in ("!SESSIONDIR!\*") do (

    if exist "%%~fJ\queued.lock" ( del "%%~fJ\queued.lock" & set /a STALE+=1 )

    if exist "%%~fJ\running.lock" (

        set "ST_PID="

        for /f "usebackq tokens=1" %%P in ("%%~fJ\running.lock") do set "ST_PID=%%P"

        if "!ST_PID!"=="PENDING" (

            del "%%~fJ\running.lock" & set /a STALE+=1

        ) else if defined ST_PID (

            %TLIST% /fi "pid eq !ST_PID!" /fo csv /nh 2>nul | findstr /i "MaxQuantCmd" >nul

            if errorlevel 1 ( del "%%~fJ\running.lock" & set /a STALE+=1 )

        )

    )

)

if !STALE! GTR 0 call :Log "Startup  : !STALE! stale lock file(s) removed"

:watch_loop

set FOUND=0 & set DONE=0 & set QUEUED=0 & set LIVE=0 & set SKIPPED=0

set ACQUIRING=0 & set RETRYING=0 & set ERRORS=0 & set UNKNOWN=0

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

:: Cleanup pass: rmdir any WORKDIR whose .done sentinel exists

for /d %%W in ("!SESSIONDIR!\*") do (

    if exist "!SESSIONDIR!\%%~nxW.done" (

        if exist "%%~fW" rmdir /s /q "%%~fW" 2>nul

    )

)

:: Orphan-done count: .done sentinels with no matching source folder

set "ORPHAN_DONE=0"

for %%S in ("!SESSIONDIR!\*.done") do (

    set "BN_=%%~nS"

    set "SRC_FOUND=0"

    for /d %%U in ("%DATAROOT%\*") do (

        for /d %%V in ("%%~fU\*") do if exist "%%~fV\!BN_!.d" set "SRC_FOUND=1"

    )

    if "!SRC_FOUND!"=="0" set /a ORPHAN_DONE+=1

)

set /a UNKNOWN=FOUND-DONE-LIVE-QUEUED-ACQUIRING-RETRYING-ERRORS-SKIPPED

echo [%time%] Poll: !FOUND! found  ^|  !DONE! done  ^|  !ORPHAN_DONE! orphan-done  ^|  !LIVE! running  ^|  !QUEUED! queued  ^|  !ACQUIRING! acquiring  ^|  !RETRYING! retrying  ^|  !ERRORS! errors  ^|  !SKIPPED! skipped  ^|  !UNKNOWN! unknown

echo [%time%] Poll: !FOUND! found  ^|  !DONE! done  ^|  !ORPHAN_DONE! orphan-done  ^|  !LIVE! running  ^|  !QUEUED! queued  ^|  !ACQUIRING! acquiring  ^|  !RETRYING! retrying  ^|  !ERRORS! errors  ^|  !SKIPPED! skipped  ^|  !UNKNOWN! unknown >> "%LOGFILE%"

timeout /t %POLL_INTERVAL% /nobreak >nul

goto :watch_loop

:: :Log — do NOT pass strings containing | > < &

:Log

echo [%time%] %~1

echo [%time%] %~1 >> "%LOGFILE%"

exit /b 0

:: :GetSize — sets VAR to file size via WMIC (handles >2 GB)

:GetSize

set "%~2="

set "_GP=%~1"

set "_GP=!_GP:\=\\!"

for /f "tokens=2 delims==" %%Z in ('%WMIC% datafile where "name=^'!_GP!^'" get FileSize /format:value 2^>nul ^| more') do for /f "tokens=1" %%V in ("%%Z") do set "%~2=%%V"

exit /b 0

:: :AdoptPID — Arg1: full mqpar.xml path; sets ADOPT_PID if live MQ found

:AdoptPID

set "ADOPT_PID="

set "_AP=%~1"

set "_AP=!_AP:\=\\!"

for /f "tokens=2 delims==" %%P in ('%WMIC% process where "name=^'MaxQuantCmd.exe^' and commandline like ^'%%!_AP!%%^'" get ProcessId /format:value 2^>nul ^| more') do (

    for /f "tokens=1" %%V in ("%%P") do if not defined ADOPT_PID set "ADOPT_PID=%%V"

)

exit /b 0

:: :CheckRetry — Arg1: .retries file  Arg2: basename

:: Increments counter; sets RC_GAVE_UP=1 at MAX_RETRIES.

:CheckRetry

set "RC_GAVE_UP=0"

set "RC=0"

if exist "%~1" for /f "usebackq tokens=1" %%N in ("%~1") do set "RC=%%N"

if !RC! GEQ %MAX_RETRIES% (

    call :Log "GaveUp   : %~2 (!RC!/%MAX_RETRIES% retries exhausted - manual review needed)"

    set "RC_GAVE_UP=1"

) else (

    set /a RC+=1

    echo !RC!> "%~1"

)

exit /b 0

:: :MarkDone — Arg1: WORKDIR  Arg2: basename  Arg3: PID|PENDING|""

:: Gate: proteinGroups.txt + "Finish writing tables" + MQ dead

:: Pass: QC robocopy, SESSIONDIR\<BN>.done written, cleanup. Sets DONE_FLAG=1.

:MarkDone

set "MD_W=%~1"

set "MD_BN=%~2"

set "MD_PID=%~3"

set "MD_DONE=!SESSIONDIR!\%MD_BN%.done"

set "DONE_FLAG=0"

if not exist "%MD_W%\combined\txt\proteinGroups.txt"  exit /b 0

if not exist "%MD_W%\combined\proc\#runningTimes.txt" exit /b 0

findstr /i "Finish writing tables" "%MD_W%\combined\proc\#runningTimes.txt" >nul 2>nul

if errorlevel 1 exit /b 0

if /i "!MD_PID!"=="PENDING" ( call :Log "WaitPID  : %MD_BN% (PENDING - deferring)" & exit /b 0 )

if "!MD_PID!"=="" (

    call :AdoptPID "%MD_W%\mqpar.xml"

    if defined ADOPT_PID ( call :Log "WaitPID  : %MD_BN% (orphan PID !ADOPT_PID! - deferring)" & exit /b 0 )

    goto :md_ok

)

%TLIST% /fi "pid eq !MD_PID!" /fo csv /nh 2>nul | findstr /i "MaxQuantCmd" >nul

if not errorlevel 1 ( call :Log "WaitPID  : %MD_BN% (PID !MD_PID! alive - deferring)" & exit /b 0 )

:md_ok

if not "%QCROOT%"=="" (

    if not exist "%QCROOT%\" ( call :Log "WARNING  : %MD_BN% QCROOT not reachable - will retry" & exit /b 0 )

    if not exist "%QCROOT%\%MD_BN%\combined\txt" mkdir "%QCROOT%\%MD_BN%\combined\txt"

    robocopy "%MD_W%\combined\txt" "%QCROOT%\%MD_BN%\combined\txt" /E /XO /R:3 /W:10 /NFL /NDL /NJH /NJS /LOG+:"%QCROOT%\copy_log.txt" >nul

    if errorlevel 8 ( call :Log "ERROR    : %MD_BN% QC copy failed - skipping cleanup" & exit /b 0 )

    call :Log "QC copy  : %MD_BN% -> %QCROOT%\%MD_BN%\combined\txt"

)

echo 1> "!MD_DONE!"

set "DONE_FLAG=1"

call :Log "Cleanup  : %MD_BN%"

rmdir /s /q "%MD_W%" 2>nul

set "_RC=!SESSIONDIR!\%MD_BN%.retries"

if exist "!_RC!" del /f /q "!_RC!"

exit /b 0

:: :CheckFolder — main per-job dispatch

:CheckFolder

set "SRC=%~1"

set "BN=%~n1"

set "WORKDIR=!SESSIONDIR!\%BN%"

set "DATADEST=!WORKDIR!\data.d"

set "RUNPARAM=!WORKDIR!\%PARAMFILE%"

if exist "!SESSIONDIR!\%BN%.done" (

    set /a DONE+=1

    exit /b 0

)

if exist "!WORKDIR!\queued.lock" (

    if !MQ_LIVE! GEQ %CPU_COUNT% ( set /a QUEUED+=1 & exit /b 0 )

    del "!WORKDIR!\queued.lock"

)

if exist "!WORKDIR!\combined\txt\proteinGroups.txt" (

    set "CK_PID="

    if exist "!WORKDIR!\running.lock" for /f "usebackq tokens=1" %%P in ("!WORKDIR!\running.lock") do set "CK_PID=%%P"

    call :MarkDone "!WORKDIR!" "%BN%" "!CK_PID!"

    if "!DONE_FLAG!"=="1" ( set /a DONE+=1 & call :Log "Completed: %BN%" & exit /b 0 )

)

if not exist "!WORKDIR!\running.lock" goto :no_lockfile

set "MQ_PID="

for /f "usebackq tokens=1" %%P in ("!WORKDIR!\running.lock") do set "MQ_PID=%%P"

if "!MQ_PID!"=="PENDING" (

    call :AdoptPID "!RUNPARAM!"

    if defined ADOPT_PID (

        echo !ADOPT_PID!> "!WORKDIR!\running.lock"

        set /a LIVE+=1

        call :Log "Adopted  : %BN% (PID:!ADOPT_PID! from PENDING)"

        exit /b 0

    )

    set "_RC=!SESSIONDIR!\%BN%.retries"

    call :CheckRetry "!_RC!" "%BN%"

    if "!RC_GAVE_UP!"=="1" ( set /a ERRORS+=1 & exit /b 0 )

    call :Log "CrashWipe: %BN% (PENDING, no live MQ - retry !RC!/%MAX_RETRIES%)"

    rmdir /s /q "!WORKDIR!"

    set /a RETRYING+=1

    exit /b 0

)

if not defined MQ_PID ( set /a ERRORS+=1 & call :Log "ERROR    : %BN% (empty running.lock)" & exit /b 0 )

set /a LIVE+=1

%TLIST% /fi "pid eq !MQ_PID!" /fo csv /nh 2>nul | findstr /i "MaxQuantCmd" >nul

if not errorlevel 1 exit /b 0

timeout /t 5 /nobreak >nul

%TLIST% /fi "pid eq !MQ_PID!" /fo csv /nh 2>nul | findstr /i "MaxQuantCmd" >nul

if not errorlevel 1 exit /b 0

del "!WORKDIR!\running.lock"

set /a LIVE-=1

call :MarkDone "!WORKDIR!" "%BN%" "!MQ_PID!"

if "!DONE_FLAG!"=="1" ( set /a DONE+=1 & call :Log "Completed: %BN% (PID !MQ_PID! exited)" & exit /b 0 )

set "FOUND_OUTPUT=0"

for %%F in ("!WORKDIR!\combined\txt\*.txt") do set "FOUND_OUTPUT=1"

if !FOUND_OUTPUT! EQU 1 (

    echo 1> "!SESSIONDIR!\%BN%.done"

    set /a DONE+=1

    call :Log "Completed: %BN% (fallback .txt - QC copy + cleanup skipped)"

    exit /b 0

)

set /a RETRYING+=1

call :Log "Failed   : %BN% (PID !MQ_PID! gone, no output, retrying)"

set "_RC=!SESSIONDIR!\%BN%.retries"

call :CheckRetry "!_RC!" "%BN%"

if "!RC_GAVE_UP!"=="1" ( set /a RETRYING-=1 & set /a ERRORS+=1 )

exit /b 0

:: :no_lockfile — new job path

:no_lockfile

call :AdoptPID "!RUNPARAM!"

if defined ADOPT_PID (

    echo !ADOPT_PID!> "!WORKDIR!\running.lock"

    set /a LIVE+=1

    call :Log "Adopted  : %BN% (PID:!ADOPT_PID!)"

    exit /b 0

)

if not exist "%SRC%\analysis.tdf"               ( set /a SKIPPED+=1 & call :Log "Skipped  : %BN% (analysis.tdf missing)"               & exit /b 0 )

if not exist "%SRC%\analysis.tdf_bin"           ( set /a SKIPPED+=1 & call :Log "Skipped  : %BN% (analysis.tdf_bin missing)"           & exit /b 0 )

if not exist "%SRC%\chromatography-data.sqlite" ( set /a SKIPPED+=1 & call :Log "Skipped  : %BN% (chromatography-data.sqlite missing)" & exit /b 0 )

if !MQ_LIVE! GEQ %CPU_COUNT% (

    if exist "!DATADEST!\analysis.tdf" if exist "!DATADEST!\analysis.tdf_bin" if exist "!DATADEST!\chromatography-data.sqlite" (

        set /a QUEUED+=1

        echo QUEUED > "!WORKDIR!\queued.lock"

        exit /b 0

    )

)

call :GetSize "%SRC%\analysis.tdf"               SZ1

call :GetSize "%SRC%\analysis.tdf_bin"           SZ2

call :GetSize "%SRC%\chromatography-data.sqlite" SZ3

timeout /t %STABILITY_WAIT% /nobreak >nul

set "SZ1B=" & set "SZ2B=" & set "SZ3B="

call :GetSize "%SRC%\analysis.tdf"               SZ1B

call :GetSize "%SRC%\analysis.tdf_bin"           SZ2B

call :GetSize "%SRC%\chromatography-data.sqlite" SZ3B

if defined SZ1B if not "!SZ1!"=="!SZ1B!" ( set /a ACQUIRING+=1 & call :Log "Acquiring: %BN%" & exit /b 0 )

if defined SZ2B if not "!SZ2!"=="!SZ2B!" ( set /a ACQUIRING+=1 & call :Log "Acquiring: %BN%" & exit /b 0 )

if defined SZ3B if not "!SZ3!"=="!SZ3B!" ( set /a ACQUIRING+=1 & call :Log "Acquiring: %BN%" & exit /b 0 )

if exist "!DATADEST!\analysis.tdf" if exist "!DATADEST!\analysis.tdf_bin" if exist "!DATADEST!\chromatography-data.sqlite" (

    set "DS1=" & set "DS2=" & set "DS3="

    call :GetSize "!DATADEST!\analysis.tdf"               DS1

    call :GetSize "!DATADEST!\analysis.tdf_bin"           DS2

    call :GetSize "!DATADEST!\chromatography-data.sqlite" DS3

    if "!DS1!"=="!SZ1B!" if "!DS2!"=="!SZ2B!" if "!DS3!"=="!SZ3B!" (

        call :Log "Verified : %BN%"

        goto :write_param

    )

)

mkdir "!WORKDIR!"  2>nul

mkdir "!DATADEST!" 2>nul

call :Log "Copying  : %BN%"

robocopy "%SRC%" "!DATADEST!" analysis.tdf analysis.tdf_bin chromatography-data.sqlite /J /R:1 /W:5 /NP /NFL /NDL /NJH /NJS >nul

if errorlevel 8 ( set /a ERRORS+=1 & call :Log "ERROR    : %BN% robocopy failed (exit !errorlevel!)" & exit /b 0 )

call :Log "Copied   : %BN%"

:write_param

set "NEED_PARAM=1"

if exist "!RUNPARAM!" (

    findstr /i "%BN%" "!RUNPARAM!" >nul 2>nul

    if not errorlevel 1 set "NEED_PARAM=0"

)

if !NEED_PARAM! EQU 0 goto :wp_done

if exist "!RUNPARAM!" del "!RUNPARAM!" 2>nul

call :WriteParam "!DATADEST!" "!FASTAFILE!" "!RUNPARAM!"

if not exist "!RUNPARAM!" ( set /a ERRORS+=1 & call :Log "ERROR    : param write failed for %BN%" & exit /b 0 )

:wp_done

if !MQ_LIVE! GEQ %CPU_COUNT% (

    set /a QUEUED+=1

    if not exist "!WORKDIR!" mkdir "!WORKDIR!"

    echo QUEUED > "!WORKDIR!\queued.lock"

    call :Log "Queued   : %BN% (!MQ_LIVE!/%CPU_COUNT%)"

    exit /b 0

)

if exist "!WORKDIR!\queued.lock" del "!WORKDIR!\queued.lock"

start "MQ.%BN%" "%MAXQUANTCMD%" "!RUNPARAM!"

timeout /t 3 /nobreak >nul

set "MQ_PID="

for /f "skip=1 tokens=2 delims=," %%P in ('%TLIST% /fi "windowtitle eq MQ.%BN%" /fi "imagename eq MaxQuantCmd.exe" /fo csv 2^>nul') do set "MQ_PID=%%~P"

if not defined MQ_PID (

    echo PENDING> "!WORKDIR!\running.lock"

    set /a LIVE+=1 & set /a MQ_LIVE+=1

    call :Log "PENDING  : %BN% (launched, PID capture failed - will retry)"

    echo.

    exit /b 0

)

echo !MQ_PID!> "!WORKDIR!\running.lock"

set /a LIVE+=1 & set /a MQ_LIVE+=1

call :Log "Launched : %BN% (PID:!MQ_PID! slot !MQ_LIVE!/%CPU_COUNT%)"

echo.

exit /b 0

:: :WriteParam — Arg1: DATADEST  Arg2: FASTAFILE  Arg3: RUNPARAM

:: Rewrites template PARAMFILE substituting placeholders. Args are plain strings.

:: %~1/%~2 expand at subroutine parse time — no !var! nesting conflict.

:WriteParam

for /f "usebackq tokens=* delims=" %%A in ("%PARAMFILE%") do (

    set "LINE=%%A"

    set "LINE=!LINE:%SEARCHTEXT%=%~1!"

    set "LINE=!LINE:%SEARCHTEXT2%=%~2!"

    echo !LINE!>> "%~3"

)

exit /b 0

