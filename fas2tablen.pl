use strict;
use warnings;
use Text::ParseWords;

my %seqh;
my %seqm;
my $seqc;
my $f1=shift @ARGV;

open(F1,$f1);
while(my $l1=<F1>){
	chomp $l1;
	$l1=~s/\r//g;
	if($l1=~/^>/){$seqc=$l1;$seqc=~s/^>//;}
	else{$seqh{$seqc}.=uc($l1);}
}
close F1;

foreach my $seq (keys %seqh){
	$seqm{$seqh{$seq}}.="$seq;";
}

print "ID\tSequence\tNames\tLength\n";
my $name;
foreach my $seqs (keys %seqm){
	if($seqm{$seqs}=~m/.*\|(.*)$/){
		$name=$1;
		$name=~s/:|;/ /g;
		my @tmpnm=split(/\s+/,$name);
		#print "@tmpnm[0]-@tmpnm[1]-@tmpnm[2]-@tmpnm[3]";
		if($name=~m/Forward/){
			$name="Fwd"."_".$tmpnm[1]."_".$tmpnm[2];
		}
		else{
			$name="Rev"."_".$tmpnm[2]."_".$tmpnm[1];
		}
	}
	my $len=length($seqs);
	print "$name\t$seqs\t$seqm{$seqs}\t$len\n";
}


__END__

perl fas2tablen.pl /cygdrive/f/promec/Qexactive/LARS/2014/desember/Rami_Morteza/Psychrobacter_sp_protxWX.fasta > /cygdrive/f/promec/Qexactive/LARS/2014/desember/Rami_Morteza/Psychrobacter_sp_protxWX.txt




