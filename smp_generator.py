import nest
import numpy as np
#from NeuroTools import signals
import matplotlib.pyplot as plt
nest.ResetKernel()
nest.SetKernelStatus({"resolution":.01})
nest.SetKernelStatus({"overwrite_files":True})
hhneurons=nest.Create("hh_cond_exp_traub",n=20)
for k in range(20):
	nest.SetStatus([hhneurons[k]],{"I_e": k*200.})
	print k
sd=nest.Create('spike_detector')
nest.SetStatus(sd,{'to_file':True})
nest.ConvergentConnect(hhneurons,sd) 
nest.Simulate(200.)
#datafile=signals.NestFile('spike_detector-21-0.gdf',withtime=True)
#spikes=signals.loadspikelist(datafile,dims=1,idlist=hhneurons)

#fig = plt.figure()
#vm=np.loadtxt('voltmeter-2-0.dat')
#gca = fig.add_subplot(111)
#gca.plot(vm[:,1],vm[:,2])
#gca.set_xlabel("Time(msec)")
#gca.set_ylabel("Vm(mV)")
#plt.show()

