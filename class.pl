#!/usr/bin/perl
#read in data for mw:
$allowed="ACDEFGHIKLMNPQRSTVWY";# Supported amino acids
$water=18.0152;                 # mol wt of H2O (added decimals, since
                                # it's multiplied by no_aa-1).
                                # molecular weights
%aawt=('A', 89.09, 'C', 121.16, 'D', 133.10, 'E', 147.13, 'F', 165.19,
       'G', 75.07, 'H', 155.16, 'I', 131.18, 'K', 146.19, 'L', 131.18,
       'M',149.21, 'N', 132.12, 'P', 115.13, 'Q', 146.15, 'R', 174.20,
       'S',105.09, 'T', 119.12, 'V', 117.15, 'W', 204.23, 'Y', 181.19);
$protein="";
print "What is the filename containing the sequences? ";
$name = <STDIN>;
chomp($name);
print "The sequence filename is $name \n";
#
open (FILENAME, $name) ||
       die "can't open $name: $!";
while ($line = <FILENAME>) {
        chomp $line;
	if ($line =~ /^>/){
	    $line =~ s/>//;
	    $seqname=($line);
	} else {
            $seq=$seq.$line;
        }
        }
$protein=$seq;
$no_aa = length($protein);
                                # amino acid composition
foreach $aa (split(//, $allowed)) {
  $residue{$aa} = ($protein =~ s/$aa//g);
  $molwt += $residue{$aa}*$aawt{$aa};
  print "$protein\n\n";
}
     $molwt -= ($no_aa-1)*$water;
     print "Seq: $seqname\nMolecular wt: $molwt\n";
