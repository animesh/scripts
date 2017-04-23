#! /usr/bin/env python

# This version uses NEST's RandomConvergentConnect functions.

import nest
import nest.raster_plot

import time
from numpy import exp

nest.ResetKernel()

startbuild = time.time()

dt      = 0.1    # the resolution in ms
simtime = 1000.0 # Simulation time in ms
delay   = 1.5    # synaptic delay in ms

# Parameters for asynchronous irregular firing
g       = 6.0
eta     = 2.0  # external rate relative to threshold rate
epsilon = 0.1  # connection probability

order     = 250
NE        = 4*order
NI        = 1*order
N_neurons = NE+NI
N_rec     = 50 # record from 50 neurons

CE    = int(epsilon*NE) # number of excitatory synapses per neuron
CI    = int(epsilon*NI) # number of inhibitory synapses per neuron  
C_tot = int(CI+CE)      # total number of synapses per neuron

# Initialize the parameters of the integrate and fire neuron
tauMem = 20.0
theta  = 20.0
J      = 10*0.1 # postsynaptic amplitude in mV

J_ex  = J
J_in  = -g*J_ex

nu_th  = theta/(J*CE*tauMem)
nu_ex  = eta*nu_th
p_rate = 1000.0*nu_ex*CE

nest.SetKernelStatus({"resolution": dt, "print_time": True})

print "Building network"

neuron_params= {"C_m":        1.0,
                "tau_m":      tauMem,
                "t_ref":      2.0,
                "E_L":        0.0,
                "V_reset":    0.0,
                "V_m":        0.0,
                "V_th":       theta}

nest.SetDefaults("iaf_psc_delta", neuron_params)

nodes_ex=nest.Create("iaf_psc_delta",NE)
nodes_in=nest.Create("iaf_psc_delta",NI)

nest.SetDefaults("poisson_generator",{"rate": p_rate})
noise=nest.Create("poisson_generator")

espikes=nest.Create("spike_detector")
ispikes=nest.Create("spike_detector")

nest.SetStatus([espikes],[{"label": "brunel-py-ex",
                   "withtime": True,
                   "withgid": True}])

nest.SetStatus([ispikes],[{"label": "brunel-py-in",
                   "withtime": True,
                   "withgid": True}])

print "Connecting devices."

nest.CopyModel("static_synapse","excitatory",{"weight":J_ex, "delay":delay})
nest.CopyModel("static_synapse","inhibitory",{"weight":J_in, "delay":delay})
 
nest.DivergentConnect(noise,nodes_ex,model="excitatory")
nest.DivergentConnect(noise,nodes_in,model="excitatory")

nest.ConvergentConnect(range(1,N_rec+1),espikes,model="excitatory")
nest.ConvergentConnect(range(NE+1,NE+1+N_rec),ispikes,model="excitatory")

print "Connecting network."

# We now iterate over all neuron IDs, and connect the neuron to
# the sources from our array. The first loop connects the excitatory neurons
# and the second loop the inhibitory neurons.

print "Excitatory connections"

nest.RandomConvergentConnect(nodes_ex, nodes_ex+nodes_in, CE,model="excitatory")

print "Inhibitory connections"

nest.RandomConvergentConnect(nodes_in, nodes_ex+nodes_in, CI,model="inhibitory")

endbuild=time.time()

print "Simulating."

nest.Simulate(simtime)

endsimulate= time.time()

events_ex = nest.GetStatus(espikes,"n_events")[0]
rate_ex   = events_ex/simtime*1000.0/N_rec
events_in = nest.GetStatus(ispikes,"n_events")[0]
rate_in   = events_in/simtime*1000.0/N_rec

num_synapses = nest.GetDefaults("excitatory")["num_connections"]+\
nest.GetDefaults("inhibitory")["num_connections"]

build_time = endbuild-startbuild
sim_time   = endsimulate-endbuild

print "Brunel network simulation (Python)"
print "Number of neurons :", N_neurons
print "Number of synapses:", num_synapses
print "       Exitatory  :", int(CE*N_neurons)+N_neurons
print "       Inhibitory :", int(CI*N_neurons)
print "Excitatory rate   : %.2f Hz" % rate_ex
print "Inhibitory rate   : %.2f Hz" % rate_in
print "Building time     : %.2f s" % build_time
print "Simulation time   : %.2f s" % sim_time

nest.raster_plot.from_device(espikes, "", hist=True)
#nest.raster_plot.show()
