:: DIA-NN 2.2.0 Academia  (Data-Independent Acquisition by Neural Networks) Compiled on May 29 2025 21:29:29 Current date and time: Tue Aug  5 09:36:11 2025 CPU: GenuineIntel Intel(R) Xeon(R) CPU E5-2683 v4 @ 2.10GHz SIMD instructions: AVX AVX2 FMA SSE4.1 SSE4.2 Logical CPU cores: 64 Thread number set to 32 Output will be filtered at 0.01 FDR Precursor/protein x samples expression level matrices will be saved along with the main report A spectral library will be generated
:: wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000005640/UP000005640_9606.fasta.gz
:: gunzip UP000005640_9606.fasta.gz
:: copy UP000005640_9606.fasta F:\promec\FastaDB\UP000005640_9606_unique_gene.fasta
SET workDir=%cd%
set DATADIR=F:\promec\TIMSTOF\LARS\2025\250812_prm\DIA
set NCPU=32
for /d %%i in (%DATADIR%\250812_mix1_104_DIA*.d) do (
  cd "C:\Program Files\DIA-NN\2.2.0\"
  :: diann.exe --lib "" --threads 32 --verbose 1 --out "F:\promec\FastaDB\UP000005640_9606_unique_gene_MC2V3.parquet" --qvalue 0.01 --out-lib "F:\promec\FastaDB\UP000005640_9606_unique_gene_MC2V3.predicted.speclib" --gen-spec-lib --predictor --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "F:\promec\FastaDB\UP000005640_9606_unique_gene.fasta" --met-excision --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --mass-acc 20.0 --mass-acc-ms1 20  --rt-profiling --fasta-search
  mkdir  %%i.DIANNv2P2%NCPU%
  start "DIANNv2P2%NCPU%.%%i" diann.exe  --f  %%i --lib "F:\promec\FastaDB\UP000005640_9606_unique_gene_MC2V3.predicted.predicted.speclib" --threads %NCPU% --verbose 1 --out %%i.DIANNv2P2%NCPU%\report.parquet --qvalue 0.01 --matrices  --out-lib %%i.DIANNv2P2%NCPU%\report-lib.parquet --gen-spec-lib --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "F:\promec\FastaDB\UP000005640_9606_unique_gene.fasta" --met-excision --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --mass-acc 20.0 --mass-acc-ms1 20 --peptidoforms --rt-profiling --fixed-mod SILAC,0.0,KR,label --lib-fixed-mod SILAC --channels SILAC,L,KR,0:0; SILAC,H,KR,8.014199:10.008269 --original-mods  --channel-spec-norm  
  dir %%i.DIANNv2P2%NCPU%
  cd %workDir%
)
