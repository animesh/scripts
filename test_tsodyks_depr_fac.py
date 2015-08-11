
from scipy import *
from matplotlib.pylab import *
from matplotlib.mlab import *

def plot_spikes():

    dt = 0.1 # time resolution
    nbins = 1000
    N = 500 # number of neurons
    
    vm = load('voltmeter-0-0-4.dat')

    figure(1)
    clf()
    plot(vm[:,0], vm[:,1], 'r')
    xlabel('time / ms')
    ylabel('$V_m [mV]$')

    savefig('test_tsodyks_depressing.png')

plot_spikes()
show()
