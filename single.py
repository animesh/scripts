import nest
import nest.voltage_trace

nest.ResetKernel()
nest.SetKernelStatus({"overwrite_files": True})

neuron = nest.Create("iaf_neuron")
noise = nest.Create("poisson_generator", 2)

voltmeter = nest.Create("voltmeter")

nest.SetStatus(noise,[{"rate": 80000.0}, {"rate": 15000.0}])

nest.SetStatus(voltmeter,[{"to_file": True, "withtime": True}])

nest.ConvergentConnect(noise, neuron, [1.2, -1.], [1.0, 1.0])
nest.Connect(voltmeter, neuron)

nest.Simulate(500.0)

nest.voltage_trace.from_device(voltmeter)
nest.voltage_trace.show()


