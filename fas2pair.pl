#!/usr/bin/perl
use strict;
my $main_file=shift @ARGV;
my $coverage=shift @ARGV;
my $window=100;
my $per_win=100;
#my $socl=$window*(1-$per_win/100);
#my $eocl=$window*(1+$per_win/100);
my @randy=qw/3000 8000 20000 150000/;

my @gseq;
my @gseqname;
my $fot;
my $fas_file=$main_file.".pairedread.fasta";
open(FT,">$fas_file");

get_other_source($main_file);

for($fot=0;$fot<=$#gseq;$fot++){
	my $slname=@gseqname[$fot];
	my $slseq=@gseq[$fot];
	my $wseqlen=length($gseq[$fot]);
	my $sno;
	my $totalcnt=$coverage;
	my $slnamews=$slname;$slnamews=~s/^>//;
	print "SL-$wseqlen SN-$slname TC-$totalcnt\n";
	for(my $c=0;$c<$totalcnt;$c++){
# 	for(my $c=0;$c<0;$c++){
   		$sno++;
		my $chlen=$randy[int(rand(3))];
		my $p=int(rand($wseqlen-$chlen-$per_win));
 	       	my $p1=$p;
        	my $p2=$p+$chlen;
		my $mf=$main_file;
		$mf=~s/\.fna//;
		my $template=$mf.$sno;
		#>DJS045A03F template=DJS054A03 dir=F library=DJS045 trim=12-543
        	my $name=">S.$sno.$totalcnt.$coverage.$window.$wseqlen.$slnamews";
		print FT">$mf.$sno.F.$p1.$p2.$chlen.$per_win template=$template dir=F library=$mf\n";
     		print FT substr($slseq,$p1,$per_win),"\n";
		print FT">$mf.$sno.R.$p1.$p2.$chlen.$per_win template=$template dir=R library=$mf\n";
		my $revstr=substr($slseq,$p2,$per_win);
		$revstr=reverse($revstr);
		$revstr=~tr/ATGC/TACG/;
     		print FT $revstr,"\n";
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


