"""
Example of using a cell type defined in 9ML with pyNN.neuron
"""


import sys
import nineml
import pyNN.neuron as sim
from pyNN.neuron.nineml import nineml_cell_type
from pyNN.utility import init_logging

from copy import deepcopy

init_logging(None, debug=True)
sim.setup(timestep=0.1, min_delay=0.1, max_delay=2.0)


# Get come models to work with
from nineml.examples.AL import leaky_iaf
from nineml.examples.AL import coba_synapse

celltype_cls = nineml_cell_type("if_cond_exp",
                                leaky_iaf.c1,
                                inhibitory=coba_synapse.c1,
                                excitatory=deepcopy(coba_synapse.c1),
                                port_map={
                                    'excitatory': [('V', 'V'), ('Isyn', 'Isyn')],
                                    'inhibitory': [('V', 'V'), ('Isyn', 'Isyn')]
                                },
                                weight_variables={
                                    'excitatory': 'q',
                                    'inhibitory': 'q'
                                })

parameters = {
    'C': 1.0,
    'gL': 50.0,
    't_ref': 5.0,
    'excitatory_tau': 1.5,
    'inhibitory_tau': 10.0,
    'excitatory_E': 0.0,
    'inhibitory_E': -70.0,
    'theta': -50.0,
    'vL': -65.0,
    'V_reset': -65.0
}

cells = sim.Population(1, celltype_cls, parameters)
cells.initialize('V', parameters['vL'])
cells.initialize('t_spike', -1e99) # neuron not refractory at start
cells.initialize('regime', 1002) # temporary hack

input = sim.Population(2, sim.SpikeSourcePoisson, {'rate': 100})

connector = sim.OneToOneConnector(weights=1.0)#, delays=0.5)
conn = [sim.Projection(input[0:1], cells, connector, target='excitatory'),
        sim.Projection(input[1:2], cells, connector, target='inhibitory')]

cells._record('V')
cells._record('excitatory_g')
cells._record('inhibitory_g')
cells.record()

sim.run(100.0)

cells.recorders['V'].write("Results/nineml_neuron.V", filter=[cells[0]])
cells.recorders['excitatory_g'].write("Results/nineml_neuron.g_exc", filter=[cells[0]])
cells.recorders['inhibitory_g'].write("Results/nineml_neuron.g_inh", filter=[cells[0]])

t = cells.recorders['V'].get()[:,1]
v = cells.recorders['V'].get()[:,2]
g_exc = cells.recorders['excitatory_g'].get()[:,2]
g_inh = cells.recorders['inhibitory_g'].get()[:,2]


#plot(t,v)



sim.end()
