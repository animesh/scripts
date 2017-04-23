@files1 = <IC_[0-9].txt.ru.class.arff>;
@files2 = <IC_[0-9][0-9].txt.ru.class.arff>;
@files=(@files1,@files2);
system("export CLASSPATH=/usit/titan/u1/ash022");
for($c=$#files;$c>=0;$c--) {
	$file=@files[$c];
	print "Processing file # $c $file\n"; 
	system("java -Xmx119000m  weka.classifiers.functions.MultilayerPerceptron -t $file -x 10 > $file.nn.txt ");
}

