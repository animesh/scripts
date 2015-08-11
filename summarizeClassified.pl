#!/usr/bin/perl -w


$good=0;
$chim=0;
$tot=0;
$stuff=0;
$separation=0;
while (<>) {
  if (!/^(\d+) /)  { next; }
  $count = $1;
  if (/(\d+\.\d+) \+.*, (\d+) chimeras/) {
      $separation += $1 * $count;
    $chim += $2;
    $tot += $count;
    $good += $count;
  } 
  elsif (/R/) {
  }
  else {
    $tot += $count;
    if (/GS[^S]*g/) {
      #print("detected reversed chimera: $_");
      $chim++;
    }
  }
  if (/S/) {
      $stuff+= $count;
  }
}
$goodper = 100 * $good / $tot;
$chimper = 100 * $chim / $good;
$separation = $separation / $good;
print ("total $tot, stuffer $stuff, useful $good ($goodper%), chimeras $chimper%, separation $separation\n");
