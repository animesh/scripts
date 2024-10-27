#python msmsCount.py /cluster/projects/nn9036k/FastaDB/phoslibMC1V3mz100to1700c2to3human.predicted.speclibreport.parquet
import sys
from pathlib import Path
if len(sys.argv)!=2:    sys.exit("USAGE: python dePep.py <path to folder containing parquet fileName like \"/cluster/projects/nn9036k/FastaDB/phoslibMC1V3mz100to1700c2to3human.predicted.speclibreport.parquet\" >")
f = Path(sys.argv[1])
#f = Path('/cluster/projects/nn9036k/FastaDB/phoslibMC1V3mz100to1700c2to3human.predicted.speclibreport.parquet')
import pandas as pd
df=pd.DataFrame()
print(f)
import pyarrow.parquet as pq
peptideHits=pq.read_table(f).to_pandas()
print(peptideHits.columns)
peptideHits.to_csv(f.with_suffix(".parse.csv"))
#peptideHits=peptideHits[~peptideHits['Protein.Ids'].str.contains('cRAP', case=False, na=False)]
peptideHits['Phospho (STY)'] = peptideHits['Precursor.Id'].str.contains('UniMod:21', case=False, na=False)
peptideHits['Phospho (STY)'].describe()
peptideHits['Scan event number'] = True
peptideHitsPhoSTY=peptideHits.pivot_table(index='Stripped.Sequence', columns='Run',values='Phospho (STY)',aggfunc='sum')
peptideHitsScans=peptideHits.pivot_table(index='Stripped.Sequence', columns='Run',values='Scan event number',aggfunc='sum')
peptideHitsPhoSTYratio=peptideHitsPhoSTY/peptideHitsScans
peptideHitsPhoSTYratioHist = peptideHitsPhoSTYratio.plot.hist()
peptideHitsPhoSTYratio.to_csv(f.with_suffix(".phoSTYratio.csv"))
print(f.with_suffix(".phoSTYratio.csv"))
peptideHitsPhoSTYratioHist.figure.savefig(f.with_suffix(".phoSTYratio.png"))
print(f.with_suffix(".phoSTYratio.png"))
