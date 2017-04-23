#!/usr/bin/perl
# USAGE: gapCover.pl contigGraphFile
#use feature "switch";
use Switch 'Perl6';

sub zeroPad {
  my $val = shift(@_);
  return ($val < 10 ? '0000' : ($val < 100 ? '000' : (($val < 1000 ? '00' : ($val < 10000 ? '0' : '')))));
}
my $argc = @ARGV;

my $line;
my $line2;
my @ctg;
# $ctg[i] has info about contig with accno "i";
#   $ctg[i][0] is 5' edge array for contig
#   $ctg[i][1] is 3' edge array for contig
#   $ctg[i][2] is length of contig;
#   each element of an edge array contains:
#     accno of contig on other side of edge (e.g. contig pointed to by 2nd 5' edge of $ctg[i] is $ctg[i][0][2][0])
#     contig end (0 for 5' 1 for 3') of contig on other side of edge (e.g. end of contig pointed to by 2nd 5' edge of $ctg[i] is $ctg[i][0][2][1])
#     depth of edge  (e.g. depth of 2nd 5' edge of $ctg[i] is $ctg[i][0][2][2])


my @scaffolds;
my $connectedGaps = 0;
my $coveredGaps = 0;
my $coveredBy2 = 0;
my $numberGaps = 0;
my @ctgSeqs;
if($argc < 1) {
   print "USAGE: gapCover.pl contigGraphFile [AllContigFile]\n";
   exit(0);
}
my $graphFile= @ARGV[0];
my $contigFile;
if ($argc == 2) {
  $contigFile=@ARGV[1];
  open(READ,"$contigFile") || die "cant find $contigile\n";
  my $ctgSeq="";
  my $ctgAccno=0;
  my $prevCtgAccno=0;
  while ($line=<READ>) {
	if (($ctgAccno) = ($line =~/^>contig[0]*(\d+)/)) {
	  if ($prevCtgAccno != 0) {
	    $ctgSeqs[$prevCtgAccno]=$ctgSeq;
#		print "$ctgSeq\n";
	  }
#	  print "$ctgAccno\n";
	  $prevCtgAccno = $ctgAccno;
	  $ctgSeq = "";
	} else {
	  chomp $line;
	  chomp $ctgSeq;
	  $ctgSeq .= $line;
	}
	if ($prevCtgAccno != 0) {
	  $ctgSeqs[$prevCtgAccno]=$ctgSeq;
	}
  }
close (READ);
}
open(READ,"$graphFile") || die "cant find $graphFile\n";
open(OUTPUT,">NewScaffolds.txt");
open(my $scaffoldFastaFile, ">NewScaffolds.fna");
open(my $alternatePathsFile, ">AltPaths.txt");
open(my $extraCtgFile,">TinyContigs.fna");
while ($line=<READ>) {
  given ($line) {
    when (/^\d+\s+contig/)	{ #add contig
      my ($ctgIdx,undef, $ctgLen) = split(' ',$line);
      $ctg[$ctgIdx][2]= $ctgLen;
	  #print "Contig $ctgIdx Length = $ctg[$ctgIdx][2]\n";
    }
    when (/^C/)	{ #add edge
      my (undef,$ctg1Idx, $ctg1End, $ctg2Idx, $ctg2End, $edgeDepth) = split(' ',$line);
	#print "Contig$ctg1Idx $ctg1End to Contig$ctg2Idx $ctg2End depth = $edgeDepth\n";
	$ctg1End = ($ctg1End =~ /5/) ? 0 : 1;
	$ctg2End = ($ctg2End =~ /5/) ? 0 : 1;
      @edge1 = ($ctg2Idx, $ctg2End, $edgeDepth);
      @edge2 = ($ctg1Idx, $ctg1End, $edgeDepth);
      push @{$ctg[$ctg1Idx][$ctg1End]},[@edge1];
#if ($ctg1Idx==1645){print "\t$ctg1End' $edge1[0] $edge1[1]' $ctg2Idx\n"; }
#if ($ctg2Idx==1645){print "\t$ctg2End' $edge2[0] $edge2[1]' $ctg1Idx\n"; }
      push @{$ctg[$ctg2Idx][$ctg2End]},[@edge2];
    }
    when (/^S/)	{ #add Scaffold	  
      my ($scaffoldNumber,$linePart) = ($line =~/S\s+(\d+)\s+\d+\s+(\d+:.+)/);
      $scaffolds[$scaffoldNumber]=$linePart;
    }
    when (/^I/)	{ #add Info --- not needed yet    
	}
    when (/^F/)	{ #add Flow --- not needed yet    
	}
    when (/^P/)	{ #add Pair --- not needed yet    
	}
  }
}

