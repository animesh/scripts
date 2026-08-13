use strict;
use warnings;
my $seq;
my $seqc;
my $seql;
my %seqh;
my %seqn;
my @st;

open(F2,$ARGV[0]);
while(my $l1=<F2>){
	chomp $l1;
  $l1=~s/\r//g;
	$seql=$l1;
  if($l1=~/^>/){
		#print "$l1\t";
  	@st=split(/\s+/,$l1);
		$seqn{$st[0]}=$l1;
  	#print "$st[0]\t";
  }
  else{
	  $seql=~s/\s+|[0-9]|\n//g;
	  $seql=uc($seql);
		$seql=~s/I/L/g;
		$seqh{$st[0]}.=$seql;
	}
}
close F2;
my $size = keys %seqn;
print "\nRead# $size sequences from $ARGV[0]\n";

print "\nOpening peptide list from $ARGV[1]\n\n";
open(F4,$ARGV[1]);
my $cntSeq=0;
my $cntMat=0;
my $cntLine=0;
while(my $l1=<F4>){
	$cntLine++;
	chomp $l1;
  $l1=~s/\r//g;
	if($cntLine==1){print "$l1\tProtein:Position\tTotal\n";}
	else{
		print "$l1\t";
		my @st=split(/\t/,$l1);
		my $pep=$st[$ARGV[2]-1];
		#else{next;}
		$pep=~s/\r//g;
		chomp($pep);
		$pep=uc($pep);
		$pep=~s/I/L/gi;
		$pep =~ s/[^A-Z,]//g;
		my $match=0;
		foreach(keys %seqn){
			#print "$_\n$seqn{$_}\n$seqh{$_}\n";
			my $pos="";
			my $offset = 0;
			$seql=$pep;
			$seq=$seqh{$_};
			my $res = index($seq, $seql, $offset);
			while ($res != -1) {
				$pos.="$res:";
				$offset = $res + 1;
				$res = index($seq, $seql, $offset);
			}
			if($pos ne ""){print "$_:$pos;";$cntMat++;$match++;}
		}
		print "\t$match\n";
	}
	$cntSeq++;
}
print "\nProcessed $cntSeq Sequences\nFound $cntMat Matches\n";
close F4;
__END__
perl pep2protmap.pl /home/animeshs/promec/promec/FastaDB/uniprot_sprot.fasta /home/animeshs/promec/promec/TIMSTOF/LARS/2026/260729_Orivio/combined/txt/peptides.txt 1 > /home/animeshs/promec/promec/TIMSTOF/LARS/2026/260729_Orivio/combined/txt/peptides.mapped.txt

head /home/animeshs/promec/promec/TIMSTOF/LARS/2026/260729_Orivio/combined/txt/peptides.mapped.txt

Read# 575503 sequences from /home/animeshs/promec/promec/FastaDB/uniprot_sprot.fasta

Opening peptide list from /home/animeshs/promec/promec/TIMSTOF/LARS/2026/260729_Orivio/combined/txt/peptides.txt

Sequence        N-term cleavage window  C-term cleavage window  Amino acid before       First amino acid        Second amino acidSecond last amino acid  Last amino acid Amino acid after        A Count R Count N Count D Count C Count Q Count E Count G Count H Count  I Count L Count K Count M Count F Count P Count S Count T Count W Count Y Count V Count U Count O Count Length  Missed cleavages Mass    Proteins        Leading razor protein   Start position  End position    Gene names      Protein names   Unique (Groups)  Unique (Proteins)       Charges PEP     Score   Identification type 86_Slot2-37_1_14092 Identification type 87_Slot2-38_1_14094  Identification type 88_Slot2-39_1_14096 Identification type 89_Slot2-40_1_14098 Identification type 90_Slot2-41_1_14100 Identification type 91_Slot2-42_1_14102  Identification type 92_Slot2-43_1_14104 Identification type 93_Slot2-44_1_14106 Identification type 94_Slot2-45_1_14108  Experiment 86_Slot2-37_1_14092  Experiment 87_Slot2-38_1_14094  Experiment 88_Slot2-39_1_14096  Experiment 89_Slot2-40_1_14098   Experiment 90_Slot2-41_1_14100  Experiment 91_Slot2-42_1_14102  Experiment 92_Slot2-43_1_14104  Experiment 93_Slot2-44_1_14106   Experiment 94_Slot2-45_1_14108  Intensity       Intensity 86_Slot2-37_1_14092   Intensity 87_Slot2-38_1_14094    Intensity 88_Slot2-39_1_14096   Intensity 89_Slot2-40_1_14098   Intensity 90_Slot2-41_1_14100   Intensity 91_Slot2-42_1_14102    Intensity 92_Slot2-43_1_14104   Intensity 93_Slot2-44_1_14106   Intensity 94_Slot2-45_1_14108   Decoy   Potential contaminant    id      Protein group IDs       Mod. peptide IDs        Evidence IDs    MS/MS IDs       Best MS/MS      Deamidation (NQ) site IDs        Oxidation (M) site IDs  Taxonomy IDs    Taxonomy names  Unique taxonomy names   Mass deficit    MS/MS Count      Protein:Position        Total
AAVEEGIVLGGGCALLR       NEKKDRVTDALNATRAAVEEGIVLGGGCAL  VEEGIVLGGGCALLRCIPALDSLTPANEDQ  R       A       A       L       R       C3       1       0       0       1       0       2       4       0       1       3       0       0       0       0       0       00       0       2       0       0       17      0       1683.8978       P10809  P10809  430     446     HSPD1   60 kDa heat shock protein, mitochondrial no      no      2       0.011187        140.24  By MS/MS        By matching     None    None    None    None     None    None    None    1       1                                                               100250  94103   6149.7  00       0       0       0       0       0                       0       17      0       0;1     0       0                       9606     Homo sapiens    Homo sapiens    0.08319713654486804     1       >sp|P86206|CH60_MESAU:246:;>sp|P18687|CH60_CRIGR:429:;>sp|P10809|CH60_HUMAN:429:;>sp|P63039|CH60_RAT:429:;>sp|P63038|CH60_MOUSE:429:;    5
...