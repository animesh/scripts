#! /usr/bin/env python

import nest
import nest.voltage_trace

nest.ResetKernel()

neuron = nest.Create("iaf_neuron")

noise = nest.Create("poisson_generator", 2)
nest.SetStatus(noise, [{"rate": 80000.0}, {"rate": 20000.0}])

sine = nest.Create("ac_generator")
nest.SetStatus(sine, [{"amplitude": 100.0, "frequency": 2.0}])

voltmeter = nest.Create("voltmeter")
nest.SetStatus(voltmeter, {"withgid": True, "withtime": True})

nest.ConvergentConnect(noise, neuron, [1.0, -1.0], 1.0)
nest.Connect(voltmeter, neuron)
nest.Connect(sine, neuron)

nest.Simulate(1000.0)

nest.voltage_trace.from_device(voltmeter)
nest.voltage_trace.show()
