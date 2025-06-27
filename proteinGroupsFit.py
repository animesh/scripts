#python proteinGroupsFit.py "L:\promec\TIMSTOF\LARS\2025\250402_dda_Hela\tesorai\HeLaCon_quantified_protein_fdr.tsv" 3 10
import sys
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.cluster import hierarchy
fPath = sys.argv[1]
#fPath = "L:\\promec\\TIMSTOF\\LARS\\2025\\250402_dda_Hela\\tesorai\\HeLaCon_quantified_protein_fdr.tsv"
idxCol = int(sys.argv[2])
#idxCol = 3
valCol = int(sys.argv[3])
#valCol = 10
print(fPath,idxCol,valCol)
df = pd.read_csv(fPath,sep='\t', index_col=idxCol)
fPath=fPath+df.columns[idxCol]+df.columns[valCol]
print(fPath)
def parseToNumList(intensityList):
    if isinstance(intensityList,float):
        return intensityList
    else:
        valueStr = intensityList.strip('[]').split()
        values = []
        for val in valueStr:
            if val.lower() == 'nan':
                values.append(np.nan)
            else:
                values.append(float(val))
        return values
df[df.columns[valCol]] = df[df.columns[valCol]].apply(parseToNumList)
df['sum'] = df[df.columns[valCol]].apply(np.nansum)
#print((df[df.columns[valCol]]-df['sum']).sum())
print(df.columns)
#df['top3avg'] = df['intensities'].apply(lambda x: np.mean(np.sort(np.array(x)[~np.isnan(x)])[-3:]) if np.sum(~np.isnan(x)) >= 3 else np.nanmean(x))
#plt.plot(df['top3avg'],df['intensity_top3'])
#df['intensitiesNormLen']=df['sum']/df['protein_length']
#plt.plot(df['intensitiesNormLen'],df['intensity_IBAQ'])
df=df[['filename','sum']]
df=df.pivot(columns='filename', values='sum')
print(df.info())
df[df==0] = np.nan
print(df.info())
df.to_excel(fPath+".xlsx")
coefV=df.corr()**2
row_linkage = hierarchy.linkage(coefV, method='average')
col_linkage = hierarchy.linkage(coefV.T, method='average')
plt.figure(figsize=(16,12))
clustered_heatmap = sns.clustermap(coefV,cmap='coolwarm',annot=True,fmt=".3f",row_linkage=row_linkage,col_linkage=col_linkage,annot_kws={"size":8},figsize=(16,12))
plt.title('Clustered R^2 Values')
plt.tight_layout()
plt.savefig(fPath+".r2.clust.svg", dpi=600, bbox_inches="tight")
plt.close()
print("Clustered R^2 Values in ", fPath+".r2.clust.svg")
slopesDF = pd.DataFrame(index=df.columns, columns=df.columns)
rsqDF = pd.DataFrame(index=df.columns, columns=df.columns)
slopesDFnpf = pd.DataFrame(index=df.columns, columns=df.columns)
interceptDFnpf = pd.DataFrame(index=df.columns, columns=df.columns)
for col_x in df.columns:
        for col_y in df.columns:
            if col_x != col_y:
                xy_data = df[[col_x, col_y]].dropna()
                x = xy_data[col_x]
                y = xy_data[col_y]
                slopesDF.loc[col_x, col_y] = (x * y).sum() / (x ** 2).sum()
                y_pred = slopesDF.loc[col_x, col_y] * x
                ss_res = np.sum((y - y_pred) ** 2)
                ss_tot = np.sum(y ** 2)  # not using y - mean(y) for origin-centered model 
                r_squared = 1 - (ss_res / ss_tot)
                rsqDF.loc[col_x, col_y] = r_squared
                slope, intercept = np.polyfit(x, y, 1)
                slopesDFnpf.loc[col_x, col_y] = slope
                interceptDFnpf.loc[col_x, col_y] = intercept
            else:
                slopesDF.loc[col_x, col_y] = 1
                slopesDFnpf.loc[col_x, col_y] = 1
                interceptDFnpf.loc[col_x, col_y] = 0
                rsqDF.loc[col_x, col_y] = 1
#print(slopesDF.dtypes)
slopesDF = slopesDF.apply(pd.to_numeric, errors='coerce')
row_linkage = hierarchy.linkage(slopesDF, method='average')
col_linkage = hierarchy.linkage(slopesDF.T, method='average')
plt.figure(figsize=(16,12))
clustered_heatmap = sns.clustermap(slopesDF,cmap='YlOrBr',annot=True,fmt=".2f",row_linkage=row_linkage,col_linkage=col_linkage,annot_kws={"size":8},figsize=(16,12))
plt.title('Clustered Slope Values')
plt.tight_layout()
plt.savefig(fPath+".m.clust.svg", dpi=600, bbox_inches="tight")
plt.close()
print("Clustered Slope Values in svg", fPath+".m.clust.svg")
slopesDFnpf = slopesDFnpf.apply(pd.to_numeric, errors='coerce')
row_linkage = hierarchy.linkage(slopesDFnpf, method='average')
col_linkage = hierarchy.linkage(slopesDFnpf.T, method='average')
plt.figure(figsize=(16,12))
clustered_heatmap = sns.clustermap(slopesDFnpf,cmap='YlOrBr',annot=True,fmt=".2f",row_linkage=row_linkage,col_linkage=col_linkage,annot_kws={"size":8},figsize=(16,12))
plt.title('Clustered Slope Values with Intercept')
plt.tight_layout()
plt.savefig(fPath+".mxPc.clust.svg", dpi=600, bbox_inches="tight")
plt.close()
print("Clustered Slope Values with Intercept in svg", fPath+".mxPc.clust.svg")
plt.close()
interceptDFnpf = interceptDFnpf.apply(pd.to_numeric, errors='coerce')
row_linkage = hierarchy.linkage(interceptDFnpf, method='average')
col_linkage = hierarchy.linkage(interceptDFnpf.T, method='average')
plt.figure(figsize=(16,12))
clustered_heatmap = sns.clustermap(interceptDFnpf,cmap='Blues',annot=True,fmt=".2f",row_linkage=row_linkage,col_linkage=col_linkage,annot_kws={"size":8},figsize=(16,12))
plt.title('Clustered Intercept Values with Slope')
plt.tight_layout()
plt.savefig(fPath+".cPmx.clust.svg", dpi=600, bbox_inches="tight")
plt.close()
print("Clustered Intercept Values with Slope in svg", fPath+".cPmx.clust.svg")
plt.close()
rsqDF = rsqDF.apply(pd.to_numeric, errors='coerce')
row_linkage = hierarchy.linkage(rsqDF, method='average')
col_linkage = hierarchy.linkage(rsqDF.T, method='average')
plt.figure(figsize=(16,12))
clustered_heatmap = sns.clustermap(rsqDF,cmap='coolwarm',annot=True,fmt=".4f",row_linkage=row_linkage,col_linkage=col_linkage,annot_kws={"size":8},figsize=(16,12))
plt.title('Clustered R^2 Values with 0 as intercept')
plt.tight_layout()
plt.savefig(fPath+".r2.0.clust.svg", dpi=600, bbox_inches="tight")
plt.close()
print("Clustered R^2 Values with 0 as intercept in svg", fPath+".r2.0.clust.svg")
plt.close()
