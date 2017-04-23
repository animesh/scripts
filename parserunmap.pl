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
#QueryAccno      QueryStart      QueryEnd        QueryLength     SubjAccno       SubjStart       SubjEnd SubjLength      NumIdent        AlignLength   QueryAlign      SubjAlign
#codbac-190o01.fb140_b1.SCF      44      577     577     contig73356     1384    1923    2096    494     549     CTATCCAATATACATTTGCAGTGTCAGGCT TATAT

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
	    $hitchrn{$namestr}=$SubjAccno;
	    $hitchrn{$namestr}=~s/[a-z]|[A-Z]//g;
	    $hitchrn{$namestr}+=0;
	    $hitpos{$namestr}="$SubjStart-$SubjEnd";
	    $hitscore{$namestr}=$AlignLength;
	}
    #}		
}
close F; 
my $cseq;
my $tseq;
my $avgbacsep;
foreach my $w (keys %hitname) {
	 my $rname=$w.".r";
	 my $fname=$w.".f";
		if($hitpos{$rname} and $hitpos{$fname}){
			$cseq++;
			my @tmp1=split(/\-|\s+/,$hitpos{$fname});
			my @tmp2=split(/\-|\s+/,$hitpos{$rname});
			$hitpos{$fname}=~s/\-/ - /g;
			$hitpos{$rname}=~s/\-/ - /g;
			my $bacsep=abs($tmp1[0]-$tmp2[0]);
 			print "$cseq\t$w\t$fname - $rname\t$hitscore{$fname} - $hitscore{$rname}\t$hitpos{$fname}\t$hitpos{$rname}\t$bacsep\t$hitchrn{$fname} - $hitchrn{$rname}\n";
			$avgbacsep+=$bacsep;		
		}
 	#print "$w\t$fname\t$rname\t-\t$compname{$w}\t$hitname{$w}\n$hitscore{$fname}-$hitscore{$rname}\t$hitpos{$fname}-$hitpos{$rname}\n";
}

#print $avgbacsep/$cseq," Avg Bac Sep\n";


