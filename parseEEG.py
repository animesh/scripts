#https://towardsdatascience.com/detecting-heart-arrhythmias-with-deep-learning-in-keras-with-dense-cnn-and-lstm-add337d9e41f
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from os import listdir
data_path="L:/promec/Animesh/mit-bih-arrhythmia-database-1.0.0/mit-bih-arrhythmia-database-1.0.0/"
import wfdb
pts=['100','101','102','103','104','105']
df=pd.DataFrame()
for pt in pts:
    file=data_path+pt
    annotation=wfdb.rdann(file,'atr')
    sym=annotation.symbol
    values, counts = np.unique(sym,return_counts=True)
    df_sub=pd.DataFrame({'sym':values,'val':counts,'pt':[pt]*len(counts)})
    df=pd.concat([df,df_sub],axis=0)
    print(df)
df.groupby('sym').val.sum().sort_values(ascending=False)
#https://archive.physionet.org/physiobank/annotations.shtml
beat=['N','L','R','B','A','a','J','S','V','r','F','e','j','n','E','/','f','Q','?']
nonbeat=['[','!',']','x','(',')','p','t','u','`','\'','^','|','~','+','s','T','*','D','=']
#https://physionet.org/content/mitdb/1.0.0/
def load_eeg(file):
    record=wfdb.rdrecord(file)
    annotation=wfdb.rdann(file,'atr')
    p_signal=record.p_signal
    assert record.fs==360,'freq!=360'
    atr_sym=annotation.symbol
    atr_sample=annotation.sample
    return p_signal, atr_sym,atr_sample
print(load_eeg('L:/promec/Animesh/mit-bih-arrhythmia-database-1.0.0/mit-bih-arrhythmia-database-1.0.0/101'))
