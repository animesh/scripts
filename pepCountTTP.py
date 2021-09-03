#https://github.com/michalsta/opentims
#!conda activate base
#!conda install pip
#!pip install opentimspy
#!pip install opentims_bruker_bridge
import sys
from pathlib import Path
if len(sys.argv)!=2:    sys.exit("USAGE: python pepCountTTP.py <path to MSn containing directory>, \n e.g.,\npython pepCountTTP.py \"F:/promec/LARS/TIMSTOF/Morten/210902 Morten 1 _Slot1-37_1_176.d\"\n")
#python pepCountTTP.py $HOME/PD/LARS/TIMSTOF/'Morten/210902 Morten 1 _Slot1-37_1_176.d'
pathFiles = Path(sys.argv[1])
#pathFiles = Path('F:/promec/LARS/TIMSTOF/Morten/210902 Morten 1 _Slot1-37_1_176.d')
from pprint import pprint
from opentimspy.opentims import OpenTIMS
try:
    import opentims_bruker_bridge
    all_columns = ('frame','scan','tof','intensity','mz','inv_ion_mobility','retention_time')
except ModuleNotFoundError:
    print("Without Bruker proprietary code we cannot yet perform tof-mz and scan-dt transformations.Download 'opentims_bruker_bridge' if you are on Linux or Windows.Otherwise, you will be able to use only these columns:")
    all_columns = ('frame','scan','tof','intensity','retention_time')
#print(all_columns)
path = Path(pathFiles)
D = OpenTIMS(path) # get data handle
print(pathFiles,D) #print(len(D)) # The number of peaks.
#D.framesTIC() # Return combined intensity for each frame. # array([ 95910, 579150, 906718, ..., 406317,   8093,   8629])
# Get a dict with data from frames 1, 5, and 67.
pprint(D.query(frames=[1], columns=all_columns))
pprint(D.query(frames=slice(2,1000,10), columns=all_columns))
# Get all MS1 frames 
# pprint(D.query(frames=D.ms1_frames, columns=all_columns))
pprint(D.query(frames=slice(2,1000,10), columns=('tof','intensity',)))
it = D.query_iter(slice(10,100,10), columns=all_columns)
pprint(next(it))
# All MS1 frames, but one at a time
iterator_over_MS1 = D.query_iter(D.ms1_frames, columns=all_columns)
pprint(next(it))
# or in a loop, only getting intensities
for fr in D.query_iter(D.ms1_frames, columns=('intensity',)):
    print(fr['intensity'])
# The frame lasts a convenient time unit that well suits chromatography peak elution.
D.rt_query(10,12) # Get numpy array with raw data in a given range 1:10
pprint(D[1:10]) # array([[     1,     33, 312260,      9],
import pandas as pd
df=pd.read_csv(pathFiles,low_memory=False,doublequote=True,sep='\t')
print(df.columns)
print(df.dtypes)
df = df.convert_dtypes(convert_boolean=False)
print(df.dtypes)
print("\nData in",pathFiles,df.describe())
df=df[df["Confidence"]=="High"]
print("\nKeeping High Confidence peptide(s)",df.describe())
df['Modifications'] = df['Modifications'].fillna("UnMod")
if 'Sequence' in df:
    dfDNQ=df[df.Modifications.str.contains("Deamidat")&~df.Modifications.str.contains("UnMod")].Sequence.to_frame()
else:
    df['Sequence']=df['Annotated Sequence'].apply(lambda st: st[st.find("].")+2:st.find(".[")])
    dfDNQ=df[df.Modifications.str.contains("Deamidat")&~df.Modifications.str.contains("UnMod")].Sequence.to_frame()
print("\nDeamidated NQ counts",dfDNQ.describe())
dfUnMod=df[df.Modifications.str.contains("UnMod")].Sequence.to_frame()
print("\nUnMod count",dfUnMod.describe())
df_diff = pd.concat([dfUnMod,dfDNQ]).drop_duplicates(keep=False)
print("\nDifference",df_diff.describe())
dfUnModInDNQ=[]
for seq in dfUnMod.Sequence:
    dfUnModInDNQ.append(dfDNQ.Sequence.str.contains(seq).sum())
print("\nUnMod NOT In DNQ",dfUnModInDNQ.count(0))
dfDNQinUnMod=[]
for seq in dfDNQ.Sequence:
    dfDNQinUnMod.append(dfUnMod.Sequence.str.contains(seq).sum())
print("\nDNQ NOT in UnMod",dfDNQinUnMod.count(0))
print("\nDNQ NOT in UnMod %",100*dfDNQinUnMod.count(0)/len(df))
