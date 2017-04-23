import nest
nest.sli_run("topology using")
layer_settings = {
    "rows": 9,
    "columns": 8,
    "extent": [4.0, 5.0],
    "center": [1.0, -1.0],
    "elements": "iaf_neuron",
    "edge_wrap": False
    }
source = topo.CreateLayer(layer_settings)
layer_settings["extent"] = [2.0, 2.0]
target = topo.CreateLayer(layer_settings)
## Connect layers
connection_settings = {
    "connection_type": "convergent",
    "mask": {"circular": {"radius": 2.0}},
    "weights": 1.0,
    "synapse_model": "static_synapse"
}
#topo.ConnectLayers(source, target, connection_settings)
topo.DumpLayerConnections()

