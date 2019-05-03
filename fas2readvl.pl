#!/usr/bin/perl
use strict;
my $main_file=shift @ARGV;
my $coverage=50;
my $window=250;
my $per_win=20;
my $socl=$window*(1-$per_win/100);
my $eocl=$window*(1+$per_win/100);


my @gseq;
my @gseqname;
my $fot;
my $fas_file=$main_file.".C$coverage.L$window.read.fasta";
open(FT,">$fas_file");

get_other_source($main_file);

for($fot=0;$fot<=$#gseq;$fot++){
	my $slname=@gseqname[$fot];
	my $slseq=@gseq[$fot];
	my $wseqlen=length($gseq[$fot]);
	my $sno;
	my $totalcnt=$coverage*$wseqlen/$window;
	my $slnamews=$slname;$slnamews=~s/^>//;
	print "SS-$slseq SL-$wseqlen SN-$slname TC-$totalcnt\n";
	for(my $c=0;$c<$totalcnt;$c++){
# 	for(my $c=0;$c<0;$c++){
   		$sno++;
		my $p=int(rand($wseqlen-$window));
 	       	my $p1=$socl;
        	my $p2=$eocl;
	        my $pcl=(rand(1));
        	$pcl=int($p1+($p2-$p1)*$pcl); #unif
		$pcl = gaussian_rand() * ($per_win*$window/(2*100)) + $window; # gauss with ~95% in eocl and socl
		print "$p\n";
        	print FT">S.$sno.$totalcnt.$coverage.$window.$wseqlen.$slnamews\n";
     		print FT substr($slseq,$p,$pcl),"\n";
                #print FT substr($slseq,$p,$window),"\n";
	}
}
close FT;

sub gaussian_rand {
    my ($u1, $u2);  # uniformly distributed random numbers
    my $w;          # variance, then a weight
    my ($g1, $g2);  # gaussian-distributed numbers

    do {
        $u1 = 2 * rand() - 1;
        $u2 = 2 * rand() - 1;
        $w = $u1*$u1 + $u2*$u2;
    } while ( $w >= 1 );

    $w = sqrt( (-2 * log($w))  / $w );
    $g2 = $u1 * $w;
    $g1 = $u2 * $w;
         return wantarray ? ($g1, $g2) : $g1;
}


sub get_other_source{
	my $other_file_pattern=shift;
	my $line;
	open(FO,$other_file_pattern)||die "can't open";
	my $seq;
	my $snames;
	while ($line = <FO>) {
        	chomp ($line);
       	if ($line =~ /^>/){
		$snames=$line;
		chomp $snames;
             push(@gseqname,$snames);
                	if ($seq ne ""){
              		push(@gseq,$seq);
              		$seq = "";
            	}
      	} 
		else {
			$seq=$seq.$line;
      	}
	}
	push(@gseq,$seq);
	$seq="";
	close FO;
	my $noseq=length(@gseq);
}


