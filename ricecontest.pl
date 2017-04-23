#!/usr/bin/perl
print "File containing sequences ?\n ";
chomp ($file = <STDIN>);
print "output file name : \n";
chomp ($filen = <STDIN>);
open (FILEIN,"$file");
open(FILEOUT,">$filen");
$sout=$filen.".html";
print FILEOUT"/home/andrew/ani/blastcl3 -p blastn -d est -i $file -o $sout -T \n";
