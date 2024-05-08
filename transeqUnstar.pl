while(<>){chomp;$l++;
if(/^>/){$_=~s/\>tp\|//g;$_=~s/\s+/\|/;$nm=$_;print ">ustp|$nm\n";$wnt=0;}
elsif(/\*/){#print "$_\n";
$fnd = index($_,'*',0);
#if($fnd>0){
print substr($_,0,$fnd),"\n";
while ($fnd!=-1) {
if($fnd>0&&$fnd>$st&&$wnt>0){print substr($_,$st+1,$fnd-$st-1),"\n";}
print ">ustp|L$l-S$st-E$fnd-$nm\n";
$st=$fnd;
$fnd = index($_,'*', $fnd+1);
$wnt++;
}
if($st>0){print substr($_,$st+1,length($_)),"\n";}
}
#}
else{
print "$_\n";
}
}

__END__
perl transeqUnstar.pl vilnius.IRD.aa.fasta > vilnius.IRD.aa.us.fasta
sed 's/DryP/ DryP/g'  vilnius.IRD.aa.us.fasta >  vilnius.IRD.aa.us.sp.fasta
grep "^>" vilnius.IRD.aa.us.sp.fasta | wc
   1608    3216  304132



