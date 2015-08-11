#!/usr/bin/perl
open F1,"split1000test.txt";
while($l=<F1>)
{
chomp($l);
$li=$li.$l;
}
@seq=split(//,$li);
$len=@seq;
print "$len";
for($cc=0;$cc<$len;$cc=($cc+900))
{
$tt=$cc+1000;
print ">sequence from $cc to $tt\n";
for($c=$cc;$c<($cc+1000);$c++)
{$seq1=$seq1.@seq[$c];}
print "$seq1\n";
$seq1="";
}

