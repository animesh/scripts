# %% mm
import pandas as pd
data=pd.read_csv("mm.csv")
mapping = {'G':0,'M':1,'L':-1}
data=data.replace({'Group': mapping})
#data=data[data["Group"] != -1]
print(data["Group"])
print ("Data for Modeling :" + str(data.shape))
# %% setup
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
conda install -c conda-forge mamba pycaret xgboost catboost
mamba install -c rapidsai -c nvidia -c conda-forge cuml
ln -s /mnt/f/GD/OneDrive/Dokumenter/GitHub/scripts .
tail -f scripts/logs.log
# %% autoML
#https://pycaret.gitbook.io/docs/get-started/quickstart#classification
from pycaret.classification import *
exp_mclf101 = setup(data = data, target = 'Group', session_id=42,use_gpu=True,silent=True)
best=compare_models()
evaluate_model(best)
plot_model(best, plot = 'auc')#plot = 'confusion_matrix')
predict_model(best)
#et=create_model('catboost')
#predictions = predict_model(tuned_et, data=data)
predictions = predict_model(best, data=data)#, raw_score=True)
predictions.head()
save_model(best, 'mm_best_pipeline')
loaded_model = load_model('mm_best_pipeline')
print(loaded_model)
#http://www.pycaret.org/tutorials/html/MCLF101.html
import pandas as pd
#dataset=pd.read_csv("mm.csv")
#data=dataset.sample(frac=0.8)
#data_unseen=dataset.drop(data.index)
#data.reset_index(drop=True, inplace=True)
#data_unseen.reset_index(drop=True, inplace=True)
#data.to_csv("mm.train.csv")
#data_unseen.to_csv("mm.test.csv")
data=pd.read_csv("mm.train.csv",index_col=False)
data.drop('Unnamed: 0',axis=1,inplace=True)
data_unseen=pd.read_csv("mm.test.csv")
data_unseen.drop('Unnamed: 0',axis=1,inplace=True)
print ("Data for Modeling :" + str(data.shape))
print("unseen Data For Predictions:"+str(data_unseen.shape))
data_unseen['Group']
#Data for Modeling :(37, 3956)
#unseen Data For Predictions:(9, 3956)
from pycaret.classification import *
exp_mclf101 = setup(data = data, target = 'Group', session_id=42,use_gpu=True)
compare_models()
#MAE lasso +/-6.6676USD
et=create_model('dt')
tuned_et = tune_model (et, n_iter = 1000)
#6.6635
unseen_predictions = predict_model (tuned_et, data=data_unseen)
#https://medium.com/aimstack/an-end-to-end-example-of-aim-logger-used-with-xgboost-library-3d461f535617
from __future__ import division
import numpy as np
import xgboost as xgb
from aim.xgboost import AimCallback
# label need to be 0 to num_class -1
data = np.loadtxt('./dermatology.data', delimiter=',',
        converters={33: lambda x:int(x == '?'), 34: lambda x:int(x) - 1})
sz = data.shape
train = data[:int(sz[0] * 0.7), :]
test = data[int(sz[0] * 0.7):, :]
train_X = train[:, :33]
train_Y = train[:, 34]
test_X = test[:, :33]
test_Y = test[:, 34]
print(len(train_X))
xg_train = xgb.DMatrix(train_X, label=train_Y)
xg_test = xgb.DMatrix(test_X, label=test_Y)
# setup parameters for xgboost
param = {}
# use softmax multi-class classification
param['objective'] = 'multi:softmax'
# scale weight of positive examples
param['eta'] = 0.1
param['max_depth'] = 6
param['nthread'] = 4
param['num_class'] = 6
watchlist = [(xg_train, 'train'), (xg_test, 'test')]
num_round = 50
bst = xgb.train(param, xg_train, num_round, watchlist)
# get prediction
pred = bst.predict(xg_test)
error_rate = np.sum(pred != test_Y) / test_Y.shape[0]
print('Test error using softmax = {}'.format(error_rate))
# do the same thing again, but output probabilities
param['objective'] = 'multi:softprob'
bst = xgb.train(param, xg_train, num_round, watchlist, 
                callbacks=[AimCallback(repo='.', experiment='xgboost_test')])
# Note: this convention has been changed since xgboost-unity
# get prediction, this is in 1D array, need reshape to (ndata, nclass)
pred_prob = bst.predict(xg_test).reshape(test_Y.shape[0], 6)
pred_label = np.argmax(pred_prob, axis=1)
error_rate = np.sum(pred_label != test_Y) / test_Y.shape[0]
print('Test error using softprob = {}'.format(error_rate))
#https://medium.com/aimstack/aim-basics-using-context-and-subplots-to-compare-validation-and-test-metrics-f1a4d7e6b9ca
import aim

# train loop
for epoch in range(num_epochs):
  for i, (images, labels) in enumerate(train_loader):
    if i % 30 == 0:
      aim.track(loss.item(), name='loss', epoch=epoch, subset='train')
      aim.track(acc.item(), name='accuracy', epoch=epoch, subset='train')
    
  # calculate validation metrics at the end of each epoch
  # ...
  aim.track(loss.item(), name='loss', epoch=epoch, subset='val')
  aim.track(acc.item(), name='acc', epoch=epoch, subset='val')
  # ...
  
  # calculate test metrics 
  # ...
  aim.track(loss.item(), name='loss', subset='test')
  aim.track(acc.item(), name='loss', subset='test')
