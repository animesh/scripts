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
while(my $l2=<F2>){
	chomp $l2;
	$l2=~s/\r//g;
	my @tmpnm=split(/\t/,$l2);
	print ">",join('|',@tmpnm),"\n";
	if($tmpnm[6] eq "-"){
		my $revseq=reverse(substr($seqh{$tmpnm[0]},$tmpnm[3]-1,$tmpnm[4]-$tmpnm[3]+1));
		$revseq=~tr/ATCG/TAGC/d;
		print $revseq,"\n";
	}
	elsif($tmpnm[6] eq "+"){
		print substr($seqh{$tmpnm[0]},$tmpnm[3]-1,$tmpnm[4]-$tmpnm[3]+1),"\n";
	}
	else{
		print "Unknown Frame\n";
	}
}
close F2;

__END__

perl fastaFile GTFfile



