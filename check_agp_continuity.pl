#!/util/bin/perl -w
#
#  Check that agp coordinates are self-consistent.  
#
#  Currently that means that the stop coordinate of one entry
#  is one base away from the start coordinate of the next entry.
#

$chr = 'chr1';

$prev_stop = 0;

while ( <> ) {
  @_ = split( /\t/, $_ );
  
  $start_coord = $_[1];
  $stop_coord = $_[2];

  if ( $chr eq $_[0]) {
    
    if ( ($start_coord - $prev_stop) != 1 ) {
      die "Inconsistent start!\n $prev_stop $start_coord \n $_ \n";
    }

  } else {
    $chr = $_[0];
  }

  $prev_stop = $stop_coord;
}
