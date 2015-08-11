import nest
import nest.topology as topo
## Initialising module
nest.sli_run("topology using")
## Create layers
layer = topo.CreateLayer({"rows": 3,
"columns": 4,
"extent": [1.0, 1.0],
"elements": "iaf_neuron"})
nest.PrintNetwork(1, layer)

layer_settings = {"rows": 9,
"columns": 8,
"extent": [4.0, 5.0],
"center": [1.0, -1.0],
"elements": "iaf_neuron",
"edge_wrap": False}
source = topo.CreateLayer(layer_settings)
layer_settings["extent"] = [2.0, 2.0]
target = topo.CreateLayer(layer_settings)
## Connect layers
connection_settings = {"connection_type": "convergent",
"mask": {"circular": {"radius": 2.0}},
"weights": 1.0,
"synapse_model": "static_synapse"}
topo.ConnectLayer(source, target, connection_settings)

