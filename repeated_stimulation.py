#! /usr/bin/env python

# repeated_stimulation.py
#
# Copyright (C) 2010 The NEST Initiative

"""
Simple example for how to repeat a stimulation protocol
using the 'origin' property of devices.

In this example, a poisson_generator generates a spike train that is
recorded directly by a spike_detector, using the following paradigm:

1. A single trial last for 1000ms.
2. Within each trial, the poisson_generator is active from 100ms to 500ms.

We achieve this by defining the 'start' and 'stop' properties of the
generator to 100ms and 500ms, respectively, and setting the 'origin' to the
simulation time at the beginning of each trial. Start and stop are interpreted
relative to the origin.
"""

import nest

# parameters
rate  = 1000.0  # generator rate in spikes/s
start =  100.0  # start of simulation relative to trial start, in ms
stop  =  500.0  # end of simulation relative to trial start, in ms

trial_duration = 1000.0 # trial duration, in ms
num_trials     = 5      # number of trials to perform

# set up network
nest.ResetKernel()
pg = nest.Create('poisson_generator',
                 params = {'rate'  : rate,
                           'start' : start,
                           'stop'  : stop}
                 )
sd = nest.Create('spike_detector')
nest.Connect(pg, sd)

# before each trial, we set the 'origin' of the poisson_generator to the current
# simulation time
for n in xrange(num_trials):
    nest.SetStatus(pg, {'origin': nest.GetKernelStatus()['time']})
    nest.Simulate(trial_duration)

# now plot the result, including a histogram
# note: The histogram will show spikes seemingly located before 100ms into
#       each trial. This is due to sub-optimal automatic placement of histogram bin borders.
import nest.raster_plot
nest.raster_plot.from_device(sd, hist=True, hist_binwidth=100.,
                             title='Repeated stimulation by Poisson generator')
nest.raster_plot.show()
