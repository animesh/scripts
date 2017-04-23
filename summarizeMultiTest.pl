#!/usr/local/bin/perl

my @heads = ("TotalScaffolds", "TotalContigsInScaffolds", "N50ScaffoldBases", "N50ContigBases");

open(OUT, ">runtest.out") || die("Cannot open runtest.out: $!\n");
open(LOG, "runtest.log") || die("Cannot open runtest.log: $!\n");

$_ = <LOG>;  # skip the header line

my @fields = split(' ', $_);
print OUT join ("\t", @fields[1..6]);
for (my $i = 0; $i <= $#heads; $i++){
    print OUT "\t$heads[$i]";
}
print OUT "\n";

while (<LOG>){
    my @fields = split(' ', $_);
    my %recs = ();
    
    
    open(QC, "test_$fields[0].qc") || next;
    while (<QC>){
	chomp;
	$_ =~ /(\S+)(=|\s+)(\S+)/;
	$recs{$1} = $3;
    }
    close(QC);
    print OUT join("\t", @fields[1..6]);
    for (my $i = 0; $i <= $#heads; $i++){
	print OUT "\t$recs{$heads[$i]}";
    }
    print OUT "\n";
}
close(LOG);
