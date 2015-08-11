@files = <IC*toML.txt>;
system("export CLASSPATH=/work/ash022");
foreach $file (@files) {
	$c++;
	print "Processing file # $c $file\n"; 
	system("perl txt2csvclass.pl $file > $file.class.csv");
	system("java weka.core.converters.CSVLoader $file.class.csv > $file.class.arff");
	system("java weka.filters.unsupervised.attribute.RemoveUseless -i $file.class.arff -o $file.ru.class.arff");
        system("java -Xmx3000m  weka.classifiers.meta.ClassificationViaRegression -t $file.class.arff -x 10 > $file.class.arff.10fold.lr.txt ");
        system("java -Xmx3000m  weka.classifiers.meta.ClassificationViaRegression -t $file.ru.class.arff -x 10 > $file.ru.class.arff.10fold.lr.txt ");
        system("java -Xmx3000m  weka.classifiers.functions.SMO -t $file.class.arff -x 10 > $file.class.arff.10fold.svm.txt ");
        system("java -Xmx3000m  weka.classifiers.functions.SMO -t $file.ru.class.arff -x 10 > $file.ru.class.arff.10fold.svm.txt ");

}

__END__
