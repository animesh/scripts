"""
Short demonstration of the smp_generator for AC Poisson trains.
"""

# import nest and Hill-Tononi module
import nest
nest.ResetKernel()

# import plotting tools
import matplotlib.pyplot as plt
import numpy as np

# create two generators with different frequencies, phases, amplitudes
g = nest.Create('smp_generator', n=2, params=[{'dc': 10000.0, 'ac': 5000.0,
                                              'freq': 10.0, 'phi': 0.0},
                                             {'dc': 0.0, 'ac': 10000.0,
                                              'freq': 5.0, 'phi': np.pi/2.}])

# create multimeters and spike detectors
m = nest.Create('multimeter', n=2, params={'interval': 0.1, 'withgid': False,
                                           'record_from': ['Rate']})
s = nest.Create('spike_detector', n=2, params={'withgid': False})

nest.Connect(m, g)
nest.Connect(g, s)

nest.Simulate(200)

for j in xrange(2):
    ev = nest.GetStatus([m[j]])[0]['events']
    t = ev['times']
    r = ev['Rate']
    plt.subplot(211)
    plt.plot(t, r, '-')

    sp = nest.GetStatus([s[j]])[0]['events']['times']
    plt.subplot(212)
    plt.hist(sp, bins=20, range=[0, 200])

plt.show()
