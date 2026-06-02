:: runDIANN.bat L:\promec\TIMSTOF\LARS\2026\260528_barbara 21 --high-acc
:: DIA-NN 2.5.1 Academia  (Data-Independent Acquisition by Neural Networks) Compiled on Apr 30 2026 08:14:29 Current date and time: Tue Jun  2 14:43:37 2026 
:: CPU: GenuineIntel Intel(R) Xeon(R) CPU E5-2683 v4 @ 2.10GHz SIMD instructions: AVX AVX2 FMA SSE4.1 SSE4.2 Logical CPU cores: 64 Thread number set to 32 Output will be filtered at 0.01 FDR Precursor/protein x samples expression level matrices will be saved along with the main report A spectral library will be generated
:: wget https://rest.uniprot.org/uniprotkb/stream?download=true&format=fasta&includeIsoform=true&query=%28%28proteome%3AUP000005640%29%29 -o "L:\promec\FastaDB\uniprotkb_proteome_UP000005640_2026_06_02.fasta"
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

cd "F:\DIA-NN\2.5.1"

set diannCmd=diann.exe!fileList!  --lib "L:\promec\FastaDB\humanv2p5p1MC2V3dNQdefaults.predicted.speclib" --threads %NCPU% --verbose 1 --out "!outputDir!\report.parquet" --qvalue 0.01 --matrices --out-lib "!outputDir!\report-lib.parquet" --gen-spec-lib --reannotate --fasta "camprotR_240512_cRAP_20190401_full_tags.fasta" --cont-quant-exclude cRAP- --fasta "L:\promec\FastaDB\uniprotkb_proteome_UP000005640_2026_06_02.fasta" --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --min-fr-mz 200 --max-fr-mz 1800 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:7,0.984016,NQ --var-mod UniMod:1,42.010565,*n --mass-acc 15 --mass-acc-ms1 15 --peptidoforms --reanalyse --rt-profiling --original-mods

if not "%mode%"=="" set diannCmd=!diannCmd! %mode%

!diannCmd!
::diann.exe --lib  --threads 24 --verbose 1 --out  --qvalue 0.01 --matrices --out-lib L:\promec\FastaDB\humanv2p5p1MC2V3dNQdefaults.parquet --gen-spec-lib --predictor --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta L:\promec\FastaDB\uniprotkb_proteome_UP000005640_2026_06_02.fasta --fasta-search --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --min-fr-mz 200 --max-fr-mz 1800 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:7,0.984016,NQ --var-mod UniMod:1,42.010565,*n --rt-profiling --high-acc --original-mods
::diann.exe --f L:\promec\TIMSTOF\LARS\2026\260528_barbara\260528_Barbara_1_Slot2-1_1_13751.d --f L:\promec\TIMSTOF\LARS\2026\260528_barbara\260528_Barbara_10_Slot2-10_1_13769.d --f L:\promec\TIMSTOF\LARS\2026\260528_barbara\260528_Barbara_11_Slot2-11_1_13774.d --f L:\promec\TIMSTOF\LARS\2026\260528_barbara\260528_Barbara_12_Slot2-12_1_13776.d --f L:\promec\TIMSTOF\LARS\2026\260528_barbara\260528_Barbara_13_Slot2-13_1_13778.d --f L:\promec\TIMSTOF\LARS\2026\260528_barbara\260528_Barbara_14_Slot2-14_1_13780.d --f L:\promec\TIMSTOF\LARS\2026\260528_barbara\260528_Barbara_15_Slot2-15_1_13782.d --f L:\promec\TIMSTOF\LARS\2026\260528_barbara\260528_Barbara_16_Slot2-16_1_13784.d --f L:\promec\TIMSTOF\LARS\2026\260528_barbara\260528_Barbara_17_Slot2-17_1_13786.d --f L:\promec\TIMSTOF\LARS\2026\260528_barbara\260528_Barbara_18_Slot2-18_1_13788.d --f L:\promec\TIMSTOF\LARS\2026\260528_barbara\260528_Barbara_19_Slot2-19_1_13790.d --f L:\promec\TIMSTOF\LARS\2026\260528_barbara\260528_Barbara_2_Slot2-2_1_13753.d --f L:\promec\TIMSTOF\LARS\2026\260528_barbara\260528_Barbara_20_Slot2-20_1_13792.d --f L:\promec\TIMSTOF\LARS\2026\260528_barbara\260528_Barbara_21_Slot2-21_1_13794.d --f L:\promec\TIMSTOF\LARS\2026\260528_barbara\260528_Barbara_3_Slot2-3_1_13755.d --f L:\promec\TIMSTOF\LARS\2026\260528_barbara\260528_Barbara_4_Slot2-4_1_13757.d --f L:\promec\TIMSTOF\LARS\2026\260528_barbara\260528_Barbara_5_Slot2-5_1_13759.d --f L:\promec\TIMSTOF\LARS\2026\260528_barbara\260528_Barbara_6_Slot2-6_1_13761.d --f L:\promec\TIMSTOF\LARS\2026\260528_barbara\260528_Barbara_7_Slot2-7_1_13763.d --f L:\promec\TIMSTOF\LARS\2026\260528_barbara\260528_Barbara_8_Slot2-8_1_13765.d --f L:\promec\TIMSTOF\LARS\2026\260528_barbara\260528_Barbara_9_Slot2-9_1_13767.d --lib L:\promec\FastaDB\humanv2p5p1MC2V3dNQdefaults.predicted.speclib --threads 21 --verbose 1 --out L:\promec\TIMSTOF\LARS\2026\260528_barbara\report.v2p5p1.human.ha.parquet --qvalue 0.01 --matrices --out-lib L:\promec\TIMSTOF\LARS\2026\260528_barbara\lib.parquet --gen-spec-lib --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta L:\promec\FastaDB\uniprotkb_proteome_UP000005640_2026_06_02.fasta --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --min-fr-mz 200 --max-fr-mz 1800 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:7,0.984016,NQ --var-mod UniMod:1,42.010565,*n --mass-acc 15 --mass-acc-ms1 15 --peptidoforms --reanalyse --rt-profiling --high-acc --original-mods