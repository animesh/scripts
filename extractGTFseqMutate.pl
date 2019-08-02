use strict;
use warnings;

my %seqh;
my %seqm;
my $seqc;
my $f1=shift @ARGV;

my %codon =
(
  "TTT" => "F", "TTC" => "F", "TTA" => "L", "TTG" => "L",
  "TCT" => "S", "TCC" => "S", "TCA" => "S", "TCG" => "S",
  "TAT" => "Y", "TAC" => "Y", "TAA" => "*", "TAG" => "*",
  "TGT" => "C", "TGC" => "C", "TGA" => "*", "TGG" => "W",
  "CTT" => "L", "CTC" => "L", "CTA" => "L", "CTG" => "L",
  "CCT" => "P", "CCC" => "P", "CCA" => "P", "CCG" => "P",
  "CAT" => "H", "CAC" => "H", "CAA" => "Q", "CAG" => "Q",
  "CGT" => "R", "CGC" => "R", "CGA" => "R", "CGG" => "R",
  "ATT" => "I", "ATC" => "I", "ATA" => "I", "ATG" => "M",
  "ACT" => "T", "ACC" => "T", "ACA" => "T", "ACG" => "T",
  "AAT" => "N", "AAC" => "N", "AAA" => "K", "AAG" => "K",
  "AGT" => "S", "AGC" => "S", "AGA" => "R", "AGG" => "R",
  "GTT" => "V", "GTC" => "V", "GTA" => "V", "GTG" => "V",
  "GCT" => "A", "GCC" => "A", "GCA" => "A", "GCG" => "A",
  "GAT" => "D", "GAC" => "D", "GAA" => "E", "GAG" => "E",
  "GGT" => "G", "GGC" => "G", "GGA" => "G", "GGG" => "G",
);


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
	print ">mut|$gn|$chr|$mut=>A|","\n";
	my $seq=substr($seqh{$chr},$min+1,$max-$min+1);
	my $mutseq="";
	if($seq=~/^ATG/){
		for (my $i = 0; $i+2 < length($seq); $i+=3)
		{
			my $aa = $codon{uc(substr($seq, $i, 3))};
			if($aa eq $mut){
				$mutseq.="GCC";#https://www.genscript.com/tools/codon-frequency-table 0.4 for "A"
			}
			else{
				$mutseq.=uc(substr($seq, $i, 3));
			}
		}
	}
	print "$mutseq\n";
}

if($utr){
	print ">utr|$gn|$chr|$min|-$utr","\n",substr($seqh{$chr},$min-$utr-1,$utr),"\n";
	print ">utr|$gn|$chr|$max|+$utr","\n",substr($seqh{$chr},$max,$utr),"\n";
}

__END__
perl extractGTFseqMutate.pl fastaFile GTFfile Gene mutatePosition lengthUTR
#example "perl extractGTFseqMutate.pl  "F:\promec\Animesh\Homo_sapiens.GRCh38.dna.primary_assembly.fa"  "F:\promec\Animesh\Homo_sapiens.GRCh38.96.gtf" UNG V 100 2>0"
fastaFile: download ftp://ftp.ensembl.org/pub/release-96/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz and gunzip
#GTF: download ftp://ftp.ensembl.org/pub/release-96/gtf/homo_sapiens/Homo_sapiens.GRCh38.96.gtf.gz and gunzip
#Gene: UNG https://www.ensembl.org/Homo_sapiens/Gene/Summary?g=ENSG00000076248;r=12:109097574-109110992
#mutateAminoAcid: V for Valine to A=>Alanine  https://en.wikipedia.org/wiki/Alanine_scanning
#UTR: 100 https://www.ensembl.org/Homo_sapiens/Location/View?db=core;g=ENSG00000076248;r=12:109097474-109111002
