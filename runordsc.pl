	system("export CLASSPATH=/work/ash022");
	$file="selcomp.arff";
	print "Processing file $file\n"; 
	system("java -Xmx3000m  weka.attributeSelection.GainRatioAttributeEval -i $file -x 10 > $file.graeclass.txt ");
	system("java -Xmx3000m  weka.attributeSelection.CfsSubsetEval -i $file -x 10   -s weka.attributeSelection.BestFirst > $file.csebfclass.txt ");
	system("java -Xmx3000m  weka.classifiers.meta.ClassificationViaRegression -t $file -x 10 > $file.lrclass.txt ");
	system("java -Xmx3000m  weka.attributeSelection.SVMAttributeEval -i $file -x 10 > $file.svmattribevaltxt ");
        system("java -Xmx3000m  weka.classifiers.functions.MultilayerPerceptron -t $file  > $file.nn.txt ");
        system("java -Xmx3000m  weka.classifiers.functions.MultilayerPerceptron -t $file  -x 5 > $file.nn5f.txt ");