#print edges
my $scaffoldSeq;
for (my $i = 1; $i <= $#scaffolds; $i++)	{
  #process scaffold[$i]
  my (@elementList) = split(';',@scaffolds[$i]);
  my $scaffoldElementNum = 1;
  my ($ctg1, $ctg1Dir) = split ':',($elementList[0]);
  my $elementStartPos += 1;
  my $elementEndPos += $ctg[$ctg1][2];
  #output first element of scaffold
  print OUTPUT "scaffold".zeroPad($i)."$i\t$elementStartPos\t".$elementEndPos."\t$scaffoldElementNum\tW\tcontig".zeroPad($ctg1)."$ctg1\t1\t".$ctg[$ctg1][2]."\t$ctg1Dir\n";
  #build scaffold sequence
  $scaffoldSeq = "";
  print $scaffoldFastaFile ">scaffold".zeroPad($i)."$i "; 
  $scaffoldSeq = $ctgSeqs[$ctg1];	#assumes we have the correct (forward) orientation of this contig in the scaffold
  $scaffoldElementNum++;  
  if ($#elementList < 2) { #single contigs scaffold
    print "Scaffold $i has no gaps\n";
  } else {
    for (my $elementIdx = 0; $elementIdx < $#elementList; $elementIdx++) { #RSW!! was elementList - 1
	  my $gapLength = 0;
	  if (($gapLength) = ($elementList[$elementIdx] =~/^gap:(\d+)/)) {
	    $numberGaps++;
	    my ($ctg1, $ctg1Dir) = split ':',($elementList[$elementIdx-1]);
	    my ($ctg2, $ctg2Dir) = split ':',($elementList[$elementIdx+1]);
		my $ctg1End = ($ctg1Dir =~ /\+/) ? 1 : 0;
		my $ctg2End = ($ctg2Dir =~ /\+/) ? 0 : 1;

		if (defined($ctg[$ctg1][$ctg1End][0][0]) && defined($ctg[$ctg2][$ctg2End][0][0])) {
		  print "Hit a gap between $ctg1 and $ctg2\n";

		  my $connectFlag = 0;
		  my $coverFlag = 0;
		  my $coveredBy2Flag = 0;
		  my @gapScaffolds;
		  my $bestGapScaffoldNumber = 0;
		  my $gapScaffoldNumber = 0;
		  my $bestEdgeDepth = 0;  #not sure if this is the best way to do this!!!
		  for (my $j=0; defined($ctg[$ctg1][$ctg1End][$j][0]); $j++) {
		    #if we find this edge connects to the other contig flanking the gap in the wrong orientation, print warning
			if (($ctg[$ctg1][$ctg1End][$j][0] == $ctg2) && !($ctg[$ctg1][$ctg1End][$j][1] == $ctg2End) ) {
			  print "WARNING $ctg1 connects to the wrong End of $ctg2 ($ctg[$ctg1][$ctg1End][$j][1])\n";
			}
			if (($ctg[$ctg1][$ctg1End][$j][0] == $ctg2) && ($ctg[$ctg1][$ctg1End][$j][1] == $ctg2End) ) {
		      $gapScaffolds[$gapScaffoldNumber]="$ctg2:$ctg2Dir";
			    if (($ctg[$ctg1][$ctg1End][$j][2] > $bestEdgeDepth)) {
			    $bestEdgeDepth = $ctg[$ctg1][$ctg1End][$j][2];
				$bestGapScaffoldNumber = $gapScaffoldNumber;
			  }
			  print "$ctg1 connects to $ctg2.  End $ctg[$ctg1][$ctg1End][$j][1]\n";
			  $gapScaffoldNumber++;			  
			  $connectFlag += 1;
			}
		    for (my $k=0; defined($ctg[$ctg2][$ctg2End][$k][0]); $k++) {
			  #first check to see if a single contig covers the gap
		      if (($ctg[$ctg1][$ctg1End][$j][0] == $ctg[$ctg2][$ctg2End][$k][0]) && ($ctg[$ctg1][$ctg1End][$j][1] != $ctg[$ctg2][$ctg2End][$k][1])) {
				my $coverCtg1 = $ctg[$ctg1][$ctg1End][$j][0];
				my $coverCtg1Dir = ($ctg[$ctg1][$ctg1End][$j][1] == 0) ? '+' : '-';
		        print "covered by $coverCtg1\n";
		        $gapScaffolds[$gapScaffoldNumber]="$coverCtg1:$coverCtg1Dir;$ctg2:$ctg2Dir";
			    if (($ctg[$ctg1][$ctg1End][$j][2] > $bestEdgeDepth)) {
			      $bestEdgeDepth = $ctg[$ctg1][$ctg1End][$j][2];
				  $bestGapScaffoldNumber = $gapScaffoldNumber;
			    }
			  $gapScaffoldNumber++;
			    $coverFlag += 1;
			  } else { #see if two contigs can cover the gap
			    my $ctg2NextCtg = $ctg[$ctg2][$ctg2End][$k][0];
				my $ctg2NextCtgEnd = ($ctg[$ctg2][$ctg2End][$k][1] == 0) ? 1 : 0;
				for (my $l=0; defined($ctg[$ctg2NextCtg][$ctg2NextCtgEnd][$l][0]); $l++) {
			      if (($ctg[$ctg1][$ctg1End][$j][0] == $ctg[$ctg2NextCtg][$ctg2NextCtgEnd][$l][0]) && ($ctg[$ctg1][$ctg1End][$j][1] != $ctg[$ctg2NextCtg][$ctg2NextCtgEnd][$l][1])) {
					my $coverCtg1 = $ctg[$ctg1][$ctg1End][$j][0];
					my $coverCtg1Dir = ($ctg[$ctg1][$ctg1End][$j][1] == 0) ? '+' : '-';
					my $coverCtg2 = $ctg[$ctg2][$ctg2End][$k][0];
					my $coverCtg2Dir = ($ctg[$ctg2][$ctg2End][$k][1] == 0) ? '-' : '+';	#we're working our way into the gap from the 3' side; but, we need the direction from the 5' side
    		        print "covered by $ctg[$ctg1][$ctg1End][$j][0] and $ctg[$ctg2][$ctg2End][$k][0]\n";
		            $gapScaffolds[$gapScaffoldNumber]="$coverCtg1:$coverCtg1Dir;$coverCtg2:$coverCtg2Dir;$ctg2:$ctg2Dir";
			        if (($ctg[$ctg1][$ctg1End][$j][2] > $bestEdgeDepth)) {
			          $bestEdgeDepth = $ctg[$ctg1][$ctg1End][$j][2];
				      $bestGapScaffoldNumber = $gapScaffoldNumber;
			        }
				  $gapScaffoldNumber++;
				  $coveredBy2Flag += 1;
				  }
			    }
			  }
			}
		  }
		  if (($coverFlag == 0) && ($coveredBy2Flag == 0) && ($connectFlag == 0)) {
		    print "Uncovered $gapLength bp gap\n";
            $gapScaffolds[$gapScaffoldNumber]="gap:$gapLength;$ctg2:$ctg2Dir";
			  $gapScaffoldNumber++;
		  } elsif ($connectFlag != 0) {
		    $connectedGaps += 1;		  
		  } elsif ($coverFlag != 0) {
			$coveredGaps += 1;
		  } else {
			$coveredBy2 += 1;
		  }
		  #output best scaffold
		  print "BEST GAP SCAFFOLD BestGSNumber $bestGapScaffoldNumber ".$gapScaffolds[$bestGapScaffoldNumber]."\n";
		  #output gap closure information into scaffold file (just eliminate gap in scaffold) or $alternatePathsFile 
		  for (my $gapScafNum = 0; $gapScafNum < $#gapScaffolds; $gapScafNum++) {
		    if ($gapScafNum == $bestGapScaffoldNumber) {
			  break;
			}
			my $tElementEndPos = $elementEndPos;
			my $tElementStartPos = $elementStartPos;
			my $tScaffoldElementNum = $scaffoldElementNum;
		    my (@gapElementList) = split(';',@gapScaffolds[$gapScafNum]);
			print $alternatePathsFile "AltPath contig".zeroPad($ctg1)."$ctg1 to contig".zeroPad($ctg2)."$ctg2\n";
			if ( $#gapElementList == 0) {
			  my ($ctg1, $ctg1Dir) = split ':',($gapElementList[0]);
			  print $alternatePathsFile "scaffold".zeroPad($i)."$i\t$tElementStartPos\tdirect connection to $ctg1\n"; # LN modified: added scaffold number and startposition
			}
		    for (my $elementIdx = 0; $elementIdx < $#gapElementList; $elementIdx++) { #RSW!! was <= gapElementList 
  	          my ($ctg1, $ctg1Dir) = split ':',($gapElementList[$elementIdx]);
		      $tElementStartPos = $tElementEndPos + 1;
	  	      if ($ctg1 =~/gap/) {
		        $tElementEndPos = $tElementStartPos + $gapLength - 1;
			    print $alternatePathsFile "scaffold".zeroPad($i)."$i\t$tElementStartPos\t$tElementEndPos\t$tScaffoldElementNum\tN\t$gapLength\tfragment\tyes\n";
		      } else {
		        $tElementEndPos = $tElementStartPos + $ctg[$ctg1][2] - 1;
		        print $alternatePathsFile "scaffold".zeroPad($i)."$i\t$tElementStartPos\t".$tElementEndPos."\t$tScaffoldElementNum\tW\tcontig".zeroPad($ctg1)."$ctg1\t1\t".$ctg[$ctg1][2]."\t$ctg1Dir\n";
		      }
		      $tScaffoldElementNum++;
		    }
		  }


		  my (@gapElementList) = split(';',@gapScaffolds[$bestGapScaffoldNumber]);
		  for (my $elementIdx = 0; $elementIdx <= $#gapElementList; $elementIdx++) { #RSW!! was elementList - 1
  	        my ($ctg1, $ctg1Dir) = split ':',($gapElementList[$elementIdx]);
		    $elementStartPos = $elementEndPos + 1;
	  	    if ($ctg1 =~/gap/) {
		      $elementEndPos = $elementStartPos + $gapLength - 1;
			  print OUTPUT "scaffold".zeroPad($i)."$i\t$elementStartPos\t$elementEndPos\t$scaffoldElementNum\tN\t$gapLength\tfragment\tyes\n";
			  for (my $i = $gapLength; $i > 0; $i--)	{
			    $scaffoldSeq .= 'N';
			  }
		    } else {
		      $elementEndPos = $elementStartPos + $ctg[$ctg1][2] - 1;
		      print OUTPUT "scaffold".zeroPad($i)."$i\t$elementStartPos\t".$elementEndPos."\t$scaffoldElementNum\tW\tcontig".zeroPad($ctg1)."$ctg1\t1\t".$ctg[$ctg1][2]."\t$ctg1Dir\n";
			  if ($ctg1Dir eq '+') {
			    $scaffoldSeq .= $ctgSeqs[$ctg1];
			  } else { #revcomp the contig
#			  print "REVERSE COMPLEMENTING 2 ".$ctgSeqs[$ctg1]."\n"; # LN commented out
	  		    my $tRevComp = reverse($ctgSeqs[$ctg1]);
				$tRevComp  =~ tr/ACGTacgt/TGCAtgca/;
#			  print "REVERSE COMPLEMENTED 2 ".$tRevComp."\n";	# LN commented out
			    $scaffoldSeq .= $tRevComp;
			  }
		    }
		    $scaffoldElementNum++;
		  }
		} else { 
		  #process gap that can't be closed
		  print "uncoverable $gapLength gap between $ctg1 and $ctg2\n";
          $gapScaffolds[$gapScaffoldNumber]="gap:$gapLength;$ctg2:$ctg2Dir";
			  $gapScaffoldNumber++;
		  
		  #for each flanking contig end with no edges, show 50bp leading into gap.
		  my $numZeroEdgeContigs = 0;
	 	  if (!defined($ctg[$ctg1][$ctg1End][0][0])) {
		    my $ctgLen = $ctg[$ctg1][2];
			my $ctgSeq=$ctgSeqs[$ctg1];
#			print "Contig $ctg1 : $ctgSeq\n";
		    print "$ctgLen bp Contig $ctg1 ".(($ctg1End == 0) ? "5'" : "3'")." has no edges ".(($ctg1End == 0) ? substr $ctgSeq,0,50 : substr $ctgSeq,-50)."\n";
		    $numZeroEdgeContigs++;
		  }
	 	  if (!defined($ctg[$ctg2][$ctg2End][0][0])) {
		    my $ctgLen = $ctg[$ctg2][2];
			my $ctgSeq=$ctgSeqs[$ctg2];
#			print "Contig $ctg2 : $ctgSeq\n";
		    print "$ctgLen bp Contig $ctg2 ".(($ctg2End == 0) ? "5'" : "3'")." has no edges ".(($ctg2End == 0) ? substr $ctgSeq,0,50 : substr $ctgSeq,-50)."\n";
		    $numZeroEdgeContigs++;
		  }
		  print "$numZeroEdgeContigs ZeroEdgeContigs\n";
		  $elementStartPos = $elementEndPos + 1;
	      $elementEndPos = $elementStartPos + $gapLength - 1;
		  print OUTPUT "scaffold".zeroPad($i)."$i\t$elementStartPos\t$elementEndPos\t$scaffoldElementNum\tN\t$gapLength\tfragment\tyes\n";
		  for (my $i = $gapLength; $i > 0; $i--)	{
		    $scaffoldSeq .= 'N';
		  }
		  $scaffoldElementNum++;
		  $elementStartPos = $elementEndPos + 1;
		  $elementEndPos = $elementStartPos + $ctg[$ctg2][2] - 1;
		  print OUTPUT "scaffold".zeroPad($i)."$i\t$elementStartPos\t".$elementEndPos."\t$scaffoldElementNum\tW\tcontig".zeroPad($ctg2)."$ctg2\t1\t".$ctg[$ctg2][2]."\t$ctg2Dir\n";
		  #if needed, Revcomp $ctg2
#TBD RSW!!!		  $dna = reverse $dna;
#		  $dna =~ tr/ACGTacgt/TGCAtgca/;
		  if ($ctg2Dir eq '+') {
		    $scaffoldSeq .= $ctgSeqs[$ctg2];
		  } else { #revcomp the contig
		    my $tRevComp = reverse($ctgSeqs[$ctg2]);
			$tRevComp  =~ tr/ACGTacgt/TGCAtgca/;
		    $scaffoldSeq .= $tRevComp;
		  }
		  #assumes orientation of $ctg2 is the same as the scaffold 
		  #$scaffoldSeq .= $ctgSeqs[$ctg2]; 	# LN commented out this line as it lead to a second instance of $ctg2 added to the file
		  $scaffoldElementNum++;
		}
	  }
	}
  }
  my $scaffoldLength = length($scaffoldSeq);
  print $scaffoldFastaFile "length=$scaffoldLength\n"; # LN modified from "length=\t$scaffoldLength\n" so that it is the same as for the other files
  my $pos = 0;
  #assumes scaffold minimum length of 60bp
  do {
    for (my $i=$pos; $i < $pos+60; $i++)	{
	  print $scaffoldFastaFile substr($scaffoldSeq,$i,1);
	}
	print $scaffoldFastaFile "\n";
    $pos+=60;
  } while ($pos < ($scaffoldLength - 60));
  print $scaffoldFastaFile substr($scaffoldSeq,$pos,$scaffoldLength - $pos)."\n";   
}
print "Total Gaps = $numberGaps   Gaps that aren't there = $connectedGaps   Gaps Covered By 1 Contig = $coveredGaps    Gaps Covered By 2 Contigs = $coveredBy2\n";
close(READ);
close(OUTPUT);
close($extraCtgFile);
close($alternatePathsFile);
close($scaffoldFastaFile);