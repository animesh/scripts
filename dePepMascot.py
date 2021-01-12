#http://mh-mascot.win.ntnu.no/mascot/help/error_tolerant_help.html
#https://towardsdatascience.com/3-pandas-functions-that-will-make-your-life-easier-4d0ce57775a1
import sys
from pathlib import Path
if len(sys.argv)!=2:    sys.exit("USAGE: python dePepMascot.py <path to peptides containing mascot exported file>, \n e.g.,\npython dePepMascot.py L:/promec/Animesh/Raw/New Study/20150512_BSA_The-PEG-envelope (2)-(8)_PeptideGroups.txt\n")
pathFiles = Path(sys.argv[1])
#pathFiles = Path("L:/promec/HF/Lars/2020/oktober/KATHLEENPHOSTOT/201105_kath_phostot_14B_PeptideGroups.txt")
import pandas as pd
df=pd.read_csv(pathFiles,low_memory=False,doublequote=True,sep='\t')
print(df.columns)
print(df.dtypes)
df = df.convert_dtypes(convert_boolean=False)
print(df.dtypes)
import numpy as np
def scale(dfT, column_name):
   dfT[column_name] = (dfT[column_name]-np.min(dfT[column_name]))/(np.max(dfT[column_name])-np.min(dfT[column_name]))
   return dfT
def drop_missing(dfT):
   dfT.dropna(axis=0, how='any', inplace=True)
   return dfT
def to_category(dfT):
   cols = dfT.select_dtypes(include='string').columns
   for col in cols:
      ratio = len(dfT[col].value_counts()) / len(dfT)
      if ratio < 0.05:
         dfT[col] = dfT[col].astype('category')
   return dfT
df_processed = df.pipe(scale,'Delta M in ppm by Search Engine A20 Mascot')#).pipe(drop_missing).pipe(to_category)
dfG=df.groupby(['Modifications','Delta M in ppm by Search Engine A20 Mascot'],as_index=False).agg({'Modifications':pd.Series.mode,'Delta M in ppm by Search Engine A20 Mascot':np.mean})
dfG["Delta M in ppm by Search Engine A20 Mascot"].hist()
dfG["Modifications"]
dfGm0ds=dfG["Modifications"].str.split('];', expand=True)
dfGm0ds=dfGm0ds.replace('^ ','',regex=True)
dfGm0ds=dfGm0ds.fillna(value=' ')
#dfGm0ds=dfGm0ds.applymap(lambda x: x.replace('^ ','',regex=True))
dfGm0ds=dfGm0ds.applymap(lambda x: x.split(' '))
writecsv=pathFiles.with_suffix('.group.csv')
dfGm0ds.to_csv(writecsv)
dfGreps=dfGm0ds.applymap(lambda x: x[0])
dfGreps=dfGreps.applymap(lambda x: x.split('x'))
dfGreps=dfGreps.applymap(lambda x: x[0])
dfGtype=dfGm0ds.applymap(lambda x: x[1])
dfGtype[0].str.repeat(dfGreps[0].astype(int))
writecsv=pathFiles.with_suffix('.group.counts.csv')
dfGtypeCont=dfGtype[0].str.repeat(dfGreps[0].astype(int)).value_counts()
print(dfGtypeCont)
dfGtypeCont.to_csv(writecsv)
plotcsv=pathFiles.with_suffix('.group.counts.plot.svg')
dfGtypeCont[dfGtypeCont>0].plot(kind='pie').figure.savefig(plotcsv,dpi=100,bbox_inches = "tight")
print("wrtten",pathFiles,"groups*")
