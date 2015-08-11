export CLASSPATH=/home/ash022/weka
java weka.core.converters.CSVLoader t3.csv < t3.arff
java weka.classifiers.functions.MultilayerPerceptron -t t3.arff -x 2

