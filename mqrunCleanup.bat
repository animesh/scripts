@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

:: Deletes bulk intermediate files for all COMPLETED jobs (done.lock present).
:: Safe to run while mqrun.bat is still running.
:: Preserves: done.lock, combined\txt\ (your results), running.lock, queued.lock
:: Deletes:   data.d\, data\, data.index, mqpar.xml,
::            combined\andromeda\, combined\search\, combined\proc\,
::            combined\sdrf\, combined\combinedRunInfo\

set SESSIONDIR=D:\TMPDIR\Raw_UP000005640_9606_1protein1gene

echo.
echo Scanning: %SESSIONDIR%
echo.

set COUNT=0
set SKIPPED=0

for /d %%J in ("%SESSIONDIR%\*") do (
    if exist "%%~fJ\done.lock" (
        set /a COUNT+=1
        echo Cleaning: %%~nxJ

        if exist "%%~fJ\data.d"                    rmdir /s /q "%%~fJ\data.d"
        if exist "%%~fJ\data"                      rmdir /s /q "%%~fJ\data"
        if exist "%%~fJ\combined\andromeda"         rmdir /s /q "%%~fJ\combined\andromeda"
        if exist "%%~fJ\combined\search"            rmdir /s /q "%%~fJ\combined\search"
        if exist "%%~fJ\combined\proc"              rmdir /s /q "%%~fJ\combined\proc"
        if exist "%%~fJ\combined\sdrf"              rmdir /s /q "%%~fJ\combined\sdrf"
        if exist "%%~fJ\combined\combinedRunInfo"   rmdir /s /q "%%~fJ\combined\combinedRunInfo"
        if exist "%%~fJ\mqpar.xml"                  del /f /q "%%~fJ\mqpar.xml"
        if exist "%%~fJ\data.index"                 del /f /q "%%~fJ\data.index"
    ) else (
        set /a SKIPPED+=1
    )
)

echo.
echo Done. Cleaned !COUNT! completed jobs, skipped !SKIPPED! incomplete/running jobs.
echo.
echo Free space on D: after cleanup:
dir D:\ | findstr "bytes free"
echo.

:: for /d %J in ("D:\TMPDIR\Raw_UP000005640_9606_1protein1gene\*") do @if exist "%J\done.lock" start /b cmd /c rmdir /s /q "%J\data.d" 2>nul
:: for /d %J in ("D:\TMPDIR\Raw_UP000005640_9606_1protein1gene\*") do @if exist "%J\done.lock" start /b cmd /c rmdir /s /q "%J\combined\search" 2>nul
