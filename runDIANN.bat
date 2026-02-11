:: git checkout 82f089aafbfca8e41405fd8b5fb1a80fbd76419f runDIANN.bat
:: runDIANN.bat F:\promec\TIMSTOF\LARS\2026\260126_Marianne_Nymark 64 --high-acc
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
for /d %%i in ("%dataDir%\*.d") do set /a dirCount+=1

if %dirCount%==0 exit /b 1

for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "timestamp=%dt:~2,2%%dt:~4,2%%dt:~6,2%_%dt:~8,2%%dt:~10,2%%dt:~12,2%"

set outputDir=%dataDir%\DIANNv2P2.%dirCount%.%timestamp%.SILAC.%NCPU%.!dirMode!
mkdir "%outputDir%" 2>nul

set fileList=
for /d %%i in ("%dataDir%\*.d") do set fileList=!fileList! --f "%%i"

cd "C:\Program Files\DIA-NN\2.2.0\"

set diannCmd=diann.exe!fileList!  --lib "F:\promec\TIMSTOF\LARS\2026\260126_Marianne_Nymark.UP000000759_2026_01_30.predicted.speclib" --threads %NCPU% --verbose 1 --out "!outputDir!\report.parquet" --qvalue 0.01 --matrices --out-lib "!outputDir!\report-lib.parquet" --gen-spec-lib --reannotate --fasta "camprotR_240512_cRAP_20190401_full_tags.fasta" --cont-quant-exclude cRAP- --fasta "F:\promec\TIMSTOF\LARS\2026\260126_Marianne_Nymark\uniprotkb_proteome_UP000000759_2026_01_30.fasta" --min-fr-mz 200 --max-fr-mz 1800  --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --mass-acc 20.0 --mass-acc-ms1 20 --peptidoforms --reanalyse --rt-profiling

if not "%mode%"=="" set diannCmd=!diannCmd! %mode%

