use lib '/scratch/bac2fish/BioPerl-1.6.1';
use strict;
use Bio::SearchIO; 
my $f=shift @ARGV;
open(FO,">$f.pb");
chomp $f;
my $lent=10;
my $pert=10;
my $eval=5*10e-2;
my $gapa=5*10e2;
my %alignlen;
my %alignspan;
my %alignmin;
my %alignmax;
my %alignevalc;
my $in = new Bio::SearchIO(-format => 'blast', 
                           -file   => $f);
while( my $result = $in->next_result ) {
  ## $result is a Bio::Search::Result::ResultI compliant object
  while( my $hit = $result->next_hit ) {
    ## $hit is a Bio::Search::Hit::HitI compliant object
    my $min;
    my $max;
    my $oldmin;
    my $oldmax;
    $alignmin{$hit->name} = 10e100;
    $alignmax{$hit->name} = -10e100;
    while( my $hsp = $hit->next_hsp ) {
      ## $hsp is a Bio::Search::HSP::HSPI compliant object
      if( $hsp->length('total') > $lent ) {
        if ( $hsp->percent_identity >= $pert && $hsp->evalue <= $eval ) {
	  if ($hsp->start('hit') < $hsp->end('hit')) {
	   $min=$hsp->start('hit');
	   $max=$hsp->end('hit');
	  }
          else {
           $min=$hsp->end('hit');
           $max=$hsp->start('hit');
          }
          if ( $alignmin{$hit->name} > $min ) { $oldmin=$alignmin{$hit->name}; $alignmin{$hit->name} = $min ;}
          if ( $alignmax{$hit->name} < $max) { $oldmax=$alignmax{$hit->name} ;$alignmax{$hit->name} = $max ;}
          if ( ($oldmin-$min) > $gapa && $oldmin!=10e100)  { $alignmin{$hit->name} = $oldmin ;}
          if ( ($max-$oldmax) > $gapa && $oldmax!=-10e100) { $alignmax{$hit->name} = $oldmax ;}
          $alignspan{$hit->name}=$alignmax{$hit->name}-$alignmin{$hit->name}+1;
          $alignlen{$hit->name}+=($hsp->percent_identity*$hsp->length('total')/100);
          $alignevalc{$hit->name}+=$hsp->evalue;
	   print "Query=",   $result->query_name,
            " Hit=",        $hit->name,
            " HitL=",        $hit->num_hsps,
            " Length=",     $hsp->length('total'),
            " Percent_id=", $hsp->percent_identity,
            " E-value=", $hsp->evalue, 
            " accumulated length=", $alignlen{$hit->name} , 
            " L match =", $alignspan{$hit->name} , 
            " Min =", $alignmin{$hit->name} , 
            " Max=", $alignmax{$hit->name} , 
            " Start=", $hsp->start('hit'), 
            " End=", $hsp->end('hit'), "\n";
	
        }
      }
    }  
  }
}
foreach my $hitm (sort {$alignlen{$b}<=>$alignlen{$a}} keys %alignlen) {
	print FO"$hitm\t$alignlen{$hitm}\t$alignevalc{$hitm}\t$alignspan{$hitm}\t$alignmin{$hitm}\t$alignmax{$hitm}\t\n";
}
