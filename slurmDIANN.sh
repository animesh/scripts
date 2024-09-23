#module --ignore_cache load DIA-NN/1.9
#wget "https://rest.uniprot.org/uniprotkb/stream?download=true&format=fasta&includeIsoform=true&query=%28%28proteome%3AUP000005640%29%29"
cd c:\Program Files\DIA-NN\1.9
diann.exe --lib "" " --threads 16 --verbose 1 --out "L:\promec\FastaDB\uniprotkb_proteome_UP000005640_2024_04_18.fasta.report.tsv" --qvalue 0.01 --matrices  --out-lib "L:\promec\FastaDB\uniprotkb_proteome_UP000005640_2024_04_18.fasta.report-lib.tsv" --gen-spec-lib --predictor --fasta "C:\Program Files\DIA-NN\1.9\camprotR_240512_cRAP_20190401_full_tags.fasta" --cont-quant-exclude cRAP- --fasta "L:\promec\FastaDB\uniprotkb_proteome_UP000005640_2024_04_18.fasta" --fasta-search --min-fr-mz 200 --max-fr-mz 2000 --met-excision --min-pep-len 7 --max-pep-len 35 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 1 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --peptidoforms --reanalyse --relaxed-prot-inf --rt-profiling
diann.exe --f "L:\promec\TIMSTOF\LARS\2024\240827_Bead_test\240827_Beads_3C_DIA_Slot2-21_1_8153.d" --f "L:\promec\TIMSTOF\LARS\2024\240827_Bead_test\240827_Beads_9C_DIA_Slot2-27_1_8165.d" --f "L:\promec\TIMSTOF\LARS\2024\240827_Bead_test\240827_Beads_9B_DIA_Slot2-26_1_8163.d" --f "L:\promec\TIMSTOF\LARS\2024\240827_Bead_test\240827_Beads_9A_DIA_Slot2-25_1_8161.d" --f "L:\promec\TIMSTOF\LARS\2024\240827_Bead_test\240827_Beads_7C_DIA_Slot2-24_1_8159.d" --f "L:\promec\TIMSTOF\LARS\2024\240827_Bead_test\240827_Beads_7B_DIA_Slot2-23_1_8157.d" --f "L:\promec\TIMSTOF\LARS\2024\240827_Bead_test\240827_Beads_7A_DIA_Slot2-22_1_8155.d" --f "L:\promec\TIMSTOF\LARS\2024\240827_Bead_test\240827_Beads_3B_DIA_Slot2-20_1_8151.d" --f "L:\promec\TIMSTOF\LARS\2024\240827_Bead_test\240827_Beads_3A_DIA_Slot2-19_1_8149.d" " --lib "L:\promec\FastaDB\uniprotkb_proteome_UP000005640_2024_04_18.fasta.report-lib.predicted.speclib" --threads 36 --verbose 1 --out "L:\promec\TIMSTOF\LARS\2024\240918_hela_test_dda_dia\bead-report-gene-high-acc.tsv" --qvalue 0.01 --matrices --min-corr 2.0 --corr-diff 1.0 --time-corr-only --out-lib L:\promec\TIMSTOF\LARS\2024\240918_hela_test_dda_dia\humanbeads.tsv --gen-spec-lib --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --unimod4 --var-mods 5 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --mass-acc 20 --mass-acc-ms1 20 --peptidoforms --reanalyse --relaxed-prot-inf --rt-profiling --high-acc --pg-level 0
#gene
diann.exe --f "L:\promec\TIMSTOF\LARS\2024\240827_Bead_test\240827_Beads_9C_DIA_Slot2-27_1_8165.d
" --f "L:\promec\TIMSTOF\LARS\2024\240827_Bead_test\240827_Beads_7B_DIA_Slot2-23_1_8157.d
" --f "L:\promec\TIMSTOF\LARS\2024\240827_Bead_test\240827_Beads_3A_DIA_Slot2-19_1_8149.d
" --lib "L:\promec\FastaDB\uniprotkb_proteome_UP000005640_2024_04_18.fasta.report-lib.predicted.speclib" --threads 12 --verbose 1 --out "L:\promec\TIMSTOF\LARS\2024\240822_Maike_dilution\DIANNv1p9\reportHA.tsv" --qvalue 0.01 --matrices  --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --unimod4 --var-mods 5 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --mass-acc 15 --mass-acc-ms1 20 --peptidoforms --relaxed-prot-inf --rt-profiling --high-acc
#prteinnames
diann.exe --f "L:\promec\TIMSTOF\LARS\2024\240827_Bead_test\240827_Beads_9C_DIA_Slot2-27_1_8165.d
" --f "L:\promec\TIMSTOF\LARS\2024\240827_Bead_test\240827_Beads_7B_DIA_Slot2-23_1_8157.d
" --f "L:\promec\TIMSTOF\LARS\2024\240827_Bead_test\240827_Beads_3A_DIA_Slot2-19_1_8149.d
" --lib "L:\promec\FastaDB\uniprotkb_proteome_UP000005640_2024_04_18.fasta.report-lib.predicted.speclib" --threads 12 --verbose 1 --out "L:\promec\TIMSTOF\LARS\2024\240822_Maike_dilution\DIANNv1p9\reportHA.tsv" --qvalue 0.01 --matrices  --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --unimod4 --var-mods 5 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --mass-acc 15 --mass-acc-ms1 20 --peptidoforms --relaxed-prot-inf --rt-profiling --pg-level 1 --direct-quant
#isoform
diann.exe --f "L:\promec\TIMSTOF\LARS\2024\240827_Bead_test\240827_Beads_9C_DIA_Slot2-27_1_8165.d
" --f "L:\promec\TIMSTOF\LARS\2024\240827_Bead_test\240827_Beads_7B_DIA_Slot2-23_1_8157.d
" --f "L:\promec\TIMSTOF\LARS\2024\240827_Bead_test\240827_Beads_3A_DIA_Slot2-19_1_8149.d
" --lib "L:\promec\FastaDB\uniprotkb_proteome_UP000005640_2024_04_18.fasta.report-lib.predicted.speclib" --threads 12 --verbose 1 --out "L:\promec\TIMSTOF\LARS\2024\240822_Maike_dilution\DIANNv1p9\reportHA.tsv" --qvalue 0.01 --matrices  --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --unimod4 --var-mods 5 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --mass-acc 15 --mass-acc-ms1 20 --peptidoforms --relaxed-prot-inf --rt-profiling --pg-level 0 --direct-quant
#legacy
diann.exe --lib "L:\promec\FastaDB\uniprotkb_proteome_UP000005640_2024_04_18.fasta.report-lib.predicted.speclib" --threads 20 --verbose 5 --out "L:\promec\TIMSTOF\LARS\2024\240918_hela_test_dda_dia\reportHeLAdoses.tsv" --qvalue 0.01 --matrices  --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "L:\promec\FastaDB\uniprotkb_proteome_UP000005640_2024_04_18.fasta" --met-excision --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 1 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --mass-acc 20.0 --mass-acc-ms1 20.0 --individual-mass-acc --individual-windows --peptidoforms --relaxed-prot-inf --rt-profiling --pg-level 0 --direct-quant
#heLaQuant
diann.exe --f "L:\promec\TIMSTOF\LARS\2024\240918_hela_test_dda_dia\hela_1_1_dia_a_S1-B1_1_8361.d" --f "L:\promec\TIMSTOF\LARS\2024\240918_hela_test_dda_dia\hela_1_1_dia_b_S1-B6_1_8366.d" --f "L:\promec\TIMSTOF\LARS\2024\240918_hela_test_dda_dia\hela_1_2_dia_a_S1-B2_1_8362.d" --f "L:\promec\TIMSTOF\LARS\2024\240918_hela_test_dda_dia\hela_1_2_dia_b_S1-B7_1_8367.d" --f "L:\promec\TIMSTOF\LARS\2024\240918_hela_test_dda_dia\hela_1_4_dia_a_S1-B3_1_8363.d" --f "L:\promec\TIMSTOF\LARS\2024\240918_hela_test_dda_dia\hela_1_4_dia_b_S1-B8_1_8368.d" --f "L:\promec\TIMSTOF\LARS\2024\240918_hela_test_dda_dia\hela_1_8_dia_a_S1-B4_1_8364.d" --f "L:\promec\TIMSTOF\LARS\2024\240918_hela_test_dda_dia\hela_1_8_dia_b_S1-B9_1_8369.d" --f "L:\promec\TIMSTOF\LARS\2024\240918_hela_test_dda_dia\hela_1_16_dia_a_S1-B5_1_8365.d" --f "L:\promec\TIMSTOF\LARS\2024\240918_hela_test_dda_dia\hela_1_16_dia_b_S1-B10_1_8370.d" --lib "L:\promec\FastaDB\uniprotkb_proteome_UP000005640_2024_04_18.fasta.report-lib.predicted.speclib" --threads 30 --verbose 1 --out "C:\Users\animeshs\DIANN\hela-report-gene-high-acc.tsv" --qvalue 0.01 --matrices --min-corr 2.0 --corr-diff 1.0 --time-corr-only --out-lib C:\Users\animeshs\DIANN\helaConc.tsv --gen-spec-lib --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --unimod4 --var-mods 5 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --mass-acc 20 --mass-acc-ms1 20 --peptidoforms --reanalyse --relaxed-prot-inf --rt-profiling --high-acc --pg-level 0
