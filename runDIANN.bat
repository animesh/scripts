:: runDIANN.bat "F:\promec\TIMSTOF\LARS\2021\SEPTEMBER\SUDHL5 silac\210920 SILAC DIA" 64 --high-acc
:: Single DIA-NN command processing all *.d directories with SILAC labels
:: Usage: runDIANN_SILAC.bat <dataDir> <NCPU> [mode]
:: DIA-NN 2.2.0 Academia  (Data-Independent Acquisition by Neural Networks) Compiled on May 29 2025 21:29:29 Current date and time: Tue Aug  5 09:36:11 2025 CPU: GenuineIntel Intel(R) Xeon(R) CPU E5-2683 v4 @ 2.10GHz SIMD instructions: AVX AVX2 FMA SSE4.1 SSE4.2 Logical CPU cores: 64 Thread number set to 32 Output will be filtered at 0.01 FDR Precursor/protein x samples expression level matrices will be saved along with the main report A spectral library will be generated
:: wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000005640/UP000005640_9606.fasta.gz
:: gunzip UP000005640_9606.fasta.gz
:: copy UP000005640_9606.fasta F:\promec\FastaDB\UP000005640_9606_unique_gene.fasta
::  mkdir -p promec/promec/TIMSTOF/LARS/2021/SEPTEMBER/SUDHL5\ silac/210920\ SILAC\ DIA
::  rsync -Parv ash022@login.nird-lmd.sigma2.no:TIMSTOF/LARS/2021/SEPTEMBER/SUDHL5*silac/210920*SILAC*DIA/*.d /home/animeshs/promec/promec/TIMSTOF/LARS/2021/SEPTEMBER/SUDHL5\ silac/210920\ SILAC\ DIA/
::  mkdir -p promec/promec/TIMSTOF/LARS/2021/SEPTEMBER/SILAC\ DIA
::   rsync -Parv ash022@login.nird-lmd.sigma2.no:TIMSTOF/LARS/2021/SEPTEMBER/SILAC*DIA/*.d /home/animeshs/promec/promec/TIMSTOF/LARS/2021/SEPTEMBER/SILAC\ DIA/
:: diann.exe --f "F:\promec\TIMSTOF\LARS\2021\SEPTEMBER\SUDHL5 silac\210920 SILAC DIA\210920 sudhl5 tot 1 dia_Slot1-28_1_234.d" --f "F:\promec\TIMSTOF\LARS\2021\SEPTEMBER\SUDHL5 silac\210920 SILAC DIA\210920 sudhl5 tot 2 dia_Slot1-29_1_235.d" --f "F:\promec\TIMSTOF\LARS\2021\SEPTEMBER\SUDHL5 silac\210920 SILAC DIA\210920 sudhl5 tot 3 dia_Slot1-30_1_236.d" --lib "F:\promec\FastaDB\UP000005640_9606_unique_gene_MC2V3.predicted.predicted.speclib" --threads 32 --verbose 1 --out "F:\promec\TIMSTOF\LARS\2021\SEPTEMBER\SUDHL5 silac\210920 SILAC DIA\210920 sudhl5 tot 1 dia_Slot1-28_1_234.d\DIANNv2p2\report.parquet" --qvalue 0.01 --matrices  --out-lib "F:\promec\TIMSTOF\LARS\2021\SEPTEMBER\SUDHL5 silac\210920 SILAC DIA\210920 sudhl5 tot 1 dia_Slot1-28_1_234.d\DIANNv2p2\replib.parquet" --gen-spec-lib --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "F:\promec\FastaDB\UP000005640_9606_unique_gene.fasta" --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --mass-acc 15.0 --mass-acc-ms1 15.0 --peptidoforms --reanalyse --rt-profiling --high-acc  --fixed-mod SILAC,0.0,KR,label --lib-fixed-mod SILAC --channels SILAC,L,KR,0:0; SILAC,H,KR,8.014199:10.008269 --original-mods  --channel-spec-nor
@echo off
setlocal enabledelayedexpansion

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

set diannCmd=diann.exe!fileList! --lib "F:\promec\FastaDB\UP000005640_9606_unique_gene_MC2V3.predicted.predicted.speclib" --threads %NCPU% --verbose 1 --out "%outputDir%\report.parquet" --qvalue 0.01 --matrices --out-lib "%outputDir%\replib.parquet" --gen-spec-lib --reannotate --fasta "camprotR_240512_cRAP_20190401_full_tags.fasta" --cont-quant-exclude cRAP- --fasta "F:\promec\FastaDB\UP000005640_9606_unique_gene.fasta" --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --mass-acc 15.0 --mass-acc-ms1 15.0 --peptidoforms --reanalyse --rt-profiling --fixed-mod SILAC,0.0,KR,label --lib-fixed-mod SILAC --channels "SILAC,L,KR,0:0; SILAC,H,KR,8.014199:10.008269" --original-mods --channel-spec-nor

if not "%mode%"=="" set diannCmd=!diannCmd! %mode%

!diannCmd!
