map[peptide:testTryModsIPAVAR massdiff:-0.004938 hit_rank:1 protein:nxp:NX_Q8TF62-1 num_matched_ions:1 num_tol_term:2 num_missed_cleavages
:1 peptide_next_aa:T calc_neutral_pep_mass:824.523222 tot_num_ions:14 num_tot_proteins:1 num_matched_peptides:402
modification_info:map[
    modified_peptide:GGNSFIT[181]S[167]S[167]M[147]K
    mod_aminoacid_mass:[
    map[position:4 mass:160.030649 static:57.021464]
    map[position:5 mass:160.030649 static:57.021464]
    map[position:6 mass:160.030649 static:57.021464]
    map[position:7 mass:196.121178 variable:68.026215 source:peffid:MOD:01892]
    map[position:8 mass:147.035385 variable:15.994900 source:param]
    map[position:7 mass:181.014010 variable:79.966331 source:peff id:MOD:00047]
    map[position:8 mass:166.998359 variable:79.966331 source:peff id:MOD:00046]
    map[position:9 mass:166.998359 variable:79.966331 source:peff id:MOD:00046]
    map[position:10 mass:147.035385 variable:15.994900 source:param]]
    aminoacid_substitution:[map[position:0 orig_aa:Q prevAA:1]   map[position:1 orig_aa:K]]]
search_score:[
    map[value:0.141 name:xcorr]
    map[name:deltacn value:0.000]
    map[name:deltacnstarvalue:0.000]
    map[name:spscore value:1.9]
    map[name:sprank value:3]
    map[name:expect value:2.55E+02]]
peptide_prev_aa:R]

print("che")

import numpy as np
import dask.array as da
x = np.arange(1000)
y = da.from_array(x, chunks=(100))
y.mean().compute()

from altair import Chart, load_dataset

# load built-in dataset as a pandas DataFrame
cars = load_dataset('cars')

Chart(cars).mark_circle().encode(
    x='Horsepower',
    y='Miles_per_Gallon',
    color='Origin',
)

import skimage.filters
from dask.diagnostics import Profiler, ResourceProfiler, visualize
dat=np.random.randint(0, 100,(50, 1104, 1104))
dat /= abs(dat).max()


#x = da.from_array(x, chunks=(50, x.shape[1] // 2, x.shape[2] // 2), name=False)
print(x)
y = x.map_overlap(skimage.filters.gaussian, depth=9, sigma=3, boundary='none')
import pandas as pd
pd.scatter_matrix(x)
with Profiler() as prof, ResourceProfiler(dt=0.1) as rprof:
    y.compute(optimize_graph=False)

from distributed import Client
from time import sleep
import random

def inc(x):
    sleep(random.random() / 10)
    return x + 1

def dec(x):
    sleep(random.random() / 10)
    return x - 1

def add(x, y):
    sleep(random.random() / 10)
    return x + y


client = Client('127.0.0.1:8786')

incs = client.map(inc, range(100))
decs = client.map(dec, range(100))
adds = client.map(add, incs, decs)
total = client.submit(sum, adds)

del incs, decs, adds
total.result()

import tensorflow as tf
hello = tf.constant('Hello, TensorFlow!')
sess = tf.Session()
a = tf.constant(12)
b = tf.constant(32)
print(sess.run(a * b))

import sonnet as snt
import tensorflow as tf
snt.resampler(tf.constant([0.]), tf.constant([0.]))

sc.stop()

import findspark
findspark.init()
import pyspark
conf = pyspark.SparkConf()
conf.setAppName("pepXMLtoJSON")
conf.set("spark.executor.memory", "8g").set(
    "spark.executor.cores", "3").set("spark.cores.max", "12")
conf.set("spark.jars.packages", "com.databricks:spark-xml_2.11:0.4.1")
sc = pyspark.SparkContext(conf=conf)
rdd = sc.parallelize(reversed([1, 2, 3, 4]))
rdd.map(lambda s: s**s**s).take(4)

from pyspark.sql import SQLContext
sqlContext = SQLContext(sc)
df = sqlContext.read.format('com.databricks.spark.xml').options(
    rootTag='msms_pipeline_analysis', rowTag='spectrum_query').load('jupyter/b1928_293T_proteinID_08A_QE3_122212.pep.xml')
df.show()
selectedData = df.select("search_result")
selectedData.printSchema
selectedData.collect().take(2)
selectedData = selectedData.toJSON
selectedData.saveAsTextFile(
    "jupyter/b1928_293T_proteinID_08A_QE3_122212.pep.json")


import pandas as pd
#table = pd.read_excel('promec/Animesh/Lymphoma/TrpofSuperSILACpTtestImp.xlsx')
table = pd.read_excel('/home/animeshs/scripts/vals.xlsx')
%matplotlib inline
table.s3.plot.hist(alpha=0.6)
table.S2.plot.hist(alpha=0.4)
table.S1.plot.hist(alpha=0.3)

import sonnet as snt
import tensorflow as tf
snt.resampler(tf.constant([0.]), tf.constant([0.]))

import matplotlib.pyplot as plt
import numpy as np
from pyteomics import fasta, parser, mass, achrom, electrochem, auxiliary
print 'Cleaving the proteins with trypsin...'
unique_peptides = set()
for description, sequence in fasta.read('uniprot-proteome-human.fasta'):
    new_peptides = parser.cleave(sequence, parser.expasy_rules['trypsin'])
    unique_peptides.update(new_peptides)
print('Done, {0} sequences obtained!'.format(len(unique_peptides)))
peptides = [{'sequence': i} for i in unique_peptides]
#peptides = [peptide for peptide in peptides if peptide['length'] <= 100]
unique_peptides
proteins = fasta.read('uniprot-proteome-human.fasta')
proteins.reset


