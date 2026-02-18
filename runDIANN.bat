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
::diann.exe --lib "" --threads 12 --verbose 1 --out "L:\promec\FastaDB\Araport11_pep_20250411.uniprot.MC2V3.parquet" --qvalue 0.01 --matrices  --out-lib "L:\Araport11_pep_20250411.uniprot.MC2V3lib.parquet" --gen-spec-lib --predictor --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "L:\promec\TIMSTOF\LARS\2025\251103_STEVEN\Araport11_pep_20250411.uniprot.fasta" --fasta "L:\promec\TIMSTOF\LARS\2025\251103_STEVEN\Araport11_pep_20250411_representative_gene_model.uniprot.fasta" --fasta "L:\promec\FastaDB\GFP.fasta" --fasta "L:\promec\FastaDB\uniprotkb_proteome_UP000006548_2025_11_06.fasta" --fasta-search --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --min-fr-mz 200 --max-fr-mz 1800 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:7,0.984016,NQ --var-mod UniMod:1,42.010565,*n --mass-acc 15 --mass-acc-ms1 15 --peptidoforms --reanalyse --rt-profiling  
::diann.exe --f "L:\promec\TIMSTOF\LARS\2026\260211_Steven\260211_Steven_9_Slot1-9_1_12869.d" --f "L:\promec\TIMSTOF\LARS\2026\260211_Steven\260211_Steven_8_Slot1-8_1_12868.d" --f "L:\promec\TIMSTOF\LARS\2026\260211_Steven\260211_Steven_7_Slot1-7_1_12867.d" --f "L:\promec\TIMSTOF\LARS\2026\260211_Steven\260211_Steven_6_Slot1-6_1_12866.d" --f "L:\promec\TIMSTOF\LARS\2026\260211_Steven\260211_Steven_5_Slot1-5_1_12865.d" --f "L:\promec\TIMSTOF\LARS\2026\260211_Steven\260211_Steven_4_Slot1-4_1_12864.d" --f "L:\promec\TIMSTOF\LARS\2026\260211_Steven\260211_Steven_3_Slot1-3_1_12863.d" --f "L:\promec\TIMSTOF\LARS\2026\260211_Steven\260211_Steven_32_Slot1-32_1_12856.d" --f "L:\promec\TIMSTOF\LARS\2026\260211_Steven\260211_Steven_31_Slot1-31_1_12855.d" --f "L:\promec\TIMSTOF\LARS\2026\260211_Steven\260211_Steven_30_Slot1-30_1_12854.d" --f "L:\promec\TIMSTOF\LARS\2026\260211_Steven\260211_Steven_2_Slot1-2_1_12862.d" --f "L:\promec\TIMSTOF\LARS\2026\260211_Steven\260211_Steven_29_Slot1-29_1_12853.d" --f "L:\promec\TIMSTOF\LARS\2026\260211_Steven\260211_Steven_28_Slot1-28_1_12852.d" --f "L:\promec\TIMSTOF\LARS\2026\260211_Steven\260211_Steven_27_Slot1-27_1_12851.d" --f "L:\promec\TIMSTOF\LARS\2026\260211_Steven\260211_Steven_26_Slot1-26_1_12850.d" --f "L:\promec\TIMSTOF\LARS\2026\260211_Steven\260211_Steven_25_Slot1-25_1_12849.d" --f "L:\promec\TIMSTOF\LARS\2026\260211_Steven\260211_Steven_24_Slot1-24_1_12848.d" --f "L:\promec\TIMSTOF\LARS\2026\260211_Steven\260211_Steven_23_Slot1-23_1_12847.d" --f "L:\promec\TIMSTOF\LARS\2026\260211_Steven\260211_Steven_22_Slot1-22_1_12846.d" --f "L:\promec\TIMSTOF\LARS\2026\260211_Steven\260211_Steven_21_Slot1-21_1_12845.d" --f "L:\promec\TIMSTOF\LARS\2026\260211_Steven\260211_Steven_20_Slot1-20_1_12841.d" --f "L:\promec\TIMSTOF\LARS\2026\260211_Steven\260211_Steven_1_Slot1-1_1_12861.d" --f "L:\promec\TIMSTOF\LARS\2026\260211_Steven\260211_Steven_19_Slot1-19_1_12840.d" --f "L:\promec\TIMSTOF\LARS\2026\260211_Steven\260211_Steven_18_Slot1-18_1_12839.d" --f "L:\promec\TIMSTOF\LARS\2026\260211_Steven\260211_Steven_17_Slot1-17_1_12838.d" --f "L:\promec\TIMSTOF\LARS\2026\260211_Steven\260211_Steven_16_Slot1-16_1_12837.d" --f "L:\promec\TIMSTOF\LARS\2026\260211_Steven\260211_Steven_15_Slot1-15_1_12836.d" --f "L:\promec\TIMSTOF\LARS\2026\260211_Steven\260211_Steven_14_Slot1-14_1_12835.d" --f "L:\promec\TIMSTOF\LARS\2026\260211_Steven\260211_Steven_13_Slot1-13_1_12834.d" --f "L:\promec\TIMSTOF\LARS\2026\260211_Steven\260211_Steven_12_Slot1-12_1_12833.d" --f "L:\promec\TIMSTOF\LARS\2026\260211_Steven\260211_Steven_11_Slot1-11_1_12832.d" --f "L:\promec\TIMSTOF\LARS\2026\260211_Steven\260211_Steven_10_Slot1-10_1_12870.d" --lib "L:\promec\FastaDB\uniprotkb_proteome_UP000001449_2026_01_09MC2V3dwfaults.predicted.speclib" --threads 12 --verbose 1 --out "L:\promec\TIMSTOF\LARS\2026\260211_Steven\report.parquet" --qvalue 0.01 --matrices  --out-lib "L:\promec\TIMSTOF\LARS\2026\260211_Steven\report-lib.parquet" --gen-spec-lib --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "L:\promec\TIMSTOF\LARS\2025\251103_STEVEN\Araport11_pep_20250411.uniprot.fasta" --fasta "L:\promec\TIMSTOF\LARS\2025\251103_STEVEN\Araport11_pep_20250411_representative_gene_model.uniprot.fasta" --fasta "L:\promec\FastaDB\GFP.fasta" --fasta "L:\promec\FastaDB\uniprotkb_proteome_UP000006548_2025_11_06.fasta" --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --min-fr-mz 200 --max-fr-mz 1800 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:7,0.984016,NQ --var-mod UniMod:1,42.010565,*n --mass-acc 15 --mass-acc-ms1 15 --peptidoforms --reanalyse --rt-profiling --high-acc  