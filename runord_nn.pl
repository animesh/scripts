@files1 = <IC_[0-9]_toML.txt.ru.class.arff>;
@files2 = <IC_[0-9][0-9]_toML.txt.ru.class.arff>;
@files=(@files1,@files2);
system("export CLASSPATH=/work/ash022");
foreach $file (@files) {
	$c++;
	print "Processing file # $c $file\n"; 
	system("java -Xmx5900m  weka.classifiers.functions.MultilayerPerceptron -t $file -x 10 > $file.nn.10fold.txt ");
}

