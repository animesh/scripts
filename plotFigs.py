import matplotlib.pyplot as plt
from numpy import *
import scipy.stats
import time
import cPickle
from symParams import *
import scipy.signal

gidCDList=loadtxt(dataFolder+simName+'gidCDList.txt')
withZero='' #if many nodes, additional zero in filenames

def getVoltageTracesFromFiles(filenames,voltList,firstNeuron):
  voltagetraces=[]
  for i in range(len(voltList)):
    voltagetraces.append([])
  for filename in filenames: 
    voltArray=loadtxt(filename)
    pots=voltArray[:,2]
    times=voltArray[:,1]
    senders=voltArray[:,0]
    for i,n in enumerate(senders):
      voltagetraces[int(n-firstNeuron)].append(pots[i])
  return voltagetraces


def lookAtVoltages(voltagetraces,startRec,plotTime):
  voltage_means=zeros(len(voltagetraces))
  for n in range(len(voltagetraces)):
    voltage_means[n]=mean(voltagetraces[n])
  print 'mean voltages (mean,std.dev):'
  meanV=mean(voltage_means)
  stdDev=sqrt(var(voltage_means))
  print meanV,stdDev
  fig=plt.figure()
  ax1=fig.add_axes([.15,.1,.7,.8]) 
  plotVolts=zeros([len(voltList),int(plotTime)])
  for i in range(len(voltList)):
    plotVolts[i,:]=voltagetraces[i][0:int(plotTime)]
    plt.plot(range(int(startRec),int(plotTime)+int(startRec)),voltagetraces[i][0:int(plotTime)],color='0.75',label=str(voltList[i]))
  plt.plot(range(int(startRec),int(plotTime)+int(startRec)),sum(plotVolts,0)/len(voltList),'r',linewidth=3)
  plt.ylabel("rate [Hz]")
  plt.xlabel("time [ms]")
  bins=arange(plotVolts.min(),plotVolts.max(),(plotVolts.max()-plotVolts.min())/50)
  hist=zeros(len(bins)-1)
  for n in range(int(plotTime)):
    hist=hist+histogram(plotVolts[:,n], bins, new=True, normed=False)[0]
  plt.plot(range(int(startRec),int(plotTime)+int(startRec)),zeros(int(plotTime)),'k:',linewidth=3)
  ax2=fig.add_axes([.85,.1,.1,.8]) 
  ax2.set_axis_off()
  plt.barh(bins[:-1],hist[:],height=(bins[1]-bins[0]),edgecolor='b')
  ax1.set_ylim(plotVolts.min(),plotVolts.max())
  ax2.set_ylim(ax1.get_ylim())
  return fig,meanV,stdDev


def getSpikeTimesFromFiles(filenames,spikeList,firstNeuron):
  spiketraintimes=[]
  for i in range(len(spikeList)):
    spiketraintimes.append([])
  for filename in filenames:
    spikeArray=loadtxt(filename)
    spiketimes=spikeArray[:,1]
    spikesenders=spikeArray[:,0]
    tmax=spiketimes[-1]
    numSpikes=len(spiketimes)
    print numSpikes, 'spikes to be sorted in ', filename
    for i,n in enumerate(spikesenders):
      spiketraintimes[int(n-firstNeuron)].append(spiketimes[i]) #for  all neurons recorded
      if i%1000000==0:
        print i,'spikes done' 
  return spiketraintimes


def plotSpikeRasterPopVar(spiketraintimes,numOfPlottedTrains,startTime,plotTime):
  fig=plt.figure()
  ax1 = fig.add_axes([.1,.4,.8,.5]) 
  for n in range(numOfPlottedTrains):
    index1=searchsorted(spiketraintimes[n],startRec)
    index2=searchsorted(spiketraintimes[n],startRec+plotTime)
    plt.plot(spiketraintimes[n][index1:index2],n*ones_like(spiketraintimes[n][index1:index2]),'|k',label=str(spikeList[n]))   
  plt.ylim(0.5,numOfPlottedTrains-0.5)
  plt.xticks([])
  plt.ylabel('neuron index')
  ###population rate
  ax2 = fig.add_axes([.1,.25,.8,.15])
  delt   =  1.
  bins=arange(startTime,plotTime+startTime+delt,delt)
  spikehist=zeros_like(bins[:-1])
  for n in range(len(spiketraintimes)):
    spikehist+=histogram(spiketraintimes[n], bins, new=True, normed=False)[0]
  plt.bar(bins[:-1],spikehist[:],width=delt,facecolor='k',edgecolor='k')
  ##mean and variance
  plt.plot(bins,mean(spikehist)*ones(len(bins)),'r',linewidth=3)
  plt.plot(bins,(std(spikehist)+mean(spikehist))*ones(len(bins)),'r',linewidth=1)
  plt.plot(bins,(-std(spikehist)+mean(spikehist))*ones(len(bins)),'r',linewidth=1)
  plt.fill_between(bins,(-std(spikehist)+mean(spikehist))*ones(len(bins)),(std(spikehist)+mean(spikehist))*ones(len(bins)),color='r',alpha=0.5)
  plt.ylabel('spikes [ms]')
  plt.xlabel('time /ms')
  return fig


### plot voltagetraces ### 
print 'getting voltagetraces:'
voltFilenames=[]
vid=str(N+2)
for thr in range(lnts):
  filename=dataFolder+simName+'voltmeter-'+withZero+vid+'-'+str(thr)+'.dat'
  voltFilenames.append(filename)
voltagetraces=getVoltageTracesFromFiles(voltFilenames,voltList,1)
savetxt('voltageTraces.txt',voltagetraces)
voltfig,voltMean,voltStdDev=lookAtVoltages(voltagetraces,startRec,plotTime)
plt.savefig('voltFig'+vers+'.pdf')

### spikes ###
print ' '
print 'getting spiketimes'
SDFilenames=[]
sdid=str(N+3)
for thr in range(lnts):
  filename=dataFolder+simName+'spike_detector-'+withZero+sdid+'-'+str(thr)+'.gdf'
  SDFilenames.append(filename)
spiketraintimes=getSpikeTimesFromFiles(SDFilenames,spikeList,1)



## rasterplot ##
print ' '
print 'plot spiketrains'
figSpikes=plotSpikeRasterPopVar(spiketraintimes,plotRasterSpikes,startRec,plotTime)
plt.savefig('spikes'+vers+'.pdf')


plt.show()
