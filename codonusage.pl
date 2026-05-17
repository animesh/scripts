#wget https://ftp.ncbi.nlm.nih.gov/pub/CCDS/current_human/CCDS_nucleotide.20221027.fna.gz
#gunzip CCDS_nucleotide.20221027.fna.gz
#wget https://ftp.ncbi.nlm.nih.gov/pub/CCDS/current_human/CCDS.20221027.txt
#perl codonusage.pl CCDS_nucleotide.20221027.fna CCDS.20221027.txt 2>0
# wc CCDS_nucleotide.20221027.fna.CCDS.20221027.txt.aa.txt
#   35625  2998400 16632199 CCDS_nucleotide.20221027.fna.CCDS.20221027.txt.aa.txt
# grep "^>" CCDS_nucleotide.20221027.fna.CCDS.20221027.txt.aa.fasta | wc
#  35624  851229 11375200
use strict;
use warnings;
use Text::ParseWords;
my $file1=shift @ARGV;
my $file2=shift @ARGV;
open F1, "$file1" or die "Can't open file : $file1 $!";
open F2, "$file2" or die "Can't open file : $file2  $!";
open FT, ">$file1.$file2.aa.fasta" or die "Can't open output file : $file1.$file2.aa.fasta $!";
open FC, ">$file1.$file2.aa.txt" or die "Can't open output file : $file1.$file2.aa.txt $!";
my %seqh;
my $seqc;
my %val;
my $cl=3;
my %c2a = (
	'TTT' => 'F','TTC' => 'F','TTA' => 'L','TTG' => 'L',
	'TCT' => 'S','TCC' => 'S','TCA' => 'S','TCG' => 'S',
	'TAT' => 'Y','TAC' => 'Y','TAA' => 'stop','TAG' => 'stop',
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

#awk -F "\t" '{print "chr"$1}' CCDS.20221027.txt | sort | uniq -c | wc
#     25      50     348
#awk -F "\t" '{print "chr"$5$1}' CCDS.20221027.txt | sort |  uniq | wc
#  37809   37809  611840
# awk -F "\t" '{print "chr"$5$1}' CCDS.20221027.txt | sort |  wc
#  37809   37809  611840
while(my $l2=<F2>){
	chomp $l2;
	$l2=~s/\r//g;
	my @tmp2=parse_line('\t',0,$l2);
	my $kh=uc($tmp2[4]."_chr".$tmp2[0]);
	$val{$kh}=$l2;
}
close F2;
print "loaded annotations $file2: ", scalar(keys %val), "\n";

#grep "^>" CCDS_nucleotide.20221027.fna | awk -F '|' '{print $1}' | sort | uniq  | wc
#  35589   35589  452325
# grep "^>" CCDS_nucleotide.20221027.fna | awk -F '|' '{print $1$3}' | sort | uniq  | wc
#  35624   35624  612181
# grep "^>" CCDS_nucleotide.20221027.fna | wc
#  35624   35624  861549
#grep "^>" CCDS_nucleotide.20221027.fna | awk -F '|' '{print $3}' | sort | uniq -c  | wc
#     24      48     325
while(my $l1=<F1>){
	chomp $l1;
	$l1=~s/\r//g;
	if($l1=~/^>/){$l1=~s/^>//g;my @snt=split(/\|/,$l1);$seqc=uc($snt[0]."_".$snt[2]);}
	else{$l1=~s/[0-9]|\s+//g;$seqh{$seqc}.=uc($l1);}
}
close F1;
print "loaded sequences $file1: ", scalar(keys %seqh), "\n";

print "writing translatedfasta file $file1.$file2.aa.fasta\n";
my $hID=$val{"CCDS_ID_CHR\#CHROMOSOME"};
delete $val{"CCDS_ID_CHR\#CHROMOSOME"};
$hID=~s/^#//;
print FC"$hID\tID\tLength\tDivBy3Rem\tStopCodons\tStopCodonPos\tCodonUsage\t";
foreach my $aa(keys %c2a){print FC"$aa-$c2a{$aa}\t";}
print FC"\n";
my $anNo=0;
my $manNo=0;
foreach (keys %seqh){
	if(!exists $val{$_}){$anNo++;print "missing annotation $anNo for $_\n"; next;}
	my $seqn=$_;
	my $seq=$seqh{$_};
	my ($seqt,$scp,$lgt,$rem,%cut)=translate($seq);
	my @stpcnt=split(/-/,$scp);
	print FC"$val{$seqn}\t$seqn\t$lgt\t$rem\t$#stpcnt\t$scp\t",length($seqt),"\t";
	foreach my $aaa(keys %c2a){
		print FC"$cut{$aaa}\t";
	}
	print FC"\n";
	my @seqtn=split(/stop/,$seqt);
	for(my $snc=0;$snc<=$#seqtn;$snc++) {
		if(length($seqtn[$snc])==0){next;}
		my $seqtns = $seqtn[$snc];
		print FT">$seqn.$snc\t$val{$seqn}\t$scp\t",length($seqt),".",length($seqtns),"\n$seqtns\n";
		if($snc>0){$manNo++;print "$manNo: $seqn\t$snc\t$val{$seqn}\tstop codons>1\n";}
	}
	delete $val{$seqn};
}
#foreach (keys %val){print "annotation $_ without sequence: $val{$_}\n";}
print "multiple stop codons leading to ", $manNo, " more sequences\n";
print "missing sequences for ", scalar(keys %val), " annotations\n";
print "missing annotation for $anNo sequences\n";
print "wrote codon usage in $file1.$file2.aa.txt\n";

close FC;
close FT;
