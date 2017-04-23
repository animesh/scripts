#!/usr/bin/perl
open(F,"cnall.txt");
$out="cnallformatted.txt";
while ($line = <F>) {
        #chomp ($line);
	$line=~s/\s+/ /g;
	@t1=split(/ /,$line);
	$t2=@t1[2];
	push(@list,$t2);
}
	%seen=();
	@combos = grep{ !$seen{$_} ++} @list;
foreach $t3 (@list)
	{
	print "$t3\n"
	}
close F;
