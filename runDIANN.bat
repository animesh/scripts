#DIA-NN 1.9.2 (Data-Independent Acquisition by Neural Networks) update https://github.com/vdemichev/DiaNN/releases/tag/1.9.2
cd "C:\Program Files\DIA-NN\1.9.2"
#https://github.com/vdemichev/DiaNN?tab=readme-ov-file#command-line-reference
#wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000005640/UP000005640_9606.fasta.gz
#gunzip UP000005640_9606.fasta.gz
#mv UP000005640_9606.fasta UP000005640_9606_unique_gene.fasta
wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Bacteria/UP000000625/UP000000625_83333.fasta.gz
gunzip UP000000625_83333.fasta.gz
mv UP000000625_83333.fasta UP000000625_83333_unique_gene.fasta
cat UP000005640_9606_unique_gene.fasta UP000000625_83333_unique_gene.fasta > UP000005640_9606_UP000000625_83333_unique_gene.fasta
mv UP000005640_9606_UP000000625_83333_unique_gene.fasta F:\promec\FastaDB\UP000005640_9606_UP000000625_83333_unique_gene.fasta
diann.exe --threads 64 --verbose 1 --out "F:\promec\FastaDB\UP000005640_9606_UP000000625_83333_unique_gene_MC1_L35_C57_vMod3_MZ117.report.tsv" --gen-spec-lib --predictor --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --fasta "F:\promec\FastaDB\UP000005640_9606_UP000000625_83333_unique_gene.fasta" --fasta-search --min-fr-mz 100 --max-fr-mz 1700 --met-excision --min-pep-len 7 --max-pep-len 35 --min-pr-mz 100 --max-pr-mz 1700 --min-pr-charge 2 --max-pr-charge 4 --cut K*,R* --missed-cleavages 1 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --peptidoforms
for /d %i in ("F:\promec\TIMSTOF\LARS\2024\241219_Hela_DDA_DIA\dia\241217_20ngHelaQC_DIAc_Slot1*.d") do (DiaNN.exe --f %i --out %i.UP000005640_9606_UP000000625_83333_unique_gene_MC1_L35_C57_vMod3_MZ117.diann.tsv  --lib "F:\promec\FastaDB\UP000005640_9606_UP000000625_83333_unique_gene_MC1_L35_C57_vMod3_MZ117.report-lib.predicted.speclib" --threads 64 --verbose 1 --qvalue 0.01 --matrices  --min-corr 2.0 --corr-diff 1.0 --time-corr-only --min-fr-mz 100 --max-fr-mz 1700 --met-excision --min-pep-len 7 --max-pep-len 35 --min-pr-mz 100 --max-pr-mz 1700 --min-pr-charge 2 --max-pr-charge 4 --cut K*,R* --missed-cleavages 1  --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --peptidoforms --direct-quant --no-norm --no-maxlfq --mass-acc 20.0 --mass-acc-ms1 20  --export-quant --no-fr-selection  --reannotate --fasta "F:\promec\FastaDB\UP000005640_9606_UP000000625_83333_unique_gene.fasta" --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP)
DiaNN.exe --f F:\promec\TIMSTOF\LARS\2024\241219_Hela_DDA_DIA\dia\241217_20ngHelaQC_DIAc_Slot1-28_1_9292.d --f F:\promec\TIMSTOF\LARS\2024\241219_Hela_DDA_DIA\dia\241217_20ngHelaQC_DIAb_Slot1-28_1_9290.d --f F:\promec\TIMSTOF\LARS\2024\241219_Hela_DDA_DIA\dia\241217_20ngHelaQC_DIAa_Slot1-28_1_9288.d --out F:\promec\TIMSTOF\LARS\2024\241219_Hela_DDA_DIA\dia\241217_20ngHelaQC_DIAcba.UP000005640_9606_UP000000625_83333_unique_gene_MC1_L35_C57_vMod3_MZ117.diann.tsv  --lib "F:\promec\FastaDB\UP000005640_9606_UP000000625_83333_unique_gene_MC1_L35_C57_vMod3_MZ117.report-lib.predicted.speclib" --threads 64 --verbose 1 --qvalue 0.01 --matrices  --min-corr 2.0 --corr-diff 1.0 --time-corr-only --min-fr-mz 100 --max-fr-mz 1700 --met-excision --min-pep-len 7 --max-pep-len 35 --min-pr-mz 100 --max-pr-mz 1700 --min-pr-charge 2 --max-pr-charge 4 --cut K*,R* --missed-cleavages 1  --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --peptidoforms --direct-quant --no-norm --no-maxlfq --mass-acc 20.0 --mass-acc-ms1 20  --export-quant --no-fr-selection  --reannotate --fasta "F:\promec\FastaDB\UP000005640_9606_UP000000625_83333_unique_gene.fasta" --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP
#filter 241217_20ngHelaQC_DIAcba.UP000005640_9606_UP000000625_83333_unique_gene_MC1_L35_C57_vMod3_MZ117.diann.tsv calculated above for 241217_20ngHelaQC_DIAc_Slot1* and respective Precursod.id's Quantity should match with those calculated in penultimate line, more at https://github.com/vdemichev/DiaNN/issues/1317
