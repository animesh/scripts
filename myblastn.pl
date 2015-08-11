#!/usr/bin/perl
print "File containing sequence names? ";
chomp ($file = <STDIN>);
open (FILEIN,"$file");
open(FILEOUT,">blastn");
while (chomp($seq = <FILEIN>))
{
$seqout = $seq.".html";
print FILEOUT"usr/people/andrew/blastcl3 -p blastn -d nr -i $seq -o $seqout -T\n";
}