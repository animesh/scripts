import nest
import numpy as np
import pylab as pl

nest.ResetKernel()

nest.SetKernelStatus({'overwrite_files': True,  # set to True to permit overwriting
                      'data_path': '',          # path to all data files, from working dir
                      'data_prefix': ''})       # prefix for all data files

# display recordables for illustration
print 'iaf_cond_alpha recordables: ', nest.GetDefaults('iaf_cond_alpha')['recordables']

# create neuron and multimeter
n = nest.Create('iaf_cond_alpha', 
                params = {'tau_syn_ex': 1.0, 'V_reset': -70.0})

m = nest.Create('multimeter',
                params = {'withtime': True,  # store time for each data point
                          'withgid': True,   # store gid for each data point
                          'to_file': True,   # write data to file
                          'label': 'my_multimeter',  # part of file name
                          'interval': 0.1,
                          'record_from': ['V_m', 'g_ex', 'g_in']})

# Create spike generators and connect
gex = nest.Create('spike_generator',
                  params = {'spike_times': np.array([10.0, 20.0, 50.0])})
gin = nest.Create('spike_generator',
                  params = {'spike_times': np.array([15.0, 25.0, 55.0])})

nest.Connect(gex, n, params={'weight':  40.0}) # excitatory
nest.Connect(n, n, params={'weight':  40.0}) # excitatory
nest.Connect(gin, n, params={'weight': -20.0}) # inhibitory
nest.Connect(n, n, params={'weight': -20.0}) # inhibitory
nest.Connect(m, n)

# simulate
nest.Simulate(100)

# obtain and display data
events = nest.GetStatus(m)[0]['events']
t = events['times'];

pl.clf()

pl.plot(t, events['g_ex'], t, events['g_in'])
pl.show()
