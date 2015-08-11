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
my %chrlen = (
189908151=>42379582,
189908152=>44616367,
189908153=>47523734,
189908154=>53547397,
189908155=>56522864,
189908156=>46629432,
189908157=>53070661,
189908158=>52310423,
189908159=>49281368,
189908160=>46181231,
189908150=>56204684,
189908162=>56528676,
189908163=>46057314,
189908164=>38981829,
189908165=>46388020,
189908166=>40293347,
189908167=>32876240,
189908161=>54366722,
189908168=>62931207,
189908169=>42602441,
189908170=>70371393,
189908171=>59200669,
189908172=>70262009,
189908173=>56456705,
189908174=>51490918
);
open(F,$file);
while(<F>){
    my @temp=split(/\|/);
    my @temp2=split(/\s+/);
    my $chrn=$chrname{@temp[1]};
    my $chrl=$chrlen{@temp[1]};
    my @tmp=split(/\s+/,$_);
    my $namesubstr=substr($tmp[0],7,6);
    $hitchre{$namesubstr}=$chrn;
}
close F;

open(F,$file);
while(<F>){
    my @temp=split(/\|/);
    my @temp2=split(/\s+/);
    my $lenrat1=@temp2[8]/$chrlen{@temp[1]};
    my $lenrat2=@temp2[9]/$chrlen{@temp[1]};
    my $alnlen=abs(@temp2[8]-@temp2[9]);
    my $chrn=$chrname{@temp[1]};
    my $chrl=$chrlen{@temp[1]};
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
        if($hitchre{$namesubstr} eq $chrn){
         if($hitscore{$namestr}<$bit_score){
		$max=$bit_score;
		$hitpos{$namestr}="$s_start-$s_end";
		$hitscore{$namestr}=$max;
		$hitchrn{$namestr}=$chrn;
		$hitchrl{$namestr}=$chrl;
		$evalhitscore{$namestr}=$e_value;
	 }
	}
	#$hitchre{$namesubstr}=$chrn;
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
my $avgbacsep;
#foreach (keys %us) {$cseq++;$tseq+=$us{$_};}

#print "Total - $tseq\tUniq - $cseq\n";
#foreach my $e (keys %hitchre) {
foreach my $w (keys %hitname) {
	 my $rname=$w.".r";
	 my $fname=$w.".f";
		#if($hitpos{$fname}){
		#if($hitpos{$rname} and $hitpos{$fname} and ($hitchrn{$fname} eq $hitchrn{$rname}){
		if($hitpos{$rname} and $hitpos{$fname} and ($hitchrn{$fname}) and ($hitchrn{$rname})){
			$cseq++;
			my @tmp1=split(/\-|\s+/,$hitpos{$fname});
			my @tmp2=split(/\-|\s+/,$hitpos{$rname});
			$hitpos{$fname}=~s/\-/ - /g;
			$hitpos{$rname}=~s/\-/ - /g;
 			#print "$w\t$fname\t$rname\t-\t$compname{$w}\t$hitname{$w}\n";
			my $bacsep=abs(@tmp1[0]-@tmp2[0]);
 			print "$cseq\t$w\t$fname - $rname\t$hitscore{$fname} - $hitscore{$rname}\t$hitpos{$fname} - $hitpos{$rname}\t$evalhitscore{$fname} - $evalhitscore{$rname}\t@tmp1[1] - @tmp2[0]\t$bacsep\t$hitchrn{$fname} - $hitchrn{$rname}\t$hitchrl{$fname} - $hitchrl{$rname}\n";
			$avgbacsep+=$bacsep;		
		}
 	#print "$w\t$fname\t$rname\t-\t$compname{$w}\t$hitname{$w}\n$hitscore{$fname}-$hitscore{$rname}\t$hitpos{$fname}-$hitpos{$rname}\n";
	#if($rname eq $compname{$w}){print "YES IT IS R"}
}
#}

print $avgbacsep/$cseq," Avg Bac Sep\n";


