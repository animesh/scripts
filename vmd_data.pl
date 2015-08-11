#!/usr/bin/env perl

# make the data file for VMD

sub seminumerically { $a=~/([0-9]*)/; $q = $1; $b =~/([0-9]*)/; $q <=> $1 }
@files = sort seminumerically <*.points>;
$count = 0;
open(OUTFILE, ">DrawMolItemSolventPoints.data");
foreach $file (@files) {
    # print the points
    $file =~ /([0-9]*)/;
    $num_points = $1;
    open(INFILE, "<$file");
    print OUTFILE "static float dot_surface_points_$count [] = {\n";
    foreach $_ (<INFILE>) {
	@data = split;
	printf OUTFILE "%4.3ff, %4.3ff, %4.3ff,\n", $data[0],$data[1],$data[2];
    }
    print OUTFILE "};\n";
    close(INFILE);
    # print the lines
    $lines = $file;
    $lines =~ s/points/lines/;
#    print "Lines->$lines\n";
    open(INFILE, "<$lines");
    print OUTFILE "static int dot_surface_lines_$count [] = {\n";
    $num_edges = 0;
    foreach (<INFILE>) {
	@data = split;
	print OUTFILE "$data[0],$data[1],\n";
	$num_edges ++;
    }
    print OUTFILE "};\n";
    close(INFILE);

    $info_points[$count] = $num_points;
    $info_edges[$count] = $num_edges;
    $count++;
}

# and make the arrays
print OUTFILE "static float *dot_surface_points[] = {\n";
for($i=0; $i<$count; $i++) {
    print OUTFILE "dot_surface_points_$i,\n";
}
print OUTFILE "};\n";
print OUTFILE "static int dot_surface_num_points[] = {\n";
for($i=0; $i<$count; $i++) {
    print OUTFILE "$info_points[$i],\n";
}
print OUTFILE "};\n";


print OUTFILE "static int *dot_surface_lines[] = {\n";
for($i=0; $i<$count; $i++) {
    print OUTFILE "dot_surface_lines_$i,\n";
}
print OUTFILE "};\n";
print OUTFILE "static int dot_surface_num_lines[] = {\n";
for($i=0; $i<$count; $i++) {
    print OUTFILE "$info_edges[$i],\n";
}
print OUTFILE "};\n";

print OUTFILE "int DrawMolItem::num_dot_surfaces = $count;\n";
close(OUTFILE);
