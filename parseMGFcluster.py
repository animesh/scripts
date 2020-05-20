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
file = pathlib.Path.cwd() / '../RawRead/20150512_BSA_The-PEG-envelope.raw.profile.MGF'
#file = pathlib.Path('F:/GD/RawRead/20150512_BSA_The-PEG-envelope.raw.profile.MGF')
#file = pathlib.Path.cwd().parent / 'RawRead/171010_Ip_Hela_ugi.raw.intensity0.charge0.MGF'
#print(file.read_text().split(' '))
out=parseMGF(file)

X=[(out[k]['pep_mass']-1.00727647)*int(out[k]['charge'].split('+')[0]) for k, _ in out.items()]
X_mz1=np.array(X).reshape(-1, 1)
print(X_mz1.shape)


import scipy.spatial.distance
dataD = scipy.spatial.distance.pdist(X_mz1, 'cityblock')
dataD.size-X_mz1.size*X_mz1.size/2

import matplotlib.pyplot as plt
binwidth=0.02
sample=100
plt.hist(dataD,bins=np.arange(min(dataD), max(dataD) + binwidth, sample*binwidth))

tol=binwidth/2
region=44
binS=np.sort(dataD)
np.count_nonzero((region-tol < binS) & (binS < region+tol))
plt.hist(binS,bins=sample)

stB=1000000
spB=2*stB#binS.size
plt.scatter(range(stB,spB),binS[stB:spB])
binSs=binS[stB:spB]
plt.scatter(range(len(binSs)),binSs)
plt.hist(binSs,bins=region)

np.count_nonzero((region-tol < binSs) & (binSs < region+tol))

#binA=[np.count_nonzero((region-tol < dataD) & (dataD < region+tol)) for binwidth in range(dataD.size)]
binA=[np.count_nonzero((region-tol < dataD) & (dataD < region+tol)) for region in range(sample)]
plt.hist(binA,bins=sample)
plt.plot(binA[:sample])
plt.scatter(range(sample),np.log2(binA[:sample]))

mz1fft=np.fft.fft(binA)
plt.hist(mz1fft,bins=sample)
mz1fftabs=np.abs(mz1fft)
mz1fftabs.size--
plt.hist(mz1fftabs,bins=sample)
plt.semilogy(mz1fftabs[:sample])
#fft = np.fft.fft(X_mz1)
plt.scatter(binSs[:sample],mz1fftabs)
#https://youtu.be/Oa_d-zaUti8?list=PL-wATfeyAMNrtbkCNsLcpoAyBBRJZVlnf&t=800
freq=np.linspace(0,len(mz1fftabs),len(mz1fftabs))#RT at SR?
plt.scatter(freq,mz1fftabs)

#https://raw.githubusercontent.com/CNIC-Proteomics/SHIFTS/master/SourceCode/SlopeCalculation.pygithub.com/CNIC-Proteomics/SHIFTS/blob/master/SourceCode/SlopeCalculation.py
def bInt(mz1,delta):
    histDic={}
    deltaBin=float(delta)
    for mz1D in mz1:
        #intD = int(mz1D / deltaBin) * deltaBin + deltaBin / 2
        #truncateDmass1 = round(intD, 1)
        #print(intD,truncateDmass1)
        truncateDmass1 = int(mz1D / deltaBin) * deltaBin + deltaBin / 2
        #truncateDmass1 = float("%.1f" % intD)
        #truncateDmass1 = int(intD)
        #print(intD,truncateDmass1)
        if truncateDmass1 not in histDic: histDic[truncateDmass1] = 1
        else: histDic[truncateDmass1] += 1
    return histDic

testBin=np.linspace(0, 1, num=10000)
testBin.size
plt.hist(testBin)

histDic1=bInt(testBin,0.1)

len(histDic1)
plt.scatter(histDic1.keys(),histDic1.values())
plt.hist(histDic1.values())

histDic2=[np.count_nonzero((binwidth-tol < testBin) & (testBin < binwidth+tol)) for binwidth in range(100)]
len(histDic2)

