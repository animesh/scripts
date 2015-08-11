#!/usr/local/bin/perl

# tiling2cam.pl - creates a celamy file from show-tiling output

my $PAD = 100;

my $refColor = "0refColor: CFF0000 T2 S \# reference";
my $refColorName = "0refColor";
my $queryForwColor = "1quForwColor: C00FF00 T2 S \# forward query";
my $queryForwName = "1quForwColor";
my $queryRevColor = "2quRevColor: C008F00 T2 S \# reverse query";
my $queryRevName = "2quRevColor";
my $offset = 0;
my $nq = 0;
my $nr = 0;

print "$refColor\n";
print "$queryForwColor\n";
print "$queryRevColor\n";

open(IN, $ARGV[0]) || die ("Cannot open $ARGV[0]: $!\n");

my $lastline = "";
while ($lastline !~ /^>/){
    $lastline = <IN>;
}

do {
    print STDERR "got $lastline\n";
    $lastline =~ /^>(\S+) (\d+)/;
    my $refName = $1;
    my $reflen = $2;
    my $firstguy = 1;
    $lastline = <IN>;
    while ($lastline !~ /^>/){
	chomp($lastline);
	my @fields = split(' ', $lastline);

	if ($firstguy){
	    if ($fields[0] < 0){
		$offset -= $fields[0];
	    }
	    $firstguy = 0;
	    print "${nr}ref: ", $offset + 1, " A$refColorName ", $offset + $reflen, 
	    " R1 \# $refName\n";
	    $nr++;
	}

	my $col = "";
	if ($fields[6] eq "-") {
	    $col = $queryRevName;
	} else {
	    $col = $queryForwName;
	}

	print "${nq}qu: ", $offset + $fields[0], " A$col ", $offset + $fields[1],
	" R2 \# $fields[7] ($fields[0], $fields[1])\n";
	$nq++;
	if (eof(IN)){
	    last;
	}
	$lastline = <IN>;
	if ($lastline =~ /^>/){
	    $offset += $reflen + $PAD;
	    if ($fields[2] < 0){
		$offset -= $fields[2];
	    }
	    last;
	}
    }


    if (eof(IN)){
	exit(0);
    }

} while (1);


close(IN);

