#!/usr/bin/perl -w

# Count how many almost identical jumps there are in a library.
# Outputs to stdout a list of jumps with the number of identical ones found as the first column.

(@ARGV > 0) || die "You need the prefix as an argument";

$p = $ARGV[0];
print "$p\n";

system("ExtractJumpingReads IN=$p.annotations OUT=$p.goodstuffer.fasta GOOD_ONLY=False READS=$p.fasta > $p.goodstuffer.txt");
exit;
system("ExtractJumpingReads IN=$p.G.V.annotations OUT=$p.jumping.fasta GOOD_ONLY=True READS=$p.fasta > $p.jumps.txt");
system('Col Col 7 8 14 15 < $p.jumps.txt | tr -d ")" | sort -n > $p.jumps.sorted.txt');
open(INFILE, "$p.jumps.sorted.txt");

@last=(-1,-1,-1,-1);
$count=1;
$MAXDIFF = 5;

while (<INFILE>) {
  if (/(\d+\s+\d+\s+\d+\s+\d+)/) {
    @current = split('\s',$1);
    #print "@current @last \n";
    #print abs($current[0] -$last[0]), " ", abs($current[1] -$last[1]), " ", abs($current[2] -$last[2]) " ",  abs($current[2] -$last[3]
			       
    if ( (abs($current[0] -$last[0]) < $MAXDIFF) +
	 (abs($current[1] -$last[1]) < $MAXDIFF) +
	 (abs($current[2] -$last[2]) < $MAXDIFF) +
	 (abs($current[3] -$last[3]) < $MAXDIFF) > 2) {
      ++$count;
    } else {
      print "$count,  jump @last\n";
      @last = @current;
      $count = 1;
    }
  }
}

