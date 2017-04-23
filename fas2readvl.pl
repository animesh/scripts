#!/usr/bin/perl

use strict;
my $coverage=25;
my $window=250;
my $main_file=shift @ARGV;
my @gseq;
my @gseqname;
my $fot;
my $socl=200;
my $eocl=300;
my $totalalength;

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
		my $totalcntn=int($totalcnt);
	   	$sno++;
		my $p1=$socl;
		my $p2=$eocl;
		my $pcl=(rand(1));
		$pcl=int($p1+($p2-$p1)*$pcl);
		my $p=int(rand($wseqlen-$pcl));
		#my $p=int(rand($wseqlen-$window));
		$totalalength+=$pcl;
		my $fracgen=sprintf("%.2f",$totalalength/$wseqlen);	
	    	print "S#-$sno\tStart-$p\tLength-$pcl\tTC-$totalcnt\tC-$coverage\tFrac-$fracgen\tTL2-$totalalength\n";
   		#$sno++;
    		#print "$sno\t$p\t$totalcnt\t$coverage\n";
        	print FT">S.$sno.$totalcntn.$pcl.[$p].$totalalength.($fracgen).$window.($wseqlen).$slnamews\n";
	     	print FT substr($slseq,$p,$pcl),"\n";
        	#print FT">S.$sno.$totalcnt.$window.$wseqlen.$slnamews\n";
     		#print FT substr($slseq,$p,$window),"\n";
	}
}


close FT;


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
	return(\@gseqname,\@gseq,$noseq);
}





