::runDIANN.bat F:\promec\TIMSTOF\LARS\2025\251107_PREETHI 10 --high-acc
:: DIA-NN 2.2.0 Academia  (Data-Independent Acquisition by Neural Networks) Compiled on May 29 2025 21:29:29 Current date and time: Tue Aug  5 09:36:11 2025 CPU: GenuineIntel Intel(R) Xeon(R) CPU E5-2683 v4 @ 2.10GHz SIMD instructions: AVX AVX2 FMA SSE4.1 SSE4.2 Logical CPU cores: 64 Thread number set to 32 Output will be filtered at 0.01 FDR Precursor/protein x samples expression level matrices will be saved along with the main report A spectral library will be generated
:: wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000000437/UP000000437_7955.fasta.gz

@echo off
setlocal enabledelayedexpansion

SET dataDir=%1
SET NCPU=%2
SET mode=%3
SET workDir=%cd%

:: Create a clean directory name from mode parameter
SET dirMode=
if not "%mode%"=="" (
    :: Remove -- prefix and - characters, keep only alphanumeric
    SET tempMode=%mode%
    SET tempMode=!tempMode:--=!
    SET tempMode=!tempMode:-=!
    SET tempMode=!tempMode: =!
    SET dirMode=!tempMode!
) else (
    SET dirMode=default
)

echo Using mode parameter: %mode%
echo Using directory suffix: %dirMode%
echo.

for /d %%i in (%dataDir%\*.d) do (
    echo Processing: %%i

    cd "C:\Program Files\DIA-NN\2.2.0\"

    :: Create output directory using clean directory name
    set outputDir=%%i.DIANNv2P2.%NCPU%.!dirMode!
    echo Creating directory: !outputDir!
    mkdir "!outputDir!" 2>nul

    :: Build DIA-NN command with mode parameter (if provided)
    set diannCmd=diann.exe --f "%%i" --lib "F:\promec\FastaDB\zebraPepMC2defaultslib.predicted.speclib" --threads %NCPU% --verbose 1 --out "!outputDir!\report.parquet" --qvalue 0.01 --matrices --out-lib "!outputDir!\report-lib.parquet" --gen-spec-lib --reannotate --fasta "camprotR_240512_cRAP_20190401_full_tags.fasta" --cont-quant-exclude cRAP- --fasta "F:\promec\FastaDB\UP000000437_7955.fasta" --met-excision --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --mass-acc 20.0 --mass-acc-ms1 20 --peptidoforms --rt-profiling

    :: Add mode parameter to DIA-NN command if it exists
    if not "%mode%"=="" (
        set diannCmd=!diannCmd! %mode%
    )

    echo.
    echo Executing: !diannCmd!
    echo.

    :: Run DIA-NN
    start "DIANNv2P2.%NCPU%.!dirMode!.%%i" !diannCmd!

    :: List contents of output directory after completion
    echo Contents of !outputDir!:
    dir "!outputDir!"
    echo.

    cd "%workDir%"
)
