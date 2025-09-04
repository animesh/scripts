::winZipFile.bat F:\promec\TIMSTOF\LARS\2025\250902_Alessandro report.gg_matrix.tsv
::zip results from batch search
@echo off
set dataDir=%1
set fileName=%2
set workDir=%cd%
setlocal enabledelayedexpansion
set "zipfile=%dataDir%\%fileName%.zip"
rem Build file list and create zip
set "files="
for /d %%i in (%dataDir%\*) do (
    if exist "%%i\%fileName%" (
        set "files=!files! %%i\%fileName%"
        find /c /v "" "%%i\%fileName%"
    )
)
if defined files (
    tar -acf "%zipfile%" %files%
    echo Created %zipfile%
) else (
    echo No %fileName% files found in subfolders
)
cd %workDir%

