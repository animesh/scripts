@echo off
:: fix from https://claude.ai/share/17edbd27-098f-432b-b48e-ccb421318621
:: install https://github.com/vdemichev/DiaNN/releases/download/2.0/DIA-NN-2.1.0-Academia.msi
:: download and gunzip https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000005640/UP000005640_9606.fasta.gz
:: move UP000005640_9606.fasta F:\promec\FastaDB\UP000005640_9606_unique_gene.fasta

SET workDir=%cd%
SET NCPU=64
SET CAMPROTPATH=camprotR_240512_cRAP_20190401_full_tags.fasta

cd "C:\Program Files\DIA-NN\2.1.0\"

:: First command - Generate spectral library
diann.exe --lib "" ^
 --threads %NCPU% ^
 --verbose 1 ^
 --out "F:\promec\FastaDB\UP000005640_9606_unique_gene.met.acet.fixprop.report.parquet" ^
 --qvalue 0.01 ^
 --matrices ^
 --out-lib "F:\promec\FastaDB\UP000005640_9606_unique_gene.met.acet.fixprop.report-lib.parquet" ^
 --gen-spec-lib ^
 --predictor ^
 --reannotate ^
 --fasta "%CAMPROTPATH%" ^
 --cont-quant-exclude cRAP- ^
 --fasta "F:\promec\FastaDB\UP000005640_9606_unique_gene.fasta" ^
 --fasta-search ^
 --min-fr-mz 100 ^
 --max-fr-mz 1700 ^
 --met-excision ^
 --min-pep-len 7 ^
 --max-pep-len 35 ^
 --min-pr-mz 100 ^
 --max-pr-mz 1700 ^
 --min-pr-charge 2 ^
 --max-pr-charge 4 ^
 --cut K*,R* ^
 --missed-cleavages 2 ^
 --unimod4 --fixed-mod UniMod:58,56.026215,n ^
 --var-mods 3 ^
 --var-mod UniMod:35,15.994915,M ^
 --var-mod UniMod:1,42.010565,K ^
 --var-mod UniMod:209,112.052430,K ^
 --var-mod UniMod:34,14.015650,K ^
 --var-mod UniMod:36,28.031300,K ^
 --var-mod UniMod:37,42.046950,K ^
 --mass-acc 15 ^
 --mass-acc-ms1 15 ^
 --individual-mass-acc ^
 --individual-windows ^
 --proteoforms ^
 --no-cut-after-mod UniMod:58 ^
 --reanalyse ^
 --rt-profiling

:: Second command - Process samples
diann.exe ^
 --f "F:\promec\TIMSTOF\LARS\2025\250411_HISTONE_SAHA\250411_HISTONE_CTR_DIA_A_Slot1-23_1_10160.d" ^
 --f "F:\promec\TIMSTOF\LARS\2025\250411_HISTONE_SAHA\250411_HISTONE_CTR_DIA_B_Slot1-23_1_10164.d" ^
 --f "F:\promec\TIMSTOF\LARS\2025\250411_HISTONE_SAHA\250411_HISTONE_CTR_DIA_C_Slot1-23_1_10168.d" ^
 --f "F:\promec\TIMSTOF\LARS\2025\250411_HISTONE_SAHA\250411_HISTONE_SAHA_DIA_A_Slot1-24_1_10162.d" ^
 --f "F:\promec\TIMSTOF\LARS\2025\250411_HISTONE_SAHA\250411_HISTONE_SAHA_DIA_B_Slot1-24_1_10166.d" ^
 --f "F:\promec\TIMSTOF\LARS\2025\250411_HISTONE_SAHA\250411_HISTONE_SAHA_DIA_C_Slot1-24_1_10170.d" ^
 --lib "F:\promec\FastaDB\UP000005640_9606_unique_gene.met.acet.fixprop.report-lib.predicted.speclib" ^
 --threads %NCPU% ^
 --verbose 1 ^
 --out "F:\promec\TIMSTOF\LARS\2025\250411_HISTONE_SAHA\DIANN2p1\met.acet.report.parquet" ^
 --qvalue 0.01 ^
 --matrices ^
 --out-lib "F:\promec\TIMSTOF\LARS\2025\250411_HISTONE_SAHA\DIANN2p1\met.acet.fixprop.lib.parquet" ^
 --fasta "%CAMPROTPATH%" ^
 --cont-quant-exclude cRAP- ^
 --fasta "F:\promec\FastaDB\UP000005640_9606_unique_gene.fasta" ^
 --min-fr-mz 100 ^
 --max-fr-mz 1700 ^
 --met-excision ^
 --min-pep-len 7 ^
 --max-pep-len 35 ^
 --min-pr-mz 100 ^
 --max-pr-mz 1700 ^
 --min-pr-charge 2 ^
 --max-pr-charge 4 ^
 --cut K*,R* ^
 --missed-cleavages 2 ^
 --unimod4 --fixed-mod UniMod:58,56.026215,n ^
 --var-mods 3 ^
 --var-mod UniMod:35,15.994915,M ^
 --var-mod UniMod:1,42.010565,K ^
 --var-mod UniMod:209,112.052430,K ^
 --var-mod UniMod:34,14.015650,K ^
 --var-mod UniMod:36,28.031300,K ^
 --var-mod UniMod:37,42.046950,K ^
 --mass-acc 15 ^
 --mass-acc-ms1 15 ^
 --proteoforms ^
 --no-cut-after-mod UniMod:58 ^
 --reanalyse ^
 --rt-profiling

cd %workDir%
