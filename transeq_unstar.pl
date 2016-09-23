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
http://www.ncbi.nlm.nih.gov/books/NBK25500/#chapter1.Downloading_Full_Records
https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=34577062,24475906&rettype=fasta&retmode=text
https://www.ncbi.nlm.nih.gov/nuccore/?term=Avicennia+marina+AND+cds
https://www.ncbi.nlm.nih.gov/nuccore/?term=Avicennia+marina+NOT+cds
http://rocaplab.ocean.washington.edu/cgi-bin/genbank_to_fasta.py
#http://rocaplab.ocean.washington.edu/tools/genbank_to_fasta
http://www.ebi.ac.uk/Tools/st/emboss_transeq/
http://www.ebi.ac.uk/Tools/st/emboss_sixpack/






