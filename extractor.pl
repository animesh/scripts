#!/usr/bin/perl
#parse blast results
$count=0;
print "the blast file name \n";
$_=<>;
chomp;
open (o,"$_")|| die;
$line=<o>;
chomp $line;
while ($line=<o>)
{
push (@file,$line);
}
for ($i=0;$i<=$#file;$i++)
{
$line=$file[$i];
chomp$line;
$full="";
if ($line=~/Query=/)
{               $i++;
                $full=$line.$file[$i++];
                chomp $full;
	push (@exon,$full);
	while($count==0){
	$i++;
	$line1=$file[$i];
                chomp$line1;
	if ($line1=~/Sequences/)
	{               #print "found";
		$i=$i+2;
		$line2=$file[$i];
                                chomp$line2;
		push (@hit,$line2);
		$count=1;
	}
	elsif($line1=~/No/)
	{
		push (@hit,$line1);
		$count=1;
	}
                }
	$count=0;
}

}
$num=0;
foreach $exon(@exon)
{
print "$exon:$hit[$num]\n";
$num++;}

