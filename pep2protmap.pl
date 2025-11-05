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
while(my $l1=<F4>){
	chomp $l1;
  $l1=~s/\r//g;
	if($l1=~/^#/){print "$l1\n";}
	elsif($l1 ne ""){
		my @st=split(/\,/,$l1);
		my $pep=$st[$ARGV[2]-1];
		#else{next;}
		$pep=~s/\r//g;
		chomp($pep);
		$pep=uc($pep);
		$pep=~s/I/L/gi;
		$pep =~ s/[^A-Z,]//g;
		if(length($pep)<10){next;}
		#print "$pep\n";
		foreach(keys %seqn){
			#print "$_\n$seqn{$_}\n$seqh{$_}\n";
			my $pos="";
			my $offset = 0;
			$seql=$pep;
			$seq=$seqh{$_};
			my $res = index($seq, $seql, $offset);
			while ($res != -1) {
				$pos.="$res;";
				$offset = $res + 1;
				$res = index($seq, $seql, $offset);
			}
			if($pos ne ""){print "$seql\t$_\t$pos\n";$cntMat++;}
		}
	}
	$cntSeq++;
}
print "\nProcessed $cntSeq Sequences\nFound $cntMat Matches\n";
close F4;
__END__
cat params.txt
enzyme = Nonspecific
massAnalyzer = TOF
fragmentIonErrorTol = 0.03Da
precursorErrorTol = 10ppm
forbiddenResidues = I,U
Z:\Download\SearchGUI-4.3.15-windows\SearchGUI-4.3.17\resources\Novor>java -jar novor.jar "L:\promec\TIMSTOF\LARS\2025\251031_MAREN\251030_MAREN_DIALYSE_DDA_Slot1-37_1_11507.d\251030_MAREN_DIALYSE_DDA_Slot1-37_1_11507_6.1.452.mgf"  -p params.txt
perl pep2protmap.pl /mnt/z/Download/UP000005640_9606_unique_gene.fasta /mnt/z/Download/251030_MAREN_DIALYSE_DDA_Slot1-37_1_11507_6.1.452.mgf.csv 10 > /mnt/z/Download/251030_MAREN_DIALYSE_DDA_Slot1-37_1_11507_6.1.452.mgf.tsv
sort /mnt/z/Download/251030_MAREN_DIALYSE_DDA_Slot1-37_1_11507_6.1.452.mgf.tsv | uniq > /mnt/z/Download/251030_MAREN_DIALYSE_DDA_Slot1-37_1_11507_6.1.452.mgf.match.tsv
perl pep2protmap.pl /mnt/z/Download/UP000000589_10090.fasta /mnt/z/Download/251030_MAREN_DIALYSE_DDA_Slot1-37_1_11507_6.1.452.mgf.csv 10 > /mnt/z/Download/251030_MAREN_DIALYSE_DDA_Slot1-37_1_11507_6.1.452.mgf.mouse.tsv 
sort /mnt/z/Download/251030_MAREN_DIALYSE_DDA_Slot1-37_1_11507_6.1.452.mgf.mouse.tsv | uniq > /mnt/z/Download/251030_MAREN_DIALYSE_DDA_Slot1-37_1_11507_6.1.452.mgf.mouse.match.tsv
