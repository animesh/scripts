:: runDIANN.bat F:\promec\Animesh\nDDA\DIA 32 --direct-quant
:: diann.exe --f Z:\Download\timsread\Fig2A-E_raw\250128_Hela_1ng_nDIA_3ms_R1.raw --f Z:\Download\timsread\Fig2A-E_raw\250128_Hela_1ng_nDIA_3ms_R2.raw --f Z:\Download\timsread\Fig2A-E_raw\250128_Hela_1ng_nDIA_3ms_R3.raw --lib  --threads 12 --verbose 1 --out Z:\Download\timsread\Fig2A-E_raw\reportng.export-quant.parquet --qvalue 0.01 --no-rt-window --out-lib Z:\Download\timsread\Fig2A-E_raw\libng.export-quant.parquet --gen-spec-lib --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta Z:\Download\UP000005640_9606_unique_gene.fasta --pre-search --pre-filter --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 2 --max-pr-charge 4 --min-fr-mz 200 --max-fr-mz 1800 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:7,0.984016,NQ --var-mod UniMod:1,42.010565,*n --window 10 --mass-acc 10 --mass-acc-ms1 10 --mass-acc-cal 15 --individual-mass-acc --individual-windows --proteoforms --reanalyse --rt-profiling --direct-quant --global-norm --original-mods --export-quant
:: diann.exe --f Z:\Download\timsread\Fig2A-E_raw\250128_Hela_1ng_nDIA_3ms_R1.raw --f Z:\Download\timsread\Fig2A-E_raw\250128_Hela_1ng_nDIA_3ms_R2.raw --f Z:\Download\timsread\Fig2A-E_raw\250128_Hela_1ng_nDIA_3ms_R3.raw --lib  --threads 12 --verbose 1 --out Z:\Download\timsread\Fig2A-E_raw\reportng.export-quant.parquet --qvalue 0.01 --matrices --no-rt-window --out-lib Z:\Download\timsread\Fig2A-E_raw\libng.export-quant.parquet --gen-spec-lib --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta Z:\Download\UP000005640_9606_unique_gene.fasta --pre-search --pre-filter --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 2 --max-pr-charge 4 --min-fr-mz 200 --max-fr-mz 1800 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:7,0.984016,NQ --var-mod UniMod:1,42.010565,*n --window 10 --mass-acc 10 --mass-acc-ms1 10 --mass-acc-cal 15 --individual-mass-acc --individual-windows --proteoforms --reanalyse --rt-profiling --direct-quant --global-norm --original-mods --export-quant
:: F:
:: cd F:\DIA-NN\2.2.0\
:: diann.exe --f "F:\HeLaDIA\260528_200ngHelaQC_DIA_newQC_Slot1-54_1_13749.d" --lib "L:\promec\FastaDB\humanMC2V3defaults.predicted.speclib" --threads 8 --verbose 1 --out "F:\HeLaDIA\260528_200ngHelaQC_DIA_newQC_Slot1-54_1_13749.d.report.parquet" --qvalue 0.01 --matrices  --out-lib "F:\HeLaDIA\260528_200ngHelaQC_DIA_newQC_Slot1-54_1_13749.d.report-lib.parquet" --gen-spec-lib --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "L:\promec\FastaDB\UP000005640_9606_1protein1gene.fasta" --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --individual-mass-acc --individual-windows --peptidoforms --rt-profiling --direct-quant  --original-mods --export-quant
:: runDIANN.bat F:\promec\TIMSTOF\LARS\2026\260518_Sonali 64 --high-acc
:: DIA-NN 2.2.0 Academia  (Data-Independent Acquisition by Neural Networks) Compiled on May 29 2025 21:29:29 Current date and time: Tue Aug  5 09:36:11 2025 CPU: GenuineIntel Intel(R) Xeon(R) CPU E5-2683 v4 @ 2.10GHz SIMD instructions: AVX AVX2 FMA SSE4.1 SSE4.2 Logical CPU cores: 64 Thread number set to 32 Output will be filtered at 0.01 FDR Precursor/protein x samples expression level matrices will be saved along with the main report A spectral library will be generated
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
for  %%i in ("%dataDir%\*.raw") do set /a dirCount+=1

if %dirCount%==0 exit /b 1

for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "timestamp=%dt:~2,2%%dt:~4,2%%dt:~6,2%_%dt:~8,2%%dt:~10,2%%dt:~12,2%"

set outputDir=%dataDir%\DIANNv2P2.%dirCount%.%timestamp%.%NCPU%.!dirMode!
mkdir "%outputDir%" 2>nul

set fileList=
for %%i in ("%dataDir%\*.raw") do set fileList=!fileList! --f "%%i"

cd "C:\Program Files\DIA-NN\2.2.0\"

set diannCmd=diann.exe!fileList!  --lib "F:\promec\FastaDB\humanMC2V3defaults.predicted.speclib" --threads %NCPU% --verbose 1 --out "!outputDir!\report.parquet" --qvalue 0.01 --matrices --out-lib "!outputDir!\report-lib.parquet" --gen-spec-lib --reannotate --fasta "camprotR_240512_cRAP_20190401_full_tags.fasta" --cont-quant-exclude cRAP- --fasta "F:\promec\FastaDB\UP000005640_9606_1protein1gene.fasta"  --min-fr-mz 200 --max-fr-mz 1800  --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --mass-acc 10.0 --mass-acc-ms1 10.0 --window 10 --peptidoforms --reanalyse --rt-profiling --original-mods  --export-quant

if not "%mode%"=="" set diannCmd=!diannCmd! %mode%

!diannCmd!
