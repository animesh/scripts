import pathlib
import numpy as np

def parseMGF(mgfData):
    data = mgfData.read_text().split('\n')
    _comments = '#;!/'
    reading_spectrum = False
    params = {}
    masses = []
    intensities = []
    charges = []
    out = {}
    cnt = 0
    fname = None
    pep_mass = 0
    pep_intensity = 0
    for line in data:
        if not reading_spectrum:
            if line.strip() == 'BEGIN IONS':
                reading_spectrum = True
        else:
            if not line.strip() or any(
                    line.startswith(c) for c in _comments):
                pass
            elif line.strip() == 'END IONS':
                reading_spectrum = False
                if fname is None:
                    title = params['title'].split()[0]
                    fname = title.split('.')[0]
                    out[fname] = {}
                if 'pepmass' in params:
                    try:
                        pl = params['pepmass'].split()
                        if len(pl) > 1:
                            pep_mass = float(pl[0])
                            pep_intensity = float(pl[1])
                        elif len(pl) == 1:
                            pep_mass = float(pl[0])
                    except ValueError:
                        print("Error in parsing pepmass value")
                out[fname][cnt] = {'pep_mass': pep_mass,
                                   'pep_intensity': pep_intensity,
                                   'rtinseconds': params['rtinseconds'],
                                   'title': params['title'],
                                   'charge': params['charge'],
                                   'mz_array': np.array(masses),
                                   'intensity_array': np.array(intensities)}
                pep_mass = 0
                pep_intensity = 0
                params = {}
                masses = []
                intensities = []
                charges = []
                cnt += 1
            else:
                l = line.split('=', 1)
                if len(l) > 1:  # spectrum-specific parameters!
                    params[l[0].lower()] = l[1].strip()
                elif len(l) == 1:  # this must be a peak list
                    l = line.split()
                    if len(l) >= 2:
                        try:
                            masses.append(float(l[0]))  # this may cause
                            intensities.append(float(l[1]))  # exceptions...
                            # charges.append(aux._parse_charge(l[2]) if len(l) > 2 else 0)
                        except ValueError:
                            print("Error in parsing line "+line)
    return out


file = pathlib.Path.cwd().parent.rglob('*.MGF')
print(next(file))
file = pathlib.Path.cwd().parent / 'RawRead/171010_Ip_Hela_ugi.raw.intensity0.charge0.MGF'
print(file.read_text().split(' '))
out=parseMGF(file)
print((out.keys()))


import cv2
import matplotlib.pylab as plt
%matplotlib inline
cvimg = cv2.imread(dataElite1)
plt.imshow(cvimg)

import torch
print("#GPU-#", torch.cuda.device_count())


from fastai.learner import *
from fastai.transforms import *
from fastai.conv_learner import *
from fastai.model import *
from fastai.dataset import *
from fastai.sgdr import *
from fastai.plots import *

learn = ConvLearner.pretrained(arch, dataElite1, precompute=True)
learn.fit(0.01, 2)


def lin(a,b,x): return a*x+b
def gen_fake_data(n, a, b):
    x = s = np.random.uniform(0,1,n)
    y = lin(a,b,x) + 0.1 * np.random.normal(0,3,n)
    return x, y
x, y = gen_fake_data(50, 3., 8.)
plt.scatter(x,y, s=8); plt.xlabel("x"); plt.ylabel("y");

from torch.utils.data import Dataset, DataLoader
ip_s = 500
op_s = 5
bat_s = 10
data_s = 1000
class randDataset(Dataset):
    def __init__(self, size, length):
        self.len = length
        self.data = torch.randn(length, size)
    def __getitem__(self, index):
        return self.data[index]
    def __len__(self):
        return self.len
rand_loader = DataLoader(randDataset(ip_s, data_s), bat_s, shuffle=True)
rand_loader

import torch.nn as nn
class FCN(nn.Module):
    def __init__(self, ip_s, op_s):
        super(FCN, self).__init__()
        self.fc1 = nn.Linear(ip_s, int((ip_s+op_s)/2))
        self.fc2 = nn.Linear(int((ip_s+op_s)/2), op_s)
    def forward(self, input):
        output = self.fc1(input)
        output = self.fc2(output)
        print("\tFCN: input", input.size(),"output", output.size())
        return output
two_layer_nn = FCN(ip_s, op_s)
two_layer_nn = nn.DataParallel(two_layer_nn)
for data in rand_loader:
    input = data
    output = two_layer_nn(input)
    print("input", input.size(),"output", output.size())
