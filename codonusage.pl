use strict;
use warnings;
use Text::ParseWords;
my $file1=shift @ARGV;
my $file2=shift @ARGV;
open F1, "$file1" or die "Can't open file : $file1 $!";
open F2, "$file2" or die "Can't open file : $file2  $!";
my %seqh;
my $seqc;
my %val;
my $cl=3;
my %c2a = (
	'TTT' => 'F','TTC' => 'F','TTA' => 'L','TTG' => 'L',
	'TCT' => 'S','TCC' => 'S','TCA' => 'S','TCG' => 'S',
	'TAT' => 'T','TAC' => 'T','TAA' => 'stop','TAG' => 'stop',
	'TGT' => 'C','TGC' => 'C','TGA' => 'stop','TGG' => 'W',

	'CTT' => 'L','CTC' => 'L','CTA' => 'L','CTG' => 'L',
	'CCT' => 'P','CCC' => 'P','CCA' => 'P','CCG' => 'P',
	'CAT' => 'H','CAC' => 'H','CAA' => 'Q','CAG' => 'Q',
	'CGT' => 'R','CGC' => 'R','CGA' => 'R','CGG' => 'R',

	'ATT' => 'I','ATC' => 'I','ATA' => 'I','ATG' => 'M',
	'ACT' => 'T','ACC' => 'T','ACA' => 'T','ACG' => 'T',
	'AAT' => 'N','AAC' => 'N','AAA' => 'K','AAG' => 'K',
	'AGT' => 'S','AGC' => 'S','AGA' => 'R','AGG' => 'R',

	'GTT' => 'V','GTC' => 'V','GTA' => 'V','GTG' => 'V',
	'GCT' => 'A','GCC' => 'A','GCA' => 'A','GCG' => 'A',
	'GAT' => 'D','GAC' => 'D','GAA' => 'E','GAG' => 'E',
	'GGT' => 'G','GGC' => 'G','GGA' => 'G','GGG' => 'G',
);

sub translate{
	my $se=shift;
        my $lt=length($se);
	my $ct=int($lt/$cl);
	my $rr=$lt%$cl;
	my $sa="";
	my %cu;
	my $cp;
	for (my $c2=0;$c2<$ct;$c2++) {
		my $sp=$c2*$cl;
		my $aa=substr($se,$sp,$cl);
		$sa.=$c2a{$aa};
		$cu{$aa}++;
		if($c2a{$aa} eq "stop"){$cp.="$sp-";}
	}
	return($sa,$cp,$lt,$rr,%cu);
}


while(my $l1=<F1>){
	chomp $l1;
        $l1=~s/\r//g;
        if($l1=~/^>/){$l1=~s/^>//g;my @snt=split(/\|/,$l1);$seqc=$snt[0];}
        else{$l1=~s/[0-9]|\s+//g;$seqh{$seqc}.=uc($l1);}
}

while(my $l2=<F2>){
	chomp $l2;
	$l2=~s/\r//g;
	my @tmp2=parse_line(',',0,$l2);
	$val{$tmp2[0]}=$l2;
}
close F2;

my $hl=0;
foreach (keys %seqh){
	$hl++;
	if($hl==1){
		print $val{"ccds_id"},",ID,Length,DivBy3Rem,StopCodons,StopCodonPos,";
		foreach my $aa(keys %c2a){
			print "$aa-$c2a{$aa},";
		}
		print "\n";
	}
	else{
		my $seqn=$_;
		my $seq=$seqh{$_};
		my ($seqt,$scp,$lgt,$rem,%cut)=translate($seq);
		my @stpcnt=split(/-/,$scp);
		print "$val{$seqn},$seqn,$lgt,$rem,$#stpcnt,$scp,";
		foreach my $aaa(keys %c2a){
			print "$cut{$aaa},";
		}
		print "\n";
        }
}

__END__

perl codonusage.pl /cygdrive/x/Elite/gaute/test/CCDS_nucleotide.20131024.fna /cygdrive/x/Elite/gaute/test/CCDS.20131024.csv > /cygdrive/x/Elite/gaute/test/CCDS.20131024.annot.csv 2>err

https://groups.google.com/a/soe.ucsc.edu/forum/#!original/genome/yKentEyv2vM/qX8r9OwxnzEJ
Table Browser tool as follows:
group: Genes and Gene Prediction Tracks
track: UCSC Genes
table: knownCanonical
region: genome
output format: sequence
ftp://ftp.ncbi.nlm.nih.gov/pub/CCDS/current_human/CCDS_nucleotide.20131024.fna.gz

email: sharma.animesh@gmail.com
