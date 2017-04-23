#from pyNN.utility import get_script_args
#simulator_name = get_script_args(1)[0]  
#exec("from pyNN.%s import *" % simulator_name)
from pyNN.neuron import *
from pyNN.nest import *
setup(timestep=0.1, min_delay=1.0, max_delay=2.0)
p1 = Population(100, IF_curr_alpha, structure=space.Grid2D())
p2 = Population(20, IF_curr_alpha, cellparams={'tau_m': 15.0, 'cm': 0.9})
p3 = Population(10, SpikeSourceArray, label="Input Population")
p4 = Population(60, IF_cond_alpha,
                cellparams={'v_thresh': -55.0, 'tau_m': 10.0, 'tau_refrac': 1.5},
                structure=space.Grid3D(3./4, 3./5), label="Column 1")

vinit_distr = RandomDistribution(distribution='uniform', parameters=[-70,-60])
p1.initialize('v', vinit_distr)
#p1.set({'tau_m':20, 'v_rest':-65})
pulse = DCSource(amplitude=0.5, start=20.0, stop=80.0)
p4.inject(pulse)
times = numpy.arange(0.0, 100.0, 1.0)
amplitudes = 0.1*numpy.sin(times*numpy.pi/100.0)
sine_wave = StepCurrentSource(times, amplitudes)
p4.inject(sine_wave)
prj4_1 = Projection(p4, p1, method=AllToAllConnector(), target='excitatory')
#prj4_4 = Projection(p4, p4, method=AllToAllConnector(), target='excitatory')
#prj3_1 = Projection(p3, p1, method=AllToAllConnector(), target='excitatory')
#prj2_1 = Projection(p2, p1, method=AllToAllConnector(), target='excitatory')
p1.record_v()
run(100.0)
p1.print_v("spikefile.dat")
#p1.print_gsyn("vfile.dat")
#print p1.meanSpikeCount(), p1.describe()
print p1,p2,p3,p4,pulse,sine_wave
end()
