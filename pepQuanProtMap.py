import sys
from pathlib import Path
if len(sys.argv)!=2:    sys.exit("USAGE: python dePepGUI.py <path to tab-sep-peptide-hits>, \n e.g.,\npython dePepGUI.py F:\promec\TIMSTOF\LARS\2021\Oktober\211021Finn\n")
pathFiles = Path(sys.argv[1])
#pathFiles = Path("F:/promec/TIMSTOF/LARS/2021/Oktober/211021Finn")
fileName='peptides.txt'
protName='cel'
trainList=list(pathFiles.rglob(fileName))
import pandas as pd
#f=trainList[0]
df=pd.DataFrame()
for f in trainList:
    if Path(f).stat().st_size > 0:
        proteinHits=pd.read_csv(f,low_memory=False,sep='\t')
        proteinHits=proteinHits[proteinHits['Proteins'].str.contains(protName)]
        proteinHits.columns=proteinHits.columns.str[0:18]
        proteinHits['Name']=f.parts[-4]
        print(proteinHits['Name'])
        proteinHits.rename({'Sequence':'ID'},inplace=True,axis='columns')
        #proteinHits.rename({'Unique Spectral Count':'uniqPSMs'},inplace=True,axis='columns')
        #proteinHits=proteinHits.ID.str.split(';', expand=True).set_index(proteinHits.uniqPSMs).stack().reset_index(level=0, name='ID')
        df=pd.concat([df,proteinHits],sort=False)
