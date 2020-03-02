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

#file = pathlib.Path.cwd().parent.rglob('*.MGF')
file = pathlib.Path.cwd() / 'mgf/20150512_BSA_The-PEG-envelope.raw.profile.MGF'
#file = pathlib.Path.cwd().parent / 'RawRead/171010_Ip_Hela_ugi.raw.intensity0.charge0.MGF'
#file = pathlib.Path('F:/mgf/20150512_BSA_The-PEG-envelope.raw.profile.MGF')
#print(file.read_text().split(' '))
out=parseMGF(file)

X=[(out[k]['pep_mass']-1.00727647)*int(out[k]['charge'].split('+')[0]) for k, _ in out.items()]
X_mz1=np.array(X).reshape(-1, 1)
print(X_mz1.shape)

X=[(out[k]['pep_intensity']) for k, _ in out.items()]
X_int=np.array(X).reshape(-1, 1)
print(X_int.shape)

X=[np.float(out[k]['rtinseconds']) for k, _ in out.items()]
X_rt=np.array(X).reshape(-1, 1)
print(X_rt.shape)

k=0
print(out[k],X_int[k],X_mz1[k],X_rt[k])
data = pd.DataFrame(data=np.column_stack((X_mz1,X_int)),columns=['mz1','intensity'])#{'mz1':[X_mz1], 'intensity':[X_int]})
data.plot('mz1','intensity', kind='scatter')
labels = pd.Series(np.round(X_rt).flatten(), index=data.index, name='labels')

#https://github.com/liliblu/hypercluster
import pandas as pd
from sklearn.datasets import make_blobs
import hypercluster

data, labels = make_blobs()
data = pd.DataFrame(data)
labels = pd.Series(labels, index=data.index, name='labels')

# With a single clustering algorithm
clusterer = hypercluster.AutoClusterer()
clusterer.fit(data).evaluate(
  methods = hypercluster.constants.need_ground_truth+hypercluster.constants.inherent_metrics,
  gold_standard = labels
  )
clusterer.visualize_evaluations()

import scipy.spatial.distance
dataD = scipy.spatial.distance.pdist(X_mz1, 'cityblock')
dataD.size-X_mz1.size*X_mz1.size/2
plt.hist(dataD,bins=np.arange(min(dataD), max(dataD) + binwidth, binwidth))
binwidth=44
tol=0.5
np.count_nonzero((binwidth-tol < dataD) & (dataD < binwidth+tol))
binA=[np.count_nonzero((binwidth-tol < dataD) & (dataD < binwidth+tol)) for binwidth in range(dataD.size)]
plt.hist(binA,bins=44)
X_int=np.array(X).reshape(-1, 1)
print(X_int.shape)
#np.digitize(dataD, binwidth)
#[i*i for i in X_mz1]

import matplotlib.pyplot as plt
a=np.histogram(dataD*1000,bins='auto')
len(a)#[0])
aD=a[0][0:len(a[0])]
len(np.array(a).reshape(-1, 1))
a[1].shape[0]
plt.plot(a[0][0:100])#,a[1][10:20])
a=np.arange(min(dataD), max(dataD) + binwidth, binwidth)
plt.hist(np.random.rand(1000))
plt.hist(np.random.randn(1000))
np.random.randint(10)
a=a+np.random.rand(len(a))
plt.hist(a)#,bins=np.arange(min(dataD), max(dataD) + binwidth, binwidth))
aD = scipy.spatial.distance.pdist(np.array(a).reshape(-1, 1), 'cityblock')
#aD = dataD
plt.hist(aD,bins=np.arange(min(dataD), max(dataD) + binwidth, binwidth))
#aDD=scipy.spatial.distance.pdist(np.array(aD).reshape(-1, 1), 'cityblock')
aDD=np.histogram(aD,bins=np.arange(min(dataD), max(dataD) + binwidth, binwidth))
#max(np.histogram(aDD,bins=np.arange(min(dataD), max(dataD) + binwidth, binwidth))[0])
aDD[1][np.argmax(aDD[0])]
plt.hist(aDD)#,bins=np.arange(min(dataD), max(dataD) + binwidth, binwidth))
plt.hist(dataD,bins=np.arange(min(dataD), max(dataD) + binwidth, binwidth))

print(X_mz1, X_rt)
plt.scatter(X_rt,X_mz1)
#plt.scatter(X_rt,X_int)
#from scipy.fftpack import fft
mz1fft=np.fft.fft(X_mz1)
mz1fftabs=np.abs(mz1fft)
plt.plot(mz1fftabs)
#fft = np.fft.fft(X_mz1)
plt.scatter(mz1fftabs,X_mz1)
#https://youtu.be/Oa_d-zaUti8?list=PL-wATfeyAMNrtbkCNsLcpoAyBBRJZVlnf&t=800
freq=np.linspace(0,len(mz1fftabs),len(mz1fftabs))#RT at SR?
plt.scatter(freq,mz1fftabs)
import librosa
sig=librosa.core.stft(X_mz1.reshape(2,-1),100,10)
sgram=np.abs(sig)
librosa.display.specshow(sgram)
T = X_rt[1] - X_rt[0]  # sampling interval
#rtD=[X_rt[1] - X_rt[0] for
N = X_mz1.size

# 1/T = frequency
f = np.linspace(0, 1 / T, N)
plt.hist(X_mz1)
plt.hist(np.abs(fft))#[:N // 2] * 1 / N)
plt.plot(np.abs(fft))#[:N // 2] * 1 / N)
#plt.ylabel("Amplitude")
#plt.xlabel("Frequency [Hz]")
plt.bar(f[:N // 2], np.abs(fft)[:N // 2] * 1 / N, width=1.5)  # 1 / N is a normalization factor
plt.show()

import scipy.fftpack
N = 600
T = 1.0 / 800.0
x = np.linspace(0.0, N*T, N)
y = np.sin(50.0 * 2.0*np.pi*x) + 0.5*np.sin(80.0 * 2.0*np.pi*x)
yf = scipy.fftpack.fft(y)
xf = np.linspace(0.0, 1.0/(2.0*T), N/2)
fig, ax = plt.subplots()
ax.plot(xf, 2.0/N * np.abs(yf[:N//2]))
plt.show()

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
