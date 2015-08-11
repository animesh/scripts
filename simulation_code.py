import sys
sys.path.append("/bcfgrid/data/pernice/nest2_1kram/lib/python2.6/site-packages") 

import nest
import matplotlib.pyplot as plt
from numpy import *
import scipy.stats
import time

from symParams import *

############################################################################

def connectNeurons(neurons,mat,delay):
  numneurons=len(mat)
  for i in range(numneurons):
    #print i
    for j in range(numneurons):
        if mat[i,j]!=0:
          nest.Connect([neurons[j]],[neurons[i]],[mat[i,j]],[delay])
  return 0 

def setCorrDetectorsList(corrList,tau_max,delta_tau,neurons):
  numCDs=len(corrList)
  corrDetectors=nest.Create("correlation_detector",numCDs)
  for n in range(numCDs):
    nest.SetStatus([corrDetectors[n]],[{"tau_max":tau_max,"delta_tau":delta_tau}])
  for n in range(numCDs):
    nest.Connect([neurons[corrList[n][0]]],[corrDetectors[n]],[{"receptor_type":0}])
    nest.Connect([neurons[corrList[n][1]]],[corrDetectors[n]],[{"receptor_type":1}])
  return corrDetectors

############################################################################

nest.ResetKernel()
nest.SetStatus([0], {'local_num_threads': lnts})
nest.SetKernelStatus({'data_prefix':simName})
nest.SetKernelStatus({'overwrite_files':True})
nest.SetKernelStatus({'data_path':dataFolder})

##### set and connect network #####
nest.SetKernelStatus({"resolution": dt, "print_time": True})
neuron_params= {"C_m":        C_mLin,
                "c_1":        c1,
                "c_2":        c2,
                "c_3":        c3,
                "tau_m":      tau_mLin,
                "dead_time":      refr_tLin}
nest.SetDefaults("pp_psc_delta", neuron_params)
nodes=nest.Create("pp_psc_delta",N)
#
#here another neuron model (like e.g "iaf_psc_delta") would be needed
#with appropriate parameters
#


### setup matrix for connections

print 'Creating matrix', time.ctime(time.time())
print 'random matrix'
mat=randomMatExInDale(N,Ne,p,p,Je,Ji)
print 'Connecting neurons:', time.ctime(time.time())
connectNeurons(nodes,mat,delay)

###
noise= nest.Create("noise_generator",1)
nest.SetStatus(noise,[{"mean":n_extLin,"std":0.}])

nest.CopyModel("static_synapse","external",{"weight":J_ext, "delay":delay})
nest.DivergentConnect(noise,nodes,model="external")

##### set and connect measurement devices #####
nest.SetDefaults("correlation_detector",{'start':startRec,"tau_max":tauMax, "delta_tau":deltaTau})
nest.SetDefaults("voltmeter",{'start':startRec, 'stop':stopRec,"to_memory":False,"to_file":True, "withtime":True, "withgid":True})
nest.SetDefaults("spike_detector",{"to_memory":False,"to_file":True, "withtime":True, "withgid":True,'start':startRec, 'stop':stopRec})
voltmeter=nest.Create("voltmeter")
spikedet=nest.Create("spike_detector")
print 'Connecting devices:', time.ctime(time.time())
for nodeNumber in voltList:
  nest.Connect(voltmeter,[nodes[nodeNumber]])
for nodeNumber in spikeList:
  nest.Connect([nodes[nodeNumber]],spikedet)
corrDetectors1=setCorrDetectorsList(corrList,tauMax,deltaTau,nodes)

## autocorrelation detectors ##
nest.SetDefaults("correlation_detector",{'start':startRec,"tau_max":tauMax, "delta_tau":deltaTau})
autoCorrDets=nest.Create("correlation_detector",N)
for n in range(N):
  nest.Connect([nodes[n]],[autoCorrDets[n]],[{"receptor_type":0}])
  nest.Connect([nodes[n]],[autoCorrDets[n]],[{"receptor_type":1}])

######  ######  ######
nest.Simulate(simtime)
######  ######  ######

###  neuron ids ##
gidNeuronList=zeros([N,1])
for n in range(N):
  gidNeuronList[n]=nodes[n]
savetxt(dataFolder+simName+'gidNeuronList.txt',gidNeuronList,delimiter=' ')
gidCDList=zeros([len(corrList),3])
for n in range(len(corrList)):
  gidCDList[n,0]=nest.GetStatus([corrDetectors1[n]],["global_id"])[0][0]
  gidCDList[n,1]=corrList[n][0]
  gidCDList[n,2]=corrList[n][1]
savetxt(dataFolder+simName+'gidCDList.txt',gidCDList,delimiter=' ')

##### list of raw correlation functions #####
listCorrs=[]
times=arange(-tauMax,tauMax+deltaTau,deltaTau)
for n in range(len(corrList)):
  listCorrs.append(nest.GetStatus([corrDetectors1[n]],['histogram'])[0][0])
#### autocorrelations ####
autoCorrs=[]
autoRates=[]
for n in range(N):
  autoCorrs.append(nest.GetStatus([autoCorrDets[n]],['histogram'])[0][0])
  autoRates.append(nest.GetStatus([autoCorrDets[n]],['n_events'])[0][0][0])
savetxt(dataFolder+simName+'_corrFunctions.txt',listCorrs, delimiter=' ')
savetxt(dataFolder+simName+'_autoCorrFuncs.txt',autoCorrs, delimiter=' ')
savetxt(dataFolder+simName+'_autoRates.txt',autoRates, delimiter=' ')
savetxt(dataFolder+matFilename, mat,fmt='%1.2f', delimiter=' ')
###############################################################################





