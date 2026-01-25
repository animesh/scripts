::git checkout a2a792eaf00c362f92c45cc15107ce9f31692d51 runDIANN.bat
::C:\Users\animeshs\OneDrive\Desktop\Scripts>runDIANN.bat F:\promec\TIMSTOF\LARS\2026\260107_Tore 64 --high-acc
:: DIA-NN 2.2.0 Academia  (Data-Independent Acquisition by Neural Networks) Compiled on May 29 2025 21:29:29 Current date and time: Tue Aug  5 09:36:11 2025 CPU: GenuineIntel Intel(R) Xeon(R) CPU E5-2683 v4 @ 2.10GHz SIMD instructions: AVX AVX2 FMA SSE4.1 SSE4.2 Logical CPU cores: 64 Thread number set to 32 Output will be filtered at 0.01 FDR Precursor/protein x samples expression level matrices will be saved along with the main report A spectral library will be generated
:: wget "https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000000589/UP000000589_10090.fasta.gz"https://rest.uniprot.org/uniprotkb/stream?download=true&format=fasta&query=%28%28proteome%3AUP000001449%29%29"

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

set diannCmd=diann.exe !fileList!  --lib "F:\promec\TIMSTOF\LARS\2026\260107_Tore\Thalassiosira_pseudonana_PASA-proteins_uniprot.MC1V3.predicted.speclib" --threads %NCPU% --verbose 1 --out "!outputDir!\report.parquet" --qvalue 0.01 --matrices --out-lib "!outputDir!\report-lib.parquet" --gen-spec-lib --reannotate --fasta "camprotR_240512_cRAP_20190401_full_tags.fasta" --cont-quant-exclude cRAP- --fasta "F:\promec\TIMSTOF\LARS\2026\260107_Tore\Thalassiosira_pseudonana_PASA-proteins_uniprot.fasta" --min-fr-mz 200 --max-fr-mz 1800 --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --cut K*,R* --missed-cleavages 1 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --var-mod UniMod:21,79.966331,STY --mass-acc 20.0 --mass-acc-ms1 20 --peptidoforms --reanalyse --rt-profiling 

if not "%mode%"=="" set diannCmd=!diannCmd! %mode%

!diannCmd!
::diann.exe --lib "" --threads 32 --verbose 1 --out "L:\promec\TIMSTOF\LARS\2026\260107_Tore\Thalassiosira_pseudonana_PASA-proteins_uniprot.report.parquet" --qvalue 0.01 --matrices  --out-lib "L:\promec\TIMSTOF\LARS\2026\260107_Tore\Thalassiosira_pseudonana_PASA-proteins_uniprot.MC1V3.parquet" --gen-spec-lib --predictor --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "L:\promec\TIMSTOF\LARS\2026\260107_Tore\Thalassiosira_pseudonana_PASA-proteins_uniprot.fasta" --fasta-search --min-fr-mz 200 --max-fr-mz 1800 --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --cut K*,R* --missed-cleavages 1 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --var-mod UniMod:21,79.966331,STY --mass-acc 20.0 --mass-acc-ms1 20 --peptidoforms --reanalyse --rt-profiling 
:: diann.exe --f "L:\promec\TIMSTOF\LARS\2026\260107_Tore\260107_Tore_15_5_Slot1-15_1_12397.d " --lib "L:\promec\TIMSTOF\LARS\2026\260107_Tore\Thalassiosira_pseudonana_PASA-proteins_uniprot.MC1V3.predicted.speclib" --threads 32 --verbose 1 --out "L:\promec\TIMSTOF\LARS\2026\260107_Tore\260107_Tore_15_5_Slot1-15_1_12397.dreport.parquet" --qvalue 0.01 --matrices  --out-lib "L:\promec\TIMSTOF\LARS\2026\260107_Tore\260107_Tore_15_5_Slot1-15_1_12397.dreplib.parquet" --gen-spec-lib --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "L:\promec\TIMSTOF\LARS\2026\260107_Tore\Thalassiosira_pseudonana_PASA-proteins_uniprot.fasta" --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --cut K*,R* --missed-cleavages 1 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --var-mod UniMod:21,79.966331,STY --mass-acc 20.0 --mass-acc-ms1 20 --peptidoforms --reanalyse --rt-profiling 