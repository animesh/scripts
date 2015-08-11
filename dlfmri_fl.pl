@files = <dlfmri_fl*.csv>;
system("export CLASSPATH=/usit/titan/u1/ash022");
foreach $file (@files) {
	$c++;
	print "Processing file # $c $file CSV2ARFF\n"; 
	system("java weka.core.converters.CSVLoader $file > $file.arff");
	print "Processing file # $c $file RemoveUseless\n"; 
	system("java weka.filters.unsupervised.attribute.RemoveUseless -i $file.arff -o $file.ru.arff");
	print "Processing file # $c $file LR\n"; 
	system("java  weka.classifiers.meta.ClassificationViaRegression -t $file.ru.arff > $file.ru.arff.10fold.lr.txt ");
	print "Processing file # $c $file SVM\n"; 
        system("java  weka.classifiers.functions.SMO -t $file.ru.arff  > $file.ru.arff.10fold.svm.txt ");
}

__END__
