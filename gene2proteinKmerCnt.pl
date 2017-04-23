use strict;
use warnings;
use Text::ParseWords;
my $file1=shift @ARGV;
my $kmer=shift @ARGV;
my $kmerstart=shift @ARGV;
open F1, "$file1" or die "Can't open file : $file1 $!";
my %seqh;
my $seqc;
my %val;
my $cl=3;
my %kmergene;
my %kmerprot;
my %c2a = (
	'TTT' => 'F','TTC' => 'F','TTA' => 'L','TTG' => 'L',
	'TCT' => 'S','TCC' => 'S','TCA' => 'S','TCG' => 'S',
	'TAT' => 'T','TAC' => 'T','TAA' => 'Z','TAG' => 'Z',
	'TGT' => 'C','TGC' => 'C','TGA' => 'Z','TGG' => 'W',

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
	}
	return($sa,$cp,$lt,$rr,%cu);
}


while(my $l1=<F1>){
	chomp $l1;
        $l1=~s/\r//g;
        if($l1=~/^>/){$l1=~s/^>//g;my @snt=split(/\|/,$l1);$seqc=$snt[0];}
        else{$l1=~s/[0-9]|\s+//g;$seqh{$seqc}.=uc($l1);}
}

my $hl=0;
my %fig;
my %fip;

foreach (keys %seqh){
	$hl++;
	my $seqn=$_;
	my $seq=$seqh{$_};
	my ($seqt,$scp,$lgt,$rem,%cut)=translate($seq);
	my $slen=length($seq);
	my $slent=length($seqt);
	print "$hl\t$seqn,$slen,$slent\t";
	for(my $cmer=$kmerstart;$cmer<=$kmer;$cmer++){
		print "$cmer\t";
		for(my $move=0;$move<=$slen-$cmer;$move++){
			$fig{$seqn.substr($seq,$move,$cmer)}++;
			if($fig{$seqn.substr($seq,$move,$cmer)}==1){$kmergene{substr($seq,$move,$cmer)}++;}
		}
		for(my $move=0;$move<=$slent-$cmer;$move++){
			$fip{$seqn.substr($seqt,$move,$cmer)}++;
			if($fip{$seqn.substr($seqt,$move,$cmer)}==1){$kmerprot{substr($seqt,$move,$cmer)}++;}
		}
	}
	print "\n";
	delete $seqh{$_};
}

my $fog=$file1.".$kmerstart.$kmer.gene.txt";
my $fop=$file1.".$kmerstart.$kmer.protein.txt";
open(FG,">$fog");
foreach my $k(keys %kmergene){
	print FG"$k\t$kmergene{$k}\t",length($k),"\n";
	delete $kmergene{$k};
}
close FG;
print "Gene kmer Length distrib in $fog\n";

open(FP,">$fop");
foreach my $k(keys %kmerprot){
	print FP"$k\t$kmerprot{$k}\t",length($k),"\n";
	delete $kmerprot{$k};
}
close FP;
print "Protein kmer Length distrib in wrote $fop\n";

__END__

perl gene2proteinKmerCnt.pl /cygdrive/l/Elite/gaute/test/CCDS_nucleotide.20131024.fna 30

output format: sequence
ftp://ftp.ncbi.nlm.nih.gov/pub/CCDS/current_human/CCDS_nucleotide.20131024.fna.gz

email: sharma.animesh@gmail.com
