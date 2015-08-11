from scipy import *
from matplotlib.pylab import *
from matplotlib.mlab import *

def plot_spikes():

    dt = 0.25 # time resolution
    nbins = 1000
    N = 500 # number of neurons

    spikes = load('spike_detector-503-0.gdf')

    figure(1)
    clf()
    subplot(2,1,1)
    plot(spikes[:,4], spikes[:,0], '.')
    xlabel('time / ms')
    ylabel('neuron number')

    subplot(2,1,2)
    h,g = hist(spikes[:,4], nbins)
    plot(g, 1.0*h/N)
    xlabel('time / ms')
    ylabel('population activity')

    savefig('test_tsodyks_shortterm.png')


plot_spikes()
show()
