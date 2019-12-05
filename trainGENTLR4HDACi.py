## Setup GENTRL Deep learning enables rapid identification of potent DDR1 kinase inhibitors https://www.nature.com/articles/s41587-019-0224-x
#https://docs.anaconda.com/anaconda/install/linux/
#! sudo apt-get install python3 libxrender1 libxext6 libgl1-mesa-glx libegl1-mesa libxrandr2 libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6
#! wget https://repo.anaconda.com/archive/Anaconda3-2019.10-Linux-x86_64.sh
#! git clone https://github.com/animesh/GENTRL.git
#! cd GENTRL/
#! python setup.py install
#https://www.rdkit.org/docs/Install.html
#! conda create -c rdkit -n my-rdkit-env rdkit
#! conda activate my-rdkit-env
#! pip install sklearn jupyterlab molsets
#! jupyter notebook --no-browser
#check setup
import os
print(os)
system("jupyter" "notebook" "list")#token
#pre-train https://github.com/insilicomedicine/GENTRL/blob/master/examples/pretrain.ipynb
import pandas as pd
! wget https://media.githubusercontent.com/media/molecularsets/moses/master/data/dataset_v1.csv
df = pd.read_csv("dataset_v1.csv")
df = df[df['SPLIT'] == 'train']
import gentrl
import torch
#torch.cuda.set_device(0)
from moses.metrics import mol_passes_filters, QED, SA, logP
from moses.metrics.utils import get_n_rings, get_mol
def get_num_rings_6(mol):
    r = mol.GetRingInfo()
    return len([x for x in r.AtomRings() if len(x) > 6])
def penalized_logP(mol_or_smiles, masked=False, default=-5):
    mol = get_mol(mol_or_smiles)
    if mol is None:
        return default
    reward = logP(mol) - SA(mol) - get_num_rings_6(mol)
    if masked and not mol_passes_filters(mol):
        return default
    return reward
df['plogP'] = df['SMILES'].apply(penalized_logP)
df.to_csv('train_plogp_plogpm.csv', index=None)
enc = gentrl.RNNEncoder(latent_size=50)
dec = gentrl.DilConvDecoder(latent_input_size=50)
model = gentrl.GENTRL(enc, dec, 50 * [('c', 20)], [('c', 20)], beta=0.001)
#model.cuda();
md = gentrl.MolecularDataset(sources=[
    {'path':'train_plogp_plogpm.csv',
     'smiles': 'SMILES',
     'prob': 1,
     'plogP' : 'plogP',
    }],
    props=['plogP'])
from torch.utils.data import DataLoader
train_loader = DataLoader(md, batch_size=50, shuffle=True, num_workers=1, drop_last=True)
model.train_as_vaelp(train_loader, lr=1e-4)
! mkdir -p saved_gentrl
model.save('./saved_gentrl/')
#train-RL https://github.com/insilicomedicine/GENTRL/blob/master/examples/train_rl.ipynb
model.load('./saved_gentrl/')
#model.cuda();
from moses.utils import disable_rdkit_log
disable_rdkit_log()
def get_num_rings_6(mol):
    r = mol.GetRingInfo()
    return len([x for x in r.AtomRings() if len(x) > 6])
def penalized_logP(mol_or_smiles, masked=False, default=-5):
    mol = get_mol(mol_or_smiles)
    if mol is None:
        return default
    reward = logP(mol) - SA(mol) - get_num_rings_6(mol)
    if masked and not mol_passes_filters(mol):
        return default
    return reward
model.train_as_rl(penalized_logP)
! mkdir -p saved_gentrl_after_rl
model.save('./saved_gentrl_after_rl/')
#sample https://github.com/insilicomedicine/GENTRL/blob/master/examples/sampling.ipynb
from rdkit.Chem import Draw
model.load('./saved_gentrl_after_rl/')
#model.cuda();
def get_num_rings_6(mol):
    r = mol.GetRingInfo()
    return len([x for x in r.AtomRings() if len(x) > 6])
def penalized_logP(mol_or_smiles, masked=True, default=-5):
    mol = get_mol(mol_or_smiles)
    if mol is None:
        return default
    reward = logP(mol) - SA(mol) - get_num_rings_6(mol)
    if masked and not mol_passes_filters(mol):
        return default
    return reward
generated = []
while len(generated) < 1000:
    sampled = model.sample(100)
    sampled_valid = [s for s in sampled if get_mol(s)]
    generated += sampled_valid
Draw.MolsToGridImage([get_mol(s) for s in sampled_valid], legends=[str(penalized_logP(s)) for s in sampled_valid])
