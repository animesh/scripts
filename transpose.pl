#!/usr/bin/perl
$f1=shift @ARGV;chomp $f1;
if (!$f1) {print "\nUSAGE:      \'perl program_name filename_2_b_transposed\'\n\n";exit;}
open F1,$f1||die"cannot open $f1";
$c1=0;
$f2=$f1.".trp.csv";
open(F2,">$f2");
while($l1=<F1>){
        chomp $l1;
        $l3=$l1;$l3=~s/\s+//g;$l3=~s/\,//g;
        if($l3 eq ""){next;}
        @t1=split(/\,/,$l1);
        for($c2=0;$c2<=$#t1;$c2++){
                $mat[$c2][$c1]=@t1[$c2];
                }
        $c1++;
}
for($c5=0;$c5<$c2;$c5++){
        for($c6=0;$c6<($c1-1);$c6++){
                print F2"$mat[$c5][$c6],";
                }
        print F2"$mat[$c5][$c6]\n";
}
print "\n$c1\n";

