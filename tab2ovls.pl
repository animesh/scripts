#!/usr/local/bin/perl

$MARGIN = 20;

if (defined $ARGV[2] && $ARGV[2] eq "tab"){
    $tab = 1;
} else {
    $tab = 0;
}

# load in map of IDs to contig lengths

if ($ARGV[1] ne "nuc") {
    open(LENS, $ARGV[1]) || die ("Cannot open $ARGV[1]: $!\n");
    
    while (<LENS>){
	chomp;

	($id, $len) = split(' ', $_);
	$lens{$id} = $len;
    }
    close(LENS);
}

$inhead = 1;
open(TAB, $ARGV[0]) || die ("Cannot open $ARGV[0]: $!\n");
while (<TAB>){
    @elements = split;

#    print join('|', @elements), "\n";
# here we collect the data
    if ($ARGV[1] ne "nuc"){
	$contig1 = $elements[0];
	$contig2 = $elements[1];
    } else {
	$contig1 = $elements[11];
	$contig2 = $elements[12];
    }
    if ($contig1 eq $contig2){ next;}

    if ($ARGV[1] ne "nuc"){
	$reflen = $lens{$contig1}; 
	$querylen = $lens{$contig2};
	$refl = $elements[6];
	$refr = $elements[7];
	$queryl = $elements[8];
	$queryr = $elements[9];
    } else {
	$reflen = $elements[7]; 
	$lens{$contig1} = $elements[7];
	$querylen = $elements[8];
	$lens{$contig2} = $elements[8];
	$refl = $elements[0];
	$refr = $elements[1];
	$queryl = $elements[2];
	$queryr = $elements[3];
    }

# keep track of where each query contig hits

    if ($refl > $refr){
	print "Wierd\n";
    }
    
    $refbeg = 
	($refl < $MARGIN) ? 1 : 0;
    $refend = 
	($reflen - $refr < $MARGIN) ? 1 : 0;
    $queryforw = 
	($queryl < $queryr) ? 1 : 0;
    $querybeg = 
	($queryl < $MARGIN || $queryr < $MARGIN) ? 1 : 0;
    $queryend = 
	($querylen - $queryl < $MARGIN || $querylen - $queryr < $MARGIN) 
	    ? 1 : 0;

    # find out if the alignment is "proper".  
		# only print matches that hit the end of the query
    if ($querybeg && $queryend){
	$matches{$contig1} .= "$contig2 $queryl $queryr 0 0 ";
    } elsif (($refend && $querybeg && $queryforw) ||
	     ($refend && $queryend && ! $queryforw) |
	     ($refbeg && $queryend && $queryforw) ||
	     ($refbeg && $querybeg && ! $queryforw)) {
	$matches{$contig1} .= 
	    "$contig2 $queryl $queryr $refl $refr ";
    }
}
close(NUCS);

$n = 0;
while (($ctg, $mtch) = each %matches){
    @fields = split(' ', $mtch);
    %match = ();

    $n++;

# pick the matches in groups of 5.
    if ($tab == 1){
	for ($j = 0; $j <= $#fields; $j += 5){
	    if (exists $seen{$ctg}) {next;}
	    print "$ctg($lens{$ctg})\t$fields[$j+3]\t$fields[$j+4]\t$fields[$j]($lens{$fields[$j]})\t$fields[$j+1]\t$fields[$j+2]\n";
	    $seen{$fields[$j]} = 1;
	}
    } else {
	print "$n:$ctg($lens{$ctg})\n";
	for ($j = 0; $j <= $#fields; $j += 5){
	    print "\t$fields[$j]($lens{$fields[$j]}) ", join(" ", @fields[($j + 1) .. ($j + 2)]), " - ", join(" ", @fields[($j + 3) .. ($j + 4)]), "\n";
	}
    }
}

exit(0);