histDicT=bInt(binSs,0.02)
len(histDicT)
plt.hist(histDicT.values(),bins=sample)#np.arange(min(dataD), max(dataD) + binwidth, binwidth))

from scipy.stats.stats import linregress
for value in binSs[:6]:
    print(value)
for index in range(0, len(binSs[:sample]) - 6):
    s, intercept, r, p, std_error = linregress(binSs[index:index + 7], binSs[index:index + 7])
    print(s, intercept, r, p, std_error,"\n")
for value in histDicT:
    temp = histDicT[value]
    print(value,temp)#,histDicT[0],histDicT[1],histDicT[2])
histDicT=histDic1
histDicT=bInt(binS,0.02)
import itertools
slope1=[]
slope1pos=[]
for index in range(0, len(histDicT) - 6):
        tempD=dict(itertools.islice(histDicT.items(), index,index + 7))
        #print(list(tempD.values()))
        s, intercept, r, p, std_error = linregress(list(tempD.keys()), list(tempD.values()))
        #print(index,tempD,s, intercept, r, p, std_error)
        slope1.append(s)
        slope1pos.append(list(tempD.keys())[0])
np.histogram(slope1,bins=1000)
plt.hist(slope1)
npslope1pos=np.array(slope1pos)
npslope1=np.array(slope1)
npthr=100000
plt.scatter(npslope1pos[npslope1>npthr],npslope1[npslope1>npthr])#,slope2)
slope2=[]
slope2pos=[]
for index1 in range(0, len(histDicT) - 13):
    tempD=dict(itertools.islice(histDicT.items(), index1 + 3,index1 + 10))
    #print(index1,len(tempD),len(slope1[index1 + 1:index1 + 8]))
    s1, intercept1, r1, p1, std_error1 = linregress(list(tempD.values()), slope1[index1 + 1:index1 + 8])
    slope2.append(s1)
    slope2pos.append(list(tempD.keys())[0])
plt.hist(slope2)
plt.plot(slope2pos,slope2)
outL=slop(histDicT,0.01)
print(outL)
plt.hist(outL)
def slop(bin,binwidth):
    outputlist = [["Bin", "\t", "Frequency", "\t", "Slope1", "\t", "Slope2", "\t", "peak-Width", "\t", "peak-Apex", "\t","intercept_mass", "\n"]]
    slope1 = [0]
    for index in range(0, len(bin) - 6):
        tempD=dict(itertools.islice(bin.items(), index,index + 7))
        s, intercept, r, p, std_error = linregress(list(tempD.keys()), list(tempD.values()))
        slope1.append(s)
    slope2 = []
    for index1 in range(0, len(bin) - 13):
        tempD=dict(itertools.islice(bin.items(), index1 + 3,index1 + 10))
        #print(index1,len(tempD),len(slope1[index1 + 1:index1 + 8]))
        s1, intercept1, r1, p1, std_error1 = linregress(list(tempD.values()), slope1[index1 + 1:index1 + 8])
        slope2.append(s1)
    apex = []
    peak = []
    interceptList = [0]
    if len(bin) % 2 == 0:
        minus1 = 6
        minus2 = 3
    else:
        minus1 = 7
        minus2 = 3
    for index3 in range(len(bin) - minus1):
        if slope1[index3] > 0.0 and slope1[index3 + 1] < 0.0:
            apex.append("1")
        else:
            apex.append("0")
    for index4 in range(len(bin) - 13):
        if slope2[index4] < 0:
            peak.append("1")
        else:
            peak.append("0")
    slope1 = [0] * 2 + slope1 + [0] * 3
    slope2 = [0] * 6 + slope2 + [0] * 6
    apex = [0] * 3 + apex + [0] * (len(bin) - (len(apex) + 3))
    peak = [0] * 6 + peak + [0] * 6
    for index6 in range(len(bin) - 6):
        if (abs(slope1[index6 + 1]) + abs(slope1[index6 + 2])) == 0.0:
            intercept_mass = float("inf")
            interceptList.append(intercept_mass)
        else:
            tempD=dict(itertools.islice(bin.items(), index6,index6))
            intercept_mass = list(tempD.values()) + (float(binwidth) * abs(slope1[index6 + 1])) / (
                abs(slope1[index6 + 1]) + abs(slope1[index6 + 2]))
            interceptList.append(intercept_mass)
    interceptList = interceptList + [0] * (len(bin) - len(interceptList))
    plot_x = []
    plot_y = []
    for index5 in range(len(bin)-13):
        tempD=dict(itertools.islice(bin.items(), index5,index5))
        outputlist.append([str(list(tempD.values())), "\t", str(slope1[index5]), "\t", str(slope1[index5]), "\t", str(slope2[index5]),"\t", str(peak[index5]), "\t", str(apex[index5]), "\t", str(interceptList[index5]), "\n"])
    return outputlist


