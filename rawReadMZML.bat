@echo off
setlocal

set "MSCONVERT=F:\ProteoWizard 4.0.26293-fd839c0\msconvert.exe"
set "OUTDIR=L:\promec\TIMSTOF\LARS\Whale_Mitra27samples_LC-MSMSAugust2024-Feb2025"

if not exist "%OUTDIR%" (
    echo ERROR: Directory not found or not accessible: %OUTDIR%
    pause
    exit /b
)

echo Scanning %OUTDIR% for .d directories...
set "count=0"

for /d %%i in ("%OUTDIR%\*.d") do (
    set /a count+=1
    echo [%%i] Converting: %%~nxi
    "%MSCONVERT%" "%%~fi" -o "%OUTDIR%"
)

echo Found %count% directories. All conversions finished.
pause
