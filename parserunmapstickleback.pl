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
my $bst=0;
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
#codbac-190o03.fb140_b1.SCF      466     232     706     groupXIII       85651   85884   20083130        212     235     GGCTGTAGTGGAGGGTAAACGCACGTAAACGCCGTTTACGCACCTCTGGAATTTAGGAAATAGCGTTTACGCACCTCTAAATAGCGTTTACGCACCTCAAAATTCCCTGTGCCTTGTATTCTGCCGTTGGAATAATCGGAAATAAATTCAGCATCATTTTAAAACACCTAAGACAAGGTTTCATATTGTTGAACAAATAAACGCTGTAATCTGAATCATTTTCATCTGCGCTGTA     GGCTGTAGTGGAGGGTAAATGCACGTAAACGCAGTTTACGCACCTCTAGAATTTTGGAAA-AGCGTTTACGCACCTATAGATAGCGTTAACGCACCTCAAAGTTCCCTGCGCCTTGTATTCTTCCGTTGGAATAATCCGAAATAAACTCGGTATAATTTTAAAACAGCTAAGACTACGTTTCCTATTGTTGAACATATAAACGCCGTAGTCTGAATCATTTTCATCTGCGCTGTA

%chrname = (
groupXIX	=>	19	,
groupXII	=>	12	,
groupX	=>	10	,
groupXXI	=>	21	,
groupXV	=>	15	,
groupII	=>	2	,
groupXVIII	=>	18	,
groupV	=>	5	,
groupXX	=>	20	,
groupXI	=>	11	,
groupIX	=>	9	,
groupXIII	=>	13	,
groupIII	=>	3	,
groupVIII	=>	8	,
groupXVI	=>	16	,
groupXIV	=>	14	,
groupVII	=>	7	,
groupXVII	=>	17	,
groupVI	=>	6	,
groupIV	=>	4	,
groupI	=>	1	,
MT	=>	0	
);

%chrnumber = (
19	=>	groupXIX	,
12	=>	groupXII	,
10	=>	groupX	,
21	=>	groupXXI	,
15	=>	groupXV	,
2	=>	groupII	,
18	=>	groupXVIII	,
5	=>	groupV	,
20	=>	groupXX	,
11	=>	groupXI	,
9	=>	groupIX	,
13	=>	groupXIII	,
3	=>	groupIII	,
8	=>	groupVIII	,
16	=>	groupXVI	,
14	=>	groupXIV	,
7	=>	groupVII	,
17	=>	groupXVII	,
6	=>	groupVI	,
4	=>	groupIV	,
1	=>	groupI	,
0	=>	MT	
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


