#!/usr/bin/perl
# getorder.pl     sharma.animesh@gmail.com     2009/03/09 10:01:28

#use warnings;
#use strict;
#$|=1;
#use Data::Dumper;
my $file=shift @ARGV;

my $pia;
my $ala;
my $eva;
my $bsa;
my $cnt;
my %us;
my $pit=0;
my $alt=0;
my $evt=0.0000000001;
my $bst=100;
my %hitpos;
my %hitname;
my $max=0;
my %hitscore;
my %compname;
my %evalhitscore;
my %hitchrn;
my %hitchrl;
my %hitchre;

#QueryAccno      QueryStart      QueryEnd        QueryLength     SubjAccno       SubjStart       SubjEnd SubjLength      NumIdent        AlignLength     QueryAlign      SubjAlign
#codbac-190o03.fb140_b1.SCF      466     232     706     XIII.1-5000000  85651   85884   5000000 212     235     GGCTGTAGTGGAGGGTAAACGCACGTAAACGCCGTTTACGCACCTCTGGAATTTAGGAAATAGCGTTTACGCACCTCTAAATAGCGTTTACGCACCTCAAAATTCCCTGTGCCTTGTATTCTGCCGTTGGAATAATCGGAAATAAATTCAGCATCATTTTAAAACACCTAAGACAAGGTTTCATATTGTTGAACAAATAAACGCTGTAATCTGAATCATTTTCATCTGCGCTGTA     GGCTGTAGTGGAGGGTAAATGCACGTAAACGCAGTTTACGCACCTCTAGAATTTTGGAAA-AGCGTTTACGCCCTATAGATAGCGTTAACGCACCTCAAAGTTCCCTGCGCCTTGTATTCTTCCGTTGGAATAATCCGAAATAAACTCGGTATAATTTTAAAACAGCTAAGACTACGTTTCCTATTGTTGAACATATAAACGCCGTAGTCTGAATCATTTTCATCTGCGCTGTA

%chrname = (
I_1_5000000	=>	1	,
I_5000001_10000000	=>	2	,
I_10000001_15000000	=>	3	,
I_15000001_20000000	=>	4	,
I_20000001_25000000	=>	5	,
I_25000001_28185914	=>	6	,
II_1_5000000	=>	7	,
II_5000001_10000000	=>	8	,
II_10000001_15000000	=>	9	,
II_15000001_20000000	=>	10	,
II_20000001_23295652	=>	11	,
III_1_5000000	=>	12	,
III_5000001_10000000	=>	13	,
III_10000001_15000000	=>	14	,
III_15000001_16798506	=>	15	,
IV_1_5000000	=>	16	,
IV_5000001_10000000	=>	17	,
IV_10000001_15000000	=>	18	,
IV_15000001_20000000	=>	19	,
IV_20000001_25000000	=>	20	,
IV_25000001_30000000	=>	21	,
IV_30000001_32632948	=>	22	,
IX_1_5000000	=>	23	,
IX_5000001_10000000	=>	24	,
IX_10000001_15000000	=>	25	,
IX_15000001_20000000	=>	26	,
IX_20000001_20249479	=>	27	,
V_1_5000000	=>	28	,
V_5000001_10000000	=>	29	,
V_10000001_12251397	=>	30	,
VI_1_5000000	=>	31	,
VI_5000001_10000000	=>	32	,
VI_10000001_15000000	=>	33	,
VI_15000001_17083675	=>	34	,
VII_1_5000000	=>	35	,
VII_5000001_10000000	=>	36	,
VII_10000001_15000000	=>	37	,
VII_15000001_20000000	=>	38	,
VII_20000001_25000000	=>	39	,
VII_25000001_27937443	=>	40	,
VIII_1_5000000	=>	41	,
VIII_5000001_10000000	=>	42	,
VIII_10000001_15000000	=>	43	,
VIII_15000001_19368704	=>	44	,
X_1_5000000	=>	45	,
X_5000001_10000000	=>	46	,
X_10000001_15000000	=>	47	,
X_15000001_15657440	=>	48	,
XI_1_5000000	=>	49	,
XI_5000001_10000000	=>	50	,
XI_10000001_15000000	=>	51	,
XI_15000001_16706052	=>	52	,
XII_1_5000000	=>	53	,
XII_5000001_10000000	=>	54	,
XII_10000001_15000000	=>	55	,
XII_15000001_18401067	=>	56	,
XIII_1_5000000	=>	57	,
XIII_5000001_10000000	=>	58	,
XIII_10000001_15000000	=>	59	,
XIII_15000001_20000000	=>	60	,
XIII_20000001_20083130	=>	61	,
XIV_1_5000000	=>	62	,
XIV_5000001_10000000	=>	63	,
XIV_10000001_15000000	=>	64	,
XIV_15000001_15246461	=>	65	,
XIX_1_5000000	=>	66	,
XIX_5000001_10000000	=>	67	,
XIX_10000001_15000000	=>	68	,
XIX_15000001_20000000	=>	69	,
XIX_20000001_20240660	=>	70	,
XV_1_5000000	=>	71	,
XV_5000001_10000000	=>	72	,
XV_10000001_15000000	=>	73	,
XV_15000001_16198764	=>	74	,
XVI_1_5000000	=>	75	,
XVI_5000001_10000000	=>	76	,
XVI_10000001_15000000	=>	77	,
XVI_15000001_18115788	=>	78	,
XVII_1_5000000	=>	79	,
XVII_5000001_10000000	=>	80	,
XVII_10000001_14603141	=>	81	,
XVIII_1_5000000	=>	82	,
XVIII_5000001_10000000	=>	83	,
XVIII_10000001_15000000	=>	84	,
XVIII_15000001_16282716	=>	85	,
XX_1_5000000	=>	86	,
XX_5000001_10000000	=>	87	,
XX_10000001_15000000	=>	88	,
XX_15000001_19732071	=>	89	,
XXI_1_5000000	=>	90	,
XXI_5000001_10000000	=>	91	,
XXI_10000001_11717487	=>	92	,
Un_1_5000000	=>	93	,
Un_5000001_10000000	=>	94	,
Un_10000001_15000000	=>	95	,
Un_15000001_20000000	=>	96	,
Un_20000001_25000000	=>	97	,
Un_25000001_30000000	=>	98	,
Un_30000001_35000000	=>	99	,
Un_35000001_40000000	=>	100	,
Un_40000001_45000000	=>	101	,
Un_45000001_50000000	=>	102	,
Un_50000001_55000000	=>	103	,
Un_55000001_60000000	=>	104	,
Un_60000001_62550211	=>	105	,
);

