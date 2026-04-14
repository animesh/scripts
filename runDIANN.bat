:: runDIANN.bat F:\promec\TIMSTOF\LARS\2026\260408_Steven 64 --high-acc
:: DIA-NN 2.2.0 Academia  (Data-Independent Acquisition by Neural Networks) Compiled on May 29 2025 21:29:29 Current date and time: Tue Aug  5 09:36:11 2025 CPU: GenuineIntel Intel(R) Xeon(R) CPU E5-2683 v4 @ 2.10GHz SIMD instructions: AVX AVX2 FMA SSE4.1 SSE4.2 Logical CPU cores: 64 Thread number set to 32 Output will be filtered at 0.01 FDR Precursor/protein x samples expression level matrices will be saved along with the main report A spectral library will be generated
:: wget https://rest.uniprot.org/uniprotkb/stream?download=true&format=fasta&includeIsoform=true&query=%28%28proteome%3AUP000006548%29%29 -o "F:\promec\TIMSTOF\LARS\2026\260408_Steven\uniprotkb_proteome_UP000006548_2026_04_13.fasta"
@echo off
setlocal enabledelayedexpansion

SET "dataDir=%~1"
SET "NCPU=%~2"
SET "mode=%~3"

if "%dataDir%"=="" exit /b 1
if "%NCPU%"=="" exit /b 1

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

if %dirCount%==0 exit /b 1

for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "timestamp=%dt:~2,2%%dt:~4,2%%dt:~6,2%_%dt:~8,2%%dt:~10,2%%dt:~12,2%"

set outputDir=%dataDir%\DIANNv2P2.%dirCount%.%timestamp%.%NCPU%.!dirMode!
mkdir "%outputDir%" 2>nul

set fileList=
for /d %%i in ("%dataDir%\*.d") do set fileList=!fileList! --f "%%i"

cd "C:\Program Files\DIA-NN\2.2.0\"

set diannCmd=diann.exe!fileList!  --lib "F:\promec\TIMSTOF\LARS\2026\260408_Steven\ArabidopsisMC2V3lib.predicted.speclib" --threads %NCPU% --verbose 1 --out "!outputDir!\report.parquet" --qvalue 0.01 --matrices --out-lib "!outputDir!\report-lib.parquet" --gen-spec-lib --reannotate --fasta "camprotR_240512_cRAP_20190401_full_tags.fasta" --cont-quant-exclude cRAP- --fasta "F:\promec\TIMSTOF\LARS\2026\260408_Steven\uniprotkb_proteome_UP000006548_2026_04_13.fasta" --min-fr-mz 200 --max-fr-mz 1800  --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --mass-acc 15.0 --mass-acc-ms1 15.0 --peptidoforms --reanalyse --rt-profiling

if not "%mode%"=="" set diannCmd=!diannCmd! %mode%

!diannCmd!
::diann.exe --lib "" --threads 32 --verbose 1 --out "F:\promec\TIMSTOF\LARS\2026\260408_Steven\ArabidopsisMC2V3.parquet" --qvalue 0.01 --matrices  --out-lib "F:\promec\TIMSTOF\LARS\2026\260408_Steven\ArabidopsisMC2V3lib.parquet" --gen-spec-lib --predictor --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "F:\promec\TIMSTOF\LARS\2026\260408_Steven\uniprotkb_proteome_UP000006548_2026_04_13.fasta" --fasta-search --min-fr-mz 200 --max-fr-mz 1800 --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --mass-acc 15.0 --mass-acc-ms1 15.0 --peptidoforms --reanalyse --rt-profiling --high-acc 
::diann.exe --f "F:\promec\TIMSTOF\LARS\2026\260408_Steven\260408_Steven_9_Slot1-9_1_13425.d" --f "F:\promec\TIMSTOF\LARS\2026\260408_Steven\260408_Steven_8_Slot1-8_1_13424.d" --f "F:\promec\TIMSTOF\LARS\2026\260408_Steven\260408_Steven_7_Slot1-7_1_13423.d" --f"F:\promec\TIMSTOF\LARS\2026\260408_Steven\260408_Steven_6_Slot1-6_1_13422.d" --f "F:\promec\TIMSTOF\LARS\2026\260408_Steven\260408_Steven_5_Slot1-5_1_13421.d" --f "F:\promec\TIMSTOF\LARS\2026\260408_Steven\260408_Steven_4_Slot1-4_1_13420.d" --f"F:\promec\TIMSTOF\LARS\2026\260408_Steven\260408_Steven_3_Slot1-3_1_13419.d" --f "F:\promec\TIMSTOF\LARS\2026\260408_Steven\260408_Steven_2_Slot1-2_1_13418.d" --f "F:\promec\TIMSTOF\LARS\2026\260408_Steven\260408_Steven_21_Slot1-21_1_13440.d" --f"F:\promec\TIMSTOF\LARS\2026\260408_Steven\260408_Steven_20_Slot1-20_1_13439.d" --f "F:\promec\TIMSTOF\LARS\2026\260408_Steven\260408_Steven_1_Slot1-1_1_13417.d" --f "F:\promec\TIMSTOF\LARS\2026\260408_Steven\260408_Steven_19_Slot1-19_1_13438.d" --f "F:\promec\TIMSTOF\ARS\2026\260408_Steven\260408_Steven_18_Slot1-18_1_13437.d" --f "F:\promec\TIMSTOF\LARS\2026\260408_Steven\260408_Steven_17_Slot1-17_1_13436.d" --f "F:\promec\TIMSTOF\LARS\2026\260408_Steven\260408_Steven_16_Slot1-16_1_13435.d" --f"F:\promec\TIMSTOF\LARS\2026\260408_Steven\260408_Steven_15_Slot1-15_1_13434.d" --f "F:\promec\TIMSTOF\LARS\2026\260408_Steven\260408_Steven_14_Slot1-14_1_13433.d" --f "F:\promec\TIMSTOF\LARS\2026\260408_Steven\260408_Steven_13_Slot1-13_1_13432.d" --f"F:\promec\TIMSTOF\LARS\2026\260408_Steven\260408_Steven_12_Slot1-12_1_13431.d" --f "F:\promec\TIMSTOF\LARS\2026\260408_Steven\260408_Steven_11_Slot1-11_1_13430.d" --f "F:\promec\TIMSTOF\LARS\2026\260408_Steven\260408_Steven_10_Slot1-10_1_13426.d" --lib "F:\promec\TIMSTOF\LARS\2026\260408_Steven\ArabidopsisMC2V3lib.predicted.speclib" --threads 32 --verbose 1 --out "F:\promec\TIMSTOF\LARS\2026\260408_Steven\report.parquet" --qvalue 0.01 --matrices  --out-lib "F:\promec\TIMSTOF\LARS\2026\260408_Steven\report-lib.parquet" --gen-spec-lib --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --mass-acc 15.0 --mass-acc-ms1 15.0 --peptidoforms --reanalyse --rt-profiling --high-acc 