!diannCmd!
::diann.exe --f "F:\promec\TIMSTOF\LARS\2026\260129_ToreBrembuPHOS\ToreB_8\260129_ToreBrembuPHOS_1b_Slot1-1_1_12737.d" --f "F:\promec\TIMSTOF\LARS\2026\260129_ToreBrembuPHOS\ToreB_8\260129_ToreBrembuPHOS_1b_Slot1-1_1_12781.d" --f "F:\promec\TIMSTOF\LARS\2026\260129_ToreBrembuPHOS\ToreB_8\260129_ToreBrembuPHOS_2b_Slot1-2_1_12738.d" --f "F:\promec\TIMSTOF\LARS\2026\260129_ToreBrembuPHOS\ToreB_8\260129_ToreBrembuPHOS_3b_Slot1-3_1_12740.d" --f "F:\promec\TIMSTOF\LARS\2026\260129_ToreBrembuPHOS\ToreB_8\260129_ToreBrembuPHOS_4b_Slot1-4_1_12741.d" --f "F:\promec\TIMSTOF\LARS\2026\260129_ToreBrembuPHOS\ToreB_8\260129_ToreBrembuPHOS_5b_Slot1-5_1_12745.d" --f "F:\promec\TIMSTOF\LARS\2026\260129_ToreBrembuPHOS\ToreB_8\260129_ToreBrembuPHOS_6b_Slot1-6_1_12746.d" --f "F:\promec\TIMSTOF\LARS\2026\260129_ToreBrembuPHOS\ToreB_8\260129_ToreBrembuPHOS_7b_Slot1-7_1_12747.d" --f "F:\promec\TIMSTOF\LARS\2026\260129_ToreBrembuPHOS\ToreB_8\260129_ToreBrembuPHOS_8b_Slot1-8_1_12748.d" --f "F:\promec\TIMSTOF\LARS\2026\260129_ToreBrembuPHOS\ToreB_8\260129_ToreBrembuPHOS_9b_Slot1-9_1_12749.d" --f "F:\promec\TIMSTOF\LARS\2026\260129_ToreBrembuPHOS\ToreB_8\260129_ToreBrembuPHOS_10b_Slot1-10_1_12750.d" --f "F:\promec\TIMSTOF\LARS\2026\260129_ToreBrembuPHOS\ToreB_8\260129_ToreBrembuPHOS_11b_Slot1-11_1_12754.d" --f "F:\promec\TIMSTOF\LARS\2026\260129_ToreBrembuPHOS\ToreB_8\260129_ToreBrembuPHOS_12b_Slot1-12_1_12755.d" --f "F:\promec\TIMSTOF\LARS\2026\260129_ToreBrembuPHOS\ToreB_8\260129_ToreBrembuPHOS_13b_Slot1-13_1_12756.d" --f "F:\promec\TIMSTOF\LARS\2026\260129_ToreBrembuPHOS\ToreB_8\260129_ToreBrembuPHOS_14b_Slot1-14_1_12757.d" --f "F:\promec\TIMSTOF\LARS\2026\260129_ToreBrembuPHOS\ToreB_8\260129_ToreBrembuPHOS_15b_Slot1-15_1_12758.d" --f "F:\promec\TIMSTOF\LARS\2026\260129_ToreBrembuPHOS\ToreB_8\260129_ToreBrembuPHOS_16b_Slot1-16_1_12759.d" --f "F:\promec\TIMSTOF\LARS\2026\260129_ToreBrembuPHOS\ToreB_8\260129_ToreBrembuPHOS_17b_Slot1-17_1_12760.d" --f "F:\promec\TIMSTOF\LARS\2026\260129_ToreBrembuPHOS\ToreB_8\260129_ToreBrembuPHOS_18b_Slot1-18_1_12761.d" --f "F:\promec\TIMSTOF\LARS\2026\260129_ToreBrembuPHOS\ToreB_8\260129_ToreBrembuPHOS_19b_Slot1-19_1_12762.d" --f "F:\promec\TIMSTOF\LARS\2026\260129_ToreBrembuPHOS\ToreB_8\260129_ToreBrembuPHOS_20b_Slot1-20_1_12763.d" --f "F:\promec\TIMSTOF\LARS\2026\260129_ToreBrembuPHOS\ToreB_8\260129_ToreBrembuPHOS_21b_Slot1-21_1_12767.d" --f "F:\promec\TIMSTOF\LARS\2026\260129_ToreBrembuPHOS\ToreB_8\260129_ToreBrembuPHOS_22b_Slot1-22_1_12768.d" --f "F:\promec\TIMSTOF\LARS\2026\260129_ToreBrembuPHOS\ToreB_8\260129_ToreBrembuPHOS_23b_Slot1-23_1_12769.d" --f "F:\promec\TIMSTOF\LARS\2026\260129_ToreBrembuPHOS\ToreB_8\260129_ToreBrembuPHOS_24b_Slot1-24_1_12770.d" --f "F:\promec\TIMSTOF\LARS\2026\260129_ToreBrembuPHOS\ToreB_8\260129_ToreBrembuPHOS_25b_Slot1-25_1_12771.d" --f "F:\promec\TIMSTOF\LARS\2026\260129_ToreBrembuPHOS\ToreB_8\260129_ToreBrembuPHOS_26b_Slot1-26_1_12772.d" --f "F:\promec\TIMSTOF\LARS\2026\260129_ToreBrembuPHOS\ToreB_8\260129_ToreBrembuPHOS_27b_Slot1-27_1_12773.d" --f "F:\promec\TIMSTOF\LARS\2026\260129_ToreBrembuPHOS\ToreB_8\260129_ToreBrembuPHOS_28b_Slot1-28_1_12774.d" --f "F:\promec\TIMSTOF\LARS\2026\260129_ToreBrembuPHOS\ToreB_8\260129_ToreBrembuPHOS_29b_Slot1-29_1_12775.d" --f "F:\promec\TIMSTOF\LARS\2026\260129_ToreBrembuPHOS\ToreB_8\260129_ToreBrembuPHOS_30b_Slot1-30_1_12776.d" --lib "F:\promec\TIMSTOF\LARS\2026\260107_Tore\Thalassiosira_pseudonana_PASA-proteins_uniprot.MC1V3.predicted.speclib" --threads 32 --verbose 1 --out "F:\promec\TIMSTOF\LARS\2026\260129_ToreBrembuPHOS\ToreB_8\report.parquet" --qvalue 0.01 --matrices  --out-lib "F:\promec\TIMSTOF\LARS\2026\260129_ToreBrembuPHOS\ToreB_8\report-lib.parquet" --gen-spec-lib --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "F:\promec\TIMSTOF\LARS\2026\260107_Tore\Thalassiosira_pseudonana_PASA-proteins_uniprot.fasta" --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --cut K*,R* --missed-cleavages 1 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --var-mod UniMod:21,79.966331,STY --mass-acc 20.0 --mass-acc-ms1 20 --peptidoforms --reanalyse --rt-profiling --high-acc
