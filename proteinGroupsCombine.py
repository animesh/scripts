# python proteinGroupsCombine.py L:\promec\HF\Lars\2024\241121_mediumtest\combined\txt\proteinGroups.txt
# %%setup
#python -m pip install pandas seaborn pathlib supervenn
import sys
from pathlib import Path
# %% read
if len(sys.argv) != 2: sys.exit("\n\nREQUIRED: pandas, seaborn, supervenn, pathlib\nUSAGE: python peptideGroupsCombine.py <path to folder containing peptides.txt file(s)>")
pathFiles = Path(sys.argv[1])
#pathFiles=Path("L:/promec/HF/Lars/2024/241121_mediumtest/combined/txt/proteinGroups.txt")
import pandas as pd
proteinHits=pd.read_csv(pathFiles,low_memory=False,sep='\t')
proteinHits=proteinHits[proteinHits['Reverse']!="+"]
proteinHits=proteinHits[proteinHits['Potential contaminant']!="+"]
#proteinHits=proteinHits[proteinHits['Only identified by site']!="+"]
#%%intensity
print("Intensity common")
proteinHitsI=proteinHits[[col for col in proteinHits.columns if 'Intensity ' in col]]
import numpy as np
dfIpDDlog2=np.log2(proteinHitsI+1)
dfIpDDlog2.to_csv(str(pathFiles) +'.dfIpDDlog2.csv')
print(dfIpDDlog2.corr(method='pearson'))
#%%scatter
import seaborn as sns
ppS=sns.PairGrid(dfIpDDlog2)
coefV=dfIpDDlog2.corr()
ppS.fig.suptitle(coefV)
ppS.map_diag(sns.histplot)
ppS.map_lower(sns.kdeplot)
ppS.map_upper(sns.regplot)
ppS.savefig(str(pathFiles)+"dfIpDDlog2.scatter.svg", dpi=100, bbox_inches="tight")
#%%score
dfCp=dfIpDDlog2
dfCp['SumC']=dfCp.astype(str).sum(axis=1)
dfCp=dfCp[dfCp['SumC']!=0]
dfCp=dfCp.sort_values('SumC',ascending=False)
dfCpDD=dfCp.drop_duplicates()    
print(dfCpDD.notna().all(axis=1).sum())
print(dfCpDD.count(axis=0))
#%%results
print("procesed" +str(pathFiles))
print("results")
print(str(pathFiles)+"Combo.score.csv")
# %% venn
from supervenn import supervenn, make_sets_from_chunk_sizes
import matplotlib.pyplot as plt
plt.figure(figsize=(10, 10))
dfIpDDlog2.replace(0, np.nan, inplace=True)
dfPGIvenn = dfIpDDlog2.notna()
dfPGIvenn['size'] = 1#dfPGIvenn.sum(axis=1)
sets, labels = make_sets_from_chunk_sizes(dfPGIvenn)
supervenn(sets, labels)
#plt.show()
plt.savefig(str(pathFiles)+"dfPGI.venn.svg", dpi=100, bbox_inches="tight")
plt.close()
plt.figure(figsize=(10, 10))
dfPepGSvenn = dfCpDD.notna()
dfPepGSvenn['size'] = 1#dfPGIvenn.sum(axis=1)
sets, labels = make_sets_from_chunk_sizes(dfPepGSvenn)
supervenn(sets, labels)
#plt.show()
plt.savefig(str(pathFiles)+"dfPGS.venn.svg", dpi=100, bbox_inches="tight")
plt.close()

