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