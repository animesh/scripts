module --ignore_cache load DIA-NN/1.8.1
#wget "https://rest.uniprot.org/uniprotkb/stream?download=true&format=fasta&includeIsoform=true&query=%28%28proteome%3AUP000000589%29%29" -O mouse.fasta
#diann-1.8.1 --lib "" --threads 12 --verbose 1 --out "mouse-report.tsv" --qvalue 0.01 --matrices  --out-lib "mouse-report-lib.tsv" --gen-spec-lib --predictor --fasta /cluster/projects/nn9036k/FastaDB/camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "mouse.fasta" --fasta-search --min-fr-mz 200 --max-fr-mz 1800 --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 5 --var-mod UniMod:1,42.010565,*n --peptidoforms --reanalyse --relaxed-prot-inf --rt-profiling 
#c:\DIA-NN\1.9\DiaNN.exe --f "C:\Users\animeshs\libDIA\240222_Maike_test1_dia_Slot1-10_1_6601.d " --f "C:\Users\animeshs\libDIA\240222_Maike_test2_dia_Slot1-11_1_6603.d" --f "C:\Users\animeshs\libDIA\240222_Maike_test3_dia_Slot1-12_1_6605.d" --f "C:\Users\animeshs\libDIA\240222_Maike_test4_dia_Slot1-13_1_6607.d" --f "C:\Users\animeshs\libDIA\240222_Maike_test5_dia_Slot1-14_1_6609.d" --lib "F:\OneDrive - NTNU\Desktop\mouse-report-lib.predicted.speclib" --threads 5 --verbose 1 --out "C:\Users\animeshs\libDIA\DIANN\mouse-report.tsv" --qvalue 0.01 --matrices  --min-corr 2.0 --corr-diff 1.0 --time-corr-only --out-lib "C:\Users\animeshs\libDIA\DIANN\mouse.tsv" --gen-spec-lib --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --unimod4 --var-mods 5 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --mass-acc 20 --mass-acc-ms1 20 --peptidoforms --reanalyse --relaxed-prot-inf --rt-profiling --pg-level 0
diann.exe --f "/cluster/work/users/ash022/mDIA/240222_Kamilla_Maike_9_dia_Slot1-27_1_6681.d
" --f "/cluster/work/users/ash022/mDIA/240222_Kamilla_Maike_8_dia_Slot1-26_1_6679.d
" --f "/cluster/work/users/ash022/mDIA/240222_Kamilla_Maike_7_dia_Slot1-25_1_6677.d
" --f "/cluster/work/users/ash022/mDIA/240222_Kamilla_Maike_6_dia_Slot1-24_1_6634.d
" --f "/cluster/work/users/ash022/mDIA/240222_Kamilla_Maike_5_dia_Slot1-23_1_6632.d
" --f "/cluster/work/users/ash022/mDIA/240222_Kamilla_Maike_4_dia_Slot1-22_1_6630.d
" --f "/cluster/work/users/ash022/mDIA/240222_Kamilla_Maike_3_dia_Slot1-21_1_6628.d
" --f "/cluster/work/users/ash022/mDIA/240222_Kamilla_Maike_2_dia_Slot1-20_1_6626.d
" --f "/cluster/work/users/ash022/mDIA/240222_Kamilla_Maike_24_dia_Slot1-42_1_6711.d
" --f "/cluster/work/users/ash022/mDIA/240222_Kamilla_Maike_23_dia_Slot1-41_1_6709.d
" --f "/cluster/work/users/ash022/mDIA/240222_Kamilla_Maike_22_dia_Slot1-40_1_6707.d
" --f "/cluster/work/users/ash022/mDIA/240222_Kamilla_Maike_21_dia_Slot1-39_1_6705.d
" --f "/cluster/work/users/ash022/mDIA/240222_Kamilla_Maike_20_dia_Slot1-38_1_6703.d
" --f "/cluster/work/users/ash022/mDIA/240222_Kamilla_Maike_1_dia_Slot1-19_1_6624.d
" --f "/cluster/work/users/ash022/mDIA/240222_Kamilla_Maike_19_dia_Slot1-37_1_6701.d
" --f "/cluster/work/users/ash022/mDIA/240222_Kamilla_Maike_18_dia_Slot1-36_1_6699.d
" --f "/cluster/work/users/ash022/mDIA/240222_Kamilla_Maike_17_dia_Slot1-35_1_6697.d
" --f "/cluster/work/users/ash022/mDIA/240222_Kamilla_Maike_16_dia_Slot1-34_1_6695.d
" --f "/cluster/work/users/ash022/mDIA/240222_Kamilla_Maike_15_dia_Slot1-33_1_6693.d
" --f "/cluster/work/users/ash022/mDIA/240222_Kamilla_Maike_14_dia_Slot1-32_1_6691.d
" --f "/cluster/work/users/ash022/mDIA/240222_Kamilla_Maike_13_dia_Slot1-31_1_6689.d
" --f "/cluster/work/users/ash022/mDIA/240222_Kamilla_Maike_12_dia_Slot1-30_1_6687.d
" --f "/cluster/work/users/ash022/mDIA/240222_Kamilla_Maike_11_dia_Slot1-29_1_6685.d
" --f "/cluster/work/users/ash022/mDIA/240222_Kamilla_Maike_10_dia_Slot1-28_1_6683.d
" --lib "/cluster/projects/nn9036k/FastaDB/mouse-report-lib.predicted.speclib" --threads 48 --verbose 1 --out "/cluster/work/users/ash022/mDIA/DIANN\mouse-report.tsv" --qvalue 0.01 --matrices  --min-corr 2.0 --corr-diff 1.0 --time-corr-only --out-lib "/cluster/projects/nn9036k/FastaDB/mouse-report-lib.tsv" --gen-spec-lib --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --unimod4 --var-mods 5 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --mass-acc 20 --mass-acc-ms1 20 --peptidoforms --reanalyse --relaxed-prot-inf --rt-profiling --pg-level 0 