open(F,$file);
while(<F>){
    my @tmp=split(/\s+/);
    my $QueryAccno=$tmp[0];       
    my $QueryStart=$tmp[1];       
    my $QueryEnd=$tmp[2];       
    my $QueryLength=$tmp[3];     
    my $SubjAccno=$tmp[4];     
    my $SubjStart=$tmp[5];       
    my $SubjEnd=$tmp[6];
    my $SubjLength=$tmp[7];  
    my $NumIdent=$tmp[8];
    my $AlignLength=$tmp[9];  
    my $QueryAlign=$tmp[10];
    my $SubjAlign=$tmp[11];
    my $namestr=substr($QueryAccno,7,8);   
    my $namesubstr=substr($QueryAccno,7,6);
    $hitname{$namesubstr}++;
   #if($per_iden >= $pit and $aln_length >= $alt and $e_value <= $evt and $bit_score >= $bst){
	#if(!$hitscore{$namestr}){$hitscore{$namestr}=0;}
	if($hitscore{$namestr}<$AlignLength){
		$SubjAccno=~s/\.|\-/\_/g;
	    $hitchrn{$namestr}=$chrname{$SubjAccno};
	    $hitchrn{$namestr}+=0;
	    $hitpos{$namestr}="$SubjStart-$SubjEnd";
	    $hitscore{$namestr}=$AlignLength;
	}
    #}		
}
close F; 
my $cseq;
my $tseq;
my $avgbacsep=0;
my $avgbacsepn=0;
foreach my $w (keys %hitname) {
	 my $rname=$w.".r";
	 my $fname=$w.".f";
		if($hitpos{$rname} and $hitpos{$fname} and ($hitscore{$fname} > $bst) and ($hitscore{$rname})>$bst){
			$cseq++;
			my @tmp1=split(/\-|\s+/,$hitpos{$fname});
			my @tmp2=split(/\-|\s+/,$hitpos{$rname});
			$hitpos{$fname}=~s/\-/ - /g;
			$hitpos{$rname}=~s/\-/ - /g;
 			print "$cseq\t$w\t$fname - $rname\t$hitscore{$fname} - $hitscore{$rname}\t$hitpos{$fname}\t$hitpos{$rname}\t$hitchrn{$fname} - $hitchrn{$rname}\t";
			if($hitchrn{$fname} eq $hitchrn{$rname}){
				my $bacsep=0;
				if(abs($tmp1[0]-$tmp2[0])>0){$bacsep=abs($tmp1[0]-$tmp2[0]);}
				elsif(abs($tmp1[0]-$tmp2[1])>0){$bacsep=abs($tmp1[0]-$tmp2[1]);}
				elsif(abs($tmp1[1]-$tmp2[0])>0){$bacsep=abs($tmp1[1]-$tmp2[0]);}
				elsif(abs($tmp1[1]-$tmp2[1])>0){$bacsep=abs($tmp1[1]-$tmp2[1]);}
				else{$bacsep=abs($tmp1[0]-$tmp2[0]);}
				$avgbacsep+=$bacsep;
				$avgbacsepn=$avgbacsep/$cseq;
				print "SSH\t$bacsep\t$avgbacsepn";
			}
			else{print "NSSH\t0\t$avgbacsepn";}
			print "\n";		
		}
 	#print "$w\t$fname\t$rname\t-\t$compname{$w}\t$hitname{$w}\n$hitscore{$fname}-$hitscore{$rname}\t$hitpos{$fname}-$hitpos{$rname}\n";
}

#print $avgbacsep/$cseq," Avg Bac Sep\n";


