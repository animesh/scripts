:: Usage: runDIANN_SILAC.bat <diannPath> <dataDir> [NCPU] [mode] [libPath] [fastaPath]
:: runDIANN.bat "F:\DIA-NN\2.3.0\" "L:\promec\TIMSTOF\LARS\2025\250329_DIA_Hela" 64 --high-acc "F:\DIA-NN\2.3.0\report-lib.predicted.speclib" "L:\promec\FastaDB\UP000005640_9606_1protein1gene.fasta"
:: runDIANN.bat "F:\DIA-NN\2.3.0\" "L:\promec\TIMSTOF\LARS\2025\250329_DIA_Hela"
:: Parameters:
::   diannPath  - DIA-NN installation directory (required)
::   dataDir    - Directory containing .d files to process (required)
::   NCPU       - Number of CPU threads (optional, default: all available CPUs)
::   mode       - Additional DIA-NN flags like --high-acc (optional, default: none)
::   libPath    - Spectral library file path (optional, default: L:\promec\FastaDB\reportgenspec-lib.predicted.speclib)
::   fastaPath  - FASTA database file path (optional, default: L:\promec\FastaDB\UP000005640_9606_1protein1gene.fasta)
:: Single DIA-NN command processing all *.d directories
:: wget https://github.com/vdemichev/DiaNN/releases/download/2.0/DIA-NN-2.3.0-Academia-Preview.msi , linux version at https://github.com/vdemichev/DiaNN/releases/download/2.0/DIA-NN-2.3.0-Academia-Linux-Preview.zip
:: wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000005640/UP000005640_9606.fasta.gz and gunzip to "L:\promec\FastaDB\UP000005640_9606_1protein1gene.fasta.gz"
:: also wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000005640/UP000005640_9606_additional.fasta.gz if needed
::  mkdir -p promec/promec/TIMSTOF/Test
::  rsync -Parv ash022@login.nird-lmd.sigma2.no:TIMSTOF/Test/*.d /home/animeshs/promec/promec/TIMSTOF/Test/
:: diann.exe --lib "" --threads 12 --verbose 1 --out "F:\DIA-NN\2.3.0\report.parquet" --qvalue 0.01 --matrices  --out-lib "F:\DIA-NN\2.3.0\report-lib.parquet" --gen-spec-lib --predictor --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "L:\promec\FastaDB\UP000005640_9606_1protein1gene.fasta" --fasta-search --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --min-fr-mz 200 --max-fr-mz 1800 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:7,0.984016,NQ --var-mod UniMod:1,42.010565,*n --peptidoforms --reanalyse --rt-profiling  

@echo off
setlocal enabledelayedexpansion

SET "diannPath=%~1"
SET "dataDir=%~2"
SET "NCPU=%~3"
SET "mode=%~4"
SET "libPath=%~5"
SET "fastaPath=%~6"

if "%diannPath%"=="" exit /b 1
if "%dataDir%"=="" exit /b 1

:: Ensure DIA-NN path ends with backslash
if "!diannPath:~-1!" neq "\" SET "diannPath=!diannPath!\"

:: Set default NCPU to number of logical processors if not provided
if "%NCPU%"=="" (
    SET "NCPU=%NUMBER_OF_PROCESSORS%"
    echo Using default CPU threads: %NCPU% ^(all available^)
) else (
    echo Using specified CPU threads: %NCPU%
)

:: Set default library path if not provided
if "%libPath%"=="" (
    SET "libPath=L:\promec\FastaDB\reportgenspec-lib.predicted.speclib"
    echo Using default spectral library
) else (
    echo Using specified spectral library
)

:: Set default FASTA path if not provided
if "%fastaPath%"=="" (
    SET "fastaPath=L:\promec\FastaDB\UP000005640_9606_1protein1gene.fasta"
    echo Using default FASTA database
) else (
    echo Using specified FASTA database
)

:: Verify DIA-NN path exists
if not exist "%diannPath%diann.exe" (
    echo Error: DIA-NN executable not found at "%diannPath%diann.exe"
    echo Please check the path or install DIA-NN at the specified location.
    exit /b 1
)

:: Verify library file exists if specified
if not exist "%libPath%" (
    echo Error: Spectral library not found at "%libPath%"
    echo Please check the library path or generate the library first.
    exit /b 1
)

:: Verify FASTA file exists
if not exist "%fastaPath%" (
    echo Error: FASTA database not found at "%fastaPath%"
    echo Please check the FASTA file path.
    exit /b 1
)

echo Using DIA-NN installation at: %diannPath%
echo Processing data directory: %dataDir%
echo Spectral library: %libPath%
echo FASTA database: %fastaPath%

if "%mode%"=="" (
    echo Mode flags: none ^(default^)
) else (
    echo Mode flags: %mode%
)

SET dirMode=default
if not "%mode%"=="" (
    SET tempMode=%mode%
    SET tempMode=!tempMode:--=!
    SET tempMode=!tempMode:-=!
    SET tempMode=!tempMode: =!
    SET dirMode=!tempMode!
)

set /a dirCount=0
for /d %%i in ("%dataDir%\*.d") do set /a dirCount+=1

if %dirCount%==0 (
    echo Error: No .d directories found in "%dataDir%"
    exit /b 1
)

echo Found %dirCount% .d directories to process

for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "timestamp=%dt:~2,2%%dt:~4,2%%dt:~6,2%_%dt:~8,2%%dt:~10,2%%dt:~12,2%"

set outputDir=%dataDir%\DIANNv2P2.%dirCount%.%timestamp%.%NCPU%.!dirMode!
mkdir "%outputDir%" 2>nul

echo Output directory: %outputDir%

set fileList=
for /d %%i in ("%dataDir%\*.d") do set fileList=!fileList! --f "%%i"

:: Change to DIA-NN directory
cd /d "%diannPath%"

set diannCmd=diann.exe!fileList! --lib "%libPath%" --threads %NCPU% --verbose 1 --out "%outputDir%\report.parquet" --qvalue 0.01 --matrices --out-lib "%outputDir%\replib.parquet" --gen-spec-lib --reannotate --fasta "camprotR_240512_cRAP_20190401_full_tags.fasta" --cont-quant-exclude cRAP- --fasta "%fastaPath%" --pre-search --pre-filter --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --min-fr-mz 200 --max-fr-mz 1800 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:7,0.984016,NQ --var-mod UniMod:1,42.010565,*n --peptidoforms --reanalyse --rt-profiling

if not "%mode%"=="" set diannCmd=!diannCmd! %mode%

echo Executing DIA-NN command...
echo %diannCmd%
echo.

!diannCmd!

if !errorlevel! neq 0 (
    echo Error: DIA-NN execution failed with error code !errorlevel!
    exit /b !errorlevel!
) else (
    echo DIA-NN execution completed successfully
    echo Results saved to: %outputDir%
)
