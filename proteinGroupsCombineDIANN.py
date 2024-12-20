#python proteinGroupsCombineDIANN.py L:\promec\TIMSTOF\LARS\2024\241219_Hela_DDA_DIA\dia\DIANN1p9p2 "*1734690479*gg*tsv"
#rsync -Pirm --include='*1734690479*tsv' --include='*/' --exclude='*' ash022@login.saga.sigma2.no:/cluster/home/ash022/scripts/dia/ /mnt/l/promec/TIMSTOF/LARS/2024/241219_Hela_DDA_DIA/dia/DIANN1p9p2/
#!pip3 install pandas matplotlib pathlib numpy --user
#bash slurmDIANNrunTTP.sh /cluster/projects/nn9036k/scripts/dia scratch.slurm #./diann-linux --f /cluster/projects/nn9036k/scripts/dia/241217_2ngHelaQC_DIAa_Slot1-29_1_9294.d --lib /cluster/projects/nn9036k/FastaDB/UP000005640_9606_unique_gene_C24_MC1_P735_MZ1001700_Mod3linux.predicted.speclib --threads 40 --verbose 1 --out /cluster/projects/nn9036k/scripts/dia/241217_2ngHelaQC_DIAa_Slot1-29_1_9294.d.1734690479.tsv --qvalue 0.01 --matrices --min-corr 2.0 --corr-diff 1.0 --time-corr-only --extracted-ms1 --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta /cluster/projects/nn9036k/FastaDB/UP000005640_9606_unique_gene.fasta --met-excision --min-pep-len 7 --max-pep-len 35 --min-pr-mz 100 --max-pr-mz 1700 --min-pr-charge 2 --max-pr-charge 4 --cut K*,R* --missed-cleavages 1 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --individual-mass-acc --individual-windows --peptidoforms --rt-profiling --direct-quant --no-norm
#Rscript geneGroupsQC.r "L:\promec\TIMSTOF\LARS\2024\241219_Hela_DDA_DIA\dia\DIANN1p9p2\intensity1734690479ggtsv.sum.unique.txt" "1" "3 4 5"
#Rscript geneGroupsQC.r "L:\promec\TIMSTOF\LARS\2024\241219_Hela_DDA_DIA\dia\DIANN1p9p2\intensity1734690479ggtsv.sum.unique.txt" "1" "6 7 8"
# %% setup
import sys
from pathlib import Path
import pandas as pd
# %% meta
pathFiles = Path(sys.argv[1])
#pathFiles=Path("L:/promec/TIMSTOF/LARS/2024/241219_Hela_DDA_DIA/dia/DIANN1p9p2")
# %% data
fileName=sys.argv[2]
#fileName='*1734690479*gg*tsv'
#fileName='tsv'
print(fileName)
fileNameOut=fileName.replace("*","")
print(fileNameOut)
trainList=list(pathFiles.rglob(fileName))
print(trainList)
print(len(trainList),"files found in",pathFiles)
# %% combine
df=pd.DataFrame()
#f=trainList[0]
for f in trainList:
    if Path(f).stat().st_size > 0:
        proteinHits=pd.read_csv(f,sep='\t',low_memory=False)
        fName=f.name.split('.')[0]
        print(fName,f)
        proteinHits.rename({proteinHits.columns[0]:'ID'},inplace=True,axis='columns')
        proteinHits.rename({proteinHits.columns[1]:'intensity'},inplace=True,axis='columns')
        proteinHits=proteinHits.ID.str.split(';', expand=True).set_index(proteinHits.intensity).stack().reset_index(level=0, name='ID')
        proteinHits=proteinHits.groupby('ID').sum()
        proteinHits['Name']=fName
        df=pd.concat([df,proteinHits],sort=False)
print(df.head())
print(df.columns)
# %% pivot
df=df.pivot(columns='Name', values='intensity')
df['sum']=df.sum(axis=1)
df=df.sort_values("sum", ascending=False)  
# %% plot
print(df.head())
print(df.columns)
#writeDPpng=pathFiles/(fileName+"Score.png")
#df.plot(kind='hist').figure.savefig(writeDPpng.absolute(),dpi=100,bbox_inches = "tight")
#print("Histogram of Score in",writeDPpng)
# %% write
writeScores=pathFiles/("intensity"+fileNameOut+".sum.csv")
df.to_csv(writeScores)#.with_suffix('.combo.csv'))
dfU=df.drop_duplicates()
writeScores=pathFiles/("intensity"+fileNameOut+".sum.unique.txt")
dfU.to_csv(writeScores,sep='\t')
dfU.drop(columns='sum',inplace=True)
import numpy as np
dfU=np.log2(dfU)
plotcsv=pathFiles/("intensity.log2."+fileNameOut+".histogram.svg")
dfU.plot(kind='hist',alpha=0.5,bins=100).figure.savefig(plotcsv,dpi=100,bbox_inches = "tight")
print("Combined intensities in\n",writeScores,"\n",plotcsv)
#dfID=df.assign(ID=df.ID.str.split(';')).explode('ID')
