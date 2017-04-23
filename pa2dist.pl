$file=shift @ARGV; chomp $file; open(FC,$file);
while($l=<FC>){
if($l=~/^>/){
chomp $l;
$l=~s/>//;
@tmp=split(/,/,$l);
@tmp2=split(/\.\./,@tmp[1]);
@tmp4=split(/\s+/,@tmp2[1]);
@tmp6=split(/\.\./,@tmp[2]);
@tmp8=split(/\s+/,@tmp6[1]);
#print "@tmp[0] @tmp2[0] @tmp4[0] @tmp6[0] @tmp8[0] @tmp4[4]\n";
#@tmp[0]=~s/^>|\s+$//g;
$name=@tmp[0];
$name=~s/^F//g;
$name=~s/^R//g;
$names{$name}++;
$scaf{@tmp[0]}=@tmp4[4];
$alen{@tmp[0]}=abs(@tmp6[0]-@tmp8[0])+1;
$apos{@tmp[0]}=@tmp6[0];
}
}
print "Read $file\n";
close FC;
open(FO,">$file.pairdist.txt");
foreach $name (keys %names){
        $cnt++;
        if($cnt%1000==0){print "$name\t on line $cnt\n";}
        $rname="R".$name;
        $fname="F".$name;
#for($cnt=0;$cnt<=$#name;$cnt++){
        if(($names{$name} == 2) && ($scaf{$fname} eq $scaf{$rname})){
        $dist=abs($apos{$fname}-$apos{$rname});
        print FO"$name\t$names{$name}\t$alen{$fname}\t$alen{$rname}\t$apos{$fname}\t$apos{$rname}\t$dist\n";
        }
}