print(df.columns)
print(df.head())
#df=df.pivot(index='ID', columns='Name', values='uniqPSMs')
#df=df.pivot_table(index='ID', columns='Name', values='MedianLog2SILAC', aggfunc='median')
#df.to_csv(pathFiles.with_suffix('.combined.txt'),sep="\")#,rownames=FALSE)
plotcsv=pathFiles/(fileName+".positionLFQ.svg")
import matplotlib.pyplot as plt
plt.scatter(df["LFQ intensity Ecol"],df["LFQ intensity Sliv"])
plt.scatter(df["Start position"],df["LFQ intensity Ecol"],c=df['Length'])
plt.scatter(df["Start position"],df["LFQ intensity Sliv"])
df.plot(kind='scatter',alpha=0.5,bins=100).figure.savefig(plotcsv,dpi=100,bbox_inches = "tight")
print(df.head())
print(df.columns)
df = df.convert_dtypes(convert_boolean=False)
print(df.dtypes)
df['Position']=df["Positions in Master Proteins"].str.split('[', expand=True)[1].str.split('-', expand=True)[0].fillna(value='0').astype(int)
import numpy as np
df['log2']=np.log2(df['Abundances (Normalized): F1: Sample'].fillna(value=0)+1)-np.log2(df['Abundances (Normalized): F2: Sample'].fillna(value=0)+1)
df['length']=df['Modifications (all possible sites)'].fillna(value=' ').str.len()
df=df.sort_values('Position')
print("DF")
print(df[['Sequence','log2','length']])
df.to_csv(pathFiles.with_suffix('.parse.txt'),sep="\t")
protein="Serpin B3"
print(protein)
dfSB3=df[df['Master Protein Descriptions'].str.contains(protein)]#.Confidence#.hist()
protein=''.join(ch for ch in protein if ch.isalnum())
dfSB3.to_csv(pathFiles.with_suffix('.'+protein+'.txt'),sep="\t")
print(dfSB3[['Sequence','log2','length']])
dfSB3.plot(kind='scatter',x='Position',y='log2',c='length',colormap='jet').figure.savefig(pathFiles.with_suffix('.'+protein+'.svg'),dpi=300,bbox_inches = "tight")
#ax = dfSB3.plot(kind='scatter',x='Position',y='Abundance Ratio (log2): (F2) / (F1)')
#dfSB3[['Position','Abundance Ratio (log2): (F2) / (F1)','Sequence']].apply(lambda row: ax.text(*row),axis=1)
dfSB3only=dfSB3[(dfSB3['Found in File: [F1]']=="High")&(dfSB3['Found in File: [F2]']=="Not Found")]
dfSB3only.to_csv(pathFiles.with_suffix('.found'+protein+'.txt'),sep="\t")
print(dfSB3only[['Sequence','log2','length']])
dfSB3onlyURT=dfSB3[(dfSB3['Found in File: [F2]']=="High")&(dfSB3['Found in File: [F1]']=="Not Found")]
dfSB3onlyURT.to_csv(pathFiles.with_suffix('.foundURT'+protein+'.txt'),sep="\t")
print(dfSB3onlyURT[['Sequence','log2','length']])
protein="Serpin B4"
print(protein)
dfSB4=df[df['Master Protein Descriptions'].str.contains(protein)]#.Confidence#.hist()
dfSB4=dfSB4[-dfSB4['Master Protein Descriptions'].str.contains("Serpin B3")]
protein=''.join(ch for ch in protein if ch.isalnum())
dfSB4.to_csv(pathFiles.with_suffix('.SB4.txt'),sep="\t")
dfSB4.plot(kind='scatter',x='Position',y='log2',c='length',colormap='jet').figure.savefig(pathFiles.with_suffix('.'+protein+'.svg'),dpi=300,bbox_inches = "tight")
print(dfSB4[['Sequence','log2','length']])
dfSB4only=dfSB4[(dfSB4['Found in File: [F1]']=="High")&(dfSB4['Found in File: [F2]']=="Not Found")]
dfSB4only.to_csv(pathFiles.with_suffix('.foundSB4.txt'),sep="\t")
print(dfSB4only[['Sequence','log2','length']])
dfSB4onlyURT=dfSB4[(dfSB4['Found in File: [F2]']=="High")&(dfSB4['Found in File: [F1]']=="Not Found")]
dfSB4onlyURT.to_csv(pathFiles.with_suffix('.foundSB4URT.txt'),sep="\t")
print(dfSB4onlyURT[['Sequence','log2','length']])
'''
import numpy as np
def scale(dfT, column_name):
   dfT[column_name] = (dfT[column_name]-np.min(dfT[column_name]))/(np.max(dfT[column_name])-np.min(dfT[column_name]))
   return dfT
def drop_missing(dfT):
   dfT.dropna(axis=0, how='any', inplace=True)
   return dfT
df.xcorr.hist()
import PySimpleGUI as sg
import re
import pandas as pd
def cnt(fname, modName):
    if modName == 'Phosphorylation':
        cnt = cntlib.Phosphorylation()
    elif modName == 'GlyGly':
        cnt = cntlib.GlyGly()
    else:
        cnt = cntlib.Other()
    with open(fname) as handle:
        for line in handle:
            cnt.update(line.encode(encoding = 'utf-8'))
    return(cnt.hexdigest())
layout = [
    [sg.Text('File 1'), sg.InputText(), sg.FileBrowse(),
     sg.Checkbox('Phosphorylation'), sg.Checkbox('GlyGly')
     ],
    [sg.Text('File 2'), sg.InputText(), sg.FileBrowse(),
     sg.Checkbox('Other')
     ],
    [sg.Output(size=(88, 20))],
    [sg.Submit(), sg.Cancel()]
]
window = sg.Window('File Compare', layout)
while True:                             # The Event Loop
    event, values = window.read()
    # print(event, values) #debug
    if event in (None, 'Exit', 'Cancel'):
        break
    if event == 'Submit':
        file1 = file2 = isitmodName = None
        # print(values[0],values[3])
        if values[0] and values[3]:
            file1 = re.findall('.+:\/.+\.+.', values[0])
            file2 = re.findall('.+:\/.+\.+.', values[3])
            isitmodName = 1
            if not file1 and file1 is not None:
                print('Error: File 1 path not valid.')
                isitmodName = 0
            elif not file2 and file2 is not None:
                print('Error: File 2 path not valid.')
                isitmodName = 0
            elif values[1] is not True and values[2] is not True and values[4] is not True:
                print('Error: Choose at least one PTM or Other')
            elif isitmodName == 1:
                print('Info: Filepaths correctly defined.')
                modNames = [] #modNames to compare
                if values[1] == True: modNames.append('GlyGly')
                if values[2] == True: modNames.append('Phosphorylation')
                if values[4] == True: modNames.append('Other')
                filepaths = [] #files
                filepaths.append(values[0])
                filepaths.append(values[3])
                print('Info: File Comparison using:', modNames)
                for modName in modNames:
                    print(modName, ':')
                    print(filepaths[0], ':', cnt(filepaths[0], modName))
                    print(filepaths[1], ':', cnt(filepaths[1], modName))
                    if cnt(filepaths[0],modName) == cnt(filepaths[1],modName):
                        print('Files match for ', modName)
                    else:
                        print('Files do NOT match for ', modName)
        else:
            print('Please choose 2 files.')
window.close()
'''
