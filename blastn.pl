#!/usr/bin/perl
print "File containing sequence names? ";
chomp ($file = <STDIN>);
open (FILEIN,"$file");
open(FILEOUT,">blastn");
while (chomp ($seq = <FILEIN>) )
{$sout=$seq.".html";
print FILEOUT"/home/andrew/bic/blastcl3 -p blastn -d nr -i $seq -o $sout -T\n";
}
