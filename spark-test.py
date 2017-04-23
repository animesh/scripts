from pyspark import SparkContext

sc = SparkContext(appName='test')
data = [1, 2, 3, 4, 5]
distData = sc.parallelize(data)
print(distData.reduce(lambda a, b: a + b))