def fragments(peptide, types, maxcharge):
    for i in range(1, len(peptide)):
        for ion_type in types:
            for charge in range(1, maxcharge + 1):
                if ion_type[0] in 'abc':
                    yield mass.fast_mass(
                        peptide[:i], ion_type=ion_type, charge=charge)
                else:
                    yield mass.fast_mass(
                        peptide[i:], ion_type=ion_type, charge=charge)


theor_spectrum = list(fragments('MIGQK', ('b', 'y'), maxcharge=1))
print(theor_spectrum)
import pandas as pd
# massaa => https://en.wikipedia.org/w/index.php?title=Proteinogenic_amino_acid&section=2
aamm = pd.read_table('/home/animeshs/scripts/massaa')
aamm.dtypes
aamm['Mon. Mass§ (Da)']
# https://en.wikipedia.org/wiki/De_novo_peptide_sequencing
mmH2O = 18.01056
mmProton = 1.00728
pep = 'GLSDGEWQQVLNVWGK'
# http://www.ionsource.com/tutorial/DeNovo/b_and_y.htm
# pep='MIGQK'
tMass = 0.0
bIon = 0.0
bIon_list = []
yIon_list = []
pep_list = []
for b in range(0, len(pep)):
    pep_list.append(pep[b])
    tMass = tMass + aamm[aamm['Short'] == pep[b]]['Mon. Mass§ (Da)'].values
    bIon = bIon + aamm[aamm['Short'] == pep[b]]['Mon. Mass§ (Da)'].values[0]
    bIon_list.append(bIon + mmProton)
    yIon = 0.0
    for y in range(b, len(pep)):
        yIon = yIon + aamm[aamm['Short'] ==
                           pep[y]]['Mon. Mass§ (Da)'].values[0]
    yIon_list.append(yIon + mmH2O + mmProton)
print(pep_list, bIon_list, bIon_list, tMass + mmH2O)
import matplotlib.pyplot as plt
plt.stem(yIon_list, bIon_list, 'r')
plt.stem(bIon_list, bIon_list, 'b')
plt.xticks(bIon_list, pep_list)


from pomegranate import *
import numpy as np
import pylab as plt

data = np.concatenate((np.random.randn(250, 1) * 2.75 +
                       1.25, np.random.randn(500, 1) * 1.2 + 7.85))
np.random.shuffle(data)
data = table['Monoisotopic mass'].values
plt.hist(data, edgecolor='c', color='c', bins=100)
#d = GeneralMixtureModel( [NormalDistribution(2.5, 1), NormalDistribution(8, 1)] )
d = GeneralMixtureModel([aamm['Mon. Mass§ (Da)'].values])
labels = d.predict(data)
print(labels[:5])
print("{} 1 labels, {} 0 labels".format(
    labels.sum(), labels.shape[0] - labels.sum()))
plt.hist(data[labels == 0], edgecolor='r', color='r', bins=20)
plt.hist(data[labels == 1], edgecolor='c', color='c', bins=20)


d.fit(data, verbose=True)

train_data = get_training_data()
test_data = get_test_data()

# Construct the module, providing any configuration necessary.
linear_regression_module = snt.Linear(output_size=FLAGS.output_size)

# Connect the module to some inputs, any number of times.
train_predictions = linear_regression_module(train_data)
test_predictions = linear_regression_module(test_data)

df = pd.DataFrame({
    'Letter': ['a', 'a', 'a', 'b', 'b', 'b', 'c', 'c', 'c'],
    'X': [4, 3, 5, 2, 1, 7, 7, 5, 9],
    'Y': [0, 4, 3, 6, 7, 10, 11, 9, 13],
    'Z': [0.2, 2, 3, 1, 2, 3, 1, 2, 3]
})


df

# wget http://www.unimod.org/modifications_list.php?pagesize=13800
import pandas as pd
table = pd.read_table('/home/animeshs/scripts/unimod')
%matplotlib inline
table['Monoisotopic mass'].plot.hist(alpha=0.6)
table['Average mass'].plot.hist(alpha=0.4)


for i in range(4):
    print(i)


import numpy as np
import tensorflow as tf

from tensorflow.examples.tutorials.mnist import input_data
mnist = input_data.read_data_sets("/tmp/data/", one_hot=True)

Xtr, Ytr = mnist.train.next_batch(5000)  # 5000 for training (nn candidates)
Xte, Yte = mnist.test.next_batch(200)  # 200 for testing

# tf Graph Input
xtr = tf.placeholder("float", [None, 784])
xte = tf.placeholder("float", [784])

# Nearest Neighbor calculation using L1 Distance
# Calculate L1 Distance
distance = tf.reduce_sum(
    tf.abs(tf.add(xtr, tf.negative(xte))), reduction_indices=1)
# Prediction: Get min distance index (Nearest neighbor)
pred = tf.arg_min(distance, 0)

accuracy = 0.

# Initializing the variables
init = tf.global_variables_initializer()

# Launch the graph
with tf.Session() as sess:
    sess.run(init)

    # loop over test data
    for i in range(len(Xte)):
        # Get nearest neighbor
        nn_index = sess.run(pred, feed_dict={xtr: Xtr, xte: Xte[i, :]})
        # Get nearest neighbor class label and compare it to its true label
        print("Test", i, "Prediction:", np.argmax(Ytr[nn_index]),
              "True Class:", np.argmax(Yte[i]))
        # Calculate accuracy
        if np.argmax(Ytr[nn_index]) == np.argmax(Yte[i]):
            accuracy += 1. / len(Xte)
    print("Done!")
    print("Accuracy:", accuracy)