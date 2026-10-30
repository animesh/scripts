:: git checkout 9612b5063996f260134b0052c20d028549d46b42 runDIANN.bat
:: runDIANN.bat F:\promec\TIMSTOF\LARS\2026\260904_Lilith 64 --high-acc
:: DIA-NN 2.2.0 Academia  (Data-Independent Acquisition by Neural Networks) Compiled on May 29 2025 21:29:29 Current date and time: Tue Aug  5 09:36:11 2025 CPU: GenuineIntel Intel(R) Xeon(R) CPU E5-2683 v4 @ 2.10GHz SIMD instructions: AVX AVX2 FMA SSE4.1 SSE4.2 Logical CPU cores: 64 Thread number set to 32 Output will be filtered at 0.01 FDR Precursor/protein x samples expression level matrices will be saved along with the main report A spectral library will be generated
:: wget "https://rest.uniprot.org/uniprotkb/stream?download=true&format=fasta&includeIsoform=true&query=%28%28proteome%3AUP000000589%29%29"
:: add >APC_MOUSE_ApcMin_p.L850* https://www.informatics.jax.org/allele/MGI:1856318#:~:text=A%20transversion%20point%20mutation%20that%20alters%20nucleotide%202549%20from%20a%20T%20to%20an%20A%20(mRNA%3A%20NM_001360980.1%3B%20protein%3A%20NM_007462.3).%20This%20converts%20codon%20850%20from%20one%20encoding%20a%20leucine%20to%20a%20stop%20codon%20(p.Leu850*)%2C%20truncating%20the%20expected%20polypeptide.%20(J%3A830)
:: diann.exe --lib "" --threads 64 --verbose 1 --out "F:\promec\FastaDB\mouseL850apc.parquet" --qvalue 0.01 --matrices  --out-lib "F:\promec\FastaDB\mouseL850apc.parquet" --gen-spec-lib --predictor --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "F:\promec\FastaDB\uniprotkb_proteome_UP000000589_2026_10_28.APC_MOUSE_ApcMin_p.L850.fasta" --fasta-search --min-fr-mz 200 --max-fr-mz 1800 --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --window 20 --mass-acc 20.0 --mass-acc-ms1 20 --individual-mass-acc --individual-windows --peptidoforms --reanalyse --rt-profiling
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

set diannCmd=diann.exe!fileList!  --lib "F:\promec\FastaDB\mouseL850apc.predicted.speclib" --threads %NCPU% --verbose 1 --out "!outputDir!\report.parquet" --qvalue 0.01 --matrices --out-lib "!outputDir!\report-lib.parquet" --gen-spec-lib --reannotate --fasta "camprotR_240512_cRAP_20190401_full_tags.fasta" --cont-quant-exclude cRAP- --fasta "F:\promec\FastaDB\uniprotkb_proteome_UP000000589_2026_10_28.APC_MOUSE_ApcMin_p.L850.fasta" --min-fr-mz 200 --max-fr-mz 1800  --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --mass-acc 20.0 --mass-acc-ms1 20 --peptidoforms --reanalyse --rt-profiling

if not "%mode%"=="" set diannCmd=!diannCmd! %mode%

!diannCmd!
:: diann.exe --f "F:\promec\TIMSTOF\LARS\2026\260904_Lilith\260904_Lilith_5467_E_Slot2-22_1_14424.d" --f "F:\promec\TIMSTOF\LARS\2026\260904_Lilith\260904_Lilith_5467_LPSM_Slot2-23_1_14425.d" --f "F:\promec\TIMSTOF\LARS\2026\260904_Lilith\260904_Lilith_5467_MP_Slot2-24_1_14426.d" --f "F:\promec\TIMSTOF\LARS\2026\260904_Lilith\260904_Lilith_5468_E_Slot2-19_1_14419.d" --f "F:\promec\TIMSTOF\LARS\2026\260904_Lilith\260904_Lilith_5468_LPSM_Slot2-20_1_14420.d" --f "F:\promec\TIMSTOF\LARS\2026\260904_Lilith\260904_Lilith_5468_MP_Slot2-21_1_14423.d" --f "F:\promec\TIMSTOF\LARS\2026\260904_Lilith\260904_Lilith_5469_E_Slot2-25_1_14428.d" --f "F:\promec\TIMSTOF\LARS\2026\260904_Lilith\260904_Lilith_5469_LPSM_Slot2-26_1_14429.d" --f "F:\promec\TIMSTOF\LARS\2026\260904_Lilith\260904_Lilith_5469_MP_Slot2-27_1_14430.d" --f "F:\promec\TIMSTOF\LARS\2026\260904_Lilith\260904_Lilith_5472_E_Slot2-28_1_14432.d" --f "F:\promec\TIMSTOF\LARS\2026\260904_Lilith\260904_Lilith_5472_LPSM_Slot2-29_1_14433.d" --f "F:\promec\TIMSTOF\LARS\2026\260904_Lilith\260904_Lilith_5472_MP_Slot2-30_1_14434.d" --lib "F:\promec\FastaDB\mouseL850apc.predicted.speclib" --threads 64 --verbose 1 --out "F:\promec\TIMSTOF\LARS\2026\260904_Lilith\DIANNv2p2\report.parquet" --qvalue 0.01 --matrices  --out-lib "F:\promec\TIMSTOF\LARS\2026\260904_Lilith\DIANNv2p2\lib.parquet" --gen-spec-lib --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "F:\promec\FastaDB\uniprotkb_proteome_UP000000589_2026_10_28.APC_MOUSE_ApcMin_p.L850.fasta" --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --mass-acc 20.0 --mass-acc-ms1 20 --peptidoforms --reanalyse --rt-profiling

