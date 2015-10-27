#!/usr/bin/perl
use strict;
use warnings;
my $f=shift @ARGV;
open (F,$f);
print $f;
my $mot=9;
my $seq=5;
my $pg=8;
my $lenmot=5;
print "Protein\tSequence\tMotif\tAminoAcid\tPosition\tMseq\tLength\n";
while (my $line = <F>) {
	chomp ($line);
	$line=~s/\r//g;
	my @se=split(/\t/,$line);
	my @motname=split(/\(|\)/,$se[$mot]);
	my @motchar=split(/[0-9]/,$motname[0]);
	my ($motpos) = $motname[0] =~ /(\d+)/;
	my @seqchar=split(//,$se[$seq]);
	my $motchar;
	for(my $c=$motpos-int($lenmot/2)-1;$c<=$motpos+int($lenmot/2);$c++){
		if($c<0){$motchar.="x";}
		elsif(length($motchar)<$lenmot){$motchar.=$seqchar[$c];}
	}
	while(length($motchar)<$lenmot){$motchar.="x";}
	print "$se[$pg]\t$se[$seq]\t$motname[1]\t$motchar[0]\t$motpos\t$motchar\t",length($motchar),"\n";
}

__END__
perl ptm2motif.pl /cygdrive/f/promec/Qexactive/Linda/Multiconsensus\ from\ 3\ ReportsPepMod.txt 2>0 > /cygdrive/f/promec/Qexactive/Linda/ModMotif.all.txt
