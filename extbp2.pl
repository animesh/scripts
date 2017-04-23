#!/usr/bin/perl
use strict;
my $main_file_pattern=shift @ARGV;chomp $main_file_pattern;
open(F,$main_file_pattern)||die "can't open";
my ($w,$c,$line,$snames,@seqname,@seq,$fresall,$seq,$seqname,%match2,%match3,%match4,%matchl1,%matchl2);
while ($line = <F>) {
        chomp ($line);
	my @temp=split(/\t/,$line);
	for($c=0;$c<=$#temp;$c++){
        if (@temp[$c] =~ /region of query/){
		my @temp2=split(/\s+/,@temp[$c]);
	        my $l1=@temp2[2]-@temp2[0];
		my $l2=@temp2[9]-@temp2[7];
		if(@temp2[0]!=@temp2[7] && @temp2[2]!=@temp2[9] && $l1>20 && $l2>20){
		#print "@temp2[0]\t@temp2[2]\t@temp2[7]\t@temp2[9]\t$l1\t$l2\n";
		$match2{@temp2[0]}=@temp2[2];
		$match3{@temp2[0]}=@temp2[7];
                $match4{@temp2[0]}=@temp2[9];
                $matchl1{@temp2[0]}=$l1;
		$matchl2{@temp2[0]}=$l2;
		}
            }
        else {
	#$seq=$seq.$line;
        }
	}
}

foreach $w (sort {$a<=>$b} keys %match2) {
	if($w<$match3{$w} && ($matchl1{$w}/$matchl2{$w}>0.9 || $matchl1{$w}/$matchl2{$w}<1.1)){
		print "$w - $match2{$w}\t$match3{$w} - $match4{$w}\t$matchl1{$w}\t$matchl2{$w}\n";
	}
}

