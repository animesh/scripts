@files = <dl*.arff>;
system("export CLASSPATH=/work/ash022");
foreach $file (@files) {
	$c++;
	print "Processing file # $c $file\n"; 
        system("java -Xmx3000m  weka.classifiers.meta.ClassificationViaRegression -t $file -c 1 > $file.10fold.lr.txt ");
        system("java -Xmx3000m  weka.classifiers.functions.SMO -t $file -c 1 > $file.10fold.svm.txt ");
        system("java -Xmx3000m  weka.classifiers.functions.MultilayerPerceptron -t $file -c 1 > $file.10fold.nn.txt ");
        system("java -Xmx3000m  weka.clusterers.EM -I 100 -N -1 -M 1.0E-6 -S 100 -t $file -c 1 > $file.em.txt ");
        system("java -Xmx3000m  weka.clusterers.SimpleKMeans -N 2 -A \"weka.core.EuclideanDistance -R first-last\" -I 500 -S 10 -t $file -c 1 > $file.kmeans.txt ");
}

__END__
