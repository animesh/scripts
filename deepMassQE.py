#git clone https://github.com/animesh/deepmass
#cd deepmass/prism/
#DATA_DIR="./data"
#cat $DATA_DIR/input_table.csv
#ModifiedSequence,Charge,Fragmentation,MassAnalyzer
#AKM(ox)LIVR,3,HCD,ITMS
#ILFWYK,2,CID,FTMS

#python preprocess.py   --input_data="${DATA_DIR}/input_table.csv"   --output_data_dir="${DATA_DIR}"   --sequence_col="ModifiedSequence"   --charge_col="Charge"   --fragmentation_col="Fragmentation"   --analyzer_col="MassAnalyzer"
#gcloud ai-platform predict     --model deepmass_prism     --project deepmass-204419     --format json     --json-instances "${DATA_DIR}/input.json" > "${DATA_DIR}/prediction.results"
#python postprocess.py     --metadata_file="${DATA_DIR}/metadata.csv"     --input_data_pattern="${DATA_DIR}/prediction.results*"     --output_data_dir="${DATA_DIR}"     --batch_prediction=False
#https://www.tensorflow.org/tutorials/eager/custom_training_walkthrough

#http://www.swig.org/download.html
#sudo apt-get install build-essential swig
#https://raw.githubusercontent.com/automl/auto-sklearn/master/requirements.txt
#pip3 install --upgrade  --user setuptools nose Cython numpy scipy scikit-learn xgboost lockfile joblib psutil pyyaml liac-arff pandas ConfigSpace pynisher pyrfr smac
#pip3 install --upgrade  --user auto-sklearn

from pathlib import Path
home=Path.home()
print(home)

pathFiles = home / Path('promec/Elite/LARS/2018/november/Rolf final/')
fileName='evidence.txt'
trainList=list(pathFiles.rglob(fileName))
print(pathFiles,trainList)

#https://github.com/AxeldeRomblay/MLBox
#pip3 install  mlbox --user
#https://github.com/AxeldeRomblay/MLBox/blob/master/examples/classification/example.ipynb
from mlbox.preprocessing import *
from mlbox.optimisation import *
from mlbox.prediction import *


#https://automl.github.io/auto-sklearn/master/
import autosklearn.classification
cls = autosklearn.classification.AutoSklearnClassifier()
cls.fit(X_train, y_train)
predictions = cls.predict(X_test)
print(predictions,cls)


#https://www.simonwenkel.com/2018/09/09/Introduction-to-auto-sklearn.html#classification-example
import sklearn.model_selection
import sklearn.datasets
import sklearn.metrics

import autosklearn.classification

X, y = sklearn.datasets.load_digits(return_X_y=True)
X_train, X_test, y_train, y_test = \
sklearn.model_selection.train_test_split(X, y, random_state=1)

automl = autosklearn.classification.AutoSklearnClassifier(
time_left_for_this_task=3600,
per_run_time_limit=300,
tmp_folder='/tmp/autosklearn_sequential_example_tmp',
output_folder='/tmp/autosklearn_sequential_example_out',
# Do not construct ensembles in parallel to avoid using more than one
# core at a time. The ensemble will be constructed after auto-sklearn
# finished fitting all machine learning models.
ensemble_size=0,
delete_tmp_folder_after_terminate=False,
)
automl.fit(X_train, y_train, dataset_name='digits')
# This call to fit_ensemble uses all models trained in the previous call
# to fit to build an ensemble which can be used with automl.predict()
automl.fit_ensemble(y_train, ensemble_size=50)

print(automl.show_models())
predictions = automl.predict(X_test)
print(automl.sprint_statistics())
print("Accuracy score", sklearn.metrics.accuracy_score(y_test, predictions))


import tensorflow as tf
print("TensorFlow version: {}".format(tf.__version__))

tf.enable_eager_execution()
print("Eager execution: {}".format(tf.executing_eagerly()))

from tensorflow import app
from __future__ import absolute_import, division, print_function
import os
import matplotlib.pyplot as plt

train_dataset_url = "https://storage.googleapis.com/download.tensorflow.org/data/iris_training.csv"
train_dataset_fp = tf.keras.utils.get_file(fname=os.path.basename(train_dataset_url), origin=train_dataset_url)
print("Local copy of the dataset file: {}".format(train_dataset_fp))
!head -n5 {train_dataset_fp}
#column_names = ['sepal_length', 'sepal_width', 'petal_length', 'petal_width', 'species']

feature_names = column_names[:-1]
label_name = column_names[-1]

print("Label: {}".format(label_name))

batch_size = 32


