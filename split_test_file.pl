$file=shift;
$chunk=50000;
open(F,$file);
while(<F>){
	$c++;
	if($c==1){$header=$_;}
	else{@seq[$c]=$_}
}
close F;
for($c1=2;$c1<$#seq;$c1+=$chunk){
	$fn++;
	$fo="$file.$fn.out";
	open(FO,">$fo");
	print FO"$header";
	for($c2=0;$c2<$chunk;$c2++){
		print FO"@seq[$c1+$c2]";
	}
	system("java -Xmx30000m weka.core.converters.CSVLoader $fo > $fo.arff");
	system("java -Xmx30000m  weka.classifiers.functions.SMO  -t ecolflow.txtecol.blast.new.train.100.arff -T $fo.arff -classifications  weka.classifiers.evaluation.output.prediction.PlainText >> $fo.result.out");
	
	close FO;
}


__END__
1177272  1177272 17659080 ecolflow.txtecol.blast.test.testname.csv

