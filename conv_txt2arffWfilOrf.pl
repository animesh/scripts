@files = <IC*toML.txt>;
system("export CLASSPATH=/work/ash022");
foreach $file (@files) {
	$c++;
	print "Processing file # $c $file\n"; 
	system("perl txt2csvclass.pl $file > $file.class.csv");
	system("java weka.core.converters.CSVLoader $file.class.csv > $file.class.arff");
	system("java weka.filters.unsupervised.attribute.RemoveUseless -i $file.class.arff -o $file.ru.class.arff");
	
}
