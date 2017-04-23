import nest
import nest.topology as tp
import math
import pylab
l=tp.CreateLayer({'rows':21,'columns':21,'elements':'iaf_neuron'})
conndict={'connection_type':'divergent','mask':{'circular':{'radius':0.4}},'kernel':{'gaussian':{'p_center':1.0,'sigma':0.15}}}
tp.ConnectLayers(l,l,conndict)

fig=tp.PlotLayer(l,nodesize=80)
ctr=tp.FindCenterElement(l)

tp.PlotTargets(ctr,l,fig=fig,
mask=conndict['mask'],kernel=conndict['kernel'],
src_size=250,tgt_color='red',tgt_size=20,
kernel_color='green')
l1=tp.CreateLayer({'rows':5,'columns':5,'elements':'iaf_neuron'})
l2=tp.CreateLayer({'rows':5,'columns':5,'elements':'iaf_neuron','center':[-1.0,1.0]})
l3=tp.CreateLayer({'rows':5,'columns':5,'elements':'iaf_neuron','center':[1.5,0.5]})
tp.ConnectLayers(l1,l3,mix_par)
