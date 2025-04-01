:: DIA-NN 2.0 Academia  (Data-Independent Acquisition by Neural Networks) Compiled on Jan 28 2025 11:23:41 https://github.com/vdemichev/DiaNN?tab=readme-ov-file#command-line-reference https://objects.githubusercontent.com/github-production-release-asset-2e65be/125283280/609eca14-5f92-4a2e-a5cf-985c43002c7a?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=releaseassetproduction%2F20250131%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250131T075203Z&X-Amz-Expires=300&X-Amz-Signature=0ba04ad7cd80eb35cd2c10104b17bdd3c95937940bedc7bebe158812b11ffed3&X-Amz-SignedHeaders=host&response-content-disposition=attachment%3B%20filename%3DDIA-NN-2.0-Academia.msi&response-content-type=application%2Foctet-stream
:: wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000005640/UP000005640_9606.fasta.gz
:: gunzip UP000005640_9606.fasta.gz
:: copy UP000005640_9606.fasta F:\promec\FastaDB\UP000005640_9606_unique_gene.fasta
SET workDir=%cd%
set DATADIR="F:\promec\TIMSTOF\LARS\2025\250329_DIA_Hela"
set NCPU=4
for /d %%i in (%DATADIR%\250327_HELA*.d) do (
  cd "C:\Program Files\DIA-NN\2.1.0\"
  :: diann.exe --lib "" --threads %NCPU% --verbose 1 --out "F:\promec\FastaDB\UP000005640_9606_unique_gene_C24_MC1_P735_MZ1001700_Mod3.parquet" --qvalue 0.01 --matrices  --out-lib "F:\promec\FastaDB\UP000005640_9606_unique_gene_C24_MC1_P735_MZ1001700_Mod3.predicted.speclib" --gen-spec-lib --predictor --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "F:\promec\FastaDB\UP000005640_9606_unique_gene.fasta" --fasta-search --min-fr-mz 100 --max-fr-mz 1700 --met-excision --min-pep-len 7 --max-pep-len 35 --min-pr-mz 100 --max-pr-mz 1700 --min-pr-charge 2 --max-pr-charge 4 --cut K*,R* --missed-cleavages 1 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --mass-acc 20.0 --mass-acc-ms1 20 --individual-mass-acc --individual-windows --peptidoforms --reanalyse --rt-profiling
  mkdir  %%i.DIANNv2P%NCPU%
  start "DIANNv2P%NCPU%.%%i" diann.exe  --f  %%i --lib "F:\promec\FastaDB\UP000005640_9606_unique_gene_C24_MC1_P735_MZ1001700_Mod3.predicted.speclib" --threads %NCPU% --verbose 1 --out %%i.DIANNv2P%NCPU%\report.parquet --qvalue 0.01 --matrices  --out-lib %%i.DIANNv2P%NCPU%\report-lib.parquet --gen-spec-lib --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "F:\promec\FastaDB\UP000005640_9606_unique_gene.fasta" --met-excision --min-pep-len 7 --max-pep-len 35 --min-pr-mz 100 --max-pr-mz 1700 --min-pr-charge 2 --max-pr-charge 4 --cut K*,R* --missed-cleavages 1 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --mass-acc 20.0 --mass-acc-ms1 20 --individual-mass-acc --individual-windows --peptidoforms --reanalyse --rt-profiling
  dir %%i.DIANNv2P%NCPU%
  cd %workDir%
)
