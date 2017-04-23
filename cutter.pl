#!/usr/bin/perl
open F1,"ricecontigAC109365.fas";
open (FILEOUT1, ">AC109365.fas.1");
open (FILEOUT2, ">AC109365.fas.2");
while($l=<F1>)
{
chomp($l);
$li=$li.$l;
}
@seq=split(//,$li);
$len=@seq;
for($c=0;$c<=($len/2+100);$c++)
{$seq1=$seq1.@seq[$c];}
for($cc=($len/2-100);$cc<=$len;$cc++)
{$seq2=$seq2.@seq[$cc];}
print FILEOUT1"$seq1";
print FILEOUT2"$seq2";

