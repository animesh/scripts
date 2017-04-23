#!/usr/bin/env perl
# make the point distribution files for VMD
# Creates 3 files - the vrml output (with the convex hull)
# then files extracting the points and lines

for($n = 30; $n < 256; $n *= 1.2) {
    $n = int($n);
    `./distribute -nbody $n -vrml $n.vrml`;
    `grep -v VRML $n.vrml | awk 'NF==3 {print \$1,\$2,\$3}' | sed s/,// > $n.points`;
    open(INFILE, "<$n.vrml");
    open(POINTS, ">$n.lines.tmp");
    while (<INFILE>) {
	s/,//g;
	@data = split;
	next if ($#data) != 3;
	print POINTS "$data[0] $data[1]\n$data[1] $data[2]\n";
    }
    close(POINTS);
    `cat $n.lines.tmp | sort -n | uniq > $n.lines`;
    unlink("$n.lines.tmp");
}

