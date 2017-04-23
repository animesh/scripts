import nest
import numpy as np
import pylab as pl
import nest.topology as tp
nest.ResetKernel()
nest.SetKernelStatus({'overwrite_files': True})

print 'iaf_cond_alpha recordables: ', nest.GetDefaults('iaf_cond_alpha')['recordables']

mm = nest.Create('multimeter',
                params = {'withtime': True,
                          'withgid': True, 
                          'to_file': True, 
                          'label': 'mmrec',  
                          'interval': 0.5,
                          'record_from': ['V_m', 'g_ex', 'g_in']})

exc = nest.Create('spike_generator',
                  params = {'spike_times': np.array([10.0, 20.0, 50.0])})
inh = nest.Create('spike_generator',
                  params = {'spike_times': np.array([15.0, 25.0, 55.0])})


lexc=tp.CreateLayer({'rows':20,'columns':20,'elements':'iaf_cond_alpha', 'tau_syn_ex': 1.0, 'V_reset': -70.0,'weight':  40.0})

linh=tp.CreateLayer({'rows':10,'columns':10,'elements':'iaf_cond_alpha', 'tau_syn_ex': 1.0, 'V_reset': -70.0,'weight':  -20.0})

conndict={'connection_type':'divergent','mask':{'circular':{'radius':0.5}},"synapse_model": "static_synapse",'kernel':{'gaussian':{'p_center':1.0,'sigma':0.15}}}

tp.ConnectLayers(lexc,lexc,conndict)
tp.ConnectLayers(linh,lexc,conndict)

nest.DivergentConnect(mm,nest.GetLeaves(lexc)[0])
nest.DivergentConnect(exc,nest.GetLeaves(lexc)[0])
nest.DivergentConnect(inh,nest.GetLeaves(linh)[0])

d = nest.GetStatus(mm)[0]['events']['V_m']
nest.Simulate(100)

events = nest.GetStatus(mm)[0]['events']
t = events['times'];
print d,t,events
pl.clf()

pl.subplot(211)
pl.plot(t, events['V_m'])
#pl.axis([0, 100, -75, -53])
pl.ylabel('Membrane potential [mV]')

pl.subplot(212)
pl.plot(t, events['g_ex'], t, events['g_in'])
#pl.axis([0, 100, 0, 45])
pl.xlabel('Time [ms]')
pl.ylabel('Synaptic conductance [nS]')
pl.legend(('exc', 'inh'))

pl.show()
