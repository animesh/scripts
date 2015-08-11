@files = <IC*.txt.ru.arff>;
system("export CLASSPATH=/work/ash022");
foreach $file (@files) {
	$c++;
	print "Processing file # $c $file\n"; 
	system("java -Xmx3000m  weka.classifiers.functions.LinearRegression -t $file -x 10 > $file.lr.txt ");
	system("java -Xmx3000m  weka.classifiers.functions.SMOreg -t $file -x 10 > $file.svm.txt ");
	system("java -Xmx3000m  weka.classifiers.functions.MultilayerPerceptron -t $file -x 10 > $file.ann.txt ");
}

