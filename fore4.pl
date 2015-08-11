#!/usr/bin/perl
print "Enter the sequence filename :>";
$name = <STDIN>;
chomp($name);
open (FILENAME, $name) ||
       die "can't open $name: $!";
$seq = "";
while ($line = <FILENAME>) {
	chomp ($line);
if($line =~ /^>/)
{	
	if ($line =~ /^>/){
          
	    $line =~ s/>//;
	    push(@seqname,$line);
             $cc++;
	    if ($seq ne ""){
	      push(@seq,$seq);
	      $seq = "";
	    }
      } else {
		  $seq=$seq.$line;
      }
}
else
{
die "this is not a fasta file: $!";
}
}

push(@seq,$seq);
$lll=@seq;
$e=0;
while($e<$lll)
{
print "\n\nSeqNam\tGCont\tCCont\tACont\tTCont\tTotGCAT\tGCPercent\n\n";
foreach $w(@seq)
{
print "@seqname[$e]\t";
$e++;
$g=$w=~s/G//g;
push(@g,$g);
print "$g\t";
$c=$w=~s/C//g;
push(@c,$c);
print "$c\t";
$a=$w=~s/A//g;
push(@a,$a);
print "$a\t";
$t=$w=~s/T//g;
push(@t,$t);
print "$t\t";
$gc=$g+$c;
push(@gc,$gc);
$total=$gc+$a+$t;
push(@total,$total);
$gcp=$gc/$total*100;
push(@gcp,$gcp);
print "$total\t";
print "$gcp\n";
}
foreach $gt(@g)
{
$gtr+=$gt;
}
print "\nTotal\t";
print "$gtr\t";
foreach $ct(@c)
{
$ctr+=$ct;
}
print "$ctr\t";
foreach $at(@a)
{
$atr+=$at;
}
print "$atr\t";
foreach $tt(@t)
{
$ttr+=$tt;
}
print "$ttr\t";
foreach $totalt(@total)
{
$totaltr+=$totalt;
}
print "$totaltr\t";
foreach $gcpt(@gcp)
{
$gcpttr+=$gcpt;
}
$length=@seq;
$gcptn=$gcpttr/$length;
print "$gcptn\n\n";
}