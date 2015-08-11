#!/usr/bin/perl

$seq = "";
print "Enter the file containing sequence:";
$infile = <>;

open (INFILE, $infile) || die "can`t open $infile: $!";

while ($line = <INFILE>){

$line =~ s/-//g;
$seq = $seq.$line;
$seq =~ tr/[a-z]/[A-Z/;
$seq =~ s/\s//g;
$seq =~ s/[0-9]//g;
}
$len = length($seq);
#print "$seq\n";
@Seq = split (//, $seq);

print "O/P filename ?\n";
$out = <>;
open (FILE, ">$out");

@char1 = qw(A G C T);
@char2=  qw(A G C T);

foreach $a1(@char1){
        $no = $seq =~ s/$a1/$a1/g;
        print "Length:$len\n$a1\t$no\n";
        $prob = $no/$len;
        print "Prob_$a1 = $prob\n\n";
                }

        foreach $a1(@char1){
        foreach $a2(@char2){
                $pair = $a1.$a2;
                $freq = $seq =~ s/$pair/$pair/g;
                #print "$freq\n";
                push (@Freq, $freq);
                $freq = "";
                push (@Pair, $pair);
                }
                }

        for($i=0; $i<=$#Freq; $i=$i+4)
                {
                for ($j =$i; $j<$i+4; $j++)
                {
                $sum = $sum + $Freq[$j];
                }
                push (@Sum, $sum);
                $sum =0;
                }
                for($i=0; $i<=$#Freq; $i=$i+4){
                    for ($j =$i; $j<$i+4; $j++)
                        {
                        $prob=($Freq[$j]/$Sum[$n])*100;
                        push (@Prob, $prob);
                        }
                        $n++;
                        }
                for ($i=0; $i<=$#Pair; $i++){
                        print "$Pair[$i]\t";
                        print FILE "$Pair[$i]\t";
                        printf  ("%.3f",$Prob[$i]);
                        printf FILE ("%.3f",$Prob[$i]);
                        print FILE "\n";
                        print "\n";
                        }