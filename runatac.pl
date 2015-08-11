@f=<*fasta>;
for($c1=0;$c1<=$#f;$c1++){
	$i=@f[$c1];
	chomp $i;
	@t=split(/\./,$i);
	$in=@t[0];
	for($c2=$c1+1;$c2<=$#f;$c2++){
		$j=@f[$c2];
		chomp $j;
		@t=split(/\./,$j);
		$jn=@t[0];
		print "$in\t$jn\n";
		system("/home/animesh/export/kmer/trunk/Linux-amd64/bin/atac.pl -dir $in.$jn.atac -id1 $in -seq1 $i -id2 $jn -seq2 $j");
	}
}

