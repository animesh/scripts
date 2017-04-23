#!/usr/bin/perl
# getorder.pl     sharma.animesh@gmail.com     2009/03/09 10:01:28

use warnings;
use strict;
$|=1;
use Data::Dumper;
my $file=shift @ARGV;
open(F,$file);

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
my %subhitid;
my %evalhitscore;

while(<F>){
    my @tmp=split(/\s+/,$_);
    my $Query_id=$tmp[0];       
    my $Subj_id=$tmp[1];       
    my $per_iden=$tmp[2];       
    my $aln_length=$tmp[3];     
    my $mismatches=$tmp[4];     
    my $gap_open=$tmp[5];       
    my $q_start=$tmp[6];
    my $q_end=$tmp[7];  
    my $s_start=$tmp[8];
    my $s_end=$tmp[9];  
    my $e_value=$tmp[10];
    my $bit_score=$tmp[11];
    my $namestr=substr($Query_id,7,8);   
    my $namesubstr=substr($Query_id,7,6);
    $compname{$namesubstr}=$namestr;
    if($per_iden >= $pit and $aln_length >= $alt and $e_value <= $evt and $bit_score >= $bst){
        if($hitscore{$namestr}<$bit_score){
		$max=$bit_score;
		$hitpos{$namestr}="$s_start-$s_end";
		$hitscore{$namestr}=$max;
		$evalhitscore{$namestr}=$e_value;
		$subhitid{$namestr}=$Subj_id;
		 
	}
 $pia+=($per_iden);
        $ala+=($aln_length);
        $eva+=($e_value);
        $bsa+=($bit_score);
 $cnt++;
        $us{$Query_id}++;
	$hitname{$namesubstr}++;
	 
	 #if(){$hitpos{$namestr}="$s_start-$s_end";}
 	#$hitpos{$namestr}="$s_start-$s_end";
        #print "$hitname{$namesubstr}\t$hitpos{$namestr}\t$Query_id\tThere are $cnt\tmatches with threshold $per_iden (Per Id), $aln_length (Aln Len), $e_value (e-val), $bit_score (bit score)\n";

  }
}
        $pia/=$cnt;
        $ala/=$cnt;
        $eva/=$cnt;
        $bsa/=$cnt;
 
#print "$cnt\tmatches with threshold $pit( Avg Per Id - $pia ), $alt (Avg Aln Len - $ala ), $evt (Avg e-val - $eva ), $bst (Avg bit score - $bsa )\n";
my $cseq;
my $tseq;
#foreach (keys %us) {$cseq++;$tseq+=$us{$_};}

#print "Total - $tseq\tUniq - $cseq\n";
foreach my $w (keys %hitname) {
	 my $rname=$w.".r";
	 my $fname=$w.".f";
		#if($hitpos{$fname}){
	    if($hitpos{$rname} and $hitpos{$fname}){
		if($subhitid{$rname} eq $subhitid{$fname}){
			$cseq++;
			$hitpos{$fname}=~s/\-/ - /g;
			$hitpos{$rname}=~s/\-/ - /g;
 			#print "$w\t$fname\t$rname\t-\t$compname{$w}\t$hitname{$w}\n";
 			print "$cseq\t$w\t$fname - $rname\t$hitscore{$fname} - $hitscore{$rname}\t$hitpos{$fname} - $hitpos{$rname}\t$evalhitscore{$fname} - $evalhitscore{$rname}\t$subhitid{$rname} - $subhitid{$fname}\n";
		}
	   }
 	#print "$w\t$fname\t$rname\t-\t$compname{$w}\t$hitname{$w}\n$hitscore{$fname}-$hitscore{$rname}\t$hitpos{$fname}-$hitpos{$rname}\n";
	#if($rname eq $compname{$w}){print "YES IT IS R"}
}

