import nest
import nest.topology as topo
import numpy as np
import math
import pylab as pl
import time
foo='simtop.'+str(time.time())

nest.ResetKernel()
nest.SetKernelStatus({'overwrite_files': True}) 

sim_time=100.0
sim_int=5.0

excitatory_dict = {
    "rows": 40,
    "columns": 40,
    "extent": [2.0, 2.0],
    "center": [0.0, 0.0],
    "elements": "iaf_cond_alpha",
    "edge_wrap": True
    }

inhibitory_dict = {
    "rows": 20,
    "columns": 20,
    "extent": [2.0, 2.0],
    "center": [0.0, 0.0],
    "elements": "iaf_cond_alpha",
    "edge_wrap": True
    }

mix_dict = {
    "rows": 10,
    "columns": 10,
    "extent": [2.0, 2.0],
    "center": [0.0, 0.0],
    "elements": "iaf_cond_alpha",
    "edge_wrap": True
    }

exc = topo.CreateLayer(excitatory_dict)
inh = topo.CreateLayer(inhibitory_dict)
mix = topo.CreateLayer(mix_dict)

exc_par = {
    "connection_type": "convergent",
    "mask": {"circular": {"radius": 1.0}},
    "weights": 40.0,
    "delays": 1.5,
    "kernel": {"gaussian": {"sigma": 0.3,"p_center": 1.3}},
    "allow_autapses": True,
    "allow_multapses": True,
    "number_of_connections": 90
    }

inh_par = {
    "connection_type": "convergent",
    "mask": {"circular": {"radius": 1.0}},
    "weights": -10.0,
    "delays": 1.5,
    "kernel": {"gaussian": {"sigma": 0.3, "p_center": 1.3}},
    "allow_autapses": True,
    "allow_multapses": True,
    "number_of_connections": 22
    }

mix_par = {
    "connection_type": "convergent",
    "mask": {"circular": {"radius": 1.0}},
    "weights": -20.0, 
    "delays": 1.0,
    "kernel": {"gaussian": {"sigma": 0.3, "p_center": 1.3}},
    "allow_autapses": True,
    "allow_multapses": True,
    "number_of_connections": 12
    }

nest.CopyModel('smp_generator', 'RetinaNode',
               params = {'ac'    : 30.0,
                         'dc'    : 30.0,
                         'freq'  : 2.0,
                         'phi'   : 0.0})
layerProps = {'rows'     : 10, 
              'columns'  : 10,
              'extent'   : [2.0, 2.0],
              'edge_wrap': True}
layerProps.update({'elements': 'RetinaNode'})
retina = topo.CreateLayer(layerProps)
retThal = {"connection_type": "divergent",
           "synapse_model": 'static_synapse',
           "mask": {"circular": {"radius": 1.0 }},
           "kernel": {"gaussian": {"p_center": 0.75, "sigma": 2.5 }},
           "weights": 50.0,
           "delays": 1.0}
layerProps.update({'elements': 'RetinaNode'})
retina = topo.CreateLayer(layerProps)

topo.ConnectLayers(exc,exc,exc_par)
topo.ConnectLayers(exc,inh,exc_par)
topo.ConnectLayers(inh,inh,exc_par)
topo.ConnectLayers(inh,exc,inh_par)
topo.ConnectLayers(exc,mix,exc_par)
topo.ConnectLayers(mix,inh,exc_par)


nest.PrintNetwork(depth=2)

pois = nest.Create('poisson_generator')
gex = nest.Create('smp_generator')
gin = nest.Create('spike_generator', params = {'spike_times': np.array([15.0, 25.0, 55.0])})

#nest.DivergentConnect(gex, nest.GetLeaves(exc)[0])
#nest.DivergentConnect(gin, nest.GetLeaves(inh)[0])
#nest.DivergentConnect(pois, nest.GetNodes(mix)[0])

[nest.SetStatus([n],{"phi": 0.1})
 for n in nest.GetLeaves(retina)[0]]

topo.ConnectLayers(retina,exc,retThal)


#mixpos = zip(*[topo.GetPosition([n]) for n in nest.GetLeaves(mix)[0]])[0]
#pylab.plot(mixpos[0], mixpos[1], 'x')
#pylab.show()

nest.CopyModel('multimeter', 'm',
               params = {'withtime': True, 
                         'withgid': True,
                         'to_file': True,
                         'label': 'simtop',
                         'interval': sim_int,
                         'record_from': ['V_m', 'g_ex', 'g_in'],
                         'withpath'   : True })

recorders = {}
for name, loc, population, model in [
    ('mix',1,mix,'mix'),
    ('inh',2,inh , 'inh'),
    ('exc', 3, exc, 'exc')
    ]:
    recorders[name] = (nest.Create('m'), loc)
    tgts = [nd for nd in nest.GetLeaves(population)[0] 
            if nest.GetStatus([nd], 'model')[0]==model]
    nest.DivergentConnect(recorders[name][0], tgts)
    print nest.GetLeaves(population)[0]
    print recorders[name]

nest.SetStatus([0],{'print_time': True})

nest.Simulate(sim_int)

for t in  pl.arange(sim_int, sim_time, sim_int):
#for t in  range(0, 0):
    print t
    nest.Simulate(sim_int)
    #pylab.clf()
    #pylab.jet()
    for name, r in recorders.iteritems():
        rec = r[0]
        sp = r[1]
        #pylab.subplot(2,2,sp)
        #d = nest.GetStatus(rec)[0]['events']['V_m']
        d = nest.GetStatus(rec)[0]['events']['V_m']
        events = nest.GetStatus(rec)[0]['events']
        t = events['times'];
        print rec,sp,d,nest.GetKernelStatus()['time'],t,events
        nest.SetStatus(rec, {'n_events': 0})
        #pylab.title(name + ', t = %6.1f ms' % nest.GetKernelStatus()pl.clf()
        pl.subplot(211)
        pl.plot(t, events['V_m'])
#pl.axis([0, 100, -75, -53])
        pl.ylabel('Membrane potential [mV]')
        
        pl.subplot(212)
        pl.plot(t, events['g_ex'], t, events['g_in'])
#pl.axis([0, 100, 0, 45])
        pl.xlabel('Time [ms]')
        pl.ylabel('Synaptic conductance [nS]')
        pl.legend(('g_exc', 'g_inh'))
#pl.show()
#    pylab.show()

#nest.Simulate(100)




print nest.GetStatus(nest.FindConnections(exc), 'target')
print nest.GetKernelStatus()
topo.DumpLayerNodes(mix,  'mix.dat')
topo.DumpLayerConnections(mix, 'static_synapse', 'mix.c.dat')