my %codon =
(
  "TTT" => "F", "TTC" => "F", "TTA" => "L", "TTG" => "L",
  "TCT" => "S", "TCC" => "S", "TCA" => "S", "TCG" => "S",
  "TAT" => "Y", "TAC" => "Y", "TAA" => "*", "TAG" => "*",
  "TGT" => "C", "TGC" => "C", "TGA" => "*", "TGG" => "W",
  "CTT" => "L", "CTC" => "L", "CTA" => "L", "CTG" => "L",
  "CCT" => "P", "CCC" => "P", "CCA" => "P", "CCG" => "P",
  "CAT" => "H", "CAC" => "H", "CAA" => "Q", "CAG" => "Q",
  "CGT" => "R", "CGC" => "R", "CGA" => "R", "CGG" => "R",
  "ATT" => "I", "ATC" => "I", "ATA" => "I", "ATG" => "M",
  "ACT" => "T", "ACC" => "T", "ACA" => "T", "ACG" => "T",
  "AAT" => "N", "AAC" => "N", "AAA" => "K", "AAG" => "K",
  "AGT" => "S", "AGC" => "S", "AGA" => "R", "AGG" => "R",
  "GTT" => "V", "GTC" => "V", "GTA" => "V", "GTG" => "V",
  "GCT" => "A", "GCC" => "A", "GCA" => "A", "GCG" => "A",
  "GAT" => "D", "GAC" => "D", "GAA" => "E", "GAG" => "E",
  "GGT" => "G", "GGC" => "G", "GGA" => "G", "GGG" => "G",
);


import pathlib
import numpy as np

def parseMGF(mgfData):
    data = mgfData.read_text().split('\n')
    _comments = '#;!/'
    reading_spectrum = False
    params = {}
    masses = []
    intensities = []
    charges = []
    out = {}
    cnt = 0
    pep_mass = 0
    pep_intensity = 0
    out = {}
    for line in data:
        if not reading_spectrum:
            if line.strip() == 'BEGIN IONS': reading_spectrum = True
        else:
            if not line.strip() or any(line.startswith(c) for c in _comments): pass
            elif line.strip() == 'END IONS':
                reading_spectrum = False
                title = params['title'].split()[0]
                if 'pepmass' in params:
                    try:
                        pl = params['pepmass'].split()
                        if len(pl) > 1:
                            pep_mass = float(pl[0])
                            pep_intensity = float(pl[2])
                        elif len(pl) == 1: pep_mass = float(pl[0])
                    except ValueError: print("Error in parsing pepmass value")
                out[cnt] = {'pep_mass': pep_mass,'pep_intensity': pep_intensity,'rtinseconds': params['rtinseconds'],'title': params['title'],'charge': params['charge'],'mz_array': np.array(masses),'intensity_array': np.array(intensities)}
                cnt += 1
            else:
                l = line.split('=', 1)
                if len(l) > 1: params[l[0].lower()] = l[1].strip()
                elif len(l) == 1:  # looks like a peak list ;)
                    l = line.split()
                    if len(l) >= 2:
                        try:
                            masses.append(float(l[0]))
                            intensities.append(float(l[1]))
                        except ValueError:
                            print("Error in parsing line "+line)
    return out

file = pathlib.Path.cwd().parent.rglob('*.MGF')
file = pathlib.Path.cwd().parent / 'RawRead/171010_Ip_Hela_ugi.raw.intensity0.charge0.MGF'
print(file.read_text().split(' '))
out=parseMGF(file)
X=[(out[k]['pep_mass']-1.00727647)*int(out[k]['charge'].split('+')[0]) for k, _ in out.items()]
X=np.array(X).reshape(-1, 1)
print(X.shape)

#https://github.com/rasbt/python-machine-learning-book/blob/master/code/ch11/ch11.ipynb
from sklearn.datasets import make_blobs
X, y = make_blobs(n_samples=150,
                  n_features=2,
                  centers=3,
                  cluster_std=0.5,
                  shuffle=True,
                  random_state=0)

from sklearn.cluster import KMeans
km = KMeans(n_clusters=3,
            init='random',
            n_init=10,
            max_iter=300,
            tol=1e-04,
            random_state=0)
y_km = km.fit_predict(X)
print(y_km)

import matplotlib.pyplot as plt
%matplotlib inline

import numpy as np
from matplotlib import cm
from sklearn.metrics import silhouette_samples

cluster_labels = np.unique(y_km)
n_clusters = cluster_labels.shape[0]
silhouette_vals = silhouette_samples(X, y_km, metric='euclidean')
y_ax_lower, y_ax_upper = 0, 0
yticks = []
for i, c in enumerate(cluster_labels):
    c_silhouette_vals = silhouette_vals[y_km == c]
    c_silhouette_vals.sort()
    y_ax_upper += len(c_silhouette_vals)
    color = cm.jet(float(i) / n_clusters)
    plt.barh(range(y_ax_lower, y_ax_upper), c_silhouette_vals, height=1.0,
             edgecolor='none', color=color)

    yticks.append((y_ax_lower + y_ax_upper) / 2.)
    y_ax_lower += len(c_silhouette_vals)

silhouette_avg = np.mean(silhouette_vals)
plt.axvline(silhouette_avg, color="red", linestyle="--")

plt.yticks(yticks, cluster_labels + 1)
plt.ylabel('Cluster')
plt.xlabel('Silhouette coefficient')

plt.tight_layout()
# plt.savefig('./figures/silhouette.png', dpi=300)
plt.show()


