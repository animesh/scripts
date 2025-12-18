::runDIANN_HeLa.bat "F:\HeLaC" 4
:: https://github.com/vdemichev/DiaNN/releases/tag/2.0 windows "https://release-assets.githubusercontent.com/github-production-release-asset/125283280/0a11e496-e188-450d-9d29-4cfb2d0cc6a3?sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-12-10T15%3A17%3A07Z&rscd=attachment%3B+filename%3DDIA-NN-2.3.1-Academia.msi&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-12-10T14%3A16%3A56Z&ske=2025-12-10T15%3A17%3A07Z&sks=b&skv=2018-11-09&sig=a2fjoSaV1xWStza6OgSZ%2BJ9IuQWshvmxcVxvQehSSo8%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2NTM4MDMyOCwibmJmIjoxNzY1Mzc2NzI4LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.6Oky5SLqxAluKT_5gf0zhYbQ_CZABZ59rvagSDwv11Y&response-content-disposition=attachment%3B%20filename%3DDIA-NN-2.3.1-Academia.msi&response-content-type=application%2Foctet-stream"
:: https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000005640/UP000005640_9606.fasta.gz
:: fasta https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000005640/UP000005640_9606.fasta.gz
:: data L:\promec\TIMSTOF\LARS\2025\251216_Preethi
@echo off
setlocal enabledelayedexpansion
SET "dataDir=%~1"
SET "NCPU=%~2"
if "%dataDir%"=="" SET "dataDir=F:\HeLaC"
if "%NCPU%"=="" SET "NCPU=4"
:: diann.exe
:: DIA-NN 2.3.1 Academia  (Data-Independent Acquisition by Neural Networks)
:: Compiled on Dec  5 2025 10:52:39
:: Current date and time: Fri Dec 12 11:03:44 2025
:: CPU: GenuineIntel Intel(R) Xeon(R) CPU E5-2643 v3 @ 3.40GHz
:: SIMD instructions: AVX AVX2 FMA SSE4.1 SSE4.2
:: Logical CPU cores: 24
:: 91Gb out of 127Gb RAM is free
:: WARNING: protein inference is enabled but no FASTA provided - is this intended?
:: How to cite:
:: using DIA-NN: Demichev et al, Nature Methods, 2020, https://www.nature.com/articles/s41592-019-0638-x
:: analysing Scanning SWATH: Messner et al, Nature Biotechnology, 2021, https://www.nature.com/articles/s41587-021-00860-4
:: analysing PTMs: Steger et al, Nature Communications, 2021, https://www.nature.com/articles/s41467-021-25454-1
:: analysing dia-PASEF: Demichev et al, Nature Communications, 2022, https://www.nature.com/articles/s41467-022-31492-0
:: analysing Slice-PASEF: Szyrwiel et al, biorxiv, 2022, https://doi.org/10.1101/2022.10.31.514544
:: plexDIA / multiplexed DIA: Derks et al, Nature Biotechnology, 2023, https://www.nature.com/articles/s41587-022-01389-w
:: CysQuant: Huang et al, Redox Biology, 2023, https://doi.org/10.1016/j.redox.2023.102908
:: using QuantUMS: Kistner at al, biorxiv, 2023, https://doi.org/10.1101/2023.06.20.545604
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "timestamp=%dt:~2,2%%dt:~4,2%%dt:~6,2%_%dt:~8,2%%dt:~10,2%%dt:~12,2%"
for /d %%i in ("%dataDir%\*.d") do (
set outputDir=%%i.DIANNv2P2.%timestamp%.%NCPU%
mkdir "!outputDir!" 2>nul
F:
cd F:\DIA-NN\2.3.1\
start "DIANN.%%i" diann.exe --f "%%i" --lib "" --threads %NCPU% --verbose 1 --out "!outputDir!\report.parquet" --qvalue 0.01 --matrices --out-lib "!outputDir!\report-lib.parquet" --gen-spec-lib --reannotate --fasta "camprotR_240512_cRAP_20190401_full_tags.fasta" --cont-quant-exclude cRAP- --fasta "F:\UP000005640_9606.fasta" --pre-search --pre-filter --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --min-fr-mz 200 --max-fr-mz 1800 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:7,0.984016,NQ --var-mod UniMod:1,42.010565,*n --mass-acc 15 --mass-acc-ms1 15 --individual-mass-acc --individual-windows --peptidoforms --rt-profiling --reanalyse
C:
cd c:\Users\animeshs\scripts
)
