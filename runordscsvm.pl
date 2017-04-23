@files1 = <IC_[0-9]_toML.txt.ru.class.arff>;
@files2 = <IC_[0-9][0-9]_toML.txt.ru.class.arff>;
@files=(@files1,@files2);
system("export CLASSPATH=/work/ash022");
foreach $file (@files) {
	$c++;
	print "Processing file # $c $file\n"; 
	system("java -Xmx3000m  weka.classifiers.functions.SMO -t $file  > $file.svmbin.txt ");
}

