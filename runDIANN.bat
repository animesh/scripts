:: runDIANN.bat "F:\promec\TIMSTOF\LARS\2021\SEPTEMBER\SILAC DIA" 64 --high-acc
:: Single DIA-NN command processing all *.d directories with SILAC labels
:: Usage: runDIANN_SILAC.bat <dataDir> <NCPU> [mode]
:: wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000005640/UP000005640_9606.fasta.gz
:: gunzip UP000005640_9606.fasta.gz
:: copy UP000005640_9606.fasta F:\promec\FastaDB\UP000005640_9606_unique_gene.fasta
::  mkdir -p promec/promec/TIMSTOF/LARS/2021/SEPTEMBER/SILAC\ DIA
::   rsync -Parv ash022@login.nird-lmd.sigma2.no:TIMSTOF/LARS/2021/SEPTEMBER/SILAC*DIA/*.d /home/animeshs/promec/promec/TIMSTOF/LARS/2021/SEPTEMBER/SILAC\ DIA/
:: diann.exe --threads 64 --verbose 1 --out "F:\promec\FastaDB\UP000005640_9606_unique_gene_MC2V3ppm15.phos.predicted.speclib.parquet" --qvalue 0.01 --out-lib "F:\promec\FastaDB\UP000005640_9606_unique_gene_MC2V3ppm15.phos.predicted.speclib" --gen-spec-lib --predictor --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "F:\promec\FastaDB\UP000005640_9606_unique_gene.fasta" --fasta-search --min-fr-mz 200 --max-fr-mz 1800 --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --var-mod UniMod:21,79.966331,STY --mass-acc 15.0 --mass-acc-ms1 15.0 --peptidoforms --rt-profiling --high-acc

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

set diannCmd=diann.exe!fileList! --lib "F:\promec\FastaDB\UP000005640_9606_unique_gene_MC2V3ppm15.phos.predicted.predicted.speclib" --threads %NCPU% --verbose 1 --out "%outputDir%\report.parquet" --qvalue 0.01 --matrices --out-lib "%outputDir%\replib.parquet" --gen-spec-lib --reannotate --fasta "camprotR_240512_cRAP_20190401_full_tags.fasta" --cont-quant-exclude cRAP- --fasta "F:\promec\FastaDB\UP000005640_9606_unique_gene.fasta" --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --var-mod UniMod:21,79.966331,STY --mass-acc 15.0 --mass-acc-ms1 15.0 --peptidoforms --reanalyse --rt-profiling --fixed-mod SILAC,0.0,KR,label --lib-fixed-mod SILAC --channels "SILAC,L,KR,0:0; SILAC,H,KR,8.014199:10.008269" --original-mods --channel-spec-nor

if not "%mode%"=="" set diannCmd=!diannCmd! %mode%

!diannCmd!


:: DIA-NN 2.2.0 Academia  (Data-Independent Acquisition by Neural Networks)
:: Compiled on May 29 2025 21:29:29
:: Current date and time: Thu Sep 18 10:29:01 2025
:: CPU: GenuineIntel Intel(R) Xeon(R) CPU E5-2683 v4 @ 2.10GHz
:: SIMD instructions: AVX AVX2 FMA SSE4.1 SSE4.2
:: Logical CPU cores: 64
:: Thread number set to 64
:: Output will be filtered at 0.01 FDR
:: A spectral library will be generated
:: Deep learning will be used to generate a new in silico spectral library from peptides provided
:: Peptides corresponding to protein sequence IDs tagged with cRAP- will be excluded from normalisation as well as quantification of protein groups that do not include proteins bearing the tag
:: DIA-NN will carry out FASTA digest for in silico lib generation
:: Min fragment m/z set to 200
:: Max fragment m/z set to 1800
:: N-terminal methionine excision enabled
:: Min peptide length set to 7
:: Max peptide length set to 30
:: Min precursor m/z set to 300
:: Max precursor m/z set to 1800
:: Min precursor charge set to 1
:: Max precursor charge set to 4
:: In silico digest will involve cuts at K*,R*
:: Maximum number of missed cleavages set to 2
:: Cysteine carbamidomethylation enabled as a fixed modification
:: Maximum number of variable modifications set to 3
:: Modification UniMod:35 with mass delta 15.9949 at M will be considered as variable
:: Modification UniMod:1 with mass delta 42.0106 at *n will be considered as variable
:: Modification UniMod:21 with mass delta 79.9663 at STY will be considered as variable
:: Peptidoform scoring enabled
:: The spectral library (if generated) will retain the original spectra but will include empirically-aligned RTs
:: High accuracy quantification mode enabled
:: Mass accuracy will be fixed to 1.5e-05 (MS2) and 1.5e-05 (MS1)
:: The following variable modifications will be localised: UniMod:35 UniMod:1 UniMod:21
:: 
:: 0 files will be processed
:: [0:00] Loading FASTA camprotR_240512_cRAP_20190401_full_tags.fasta
:: [0:00] Loading FASTA F:\promec\FastaDB\UP000005640_9606_unique_gene.fasta
:: [0:31] Processing FASTA
:: [3:14] Assembling elution groups
:: [6:53] 100805208 precursors generated
:: [6:53] Gene names missing for some isoforms
:: [6:53] Library contains 20747 proteins, and 20470 genes
:: [10:03] Encoding peptides for spectra and RTs prediction
:: [17:44] Predicting spectra and IMs
:: [227:51] Predicting RTs
:: [243:14] Decoding predicted spectra and IMs
:: [245:21] Decoding RTs
:: [246:17] Saving the library to F:\promec\FastaDB\UP000005640_9606_unique_gene_MC2V3ppm15.phos.predicted.predicted.speclib
:: [250:24] Initialising library
:: Finished
:: 
:: 
:: How to cite:
:: using DIA-NN: Demichev et al, Nature Methods, 2020, https://www.nature.com/articles/s41592-019-0638-x
:: analysing Scanning SWATH: Messner et al, Nature Biotechnology, 2021, https://www.nature.com/articles/s41587-021-00860-4
:: analysing PTMs: Steger et al, Nature Communications, 2021, https://www.nature.com/articles/s41467-021-25454-1
:: analysing dia-PASEF: Demichev et al, Nature Communications, 2022, https://www.nature.com/articles/s41467-022-31492-0
:: analysing Slice-PASEF: Szyrwiel et al, biorxiv, 2022, https://doi.org/10.1101/2022.10.31.514544
:: plexDIA / multiplexed DIA: Derks et al, Nature Biotechnology, 2023, https://www.nature.com/articles/s41587-022-01389-w
:: CysQuant: Huang et al, Redox Biology, 2023, https://doi.org/10.1016/j.redox.2023.102908
:: using QuantUMS: Kistner at al, biorxiv, 2023, https://doi.org/10.1101/2023.06.20.545604

