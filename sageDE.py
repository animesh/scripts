# %% setup
#for i in /cluster/work/users/ash022/veronica/*He*.d ; do echo $i ; timsconvert --chunk_size 5000000000 --verbose --input $i ;  done
#sage sage.json -f human_crap.fasta --batch-size 40 /cluster/work/users/ash022/*.mzML
#cp lfq.parquet $HOME/PD/TIMSTOF/LARS/2024/240605_Veronica/HeLa/
# %% data
proteinHits=pd.read_parquet("TIMSTOF/LARS/2024/240605_Veronica/HeLa/lfq.parquet")
fName=dfMeta.name[dfMeta.processing_run_uuid==f.parents[0].name]
print(fName,f)
proteinHits.rename({'protein_group_name':'ID'},inplace=True,axis='columns')
proteinHits.rename({'number_psms':'PSMs'},inplace=True,axis='columns')
proteinHits=proteinHits.ID.str.split(';', expand=True).set_index(proteinHits.PSMs).stack().reset_index(level=0, name='ID')
proteinHits=proteinHits.groupby('ID').sum()
proteinHits['Name']=fName.values[0]
df['PSMs']=df.sum(axis=1)
df=df.sort_values("PSMs", ascending=False)
# %% plot
plotcsv=pathFiles/("PSMs.histogram.svg")
df.plot(kind='hist',alpha=0.5,bins=100).figure.savefig(plotcsv,dpi=100,bbox_inches = "tight")
print(df.head())
print(df.columns)
# %% write
writeScores=pathFiles/("PSMs.sum.csv")
df.to_csv(writeScores)#.with_suffix('.combo.csv'))
print("PSMs in\n",writeScores,"\n",plotcsv)
#dfID=df.assign(ID=df.ID.str.split(';')).explode('ID')