#https://towardsdatascience.com/introduction-to-hydra-cc-a-powerful-framework-to-configure-your-data-science-projects-ed65713a53c6
#import hydra
#from hydra import utils 
import pandas as pd 
#@hydra.main(config_path="conf", config_name='preprocessing.yaml')
#pd.read_csv(utils.get_original_cwd() + "/" + config.dataset.data, encoding=config.dataset.encoding)
#python file.py model=logisticregression
df=pd.read_csv("data/data.csv")
from sklearn.preprocessing import StandardScaler
X,y=df.iloc[:,:-1],df['Group']
scalar = StandardScaler().fit(X)
scalar.feature_names_in_
#from sklearnex import patch_sklearn
#patch_sklearn()
#sklearnex.unpatch_sklearn()
# You need to re-import scikit-learn algorithms after the unpatch:
from sklearn.cluster import KMeans
kmeans = KMeans(n_clusters=2, random_state=0).fit(X)
print(f"kmeans.labels_ = {kmeans.labels_}")
#df.corr('spearman')
print(df.groupby(["Group"])['NDUFB7.6'].transform(lambda x: x.fillna(x.mean())))
dfNAR=df.groupby(["Group"]).transform(lambda x: x.fillna(x.mean()))
print(min(dfNAR.min()))
dfNARM=dfNAR.fillna(int(min(dfNAR.min())-1))
print(min(dfNARM.min()))
dfNARM["Group"]=df["Group"]
dfNARM.to_csv("data/data.NARM.csv",index=False)
X,y=dfNARM.iloc[:,:-1],dfNARM['Group']
scalar = StandardScaler().fit(X)
scalar.feature_names_in_
kmeans = KMeans(n_clusters=2, random_state=0).fit(X)
print(f"kmeans.labels_ = {kmeans.labels_}")
#https://scikit-learn.org/stable/auto_examples/release_highlights/plot_release_highlights_1_0_0.html
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder
X=dfNARM
preprocessor = ColumnTransformer(
    [
        ("numerical", StandardScaler(), ["age"]),
        ("categorical", OneHotEncoder(), ["Group"]),
    ],
    verbose_feature_names_out=False,
).fit(X)
preprocessor.get_feature_names_out()
from sklearn.linear_model import LogisticRegression
from sklearn.pipeline import make_pipeline
pipe = make_pipeline(preprocessor, LogisticRegression())
pipe.fit(X, y)
pipe[:-1].get_feature_names_out()
#https://scikit-learn.org/stable/auto_examples/miscellaneous/plot_anomaly_comparison.html#sphx-glr-auto-examples-miscellaneous-plot-anomaly-comparison-py
from sklearn.ensemble import HistGradientBoostingClassifier
anomaly_algorithms = [
    ("Robust covariance", EllipticEnvelope(contamination=outliers_fraction)),
    ("One-Class SVM", svm.OneClassSVM(nu=outliers_fraction, kernel="rbf", gamma=0.1)),
    (
        "One-Class SVM (SGD)",
        make_pipeline(
            Nystroem(gamma=0.1, random_state=42, n_components=150),
            SGDOneClassSVM(
                nu=outliers_fraction,
                shuffle=True,
                fit_intercept=True,
                random_state=42,
                tol=1e-6,
            ),
        ),
    ),
    (
        "Isolation Forest",
        IsolationForest(contamination=outliers_fraction, random_state=42),
    ),
    (
        "Local Outlier Factor",
        LocalOutlierFactor(n_neighbors=35, contamination=outliers_fraction),
    ),
]
        if name == "Local Outlier Factor":
            y_pred = algorithm.fit_predict(X)
        else:
            y_pred = algorithm.fit(X).predict(X)

        # plot the levels lines and the points
        if name != "Local Outlier Factor":  # LOF does not implement predict
            Z = algorithm.predict(np.c_[xx.ravel(), yy.ravel()])
            Z = Z.reshape(xx.shape)
            plt.contour(xx, yy, Z, levels=[0], linewidths=2, colors="black")


import sys
if len(sys.argv)!=3: sys.exit("\n\nREQUIRED: pandas! Tested with Python 3.7.9 \n\nUSAGE: python resultsGroupby.py <path to file of interest like \"L:\promec\mqpar.xml.1623227664.results\combined\txt\proteinGroupsCombine.py> <column of interest like \"Score\"\n\n")
#python resultsGroupby.py "L:\promec\USERS\Synnøve\20210709_Synnove_6samples\HF\combined\txt\msmsScans.txt" "Raw file"
inpF = sys.argv[1]
columnID = sys.argv[2]
#inpF = "L:\\promec\\USERS\\Synnøve\\20210709_Synnove_6samples\\HF\\combined\\txt\\msmsScans.txt"
#columnID = "Raw file"
import pandas as pd
df = pd.read_table(inpF)
df.describe()
print(df.columns)
print(df.head())
#print(df.info())
dfC=df.groupby(columnID).count()
print(dfC)
outFc=inpF+columnID+"count.csv"
dfC.to_csv(outFc)#.with_suffix('.combo.csv'))
print(outFc)
outFc=inpF+columnID+"count.png"
dfC.iloc[:,1].plot(kind="barh").figure.savefig(outFc,dpi=100,bbox_inches = "tight")
#plt.close()
print(outFc)
dfS=df.groupby(columnID).sum()