#dependencies: pandas and pathlib
#install: pip install pandas pathlib
#data: https://ftp.pride.ebi.ac.uk/pride/data/archive/2014/09/PXD000279/dynamicrangebenchmark.zip
#USAGE: python pepIntSum.py <path to folder containing peptides.txt AND proteinGroups.txt files for the experiment>
#e.g. tested on windows-11: python.exe pepIntSum.py  C:\Users\sharm\Downloads\dynamicrangebenchmark\
import sys
from pathlib import Path
pathFiles = Path(sys.argv[1])
#pathFiles = Path("L:\\promec\\USERS\\Alessandro\\230119_66samples-redo\\combined\\txt\\")
import pandas as pd
df=pd.read_csv(pathFiles/"peptides.txt",low_memory=False,sep='\t')
print(df.columns)
print(df.head())
#import matplotlib.pyplot as plt
#plt.plot(df['Intensity'])
dfS=df.copy()
#dfS=df[df['PEP']<0.01]
#print(dfS['Mod. peptide IDs'].value_counts())
#plt.plot(dfS['Intensity'])
#dfS.rename({'Leading razor protein':'ID'},inplace=True,axis='columns')
dfS.rename({'Proteins':'ID'},inplace=True,axis='columns')
print(dfS[dfS==0].count())
import numpy as np
dfS.replace(0, np.nan, inplace=True)
print(dfS[dfS==0].count())
dfS['IDs']=dfS.ID.str.split(';')
dfSE=dfS.explode('IDs')
dfSEG=dfSE.groupby(dfSE['IDs']).aggregate('sum')
dfSEG.to_csv(pathFiles/'peptides.combinedIntensity.csv')#,sep="\")#,rownames=FALSE)
#dfP=dfS.pivot_table(index='ID', columns='Sequence', values='Intensity', aggfunc='sum')
#dfP.to_csv(pathFiles.with_suffix('.combinedIntensity.csv'))#,sep="\")#,rownames=FALSE)
dfProtG=pd.read_csv(pathFiles/"proteinGroups.txt",low_memory=False,sep='\t')
dfProtG.rename({'Protein IDs':'ID'},inplace=True,axis='columns')
dfProtG['IDs']=dfProtG.ID.str.split(';')
dfProtGE=dfProtG.explode('IDs')
dfM=dfProtGE.merge(dfSEG,left_on='IDs', right_on='IDs',how='outer',indicator=True)
dfM.to_csv(pathFiles/'proteins.mergedIntensity.csv')#,sep="\")#,rownames=FALSprint(dfM.columns)
print(dfM[dfM['_merge']=="right_only"])
print(dfM[dfM['_merge']=="left_only"])
print(dfM[dfM['IDs'].str.contains('REV__')])
#dfC=dfM[dfM['_merge']=="left_only"]
dfC=dfM[dfM['_merge']=="both"].filter(regex='Intensity',axis=1)
dfC["ID"]=dfM['IDs']
dfC["IDs"]=dfM['ID']
dfC["diffInt"]=(dfC['Intensity_y']-dfC['Intensity_x'])/dfC['Intensity_x']
print(dfC.columns)
print("\nDff Intensity Summary\n",dfC["diffInt"].describe())
dfC["diffInt"].hist()
dfC.to_csv(pathFiles/'proteins.merged.selIntensity.csv')#,sep="\")#,rownames=FALSprint(dfM.column#plt.plot(diffInt,"o")
#plt.savefig(pathFiles.with_suffix('.combinedIntensity.png'),dpi=100,bbox_inches = "tight")
#plt.show()
df['order_month'] = df['InvoiceDate'].dt.to_period('M')
df['cohort'] = df.groupby('CustomerID')['InvoiceDate'] \
                 .transform('min') \
                 .dt.to_period('M') 
# add an indicator for periods (months since first purchase)
df_cohort = df.groupby(['cohort', 'order_month']) \
              .agg(n_customers=('CustomerID', 'nunique')) \
              .reset_index(drop=False)
df_cohort['period_number'] = (df_cohort.order_month - df_cohort.cohort).apply(attrgetter('n'))
cohort_pivot = df_cohort.pivot_table(index = 'cohort',
                                     columns = 'period_number',
                                     values = 'n_customers')

# divide by the cohort size (month 0) to obtain retention as %
cohort_size = cohort_pivot.iloc[:,0]
retention_matrix = cohort_pivot.divide(cohort_size, axis = 0)                
df = df[['CustomerID', 'InvoiceNo', 'InvoiceDate']].drop_duplicates()
with sns.axes_style("white"):
    fig, ax = plt.subplots(1, 2, figsize=(12, 8), sharey=True, gridspec_kw={'width_ratios': [1, 11]})
    
    # retention matrix
    sns.heatmap(retention_matrix, 
                mask=retention_matrix.isnull(), 
                annot=True, 
                fmt='.0%', 
                cmap='RdYlGn', 
                ax=ax[1])
    ax[1].set_title('Monthly Cohorts: User Retention', fontsize=16)
    ax[1].set(xlabel='# of periods',
              ylabel='')

    # cohort size
    cohort_size_df = pd.DataFrame(cohort_size).rename(columns={0: 'cohort_size'})
    white_cmap = mcolors.ListedColormap(['white'])
    sns.heatmap(cohort_size_df, 
                annot=True, 
                cbar=False, 
                fmt='g', 
                cmap=white_cmap, 
                ax=ax[0])

    fig.tight_layout()
