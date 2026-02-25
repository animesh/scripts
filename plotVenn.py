#python plotVenn.py comb-mntzDownloadMQ-mntzDownloadtesorAI-ProteinIDs-proteingroupid-iBAQ-intensityIBAQ.csv
#python plotVenn.py comb-mntzDownloadMQ-mntzDownloadtesorAI-ProteinIDs-proteingroupid-Top3-intensitytop3.csv
import sys
import pandas as pd
import numpy as np
from supervenn import supervenn
from matplotlib import pyplot as plt
import seaborn as sbn
fileName = sys.argv[1] if len(sys.argv) > 1 else 'merged_master_by_ID.csv'
dfPGI = pd.read_csv(fileName)
dfPGI[dfPGI==0] = np.nan
print(dfPGI.notna().all(axis=1).sum())
print(dfPGI.count(axis=0))
# venn
plt.figure(figsize=(10, 10))
dfPGIvenn = dfPGI.notna()
dfPGIvenn['size'] = 1
sets = [set(dfPGI.index[dfPGI[col].notna()]) for col in dfPGI.columns]
labels = list(dfPGI.columns)
supervenn(sets, labels)
plt.savefig(fileName + ".log2.venn.png", dpi=100, bbox_inches="tight", format='png')
plt.close()
# pairplot
sbn.pairplot(dfPGI).figure.savefig(fileName + ".log2.scatter.png", dpi=100, bbox_inches="tight", format='png')
