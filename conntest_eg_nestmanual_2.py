import nest
import nest.topology as topo
import math
import pylab
nest.ResetKernel()

conf = {
    'N'              : 10,
    'size'           : 8.0,
    'sim_time'       : 500.0,
    'sim_int'        : 5.0
    }

nest.CopyModel(
    'iaf_cond_alpha', 'Model',
    params = {
        'C_m'       :  32.0,
        'E_ex'      :   0.0,
        'V_reset'   : -64.0,
        'V_th'      : -40.0,
        't_ref'     :   2.0,
        'E_in'      : -80.0,
        'I_e'       :   0.0,
        'V_m'       : -65.0
        }
    )

nest.CopyModel(
    'Model', 'NCluster', 
    params = {
        'C_m'  :  16.0,
        'V_th' : -60.0,
        't_ref':   1.0,
        'E_in' : -70.0
        }
    )

layer_conf = {
    'rows'     : conf['N'], 
    'columns'  : conf['N'],
    'extent'   : [conf['size'], conf['size']],
    'edge_wrap': True
}

layer_conf.update({'elements': 'iaf_cond_alpha'})
Np = topo.CreateLayer(layer_conf)

nest.CopyModel('Model', 'CtxExNeuron')

layer_conf.update({'elements': 'iaf_psc_alpha'})
CEp = topo.CreateLayer(layer_conf)

nest.CopyModel(
    'Model', 'CtxInNeuron', 
    params = {
        'C_m'  :   16.0,
        'V_th' :  -60.0,
        't_ref':    1.0
        }
    )

layer_conf.update({'elements': 'iaf_neuron'})
CIp = topo.CreateLayer(layer_conf)
nest.PrintNetwork()

nest.CopyModel(
    'multimeter', 'RecordingNode',
    params = {
        'interval'   : conf['sim_int'],
        'record_from': ['V_m'],
        'record_to'  : ['memory'],
        'withgid'    : True,
        'withpath'   : False,
        'withtime'   : False
        }
    )


Nppos = zip(*[topo.GetPosition([n]) for n in nest.GetLeaves(Np)[0]])[0]
pylab.plot(Nppos[0], Nppos[1], 'x')
axis = conf['size']/2 + 0.2
pylab.axis([-axis,axis,-axis,axis])
pylab.title('Layer Np')
#pylab.show()

nest.SetStatus([0],{'print_time': True})
#nest.Simulate(conf['sim_int'])



cdict = {
    "connection_type": "divergent",
    "synapse_model": "tsodyks_synapse",
    "mask": {
        "doughnut": {"inner_radius": 0.1,"outer_radius": 0.4}
        },
    "delays": 1.3,
    "weights": {
        "gaussian": {"sigma": 1.5, "p_center": 2.0,"c": 1.0, "mean": 0.1}
        },
    "kernel": {
        "linear": {"a": -0.5, "c": 1.0,"min": 0.4, "max": 0.9}
        }
    }

topo.ConnectLayers(CIp, CEp, cdict)


# Create two neuron types
#nest.CopyModel("iaf_neuron", "my_excitatory")
#nest.CopyModel("iaf_neuron", "my_inhibitory")
# Create a single layer
#dict = {"rows": 3,"columns": 4,"extent": [1.0, 1.0],"elements": ["my_excitatory", ["my_inhibitory", "my_excitatory"]]}
#layer = topo.CreateLayer(dict)
# Connect layer to itself
#dict = {"connection_type": "divergent","mask": {"circular": {"radius": 0.1}},"targets": {"lid : 2,"model": "my_excitatory"}}
#dict = {"connection_type": "divergent","mask": {"doughnut": {"inner_radius": 0.1,"outer_radius": 0.3}},"number_of_connections": 100,"allow_multapses": False}
#topo.ConnectLayers(layer, layer, dict)
#layer = topo.CreateLayer({"rows": 5,"columns": 4,"extent": [1.0, 1.0],"elements": "iaf_neuron"})
#node_a = [nest.GetLeaves(layer)[0][2]]
#node_b = [nest.GetLeaves(layer)[0][3]]
#print topo.GetRelativeDistance(node_a, node_b)
#topo.LayerGidPositionMap(layer, 'out.txt')
#topo.PrintLayerConnections(layer, 'static_synapse', 'out.txt')


excitatory_dict = {
"rows": 300,
"columns": 300,
"extent": [2.0, 2.0],
"elements": "iaf_neuron",
"edge_wrap": True}

inhibitory_dict = {
"rows": 150,
"columns": 150,
"extent": [2.0, 2.0],
"center": [0.0, 0.0],
"elements": "iaf_neuron",
"edge_wrap": True}

exc = topo.CreateLayer(excitatory_dict)
inh = topo.CreateLayer(inhibitory_dict)

exc_par = {"connection_type": "convergent",
"mask": {"circular": {"radius": 1.8}},
"weights": 1.0,
"delays": 1.5,
"kernel": {"gaussian": {"sigma": 0.3,
"p_center": 1.3}},
"allow_autapses": True,
"allow_multapses": True,
"number_of_connections": 9000}

inh_par = {"connection_type": "convergent",
"mask": {"circular": {"radius": 1.8}},
"weights": 4.0, # the weight of inhibitory connections are four times as high as excitatory.
"delays": 1.5,
"kernel": {"gaussian": {"sigma": 0.3, "p_center": 1.3}},
"allow_autapses": True,
"allow_multapses": True,
"number_of_connections": 2250}

topo.ConnectLayers(exc,exc,exc_par)
#topo.ConnectLayer(exc,inh,exc_par)
#topo.ConnectLayer(inh,inh,inh_par)
#topo.ConnectLayer(inh,exc,inh_par)



