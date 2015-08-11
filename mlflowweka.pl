@files = <schiz*.arff>;
system("export CLASSPATH=/usit/titan/u1/ash022");
foreach $file (@files) {
	$c++;
	print "Processing file # $c $file\n"; 
	#system("java weka.core.converters.CSVLoader $file > $file.class.arff");
	#system("java weka.filters.unsupervised.attribute.RemoveUseless -i $file.class.arff -o $file.ru.class.arff");
	system("java -Xmx96000m  weka.filters.supervised.attribute.AttributeSelection -E \"weka.attributeSelection.CfsSubsetEval\" -S \"weka.attributeSelection.BestFirst -D 1 -N 5\" -i $file -o $file.csebf.arff");
	$file="$file.csebf.arff";
        system("java -Xmx96000m  weka.classifiers.meta.ClassificationViaRegression -t $file  > $file.10fold.lr.txt ");
        system("java -Xmx96000m  weka.classifiers.functions.SMO -t $file  > $file.10fold.svm.txt ");
        system("java -Xmx96000m  weka.classifiers.functions.MultilayerPerceptron -t $file  > $file.10fold.nn.txt ");
        system("java -Xmx96000m  weka.clusterers.EM -I 100 -N -1 -M 1.0E-6 -S 100 -t $file  > $file.em.txt ");
        system("java -Xmx96000m  weka.clusterers.SimpleKMeans -N 3 -A \"weka.core.EuclideanDistance -R first-last\" -I 500 -S 10 -t $file  > $file.kmeans.txt ");
}

__END__
