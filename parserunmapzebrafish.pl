#!/usr/bin/perl
# getorder.pl     sharma.animesh@gmail.com     2009/03/09 10:01:28

use warnings;
use strict;
$|=1;
use Data::Dumper;
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
my %chrname = (
189908151=>10,
189908152=>11,
189908153=>12,
189908154=>13,
189908155=>14,
189908156=>15,
189908157=>16,
189908158=>17,
189908159=>18,
189908160=>19,
189908150=>1,
189908162=>20,
189908163=>21,
189908164=>22,
189908165=>23,
189908166=>24,
189908167=>25,
189908161=>2,
189908168=>3,
189908169=>4,
189908170=>5,
189908171=>6,
189908172=>7,
189908173=>8,
189908174=>9
);

#ueryAccno      QueryStart      QueryEnd        QueryLength     SubjAccno       SubjStart       SubjEnd SubjLength      NumIdent        AlignLength     QueryAlign      SubjAlign
#codbac-190k05.fb140_b1.SCF      503     43      567     gi|189908155|ref|NC_007125.3|NC_007125  749394  749854  56522864        415     461    GATGGAGGCTCTCCTCCCCTCAGTAGTAATGTGAGTGTGAAAATACTGATCCAGGACCAGAACGACAACGCCCCTCAGGTTCTGTATCCAGTCCAGACTGGTGGTTCTCTGGTGGCTGAAATGGTGCCTCGTTCAGTAGATGTGGGCTATCTGGTCACTAAAGTGGTGGCTGTTGATGTGGACTCTGGACAGAATGCCTGGCTCTCCTATAAACTACAGAAAGTCACAGACAGGGCCCTGTTTGAAGTGGGCTTACAGAATGGAGAAATAAGAACTATCCGCCAAGTCACTGATAAAGATGCTGTGAAACAAAGACTGACTGTTATAGTGGAGGACAACGGACAGCCCTCTCGTTCAGCTACAGTCATTGTTAACGTGGTGGTGGCGGACAGCTTCCCTGAAGTGCTCTCGGAGTTCACTGACTTTACACACGACAAGGAGTACAATGACAACCTGACTTT   GACGGAGGCTCTCCTCCTCTCAGTAGCAACGCGAGCGTCAAAATCCTGATTCAGGACCAGAATGACAACGCGCCTCAGGTTCTGTATCCGGTCCAGTCGGGCGCTTCTGTGGTGGCTGAAATAGTGCCTCGTTCGGCAGATGTGGGTTATCTGGTGACTAAAGTGGTGGCTGTTGATGTGGACTCTGGACAGAACGCCTGGCTCTCCTATAAACTGCACAAAGCCACAGACAGGGCGCTGTTTGAAGTGGGCGCACAGAATGGAGAAATCAGAACTGTCCGGCAAGTGACAGATAAAGATGCTGTCAAACAAAGACTCACTGTTGTAGTGGAGGACAACGGGCAGCCCTCTCGATCAGCTACAGTCAATGTTAACGTGGCGGGCGGACAGCTTCCCTGAGGTGCTCTCGGAGTTCACCGACTTTACGCACGACAAGGAATACAACGACAACCTGACTTT
#codbac-190k03.fb140_b1.SCF      510     465     511     chromosome-19   44540518        44540561        48708673        42      46      CACACACACACACACACACACACACACAATCACAGGGCTGTATGCA  CACACACACACACACACACACACACACAATCAC-GCGCTG-ATACA


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
		my @nm=split(/\-/,$SubjAccno);
	    $hitchrn{$namestr}=$SubjAccno;
	    $hitchrn{$namestr}=~s/MT/0/g;
	    $hitchrn{$namestr}=~s/[a-z]|[A-Z]|\-//g;
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


