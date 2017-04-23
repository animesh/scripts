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
my $evt=1000;
my $bst=0;
my %hitpos;
my %hitname;
my $max=0;
my %hitscore;
my %compname;
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
    if($hitscore{$Query_id}<$bit_score){$hitscore{$Query_id}=$bit_score};
}
foreach (keys %hitscore) {
	$cnt++;
	print "$cnt\t$_=>$hitscore{$_}\n";
}