distortions = []
for i in range(1, 11):
    km = KMeans(n_clusters=i,
                init='k-means++',
                n_init=10,
                max_iter=300,
                random_state=0)
    km.fit(X)
    distortions.append(km.inertia_)
plt.plot(range(1, 11), distortions, marker='o')
plt.xlabel('Number of clusters')
plt.ylabel('Distortion')
plt.tight_layout()
#plt.savefig('./figures/elbow.png', dpi=300)
plt.show()

from sklearn.cluster import AgglomerativeClustering
ac = AgglomerativeClustering(n_clusters=4,
                             affinity='euclidean',
                             linkage='complete')
y_ac = ac.fit_predict(X)
plt.scatter(X,y_ac)

km = KMeans(n_clusters=4, random_state=0)
y_km = km.fit_predict(X)
plt.scatter(X,y_km)

from sklearn.cluster import DBSCAN
db = DBSCAN(eps=0.2, min_samples=5, metric='euclidean')
y_db = db.fit_predict(X)
plt.scatter(X,y_db)

from scipy.cluster.hierarchy import linkage
from scipy.spatial.distance import pdist
import pandas as pd
df=X
row_clusters = linkage(pdist(df, metric='euclidean'), method='complete')
pd.DataFrame(row_clusters,
             columns=['row label 1', 'row label 2',
                      'distance', 'no. of items in clust.'],
             index=['cluster %d' % (i + 1)
                    for i in range(row_clusters.shape[0])])


import cv2
import matplotlib.pylab as plt
%matplotlib inline
cvimg = cv2.imread(dataElite1)
plt.imshow(cvimg)

import torch
print("#GPU-#", torch.cuda.device_count())


from fastai.learner import *
from fastai.transforms import *
from fastai.conv_learner import *
from fastai.model import *
from fastai.dataset import *
from fastai.sgdr import *
from fastai.plots import *

learn = ConvLearner.pretrained(arch, dataElite1, precompute=True)
learn.fit(0.01, 2)


def lin(a,b,x): return a*x+b
def gen_fake_data(n, a, b):
    x = s = np.random.uniform(0,1,n)
    y = lin(a,b,x) + 0.1 * np.random.normal(0,3,n)
    return x, y
x, y = gen_fake_data(50, 3., 8.)
plt.scatter(x,y, s=8); plt.xlabel("x"); plt.ylabel("y");

from torch.utils.data import Dataset, DataLoader
ip_s = 500
op_s = 5
bat_s = 10
data_s = 1000
class randDataset(Dataset):
    def __init__(self, size, length):
        self.len = length
        self.data = torch.randn(length, size)
    def __getitem__(self, index):
        return self.data[index]
    def __len__(self):
        return self.len
rand_loader = DataLoader(randDataset(ip_s, data_s), bat_s, shuffle=True)
rand_loader

import torch.nn as nn
class FCN(nn.Module):
    def __init__(self, ip_s, op_s):
        super(FCN, self).__init__()
        self.fc1 = nn.Linear(ip_s, int((ip_s+op_s)/2))
        self.fc2 = nn.Linear(int((ip_s+op_s)/2), op_s)
    def forward(self, input):
        output = self.fc1(input)
        output = self.fc2(output)
        print("\tFCN: input", input.size(),"output", output.size())
        return output
two_layer_nn = FCN(ip_s, op_s)
two_layer_nn = nn.DataParallel(two_layer_nn)
for data in rand_loader:
    input = data
    output = two_layer_nn(input)
    print("input", input.size(),"output", output.size())


sub translate
{
  my $seqn = shift;
  my $seq = shift;
  my $start = shift;
  my $end = shift;

  return if !defined $seq;

  $start = 1 if !defined $start;
  $end = length($seq) if !defined $end;


  $start--;
  my $nona=$seq=~s/[^A-Z]//g;
  my $s = substr($seq, $start, $end-$start);
  my $l = length ($s);

  my $aaseq;

  for (my $i = 0; $i+2 < $l; $i+=3)
  {
    my $aa = $codon{uc(substr($s, $i, 3))};
    $aaseq .= $aa;
  }

  my $aalen = length($aaseq);
  print "$seqn|$start-$end|proteinLength-$aalen|hanging-",$l%3,"|UTR-$nona|\n$aaseq\n";
}



my $file  = shift @ARGV or die $USAGE;
my $start = shift @ARGV;
my $end   = shift @ARGV;

open FASTA, "< $file" or die "Can't open $file for reading ($!)\n";


my $seq;
my $seqn;
while (<FASTA>){
  chomp;
  if (/^>/){
        $seqn=$_;
	translate($seqn,$seq, $start, $end);
	$seq="";
  }
  else{
    $seq .= $_;
  }
}

translate($seqn,$seq, $start, $end);


#http://www.deeplearningbook.org/contents/monte_carlo.html
##https://github.com/kusterlab/prosit/blob/master/prosit/prediction.py
#https://github.com/erikbern/ann-presentation
