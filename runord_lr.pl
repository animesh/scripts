@files2 = <IC_[0-9][0-9].txt.ru.class.arff>;
system("export CLASSPATH=/work/ash022");
for($c=49;$c<=57;$c++) {
	$file=@files2[$c];
	print "Processing file # $c $file\n"; 
	#system("java -Xmx3000m  weka.attributeSelection.GainRatioAttributeEval -i $file -x 10 > $file.graeclass.txt ");
	#system("java -Xmx3000m  weka.attributeSelection.CfsSubsetEval -i $file -x 10   -s weka.attributeSelection.BestFirst > $file.csebfclass.txt ");
	system("java -Xmx1500m  weka.classifiers.meta.ClassificationViaRegression -t $file -x 10 > $file.lrclass.txt ");
	#system("java -Xmx3000m  weka.attributeSelection.SVMAttributeEval -i $file -x 10 > $file.svmattribevaltxt ");
}

