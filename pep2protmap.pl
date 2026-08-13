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
perl pep2protmap.pl /root/bit-pep/uniprot_sprot.fasta /root/bit-pep/combined_peptide.tsv 1 > ../Download/combined_peptide.mapped.tsv
head ../Download/combined_peptide.mapped.tsv

Read# 575503 sequences from /root/bit-pep/uniprot_sprot.fasta

Opening peptide list from /root/bit-pep/combined_peptide.tsv

Peptide Sequence        Prev AA Next AA Start   End     Peptide Length  Charges Protein Protein ID      Entry Name      Gene    Protein Description     Mapped Genes    Mapped Proteins 260729_Orivio_1486_Slot2_37_1_14092 Spectral Count      260729_Orivio_1487_Slot2_38_1_14094 Spectral Count 260729_Orivio_1488_Slot2_39_1_14096 Spectral Count      260729_Orivio_1489_Slot2_40_1_14098 Spectral Count      260729_Orivio_1490_Slot2_41_1_14100 Spectral Count      260729_Orivio_1491_Slot2_42_1_14102 Spectral Count 260729_Orivio_1492_Slot2_43_1_14104 Spectral Count      260729_Orivio_1493_Slot2_44_1_14106 Spectral Count      260729_Orivio_1494_Slot2_45_1_14108 Spectral Count      260729_Orivio_1486_Slot2_37_1_14092 Intensity   260729_Orivio_1487_Slot2_38_1_14094 Intensity      260729_Orivio_1488_Slot2_39_1_14096 Intensity   260729_Orivio_1489_Slot2_40_1_14098 Intensity   260729_Orivio_1490_Slot2_41_1_14100 Intensity   260729_Orivio_1491_Slot2_42_1_14102 Intensity   260729_Orivio_1492_Slot2_43_1_14104 Intensity      260729_Orivio_1493_Slot2_44_1_14106 Intensity   260729_Orivio_1494_Slot2_45_1_14108 Intensity   260729_Orivio_1486_Slot2_37_1_14092 MaxLFQ Intensity    260729_Orivio_1487_Slot2_38_1_14094 MaxLFQ Intensity    260729_Orivio_1488_Slot2_39_1_14096 MaxLFQ Intensity       260729_Orivio_1489_Slot2_40_1_14098 MaxLFQ Intensity    260729_Orivio_1490_Slot2_41_1_14100 MaxLFQ Intensity    260729_Orivio_1491_Slot2_42_1_14102 MaxLFQ Intensity    260729_Orivio_1492_Slot2_43_1_14104 MaxLFQ Intensity       260729_Orivio_1493_Slot2_44_1_14106 MaxLFQ Intensity    260729_Orivio_1494_Slot2_45_1_14108 MaxLFQ Intensity    260729_Orivio_1486_Slot2_37_1_14092 Match Type  260729_Orivio_1487_Slot2_38_1_14094 Match Type  260729_Orivio_1488_Slot2_39_1_14096 Match Type     260729_Orivio_1489_Slot2_40_1_14098 Match Type  260729_Orivio_1490_Slot2_41_1_14100 Match Type  260729_Orivio_1491_Slot2_42_1_14102 Match Type  260729_Orivio_1492_Slot2_43_1_14104 Match Type  260729_Orivio_1493_Slot2_44_1_14106 Match Type     260729_Orivio_1494_Slot2_45_1_14108 Match Type  Protein:Position        Total
AAALSGGGGPGAQAPR        R       P       208     223     16      3       sp|Q5XG87|PAPD7_HUMAN   Q5XG87  PAPD7_HUMAN     TENT4A  Terminal nucleotidyltransferase 4A                      0       0       1       0       0       0       0       0       0 0.0      0.0     0.0     0.0     0.0     0.0     0.0     0.0     0.0     0.0     0.0     0.0     0.0     0.0     0.0     0.0     0.0     0.0     unmatched       unmatched       MS/MS   unmatched       unmatched       unmatched       unmatched       unmatched  unmatched       >sp|Q5XG87|PAPD7_HUMAN:207:;    1