while(<>){chomp;$l++;
if(/^>/){$_=~s/\>//g;$_=~s/\s+/\|/;$nm=$_;print ">ncbi|$nm\n";$wnt=0;}
elsif(/\*/){#print "$_\n";
$fnd = index($_,'*',0);
#if($fnd>0){
print substr($_,0,$fnd),"\n";
while ($fnd!=-1) {
if($fnd>0&&$fnd>$st&&$wnt>0){print substr($_,$st+1,$fnd-$st-1),"\n";}
print ">ncbi|L$l-S$st-E$fnd-$nm\n";
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
perl /home/animeshs/scripts/transeq_unstar.pl ../../../Gygi/Homo_sapiens.GRCh37.61.pep.all.fa > ../../../Gygi/Homo_sapiens.GRCh37.61.pep.all.unstar.fasta
sed 's/^$/X/' Homo_sapiens.GRCh37.61.pep.all.unstar.fasta > Homo_sapiens.GRCh37.61.pep.all.unstar.X.fasta




