#!/usr/bin/perl
use strict;
my $file=shift @ARGV;
open(F,$file);
my $file0o=$file.".0.out";
open(F0O,">$file0o");
my $fileo=$file.".out";
open(FO,">$fileo");
my $l;
my $c;
my $k;
my $c1;
my %elem;
my $min=1000000000000000000000000000000000;
my $max=0;
my $genomesize=2045775;

while($l=<F>){
	$c++;
	chomp $l;
	my @t=split(/\t/,$l);
	if(@t[2]=~/^[0-9]/){
		my $end=@t[3]+@t[2];
		my $start=@t[3];
		if($min>$start){
			$min=$start;
		}
		if($max<$end){
			$max=$end;
		}
		#print "$c\t$start\t$end\t$l\t$min\t$max\n";
		for($c1=$start;$c1<$end;$c1++){
			$elem{$c1}++;
		}
	}
}


		for($c1=$min;$c1<$max;$c1++){
			if($elem{$c1} ne ""){
				my $ratio=$elem{$c1}/$genomesize;
				print FO"$c1\t$elem{$c1}\t$ratio\n";
			}
			else{
                                print FO"$c1\t0\t0\n";
				print F0O"$c1\t0\t0\n";
				#print "$c1\t0\n";
			}
		}


#foreach $k (sort {$a<=>$b} keys %elem){
#	print FO"$k\t$elem{$k}\n";
#}
