#cluster https://nbviewer.jupyter.org/github/KrishnaswamyLab/PHATE/blob/master/Python/tutorial/EmbryoidBody.ipynb
#!pip install --user phate matplotlib==3.1 scprep
#demo https://www.krishnaswamylab.org/projects/phate/eb-web-tool
import sys
base_path = os.path.expanduser("~")
print(base_path)
from pathlib import Path
pathFiles = Path("L:/promec/HF/Lars/2019/november/siri_marit/combined/txt/")
fileName='proteinGroups.txt'
trainList=list(pathFiles.rglob(fileName))

import pandas as pd
df=pd.read_csv(trainList[0],low_memory=False,sep='\t')
print(df.head())
print(df.columns)
dfLFQ=df.loc[:, df.columns.str.startswith('LFQ')&df.columns.str.contains('apim')]

import scprep
import phate
sparse=True
scprep.plot.plot_library_size(dfLFQ, percentile=20)
filtered_batches = scprep.filter.filter_library_size(dfLFQ, percentile=20, keep_cells='above')
scprep.plot.plot_library_size(filtered_batches, percentile=20)

#EBT_counts, sample_labels = scprep.utils.combine_batches(filtered_batches.transpose(),["pool", "r1", "r2", "r3"],append_to_cell_names=True)
#EBT_counts.head()
#EBT_counts = scprep.filter.filter_rare_genes(EBT_counts, min_cells=10)
#EBT_counts = scprep.normalize.library_size_normalize(EBT_counts)
phate_operator = phate.PHATE(n_jobs=-2)
dfLFQ=dfLFQ.rename(columns = lambda x : str(x)[21:])
#EBT_counts=np.log2(dfLFQ.transpose()+1)
EBT_counts=np.log2(dfLFQ+1)
sample_labels=dfLFQ.index
#sample_labels=dfLFQ.columns
Y_phate = phate_operator.fit_transform(EBT_counts)
scprep.plot.scatter2d(Y_phate, c=sample_labels, figsize=(12,8), cmap="Spectral",ticks=False, label_prefix="PHATE")
phate_operator.set_params(knn=4, decay=15, t=12)
# phate_operator = phate.PHATE(knn=4, decay=15, t=12, n_jobs=-2)
Y_phate = phate_operator.fit_transform(EBT_counts)
scprep.plot.scatter2d(Y_phate, c=sample_labels, figsize=(12,8), cmap="Spectral",ticks=False, label_prefix="PHATE")

import sklearn.decomposition # PCA
import time
start = time.time()
pca_operator = sklearn.decomposition.PCA(n_components=2)
Y_pca = pca_operator.fit_transform(np.array(EBT_counts))
end = time.time()
print("Embedded PCA in {:.2f} seconds.".format(end-start))
import matplotlib.pyplot as plt
plt.scatter(Y_pca[:,0],Y_pca[:,1])
import sklearn.manifold # t-SNE
start = time.time()
tsne_operator = sklearn.manifold.TSNE(n_components=2)
#Y_tsne = tsne_operator.fit_transform(pca_operator.fit_transform(np.array(EBT_counts)))
Y_tsne = tsne_operator.fit_transform(np.array(EBT_counts))
end = time.time()
print("Embedded t-SNE in {:.2f} seconds.".format(end-start))
plt.scatter(Y_tsne[:,0],Y_tsne[:,1])

#https://towardsdatascience.com/how-to-program-umap-from-scratch-e6eff67f55fe
from umap import UMAP
plt.figure(figsize=(20,15))
model = UMAP(n_neighbors = 15, min_dist = 0.25, n_components = 2, verbose = True)
umap = model.fit_transform(X_train)
plt.scatter(umap[:, 0], umap[:, 1], c = y_train.astype(int), cmap = 'tab10', s = 50)

#https://github.com/ruggleslab/blackSheep
import blacksheep
annotations = blacksheep.binarize_annotations(sample_labels)

# Run outliers comparative analysis
outliers, qvalues = blacksheep.deva(
    values, annotations,
    save_outlier_table=True,
    save_qvalues=True,
    save_comparison_summaries=True
)

# Pull out results
qvalues_table = qvalues.df
vis_table = outliers.frac_table

# Make heatmaps for significant genes
for col in annotations.columns:
    axs = blacksheep.plot_heatmap(annotations, qvalues_table, col, vis_table, savefig=True)
#https://github.com/ruggleslab/blacksheep_supp/blob/dev/vignettes/running_outliers.ipynb
# Normalize values
phospho = blacksheep.read_in_values('') #Fill in file here
protein = blacksheep.read_in_values('') #Fill in file here


