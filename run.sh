perl multi_layer_perceptron.pl irisnrm.mix.txt 4 300

perl match_column.pl irisnrm.mix.txt.out irisnrm.mix.txt.mis.out


perl online_ftr_sel_otp.pl irisnrm.mix.txt 4 100

perl rank.pl irisnrm.mix.txtofs.txt

cat irisnrm.mix.txtofs.txt.out
