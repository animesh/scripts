import org.apache.spark.SparkConf
import org.apache.spark.SparkContext
sc.stop()
val conf = new SparkConf().setMaster("local[2]").setAppName("dmed5714").set("spark.cores.max", "8")
//val conf = new SparkConf(true).setMaster("spark://129.241.180.233:7077").setAppName("promec2").set("spark.cores.max", "8")
val sc = new SparkContext(conf)
sc.parallelize(1 to 100).
  filter(x => x % 10 == 0).
  map(x => x*x).
  take(10)
