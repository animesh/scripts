import sys
import numpy as np
from pyspark import SparkConf, SparkContext

conf = SparkConf()
#conf.setMaster("local")
conf.setAppName("spark-mz-distrib")
#conf.set("spark.executor.memory", "32g")

sc = SparkContext(conf = conf)

def parseVector(line):
    return np.array([float(x) for x in line.split(' ')])

#fl="/data/promec/data/140801_BSA.mgf"
lines = sc.textFile(sys.argv[1])
print "Input File: " + str(sys.argv[1])
data = lines.map(parseVector).cache()
#pairs = lines.map(lambda s: (s, 1))
#counts = pairs.reduceByKey(lambda a, b: a + b)
#counts = fl.flatMap(lambda line: line.split(" ")) \
#             .map(lambda word: (word, 1)) \
#             .reduceByKey(lambda a, b: a + b)
data.saveAsTextFile("mgfcnt.txt")

print "Final centers: " + str(np)

sc.stop()