#https://tensorsignatures.readthedocs.io/en/latest/tutorials.html#getting-started
# pip install tensorsignatures==0.4.0
import tensorsignatures as ts
data_set = ts.TensorSignatureData(seed=573, rank=3, samples=100, dimensions=[3, 5], mutations=1000)
snv = data_set.snv()
snv.shape
snv_collapsed = snv.sum(axis=(0,1,2,3,))
snv_coding = snv[0,].sum(axis=(0,1,2,4))
snv_template = snv[1,].sum(axis=(0,1,2,4))
import matplotlib.pyplot as plt
import numpy as np
fig, axes = plt.subplots(3, 3, sharey=True, sharex=True)
for i, ax in enumerate(np.ravel(axes)):
   ax.bar(np.arange(96), snv_collapsed[:, i], color=ts.DARK_PALETTE)
   ax.set_title('Sample {}'.format(i))
   if i%3==0: ax.set_ylabel('Counts')
   if i>=6: ax.set_xlabel('Mutation type')
fig, axes = plt.subplots(1, 2, sharey=True)
axes[0].bar(np.arange(96), snv_coding, color=ts.DARK_PALETTE)
axes[0].set_title('Coding strand mutations')
axes[1].bar(np.arange(96), snv_template, color=ts.DARK_PALETTE)
axes[1].set_title('Template strand mutations')
plt.figure(figsize=(16, 3))
ts.plot_signatures(data_set.S.reshape(3,3,-1,96,3))
#git clone https://github.com/WarrenWeckesser/heatmapcluster.git
#cd heatmapcluster
#python setup.py install
import numpy as np
import matplotlib.pyplot as plt
from heatmapcluster import heatmapcluster
def make_data(size, seed=None):
    if seed is not None:
        np.random.seed(seed)
    s = np.random.gamma([7, 6, 5], [6, 8, 6], size=(size[1], 3)).T
    i = np.random.choice(range(len(s)), size=size[0])
    x = s[i]
    t = np.random.gamma([8, 5, 6], [3, 3, 2.1], size=(size[0], 3)).T
    j = np.random.choice(range(len(t)), size=size[1])
    x += 1.1*t[j].T
    x += 2*np.random.randn(*size)
    row_labels = [('R%02d' % k) for k in range(x.shape[0])]
    col_labels = [('C%02d' % k) for k in range(x.shape[1])]
    return x, row_labels, col_labels
x, row_labels, col_labels = make_data(size=(64, 48), seed=123)
h = heatmapcluster(x, row_labels, col_labels,
                   num_row_clusters=3, num_col_clusters=0,
                   label_fontsize=6,
                   xlabel_rotation=-75,
                   cmap=plt.cm.coolwarm,
                   show_colorbar=True,
                   top_dendrogram=True)
plt.show()
from scipy.cluster.hierarchy import linkage
h = heatmapcluster(x, row_labels, col_labels,
                   num_row_clusters=3, num_col_clusters=0,
                   label_fontsize=6,
                   xlabel_rotation=-75,
                   cmap=plt.cm.coolwarm,
                   show_colorbar=True,
                   top_dendrogram=True,
                   row_linkage=lambda x: linkage(x, method='average',
                                                 metric='correlation'),
                   col_linkage=lambda x: linkage(x.T, method='average',
                                                 metric='correlation'),
                   histogram=True)

#https://threader.app/thread/1105139360226140160
import tensorflow as tf
print(tf.__version__)
import datetime
print(datetime.datetime.now())
tf.keras.backend.clear_session()
(x_train, y_train), (x_test, y_test) = dfLFQ.load_data()
x_train, x_test = (x_train-min(x_train) / (max(x_train)-min(x_train) , (x_test-min(x_test) / (max(x_test)-min(x_test)
print("Eager:",tf.executing_eagerly())
print("GPU:",tf.test.is_gpu_available())#:with tf.device("/gpu:0"):
#tf.keras.backend.clear_session()

def create_model():
  return tf.keras.models.Sequential([
    tf.keras.layers.Flatten(input_shape=(28, 28)),
    tf.keras.layers.Dense(512, activation='relu'),
    tf.keras.layers.Dropout(0.2),
    tf.keras.layers.Dense(10, activation='softmax')
  ])

model = create_model()
model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

log_dir="..\\notebooks\logs\\" + datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
tensorboard_callback = tf.keras.callbacks.TensorBoard(log_dir=log_dir, histogram_freq=1)

model.fit(x=x_train,
          y=y_train,
          epochs=5,
          validation_data=(x_test, y_test),
          callbacks=[tensorboard_callback])

#https://www.youtube.com/watch?v=B4p6gvPs-gM
!cd ../CellBender/examples/remove_background
!python generate_tiny_10x_pbmc.py
!$HOME/.local/bin/cellbender remove-background      --input ./tiny_raw_gene_bc_matrices/GRCh38      --output ./tiny_10x_pbmc.h5      --expected-cells 500   --total-droplets-included 5000
