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
		$seqh{$st[0]}.=$seql;
	}
}
close F2;

my $pep=$ARGV[1];
$pep=~s/\r//g;
chomp($pep);

if($ARGV[2]){
	open(F1,$ARGV[2]);
	while(my $l1=<F1>){
		chomp $l1;
	        $l1=~s/\r//g;
	        if($l1=~/^>/){my @st=split(/\s+/,$l1);$seqc=$st[0];}
	        else{$l1=~s/[0-9]|\s+//g;$seq.=uc($l1);}
	}
	close F1;
}

foreach(keys %seqn){
	#print "$_\n$seqn{$_}\n$seqh{$_}\n";
	my $pos="";
	my $offset = 0;
	$seql=$pep;
	$seq=$seqh{$_};
	$seql=~s/I/L/gi;
	$seq=~s/I/L/gi;
	my $res = index($seq, $seql, $offset);
	while ($res != -1) {
		$pos.="$res;";
		$offset = $res + 1;
		$res = index($seq, $seql, $offset);
	}
	if($pos ne ""){print "$_\t$pos\n";}
}

__END__
#http://computationalbiologynews.blogspot.com/2020/03/novel-insert-in-spike-glycoprotein-of.html
#setup https://www.uniprot.org/downloads
wget ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot_varsplic.fasta.gz
gunzip uniprot_sprot_varsplic.fasta.gz
#check for PRRA peptide
perl pep2protmap.pl uniprot_sprot_varsplic.fasta "PRRA" > PRRA.var.pos.txt
