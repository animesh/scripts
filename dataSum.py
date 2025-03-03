#install: pip install skimpy summarytools numpy pandas
#usage: python dataSum.py proteinGroups.txt "Intensity "
#blog: https://medium.com/coding-nexus/why-i-stopped-using-pandas-describe-method-two-libraries-that-do-it-better-e2890c2c24d1
from skimpy import skim
from summarytools import dfSummary
import numpy as np
import pandas as pd
import sys
fileName=sys.argv[1]
colName=sys.argv[2]
df = pd.read_csv(fileName,sep='\t')
df[df==0]=None
df = df.select_dtypes(include='number')
df = df.filter(regex=colName,axis=1)
df = np.log2(df)
skim(df)
dfSummary(df).to_html(fileName+'summary.html')
