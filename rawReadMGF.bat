:: rawReadMGF.bat "L:\promec\TIMSTOF\LARS\Whale_Mitra27samples_LC-MSMSAugust2024-Feb2025\240819_Mitra_FOC4050_1_Slot2-10_1_8042.d"
@echo off
setlocal

set "MSCONVERT=F:\ProteoWizard 4.0.26293-fd839c0\msconvert.exe"

if "%~1"=="" (
    echo ERROR: No input specified.
    echo Usage: 
    echo   1. For a single dataset: convert_mgf.bat "path\to\sample.d"
    echo   2. For an entire folder:  convert_mgf.bat "path\to\parent_folder"
    pause
    exit /b
)

set "INPUT_PATH=%~1"

if not exist "%INPUT_PATH%" (
    echo ERROR: Path not found: %INPUT_PATH%
    pause
    exit /b
)

:: Check if input path ends with .d (single dataset mode)
if /i "%INPUT_PATH:~-2%"==".d" (
    goto SINGLE_FILE
) else (
    goto BATCH_FOLDER
)

:SINGLE_FILE
set "OUTDIR=%~dp1"
if "%OUTDIR:~-1%"=="\" set "OUTDIR=%OUTDIR:~0,-1%"
echo Converting single dataset: %~nx1 to MGF...
"%MSCONVERT%" "%INPUT_PATH%" -o "%OUTDIR%" --mgf
goto END

:BATCH_FOLDER
set "OUTDIR=%INPUT_PATH%"
if "%OUTDIR:~-1%"=="\" set "OUTDIR=%OUTDIR:~0,-1%"
echo Scanning %OUTDIR% for .d directories...
set "count=0"
for /d %%i in ("%OUTDIR%\*.d") do (
    set /a count+=1
    echo [%%i] Converting to MGF: %%~nxi
    "%MSCONVERT%" "%%~fi" -o "%OUTDIR%" --mgf
)
echo Found %count% directories. All conversions finished.
goto END

:END
pause