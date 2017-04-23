#!/usr/local/bin/perl

use CGI;

$query = new CGI;
print $query->header;
print $query->start_html;
print "<H1>what is the filename of the sequence containing file?</H1>\n" , $query->textfield('name',$name,50);
$name = <STDIN>;
chomp($name);
print "The sequence filename is $name \n";
open (FILENAME, $name) ||
       die "can't open $name: $!";
$seq = "";
while ($line = <FILENAME>) {
	chomp ($line);
	if ($line =~ /^>/){
	    $line =~ s/>//;
	    push(@seqname,$line);
	    if ($seq ne ""){
	      push(@seq,$seq);
	      $seq = "";
	    }
      } else {
            $seq=$seq.$line;
      }
}
push(@seq,$seq);
  foreach $j (@seqname){
  print "the sequence name is $seqname[$j]\n";
  }
  foreach $i (@seq) {
  print "Sequence read from file is:\n$seq[$i] \n";
  }
close (FILENAME);
$protein=$seq;
$no_aa = length($protein);
                                # amino acid composition
foreach $aa (split(//, $allowed)) {
  $residue{$aa} = ($protein =~ s/$aa//g);
  $molwt += $residue{$aa}*$aawt{$aa};
  print "$protein\n\n";
}
     $molwt -= ($no_aa-1)*$water;
$query->import_names('Q');
    print "Seq: $seqname \n Molecular wt: $molwt\n <EM>$Q::$seqname,$molwt</EM>\n";
print $query->end_html;