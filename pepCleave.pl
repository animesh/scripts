#!/usr/bin/perl
use strict;
use warnings;
use File::Basename;

# Monoisotopic masses of amino acid residues
my %MONOISOTOPIC_MASS = (
    'A' => 71.03711, 'R' => 156.10111, 'N' => 114.04293, 'D' => 115.02694, 'C' => 103.00919,
    'E' => 129.04259, 'Q' => 128.05858, 'G' => 57.02146, 'H' => 137.05891, 'I' => 113.08406,
    'L' => 113.08406, 'K' => 128.09496, 'M' => 131.04049, 'F' => 147.06841, 'P' => 97.05276,
    'S' => 87.03203, 'T' => 101.04768, 'W' => 186.07931, 'Y' => 163.06333, 'V' => 99.06841,
    'U' => 150.95363, 'O' => 237.14773
);

sub calculate_monoisotopic_mass {
    my ($peptide) = @_;
    my $mass = 18.01056; # H2O for termini
    foreach my $aa (split //, $peptide) {
        if (exists $MONOISOTOPIC_MASS{$aa}) {
            $mass += $MONOISOTOPIC_MASS{$aa};
        }
    }
    return $mass;
}

sub test_mass_equality {
    my $p1 = "LSLAQEDLISNR";
    my $p2 = "GSLLLGGLDAEASR";
    my $m1 = calculate_monoisotopic_mass($p1);
    my $m2 = calculate_monoisotopic_mass($p2);
    
    print "Test: Comparing '$p1' and '$p2'\n";
    print "Length $p1: " . length($p1) . "\n";
    print "Length $p2: " . length($p2) . "\n";
    printf "Mass $p1: %.4f\n", $m1;
    printf "Mass $p2: %.4f\n", $m2;
    
    my $diff = abs($m1 - $m2);
    printf "Difference: %.4f\n", $diff;
    
    if ($diff < 0.0001) {
        print "Result: Masses are EQUAL\n";
    } else {
        print "Result: Masses are DIFFERENT\n";
    }
}

# Run the test
test_mass_equality();

my $fastaF = $ARGV[0] // "L:/promec/FastaDB/UP000005640_9606_unique_gene.fasta";
my $minLen = $ARGV[1] // 10;
my $maxLen = $ARGV[2] // 30;

my $fastaFO = "$fastaF.len${minLen}to${maxLen}.fasta";
print "Generating subsequences from $fastaF\n";
print "minLen $minLen maxLen $maxLen -> writing to $fastaFO\n";

open(my $fh, '<', $fastaF) or die "Could not open file '$fastaF' $!";
open(my $out, '>', $fastaFO) or die "Could not open file '$fastaFO' $!";

my %unique_peptides;
my $count_written = 0;

my $description = "";
my $sequence = "";

sub process_sequence {
    my ($desc, $seq) = @_;
    return unless $desc;
    
    my $seqlen = length($seq);
    my $sid = (split /\s+/, $desc)[0];
    
    for (my $i = 0; $i <= $seqlen - $minLen; $i++) {
        for (my $L = $minLen; $L <= $maxLen; $L++) {
            last if ($i + $L > $seqlen);
            
            my $peptide = substr($seq, $i, $L);
            next if exists $unique_peptides{$peptide};
            
            $unique_peptides{$peptide} = 1;
            
            my $mass = calculate_monoisotopic_mass($peptide);
            my $start = $i + 1;
            my $end = $i + $L;
            
            my $header = ">$sid|$start-$end len=$L mass=" . sprintf("%.4f", $mass) . " O=$seqlen $desc";
            print $out "$header\n$peptide\n";
            $count_written++;
        }
    }
}

while (my $line = <$fh>) {
    chomp $line;
    next if $line =~ /^\s*$/;
    
    if ($line =~ /^>(.*)/) {
        process_sequence($description, $sequence) if $description;
        $description = $1;
        $sequence = "";
    } else {
        $sequence .= $line;
    }
}
process_sequence($description, $sequence) if $description;

close $fh;
close $out;

print "Done, wrote $count_written unique subsequences\n";

# Amino Acid Composition
my $peptideCombined = join("", keys %unique_peptides);
if ($peptideCombined) {
    my %aaCnt;
    foreach my $aa (split //, $peptideCombined) {
        $aaCnt{$aa}++;
    }
    
    print "\nAmino Acid Composition:\n";
    foreach my $aa (sort keys %aaCnt) {
        print "$aa: $aaCnt{$aa}\n";
    }
}

