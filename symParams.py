from numpy import *
import nest
import time
import sys

###### Parameters #####

## simulation
lnts    =4   #local num threads
dt      = 1.    # the resolution in ms
simtime = 30.*1000. # Simulation time in ms
delay   = 2.    # synaptic delay in ms
startRec= 10000.    #start for recording devices (cut transients)
stopRec=  100*1000.  # stop for rate recording (to get not too many spikes)

rng_seed= 3
if len(sys.argv)>1:
  rng_seed=int(sys.argv[1])
grng_seed=4
if len(sys.argv)>2:
  grng_seed=int(sys.argv[2])

simName = 'linear_' #prefix for data files
matFilename='symmatrix.txt'
vers='1'
dataFolder='/data/pernice/symData/testData/'

## network
p       = 0.1  # connection probability
order   = 200
Ne      = 4*order
Ni      = 1*order
N       = Ne+Ni
CE      = int(p*Ne) # number of excitatory synapses per neuron
CI      = int(p*Ni) # number of inhibitory synapses per neuron  
C_tot   = (CI+CE)
atts=[0.25,0.5]
sigmas=[N*p/atts[0]/2,N*p/atts[1]/2]
print sigmas

## neurons
g       = 5.
J       = 1.5 
J_ext   = 1.
Je      = J 
Ji      = -g*Je

#linear
tau_mLin=10.
C_mLin=1.  
c1=1.#Hz/V
c2=0.#offset 
c3=0.
refr_tLin=1.e-8
reset=0.

## ext input
n_extLin=1. #constant external input #in tau*V

## devices

#voltages
numRecV= 50
voltList= range(numRecV)

#spikes
numRecSp = N
spikeList=range(numRecSp)
plotRasterSpikes=N
plotTime= 1500

#correlation pairs
numStarts=50
tauMax=100. #maximum time lag for correlation measurement
deltaTau=10. #correlation function resolution
corrList=[]
ds=range(-2*order-5,2*order+5,10)
starts=random.permutation(N)[0:numStarts]
for start in starts:
  for d in ds:
    corrList.append([start,(start+d)%N])


##### Methods #####

def randomMatExInDale(N,Ne,Pe,Pi,Je=1,Ji=1):
  mat=zeros([N,N])
  for i in range(N):
    for j in range(Ne):
      r=random.random()
      if r<Pe:
        mat[i,j]=Je
    for j in range(Ne,N):
      r=random.random()
      if r<Pi:
        mat[i,j]=Ji
  return mat

