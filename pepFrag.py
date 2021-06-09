#!/usr/bin/env python
# coding: utf-8
#..\..\AppData\Local\r-miniconda\condabin\mamba.bat install pandas
import pandas as pd
# massaa => https://en.wikipedia.org/w/index.php?title=Proteinogenic_amino_acid&section=2
aamm = pd.read_table('massaa')
aamm['Mon. Mass§ (Da)']
mmH2O = 18.01056
mmProton = 1.00728
pep = 'FYDKMQNAESGR'
# http://www.ionsource.com/tutorial/DeNovo/b_and_y.htm
# pep='MIGQK'
tMass = 0.0
bIon = 0.0
bIon_list = []
yIon_list = []
pep_list = []
for b in range(0, len(pep)):
    pep_list.append(pep[b])
    tMass = tMass + aamm[aamm['Short'] == pep[b]]['Mon. Mass§ (Da)'].values
    bIon = bIon + aamm[aamm['Short'] == pep[b]]['Mon. Mass§ (Da)'].values[0]
    bIon_list.append(bIon + mmProton)
    yIon = 0.0
    for y in range(b, len(pep)):
        yIon = yIon + aamm[aamm['Short'] ==
                           pep[y]]['Mon. Mass§ (Da)'].values[0]
    yIon_list.append(yIon + mmH2O + mmProton)
print(pep_list, bIon_list, yIon_list, tMass + mmH2O)
import matplotlib.pyplot as plt
plt.stem(yIon_list, bIon_list, 'r')
plt.stem(bIon_list, bIon_list, 'b')
plt.xticks(bIon_list, pep_list)
get_ipython().run_cell_magic('bash', '', "cat $HOME/PD/HF/Siri/combined/txt/evidence.txt | awk -F '\\t' '{print $4}' | sort | uniq -c | tail ")
chg = get_ipython().getoutput("awk -F '\\t' '{print $15}' $HOME/PD/HF/Siri/combined/txt/evidence.txt ")
#https://colab.research.google.com/github/animesh/DeepCollisionalCrossSection/blob/master/process_data_final.ipynb#scrollTo=kMrHXX61ISRz
import pandas as pd
data_path = 'L:/promec/HF/Siri/combined/txt/evidence.txt'
outpath = '.'
df=pd.read_table(data_path)
df.head()
df["Score"].hist()
df["Missed cleavages"].hist()
df = df.rename(index=str, columns={"Modified sequence": "Modified_sequence"})
df['Modified_sequence'] = df['Modified_sequence'].str.replace('_','')
df['Modified_sequence']
print(df.shape)

import numpy as np
np.log2(df['Intensity']).hist()
low = np.percentile(df['Intensity'], 10)
high = np.percentile(df['Intensity'], 90)
print(low, high)

from sklearn.preprocessing import LabelEncoder, StandardScaler, OneHotEncoder
data=df
dat = data['Sequence']
dat = [list(d) for d in dat]
#process data into one hot encoding
flat_list = ['_'] + [item for sublist in dat for item in sublist]
# define example
values = np.array(flat_list)
label_encoder = LabelEncoder()
label_encoder.fit(values)
print(values,label_encoder.classes_, len(label_encoder.classes_),label_encoder.transform([['_']]))

import re, os, csv
import pickle
with open('enc.pickle', 'wb') as handle:
    pickle.dump(label_encoder, handle)
import csv
with open('enc_list.csv', 'w') as myfile:
    wr = csv.writer(myfile, quoting=csv.QUOTE_ALL)
    wr.writerow(list(label_encoder.classes_))

df.groupby(['Sequence', 'Charge'], group_keys=False).count()#apply(lambda x: x.loc[x.Intensity.idxmax()])
dfMaxS=df.groupby(['Sequence', 'Charge'], group_keys=False).apply(lambda x: x.loc[x.Score.idxmax()])
dfMaxS["Score"].hist()
dfMaxS['label']=dfMaxS['Score'].values.tolist()

def split(data, name, s, label_encoder_path='enc.pickle', ids=None, calc_minval=True):
    np.random.seed(s)
    with open(label_encoder_path, 'rb') as handle:
        label_encoder = pickle.load(handle)
    data['encseq'] = data['Sequence'].apply(lambda x: label_encoder.transform(list(x)))
    if calc_minval:
        data['minval'] = np.min(data['label'])
        data['maxval'] = np.max(data['label'])
    else:
        data['minval']=-2
        data['maxval']=325
    data['task'] = 0
    print('Name: ', name, 'Seed: ', s, 'Len test: ', len(data[data['test']]),'Len set test: ', len(set(data[data['test']])),'Len not test: ', len(data[~data['test']]),'Len set not test: ', len(set(data[~data['test']])))
    data[~data['test']].to_pickle(name + str(s) + '_train.pkl')
    data[data['test']].to_pickle(name +str(s) + '_test.pkl')
    return data

import random
dfMaxS['test']=np.random.choice([True, False], dfMaxS.shape[0])#bool(random.getrandbits(1))
dd=split(dfMaxS, outpath, 2)

trainseqs = dd[~dd['test']]['Sequence'].values.tolist()
ddd = dd[dd['test']]
ddd[ddd['Sequence'].isin(trainseqs)].shape
len(ddd)

#https://www.kaggle.com/ayuraj/experiment-tracking-with-weights-and-biases#%F0%9F%92%BE-4.-Create-a-W&B-Artifact
get_ipython().system('pip install --upgrade -q wandb')
import wandb
wandb.login()


# In[ ]:


def seed_everything():
    os.environ['TF_CUDNN_DETERMINISTIC'] = '1'
    np.random.seed(hash("improves reproducibility") % 2**32 - 1)
    tf.random.set_seed(hash("by removing stochasticity") % 2**32 - 1)
seed_everything()


# In[ ]:


# Initialize a run
run = wandb.init(project='plant-pathology',
                 config=CONFIG,
                 group='EfficientNet',
                 job_type='evaluate') # Note the job_type

# Update `wandb.config`
wandb.config.type = 'baseline'
wandb.config.kaggle_competition = 'Plant Pathology 2021 - FGVC8'

# Evaluate model
loss, auc, f1_score = model.evaluate(validloader)

# Log scores using wandb.log()
wandb.log({'val_AUC': auc,
           'val_F1_score': f1_score})

# Finish the run
run.finish()


# In[ ]:


# Save model
model.save('efficientnetb0-baseline.h5')

# Initialize a new W&B run
run = wandb.init(project='plant-pathology',
                 config=CONFIG,
                 group='EfficientNet',
                 job_type='save') # Note the job_type

# Update `wandb.config`
wandb.config.type = 'baseline'
wandb.config.kaggle_competition = 'Plant Pathology 2021 - FGVC8'

# Save model as Model Artifact
artifact = wandb.Artifact(name='efficientnet-b0', type='model')
artifact.add_file('efficientnetb0-baseline.h5')
run.log_artifact(artifact)

# Finish W&B run
run.finish()
