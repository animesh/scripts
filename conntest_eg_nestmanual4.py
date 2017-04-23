nest.CopyModel("iaf_neuron", "my_excitatory")
nest.CopyModel("iaf_neuron", "my_inhibitory")
dict = {"rows": 3,"columns": 4, "extent": [1.0, 1.0],"elements": ["my_excitatory", ["my_inhibitory", "my_excitatory"]]}
layer = topo.CreateLayer(dict)
dict = {"connection_type": "divergent","mask": {"circular": {"radius": 0.1}},"targets": {"lid : 2,"model": "my_excitatory"}}
dict = {"connection_type": "divergent","mask": {"doughnut": {"inner_radius": 0.1,"outer_radius": 0.3}},"number_of_connections": 100,"allow_multapses": False}
topo.ConnectLayers(layer, layer, dict)
layer = topo.CreateLayer({"rows": 5,"columns": 4,"extent": [1.0, 1.0],"elements": "iaf_neuron"})
node_a = [nest.GetLeaves(layer)[0][2]]
node_b = [nest.GetLeaves(layer)[0][3]]
print topo.GetRelativeDistance(node_a, node_b)
topo.LayerGidPositionMap(layer, 'out.txt')
topo.PrintLayerConnections(layer, 'static_synapse', 'out.txt')
