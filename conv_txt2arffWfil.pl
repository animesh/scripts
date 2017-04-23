@files = <IC*.txt>;
system("export CLASSPATH=/work/ash022");
foreach $file (@files) {
	$c++;
	print "Processing file # $c $file\n"; 
	system("perl txt2csv.pl $file > $file.csv");
	system("java weka.core.converters.CSVLoader $file.csv > $file.arff");
	system("java weka.filters.unsupervised.attribute.RemoveUseless -i $file.arff -o $file.ru.arff");
}
