#!/bin/csh -f
echo "starting fasta33_t - protein" `date`
foreach z ( 1 2 6 11 12 16 )
fasta33_t -q  -z $z mgstm1.aa /wrp_lib/sp_protein.lseg > test_m1_a.ok2_t_${z}
fasta33_t -q  -z $z oohu.aa /wrp_lib/sp_protein.lseg > test_m1_b.ok2_t_${z}
fasta33_t -q -S -z $z prio_atepa.aa /wrp_lib/sp_protein.lseg > test_m1_c.ok2S_t_${z}
fasta33_t -q -S -z $z h10_human.aa /wrp_lib/sp_protein.lseg > test_m1_d.ok2S_t_${z}
end
echo "done"
echo "starting ssearch33_t" `date`
foreach z ( 1 2 6 11 12 16 )
ssearch33_t -q  -z $z mgstm1.aa /wrp_lib/sp_protein.lseg > test_m1_a.ssS_t_${z}
ssearch33_t -q  -z $z oohu.aa /wrp_lib/sp_protein.lseg > test_m1_b.ssS_t_${z}
ssearch33_t -q -sBL62 -S -z $z prio_atepa.aa /wrp_lib/sp_protein.lseg > test_m1_c.ssSbl62_t_${z}
ssearch33_t -q -sBL62 -S -z $z h10_human.aa /wrp_lib/sp_protein.lseg > test_m1_d.ssSbl62_t_${z}
end
echo "done"
echo "starting fasta33 - protein" `date`
foreach z ( 1 2 6 11 12 16 )
fasta33 -q  -z $z mgstm1.aa /wrp_lib/sp_protein.lseg > test_m1_a.ok2_${z}
fasta33 -q  -z $z oohu.aa /wrp_lib/sp_protein.lseg > test_m1_b.ok2_${z}
fasta33 -q -S -sBL62 -z $z prio_atepa.aa /wrp_lib/sp_protein.lseg > test_m1_c.ok2Sbl62_${z}
fasta33 -q -S -sBL62 -z $z h10_human.aa /wrp_lib/sp_protein.lseg > test_m1_d.ok2Sbl62_${z}
end
echo "done"
echo "starting ssearch3" `date`
foreach z ( 1 2 6 11 12 16 )
ssearch33 -q  -z $z mgstm1.aa /wrp_lib/sp_protein.lseg > test_m1_a.ssS_${z}
ssearch33 -q  -z $z oohu.aa /wrp_lib/sp_protein.lseg > test_m1_b.ssS_${z}
ssearch33 -q -S -z $z prio_atepa.aa /wrp_lib/sp_protein.lseg > test_m1_c.ssS_${z}
ssearch33 -q -S -z $z h10_human.aa /wrp_lib/sp_protein.lseg > test_m1_d.ssS_${z}
end
echo "done" `date`