X=[(out[k]['pep_intensity']) for k, _ in out.items()]
X_int=np.array(X).reshape(-1, 1)
print(X_int.shape)

X=[np.float(out[k]['rtinseconds']) for k, _ in out.items()]
X_rt=np.array(X).reshape(-1, 1)
print(X_rt.shape)

k=0
print(out[k],X_int[k],X_mz1[k],X_rt[k])

import pandas as pd
data = pd.DataFrame(data=np.column_stack((X_mz1,X_int)),columns=['mz1','intensity'])#{'mz1':[X_mz1], 'intensity':[X_int]})
data.plot('mz1','intensity', kind='scatter')

curV=npslope1pos[npslope1>npthr]
np.gcd.reduce([15, 25, 35])#https://docs.scipy.org/doc/numpy/reference/generated/numpy.gcd.html
np.gcd.reduce(np.int64(np.round([ 43.1,  43.1,  86.2,  86.2, 129.3])))
np.gcd.reduce(np.int64(np.round(curV)))
x=np.linspace(-int(2*np.pi*10),int(2*np.pi*10),100)
#x=np.linspace(0.0, 600/800, 600)
curV = np.sin(50.0*2.0*np.pi*x)
curV = np.sin(x)
plt.plot(curV)
mz1fft=np.fft.fft(curV)
mz1fftabs=np.abs(mz1fft)
np.max(mz1fftabs)
np.argmax(mz1fftabs[1:])#/np.pi
plt.plot(mz1fftabs)
plt.semilogy(mz1fftabs)

plt.plot()

mz1fft=np.fft.fft(binS)
mz1fftabs=np.abs(mz1fft)
mz1fftabs.size
plt.semilogy(mz1fftabs)#[int(10E3):int(10E4)])
#fft = np.fft.fft(X_mz1)
plt.scatter(mz1fftabs,binSs)
#https://youtu.be/Oa_d-zaUti8?list=PL-wATfeyAMNrtbkCNsLcpoAyBBRJZVlnf&t=800
freq=np.linspace(0,len(mz1fftabs),len(mz1fftabs))#RT at SR?
plt.scatter(freq,mz1fftabs)


from sklearn.mixture import GaussianMixture as GMM
gmm_model=GMM(n_components=10,covariance_type='tied').fit(np.array(binA).reshape(-1, 1))
gmm_predictions=gmm_model.predict(np.array(binA).reshape(-1, 1))



from sklearn.cluster import KMeans
kmeans_model=KMeans(n_clusters=3)
kmeans_model.fit(np.array(binA).reshape(-1, 1))
labels = kmeans_model.predict(np.array(binA).reshape(-1, 1))
centroids = kmeans_model.cluster_centers_
colors = map(lambda x: colmap[x+1], labels)
plt.scatter(labels, binA)#, color=colors, alpha=0.5, edgecolor='k')
for idx, centroid in enumerate(centroids):
    plt.scatter(*centroid, color=colmap[idx+1])

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


#https://github.com/liliblu/hypercluster
labels = pd.Series(np.round(X_rt).flatten(), index=data.index, name='labels')
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
