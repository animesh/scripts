#!/usr/bin/perl
while(<>){chomp;split(/\s+/);$c++;$dictast{length(@_[0])}.=">s.$c\n@_[0]\n";}
foreach $w (sort {$b<=>$a} keys %dictast){
	open(FI,">temp.blast.in");
	print "Blasting $w length word(s) file\n";
	print FI"$dictast{$w}";
	close FI;
	#system("cp 1T32.A.fas temp.blast.in");
	system("blastcl3 -p blastp -d nr -i temp.blast.in -o temp.blast.out");
	open(FO,"temp.blast.out");
	my $c=0; 
	while(<FO>){
		print $_;
		if($_=~/^Sequences producing significant/){
			close FO;	
			die;
		}
	}
}
