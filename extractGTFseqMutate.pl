use strict;
use warnings;

my %seqh;
my %seqm;
my $seqc;
my $f1=shift @ARGV;
open(F1,$f1);
while(my $l1=<F1>){
	chomp $l1;
	$l1=~s/\r//g;
	if($l1=~/^>/){$seqc=$l1;$seqc=~s/^>//;$seqc=~s/^(\w+).*$/$1/;}
	else{$seqh{$seqc}.=uc($l1);}
}
close F1;

my $f2=shift @ARGV;
open(F2,$f2);
my $gn=shift @ARGV;
my $mut=shift @ARGV;
my $utr=shift @ARGV;
my $min=1e9999;
my $max=-$min;
my $chr;
while(my $l2=<F2>){
	if($l2=~m/\b$gn\b/){
		chomp $l2;
		$l2=~s/\r//g;
		my @tmpnm=split(/\t/,$l2);
		if($min>$tmpnm[3]){$min=$tmpnm[3]}
		if($max<$tmpnm[4]){$max=$tmpnm[4]}
		$chr=$tmpnm[0];
		print ">",join('|',@tmpnm),"\n";
		if($tmpnm[6] eq "-"){
			my $revseq=reverse(substr($seqh{$tmpnm[0]},$tmpnm[3]-1,$tmpnm[4]-$tmpnm[3]+1));
			$revseq=~tr/ATCG/TAGC/;
			print $revseq,"\n";
		}
		elsif($tmpnm[6] eq "+"){print substr($seqh{$tmpnm[0]},$tmpnm[3]-1,$tmpnm[4]-$tmpnm[3]+1),"\n";}
		else{print "Unknown Frame\n";}
	}
}
close F2;

if($mut){
	print ">mut|$gn|$chr|$mut|","\n";
	my $seq=substr($seqh{$chr},$min+1,$max-$min+1);
	$seq="T".$seq;
	print "$seq\n";
}

if($utr){
	print ">utr|$gn|$chr|$min|-$utr","\n",substr($seqh{$chr},$min-$utr-1,$utr),"\n";
	print ">utr|$gn|$chr|$max|+$utr","\n",substr($seqh{$chr},$max,$utr),"\n";
}

__END__
perl extractGTFseqMutate.pl fastaFile GTFfile Gene mutatePosition lengthUTR
#example "perl extractGTFseqMutate.pl ../Homo_sapiens.GRCh38.dna.primary_assembly.fa ../Homo_sapiens.GRCh38.96.gtf UNG 1 100 2>0"
fastaFile: download ftp://ftp.ensembl.org/pub/release-96/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz and gunzip
#GTF: download ftp://ftp.ensembl.org/pub/release-96/gtf/homo_sapiens/Homo_sapiens.GRCh38.96.gtf.gz and gunzip
#Gene: UNG https://www.ensembl.org/Homo_sapiens/Gene/Summary?g=ENSG00000076248;r=12:109097574-109110992
#mutatePosition: 1
#UTR: 100 https://www.ensembl.org/Homo_sapiens/Location/View?db=core;g=ENSG00000076248;r=12:109097474-109111002
