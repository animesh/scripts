#https://towardsdatascience.com/quantum-physics-visualization-with-python-35df8b365ff
import matplotlib.pyplot as plt
import numpy as np
#Constants
h = 6.626e-34
m = 9.11e-31
#Values for L and x
x_list = np.linspace(0,1,100)
L = 1
def psi(n,L,x):
    return np.sqrt(2/L)*np.sin(n*np.pi*x/L)
def psi_2(n,L,x):
    return np.square(psi(n,L,x))
plt.figure(figsize=(15,10))
plt.suptitle("Wave Functions", fontsize=18)
for n in range(1,4):
    #Empty lists for energy and psi wave
    psi_2_list = []
    psi_list = []
    for x in x_list:
        psi_2_list.append(psi_2(n,L,x))
        psi_list.append(psi(n,L,x))
    plt.subplot(3,2,2*n-1)
    plt.plot(x_list, psi_list)
    plt.xlabel("L", fontsize=13)
    plt.ylabel("Ψ", fontsize=13)
    plt.xticks(np.arange(0, 1, step=0.5))
    plt.title("n="+str(n), fontsize=16)
    plt.grid()
    plt.subplot(3,2,2*n)
    plt.plot(x_list, psi_2_list)
    plt.xlabel("L", fontsize=13)
    plt.ylabel("Ψ*Ψ", fontsize=13)
    plt.xticks(np.arange(0, 1, step=0.5))
    plt.title("n="+str(n), fontsize=16)
    plt.grid()
plt.tight_layout(rect=[0, 0.03, 1, 0.95])

#https://towardsdatascience.com/python-based-plotting-with-matplotlib-8e1c301e2799
from mpl_toolkits.mplot3d import Axes3D #https://stackoverflow.com/questions/3810865/matplotlib-unknown-projection-3d-error
import matplotlib.pyplot as plt
import numpy as np
#Probability of 1s
def prob_1s(x,y,z):
    r=np.sqrt(np.square(x)+np.square(y)+np.square(z))
    #Remember.. probability is psi squared!
    return np.square(np.exp(-r)/np.sqrt(np.pi))
#Random coordinates
x=np.linspace(0,1,30)
y=np.linspace(0,1,30)
z=np.linspace(0,1,30)
elements = []
probability = []
for ix in x:
    for iy in y:
        for iz in z:
            #Serialize into 1D object
            elements.append(str((ix,iy,iz)))
            probability.append(prob_1s(ix,iy,iz))

#Ensure sum of probability is 1
probability = probability/sum(probability)
#Getting electron coordinates based on probabiliy
coord = np.random.choice(elements, size=100000, replace=True, p=probability)
elem_mat = [i.split(',') for i in coord]
elem_mat = np.matrix(elem_mat)
x_coords = [float(i.item()[1:]) for i in elem_mat[:,0]]
y_coords = [float(i.item()) for i in elem_mat[:,1]]
z_coords = [float(i.item()[0:-1]) for i in elem_mat[:,2]]
#Plotting
fig = plt.figure(figsize=(10,10))
ax = fig.add_subplot(111, projection='3d')
ax.scatter(x_coords, y_coords, z_coords, alpha=0.05, s=2)
ax.set_title("Hydrogen 1s density")
plt.show()



#https://www.eadan.net/blog/german-tank-problem/
import numpy as np
num_tanks = 1000
num_captured = 15
serial_numbers = np.arange(1, num_tanks + 1)
num_simulations = 100_000
def capture_tanks(serial_numbers, n):
     """Capture `n` tanks, uniformly, at random."""
     return np.random.choice(serial_numbers, n, replace=False)
simulations = [
    capture_tanks(serial_numbers, num_captured)
    for _ in range(num_simulations)
]

import matplotlib.pyplot as plt
first_estimates = [max(s) for s in simulations]
plt.hist(first_estimates)
avg_first_estimates = np.mean(first_estimates)

def max_plus_avg_spacing(simulation):
    m = max(simulation)
    avg_spacing = (m / num_captured) - 1
    return m + avg_spacing
new_estimates = [max_plus_avg_spacing(s) for s in simulations]
plt.hist(new_estimates)
avg_new_estimates = np.mean(new_estimates)

print(np.std(first_estimates))  #=> 57
print(np.std(new_estimates))    #=> 62

import pymc3 as pm
captured = [499, 505, 190, 427, 185, 572, 818, 721,912, 302, 765, 231, 547, 410, 884]
print(max_plus_avg_spacing(captured))   #=> 971.8

with pm.Model():
    num_tanks = pm.DiscreteUniform(
        "num_tanks",
	lower=max(captured),
	upper=2000
    )
    likelihood = pm.DiscreteUniform(
        "observed",
	lower=1,
	upper=num_tanks,
	observed=captured
    )
    posterior = pm.sample(10000, tune=1000)
pm.plot_posterior(posterior, credible_interval=0.95)
#https://stackoverflow.com/questions/25735153/plotting-a-fast-fourier-transform-in-python
#%matplotlib inline
import numpy as np
import matplotlib.pyplot as plt
import scipy.fftpack

fig = plt.figure(figsize=[14,4])
N = 600           # Number of samplepoints
Fs = 800.0
T = 1.0 / Fs      # N_samps*T (#samples x sample period) is the sample spacing.
N_fft = 80        # Number of bins (chooses granularity)
x = np.linspace(0, N*T, N)     # the interval
y = np.sin(50.0 * 2.0*np.pi*x) + 0.5*np.sin(80.0 * 2.0*np.pi*x)   # the signal

# removing the mean of the signal
mean_removed = np.ones_like(y)*np.mean(y)
y = y - mean_removed

# Compute the fft.
yf = scipy.fftpack.fft(y,n=N_fft)
xf = np.arange(0,Fs,Fs/N_fft)

##### Plot the fft #####
ax = plt.subplot(121)
pt, = ax.plot(xf,np.abs(yf), lw=2.0, c='b')
p = plt.Rectangle((Fs/2, 0), Fs/2, ax.get_ylim()[1], facecolor="grey", fill=True, alpha=0.75, hatch="/", zorder=3)
ax.add_patch(p)
ax.set_xlim((ax.get_xlim()[0],Fs))
ax.set_title('FFT', fontsize= 16, fontweight="bold")
ax.set_ylabel('FFT magnitude (power)')
ax.set_xlabel('Frequency (Hz)')
plt.legend((p,), ('mirrowed',))
ax.grid()

##### Close up on the graph of fft#######
# This is the same histogram above, but truncated at the max frequence + an offset.
offset = 1    # just to help the visualization. Nothing important.
ax2 = fig.add_subplot(122)
ax2.plot(xf,np.abs(yf), lw=2.0, c='b')
ax2.set_xticks(xf)
ax2.set_xlim(-1,int(Fs/6)+offset)
ax2.set_title('FFT close-up', fontsize= 16, fontweight="bold")
ax2.set_ylabel('FFT magnitude (power) - log')
ax2.set_xlabel('Frequency (Hz)')
ax2.hold(True)
ax2.grid()

plt.yscale('log')

import numpy as np
import matplotlib.pyplot as plt
import scipy.fftpack

# Number of samplepoints
N = 600
# sample spacing
T = 1.0 / 800.0
x = np.linspace(0.0, N*T, N)
y = 10 + np.sin(50.0 * 2.0*np.pi*x) + 0.5*np.sin(80.0 * 2.0*np.pi*x)
yf = scipy.fftpack.fft(y)
xf = np.linspace(0.0, 1.0/(2.0*T), N/2)

plt.subplot(2, 1, 1)
plt.plot(xf, 2.0/N * np.abs(yf[0:N/2]))
plt.subplot(2, 1, 2)
plt.plot(xf[1:], 2.0/N * np.abs(yf[0:N/2])[1:])
"""
Discrete Fourier Transforms - FFT.py

The underlying code for these functions is an f2c translated and modified
version of the FFTPACK routines.

fft(a, n=None, axis=-1)
ifft(a, n=None, axis=-1)
rfft(a, n=None, axis=-1)
irfft(a, n=None, axis=-1)
hfft(a, n=None, axis=-1)
ihfft(a, n=None, axis=-1)
fftn(a, s=None, axes=None)
ifftn(a, s=None, axes=None)
rfftn(a, s=None, axes=None)
irfftn(a, s=None, axes=None)
fft2(a, s=None, axes=(-2,-1))
ifft2(a, s=None, axes=(-2, -1))
rfft2(a, s=None, axes=(-2,-1))
irfft2(a, s=None, axes=(-2, -1))
"""
__all__ = ['fft','ifft', 'rfft', 'irfft', 'hfft', 'ihfft', 'rfftn',
           'irfftn', 'rfft2', 'irfft2', 'fft2', 'ifft2', 'fftn', 'ifftn',
           'refft', 'irefft','refftn','irefftn', 'refft2', 'irefft2']

from numpy.core import asarray, zeros, swapaxes, shape, conjugate, take
import fftpack_lite as fftpack
from helper import *

_fft_cache = {}
_real_fft_cache = {}

def _raw_fft(a, n=None, axis=-1, init_function=fftpack.cffti,
             work_function=fftpack.cfftf, fft_cache = _fft_cache ):
    a = asarray(a)

    if n == None: n = a.shape[axis]

    if n < 1: raise ValueError("Invalid number of FFT data points (%d) specified." % n)

    try:
        wsave = fft_cache[n]
    except(KeyError):
        wsave = init_function(n)
        fft_cache[n] = wsave

    if a.shape[axis] != n:
        s = list(a.shape)
        if s[axis] > n:
            index = [slice(None)]*len(s)
            index[axis] = slice(0,n)
            a = a[index]
        else:
            index = [slice(None)]*len(s)
            index[axis] = slice(0,s[axis])
            s[axis] = n
            z = zeros(s, a.dtype.char)
            z[index] = a
            a = z

    if axis != -1:
        a = swapaxes(a, axis, -1)
    r = work_function(a, wsave)
    if axis != -1:
        r = swapaxes(r, axis, -1)
    return r


def fft(a, n=None, axis=-1):
    """fft(a, n=None, axis=-1)

    Return the n point discrete Fourier transform of a. n defaults to
    the length of a. If n is larger than the length of a, then a will
    be zero-padded to make up the difference.  If n is smaller than
    the length of a, only the first n items in a will be used.

    The packing of the result is "standard": If A = fft(a, n), then A[0]
    contains the zero-frequency term, A[1:n/2+1] contains the
    positive-frequency terms, and A[n/2+1:] contains the negative-frequency
    terms, in order of decreasingly negative frequency. So for an 8-point
    transform, the frequencies of the result are [ 0, 1, 2, 3, 4, -3, -2, -1].

    This is most efficient for n a power of two. This also stores a cache of
    working memory for different sizes of fft's, so you could theoretically
    run into memory problems if you call this too many times with too many
    different n's."""

    return _raw_fft(a, n, axis, fftpack.cffti, fftpack.cfftf, _fft_cache)


def ifft(a, n=None, axis=-1):
    """ifft(a, n=None, axis=-1)

    Return the n point inverse discrete Fourier transform of a.  n
    defaults to the length of a. If n is larger than the length of a,
    then a will be zero-padded to make up the difference. If n is
    smaller than the length of a, then a will be truncated to reduce
    its size.

    The input array is expected to be packed the same way as the output of
    fft, as discussed in it's documentation.

    This is the inverse of fft: ifft(fft(a)) == a within numerical
    accuracy.

    This is most efficient for n a power of two. This also stores a cache of
    working memory for different sizes of fft's, so you could theoretically
    run into memory problems if you call this too many times with too many
    different n's."""

    a = asarray(a).astype(complex)
    if n == None:
        n = shape(a)[axis]
    return _raw_fft(a, n, axis, fftpack.cffti, fftpack.cfftb, _fft_cache) / n


def rfft(a, n=None, axis=-1):
    """rfft(a, n=None, axis=-1)

    Return the n point discrete Fourier transform of the real valued
    array a. n defaults to the length of a. n is the length of the
    input, not the output.

    The returned array will be the nonnegative frequency terms of the
    Hermite-symmetric, complex transform of the real array. So for an 8-point
    transform, the frequencies in the result are [ 0, 1, 2, 3, 4]. The first
    term will be real, as will the last if n is even. The negative frequency
    terms are not needed because they are the complex conjugates of the
    positive frequency terms. (This is what I mean when I say
    Hermite-symmetric.)

    This is most efficient for n a power of two."""

    a = asarray(a).astype(float)
    return _raw_fft(a, n, axis, fftpack.rffti, fftpack.rfftf, _real_fft_cache)


def irfft(a, n=None, axis=-1):
    """irfft(a, n=None, axis=-1)

    Return the real valued n point inverse discrete Fourier transform
    of a, where a contains the nonnegative frequency terms of a
    Hermite-symmetric sequence. n is the length of the result, not the
    input. If n is not supplied, the default is 2*(len(a)-1). If you
    want the length of the result to be odd, you have to say so.

    If you specify an n such that a must be zero-padded or truncated, the
    extra/removed values will be added/removed at high frequencies. One can
    thus resample a series to m points via Fourier interpolation by: a_resamp
    = irfft(rfft(a), m).

    This is the inverse of rfft:
    irfft(rfft(a), len(a)) == a
    within numerical accuracy."""

    a = asarray(a).astype(complex)
    if n == None:
        n = (shape(a)[axis] - 1) * 2
    return _raw_fft(a, n, axis, fftpack.rffti, fftpack.rfftb,
                    _real_fft_cache) / n


def hfft(a, n=None, axis=-1):
    """hfft(a, n=None, axis=-1)
    ihfft(a, n=None, axis=-1)

    These are a pair analogous to rfft/irfft, but for the
    opposite case: here the signal is real in the frequency domain and has
    Hermite symmetry in the time domain. So here it's hermite_fft for which
    you must supply the length of the result if it is to be odd.

    ihfft(hfft(a), len(a)) == a
    within numerical accuracy."""

    a = asarray(a).astype(complex)
    if n == None:
        n = (shape(a)[axis] - 1) * 2
    return irfft(conjugate(a), n, axis) * n


def ihfft(a, n=None, axis=-1):
    """hfft(a, n=None, axis=-1)
    ihfft(a, n=None, axis=-1)

    These are a pair analogous to rfft/irfft, but for the
    opposite case: here the signal is real in the frequency domain and has
    Hermite symmetry in the time domain. So here it's hfft for which
    you must supply the length of the result if it is to be odd.

    ihfft(hfft(a), len(a)) == a
    within numerical accuracy."""

    a = asarray(a).astype(float)
    if n == None:
        n = shape(a)[axis]
    return conjugate(rfft(a, n, axis))/n


def _cook_nd_args(a, s=None, axes=None, invreal=0):
    if s is None:
        shapeless = 1
        if axes == None:
            s = list(a.shape)
        else:
            s = take(a.shape, axes)
    else:
        shapeless = 0
    s = list(s)
    if axes == None:
        axes = range(-len(s), 0)
    if len(s) != len(axes):
        raise ValueError, "Shape and axes have different lengths."
    if invreal and shapeless:
        s[axes[-1]] = (s[axes[-1]] - 1) * 2
    return s, axes


def _raw_fftnd(a, s=None, axes=None, function=fft):
    a = asarray(a)
    s, axes = _cook_nd_args(a, s, axes)
    itl = range(len(axes))
    itl.reverse()
    for ii in itl:
        a = function(a, n=s[ii], axis=axes[ii])
    return a


def fftn(a, s=None, axes=None):
    """fftn(a, s=None, axes=None)

    The n-dimensional fft of a. s is a sequence giving the shape of the input
    an result along the transformed axes, as n for fft. Results are packed
    analogously to fft: the term for zero frequency in all axes is in the
    low-order corner, while the term for the Nyquist frequency in all axes is
    in the middle.

    If neither s nor axes is specified, the transform is taken along all
    axes. If s is specified and axes is not, the last len(s) axes are used.
    If axes are specified and s is not, the input shape along the specified
    axes is used. If s and axes are both specified and are not the same
    length, an exception is raised."""

    return _raw_fftnd(a,s,axes,fft)

def ifftn(a, s=None, axes=None):
    """ifftn(a, s=None, axes=None)

    The inverse of fftn."""

    return _raw_fftnd(a, s, axes, ifft)


def fft2(a, s=None, axes=(-2,-1)):
    """fft2(a, s=None, axes=(-2,-1))

    The 2d fft of a. This is really just fftn with different default
    behavior."""

    return _raw_fftnd(a,s,axes,fft)


def ifft2(a, s=None, axes=(-2,-1)):
    """ifft2(a, s=None, axes=(-2, -1))

    The inverse of fft2d. This is really just ifftn with different
    default behavior."""

    return _raw_fftnd(a, s, axes, ifft)


def rfftn(a, s=None, axes=None):
    """rfftn(a, s=None, axes=None)

    The n-dimensional discrete Fourier transform of a real array a. A real
    transform as rfft is performed along the axis specified by the last
    element of axes, then complex transforms as fft are performed along the
    other axes."""

    a = asarray(a).astype(float)
    s, axes = _cook_nd_args(a, s, axes)
    a = rfft(a, s[-1], axes[-1])
    for ii in range(len(axes)-1):
        a = fft(a, s[ii], axes[ii])
    return a

def rfft2(a, s=None, axes=(-2,-1)):
    """rfft2(a, s=None, axes=(-2,-1))

    The 2d fft of the real valued array a. This is really just rfftn with
    different default behavior."""

    return rfftn(a, s, axes)

def irfftn(a, s=None, axes=None):
    """irfftn(a, s=None, axes=None)

    The inverse of rfftn. The transform implemented in ifft is
    applied along all axes but the last, then the transform implemented in
    irfft is performed along the last axis. As with
    irfft, the length of the result along that axis must be
    specified if it is to be odd."""

    a = asarray(a).astype(complex)
    s, axes = _cook_nd_args(a, s, axes, invreal=1)
    for ii in range(len(axes)-1):
        a = ifft(a, s[ii], axes[ii])
    a = irfft(a, s[-1], axes[-1])
    return a

def irfft2(a, s=None, axes=(-2,-1)):
    """irfft2(a, s=None, axes=(-2, -1))

    The inverse of rfft2. This is really just irfftn with
    different default behavior."""

    return irfftn(a, s, axes)

# Deprecated names
from numpy import deprecate
refft = deprecate(rfft, 'refft', 'rfft')
irefft = deprecate(irfft, 'irefft', 'irfft')
refft2 = deprecate(rfft2, 'refft2', 'rfft2')
irefft2 = deprecate(irfft2, 'irefft2', 'irfft2')
refftn = deprecate(rfftn, 'refftn', 'rfftn')
irefftn = deprecate(irfftn, 'irefftn', 'irfftn')


import numpy as np
from scipy import fftpack


np.random.seed(1234)

time_step = 0.02
freqinp=0.2
period = 1/freqinp

time_vec = np.arange(0, 20, time_step)
sig = np.sin(2 * np.pi / period * time_vec) + \
      0.5 * np.random.randn(time_vec.size)

print 10

sample_freq = fftpack.fftfreq(sig.size, d=time_step)
sig_fft = fftpack.fft(sig)
pidxs = np.where(sample_freq > 0)
freqs, power = sample_freq[pidxs], np.abs(sig_fft)[pidxs]
freq = freqs[power.argmax()]

print freq, 24


from statistics import  *
from math import  *
from fractions import Fraction as F

def fib(n):
   if n == 0 or n == 1:
      return n
   else:
      return fib(n-1) + fib(n-2)
fiblis=[fib(n) for n in range(16)]
print(F(1,2),fiblis,mean(fiblis),stdev(fiblis),pstdev(fiblis)) #
print(stdev(fiblis)*sqrt(F(15,16)))


"""
nary - convert integer to a number with an arbitrary base.
"""

__all__ = ['nary']

_alphabet='0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
def _getalpha(r):
    if r>=len(_alphabet):
        return '_'+nary(r-len(_alphabet),len(_alphabet))
    return _alphabet[r]

def nary(number, base=64):
    """
    Return string representation of a number with a given base.
    """
    if isinstance(number, str):
        number = eval(number)
    n = number
    s = ''
    while n:
        n1 = n // base
        r = n - n1*base
        n = n1
        s = _getalpha(r) + s
    return s

def encode(string):
    import md5
    return nary('0x'+md5.new(string).hexdigest())

#print nary(12345124254252525522512324,64)

import pdb
def combine(s1,s2):      # define subroutine combine, which...
    s3 = s1 + s2 + s1    # sandwiches s2 between copies of s1, ...
    s3 = '"' + s3 +'"'   # encloses it in double quotes,...
    return s3            # and returns it.

a = "aaa"
pdb.set_trace()
b = "bbb"
c = "ccc"
final = combine(a,b)
print final


my_list = [12, 5, 13, 8, 9, 65]
def bubble(bad_list):
    length = len(bad_list) - 1
    sorted = False

    while not sorted:
        sorted = True
        for i in range(length):
            if bad_list[i] > bad_list[i+1]:
                sorted = False
                bad_list[i], bad_list[i+1] = bad_list[i+1], bad_list[i]

bubble(my_list)
print my_list

"""
http://stackoverflow.com/questions/895371/bubble-sort-homework
n <enter>
<enter>
p <variable>
q
c
l
s
r
source http://pythonconquerstheuniverse.wordpress.com/category/python-debugger/
http://www.youtube.com/watch?v=bZZTeKPRSLQ
"""

import Numeric
def foo(a):
    a = Numeric.array(a)
    m,n = a.shape
    for i in range(m):
        for j in range(n):
            a[i,j] = a[i,j] + 10*(i+1) + (j+1)
    return a

#playing with output of https://github.com/animesh/RawRead
import pandas as pd
#df=pd.read_table('/home/animeshs/Documents/RawRead/20150512_BSA_The-PEG-envelope.raw.intensity0.charge0.FFT.txt')#, low_memory=False)
df=pd.read_table('/home/animeshs/Documents/RawRead/20150512_BSA_The-PEG-envelope.raw.profile.intensity0.charge0.MS.txt')
df.describe()
df.hist()
import numpy as np
log2df=np.log2(df)#['intensity'])
log2df.hist()

#check with https://github.com/animesh/ann/blob/master/ann/Program.cs
#Iteration = 1   Error = 0.298371108760003       Outputs = 0.751365069552316     0.772928465321463
#Iteration = 2   Error = 0.291027773693599       Outputs = 0.742088111190782     0.775284968294459
inp=[0.05,0.10]
inpw=[[0.15,0.20],[0.25,0.3]]
hidden=2
hidw=[[0.4,0.45],[0.5,0.55]]
outputc=2
outputr=[0.01,0.99]
bias=[0.35,0.6]
cons=[1,1]
lr=0.5
error=1
itr=1000

#https://github.com/jcjohnson/pytorch-examples/blob/master/README.md  numpy
import numpy as np
x=np.asarray(inp)
y=np.asarray(outputr)
b=np.asarray(bias)
w1=np.asarray(inpw)
w1=w1.T
w2=np.asarray(hidw)
w2=w2.T
print(x,y,b,w1,w2)

h=1/(1+np.exp(-(x.dot(w1)+bias[0])))
y_pred=1/(1+np.exp(-(h.dot(w2)+bias[1])))
0.5*np.square(y_pred - y).sum()

w3=w2-lr*np.outer((y_pred - y)*(1-y_pred)*y_pred,h).T
w2-lr*(y_pred[1] - y[1])*(1-y_pred[1])*y_pred[1]*h[1]
w2-lr*(y_pred[0] - y[0])*(1-y_pred[0])*y_pred[0]*h[0]
w4=w1-lr*sum((y_pred - y)*(1-y_pred)*y_pred*w2)*h*(1-h)*x

h1=1/(1+np.exp(-(x.dot(w4)+b[0])))
y_pred_h1=1/(1+np.exp(-(h1.dot(w3)+b[1])))
0.5*np.square(y_pred_h1 - y).sum()

w3-=lr*(y_pred - y)*(1-y_pred)*y_pred*h
w4=w4-lr*sum(((y_pred - y)*(1-y_pred)*y_pred*w2)*h*(1-h)*x
h1=1/(1+np.exp(-(x.dot(w4)+b[0])))
y_pred_h1=1/(1+np.exp(-(h1.dot(w3)+b[1])))
0.5*np.square(y_pred_h1 - y).sum()


import random
import torch
N=22
scale=10
D_in, H, D_out = N*scale*scale, N*scale*scale, N*scale

class DynamicNet(torch.nn.Module):
    def __init__(self, D_in, H, D_out):
        super(DynamicNet, self).__init__()
        self.input_linear = torch.nn.Linear(D_in, H)
        self.middle_linear = torch.nn.Linear(H, H)
        self.output_linear = torch.nn.Linear(H, D_out)
    def forward(self, x):
        h_relu = self.input_linear(x).clamp(min=0)
        for _ in range(random.randint(0, int(N/scale))):
            h_relu = self.middle_linear(h_relu).clamp(min=0)
        y_pred = self.output_linear(h_relu)
        return y_pred

x = torch.randn(N, D_in)
y = torch.randn(N, D_out)

model = DynamicNet(D_in, H, D_out)

criterion = torch.nn.MSELoss(reduction='sum')
optimizer = torch.optim.SGD(model.parameters(), lr=1e-4, momentum=0.9)


import numpy as np
import dask.array as da
x = da.random.random((100000, 2000), chunks=(10000, 2000))
y = da.from_array(x, chunks=(100))
y.mean().compute()

import time

t0 = time.time()
q, r = da.linalg.qr(x)
test = da.all(da.isclose(x, q.dot(r)))
assert(test.compute()) # compute(get=dask.threaded.get) by default
print(time.time() - t0)
# python -m TBB intelCompilerTest.py

%matplotlib inline
import pandas as pd
import matplotlib.pyplot as plt
plt.hist(np.random.random_sample(10000))

import tensorflow as tf
hello = tf.constant('Hello, TensorFlow!')
sess = tf.Session()
a = tf.constant(12)
b = tf.constant(32)
print(sess.run(a * b))

import sonnet as snt
import tensorflow as tf
snt.resampler(tf.constant([0.]), tf.constant([0.]))

sc.stop()

import findspark
findspark.init()
import pyspark
conf = pyspark.SparkConf()
conf.setAppName("pepXMLtoJSON")
conf.set("spark.executor.memory", "8g").set(
    "spark.executor.cores", "3").set("spark.cores.max", "12")
conf.set("spark.jars.packages", "com.databricks:spark-xml_2.11:0.4.1")
sc = pyspark.SparkContext(conf=conf)
rdd = sc.parallelize(reversed([1, 2, 3, 4]))
rdd.map(lambda s: s**s**s).take(4)

from pyspark.sql import SQLContext
sqlContext = SQLContext(sc)
df = sqlContext.read.format('com.databricks.spark.xml').options(
    rootTag='msms_pipeline_analysis', rowTag='spectrum_query').load('jupyter/b1928_293T_proteinID_08A_QE3_122212.pep.xml')
df.show()
selectedData = df.select("search_result")
selectedData.printSchema
selectedData.collect().take(2)
selectedData = selectedData.toJSON
selectedData.saveAsTextFile(
    "jupyter/b1928_293T_proteinID_08A_QE3_122212.pep.json")

```python
inpF <-"L://Animesh/mouseSILAC/dePepSS1LFQ1/proteinGroups.txt"
data <- read.delim(inpF, row.names = 1, sep = "\t", header = T)
summary(data)
```

import pandas as pd
table = pd.read_excel('L://Animesh/Lymphoma/TrpofSuperSILACpTtestImp.xlsx')
#table = pd.read_excel('/home/animeshs/scripts/vals.xlsx')
%matplotlib inline
import numpy as np
x=np.linspace(0.0, 100.0, num=500)
import matplotlib.pyplot as plt
plt.plot(x,np.sin(x))
x=2*x
plt.show()
table.A0A024QZX5.plot.hist(alpha=0.5)

import sonnet as snt
import tensorflow as tf
snt.resampler(tf.constant([0.]), tf.constant([0.]))

import matplotlib.pyplot as plt
import numpy as np
from pyteomics import fasta, parser, mass, achrom, electrochem, auxiliary
print 'Cleaving the proteins with trypsin...'
unique_peptides = set()
for description, sequence in fasta.read('uniprot-proteome-human.fasta'):
    new_peptides = parser.cleave(sequence, parser.expasy_rules['trypsin'])
    unique_peptides.update(new_peptides)
print('Done, {0} sequences obtained!'.format(len(unique_peptides)))
peptides = [{'sequence': i} for i in unique_peptides]
#peptides = [peptide for peptide in peptides if peptide['length'] <= 100]
unique_peptides
proteins = fasta.read('uniprot-proteome-human.fasta')
proteins.reset


def fragments(peptide, types, maxcharge):
    for i in range(1, len(peptide)):
        for ion_type in types:
            for charge in range(1, maxcharge + 1):
                if ion_type[0] in 'abc':
                    yield mass.fast_mass(
                        peptide[:i], ion_type=ion_type, charge=charge)
                else:
                    yield mass.fast_mass(
                        peptide[i:], ion_type=ion_type, charge=charge)


theor_spectrum = list(fragments('MIGQK', ('b', 'y'), maxcharge=1))
print(theor_spectrum)
import pandas as pd
# massaa => https://en.wikipedia.org/w/index.php?title=Proteinogenic_amino_acid&section=2
aamm = pd.read_table('/home/animeshs/scripts/massaa')
aamm.dtypes
aamm['Mon. Mass§ (Da)']
# https://en.wikipedia.org/wiki/De_novo_peptide_sequencing
mmH2O = 18.01056
mmProton = 1.00728
pep = 'GLSDGEWQQVLNVWGK'
# http://www.ionsource.com/tutorial/DeNovo/b_and_y.htm
# pep='MIGQK'
tMass = 0.0
bIon = 0.0
bIon_list = []
yIon_list = []
pep_list = []
for b in range(0, len(pep)):
    pep_list.append(pep[b])
    tMass = tMass + aamm[aamm['Short'] == pep[b]]['Mon. Mass§ (Da)'].values
    bIon = bIon + aamm[aamm['Short'] == pep[b]]['Mon. Mass§ (Da)'].values[0]
    bIon_list.append(bIon + mmProton)
    yIon = 0.0
    for y in range(b, len(pep)):
        yIon = yIon + aamm[aamm['Short'] ==
                           pep[y]]['Mon. Mass§ (Da)'].values[0]
    yIon_list.append(yIon + mmH2O + mmProton)
print(pep_list, bIon_list, bIon_list, tMass + mmH2O)
import matplotlib.pyplot as plt
plt.stem(yIon_list, bIon_list, 'r')
plt.stem(bIon_list, bIon_list, 'b')
plt.xticks(bIon_list, pep_list)


from pomegranate import *
import numpy as np
import pylab as plt

data = np.concatenate((np.random.randn(250, 1) * 2.75 + 1.25, np.random.randn(500, 1) * 1.2 + 7.85))
np.random.shuffle(data)
data = table['Monoisotopic mass'].values
plt.hist(data, edgecolor='c', color='c', bins=100)
#d = GeneralMixtureModel( [NormalDistribution(2.5, 1), NormalDistribution(8, 1)] )
d = GeneralMixtureModel([aamm['Mon. Mass§ (Da)'].values])
labels = d.predict(data)
print(labels[:5])
print("{} 1 labels, {} 0 labels".format(
    labels.sum(), labels.shape[0] - labels.sum()))
plt.hist(data[labels == 0], edgecolor='r', color='r', bins=20)
plt.hist(data[labels == 1], edgecolor='c', color='c', bins=20)


d.fit(data, verbose=True)

train_data = get_training_data()
test_data = get_test_data()

# Construct the module, providing any configuration necessary.
linear_regression_module = snt.Linear(output_size=FLAGS.output_size)

# Connect the module to some inputs, any number of times.
train_predictions = linear_regression_module(train_data)
test_predictions = linear_regression_module(test_data)

df = pd.DataFrame({
    'Letter': ['a', 'a', 'a', 'b', 'b', 'b', 'c', 'c', 'c'],
    'X': [4, 3, 5, 2, 1, 7, 7, 5, 9],
    'Y': [0, 4, 3, 6, 7, 10, 11, 9, 13],
    'Z': [0.2, 2, 3, 1, 2, 3, 1, 2, 3]
})


df

# wget http://www.unimod.org/modifications_list.php?pagesize=13800
import pandas as pd
table = pd.read_table('/home/animeshs/scripts/unimod')
%matplotlib inline
table['Monoisotopic mass'].plot.hist(alpha=0.6)
table['Average mass'].plot.hist(alpha=0.4)


for i in range(4):
    print(i)


import numpy as np
import tensorflow as tf

from tensorflow.examples.tutorials.mnist import input_data
mnist = input_data.read_data_sets("/tmp/data/", one_hot=True)

Xtr, Ytr = mnist.train.next_batch(5000)  # 5000 for training (nn candidates)
Xte, Yte = mnist.test.next_batch(200)  # 200 for testing

# tf Graph Input
xtr = tf.placeholder("float", [None, 784])
xte = tf.placeholder("float", [784])

# Nearest Neighbor calculation using L1 Distance
# Calculate L1 Distance
distance = tf.reduce_sum(
    tf.abs(tf.add(xtr, tf.negative(xte))), reduction_indices=1)
# Prediction: Get min distance index (Nearest neighbor)
pred = tf.arg_min(distance, 0)

accuracy = 0.

# Initializing the variables
init = tf.global_variables_initializer()

# Launch the graph
with tf.Session() as sess:
    sess.run(init)

    # loop over test data
    for i in range(len(Xte)):
        # Get nearest neighbor
        nn_index = sess.run(pred, feed_dict={xtr: Xtr, xte: Xte[i, :]})
        # Get nearest neighbor class label and compare it to its true label
        print("Test", i, "Prediction:", np.argmax(Ytr[nn_index]),
              "True Class:", np.argmax(Yte[i]))
        # Calculate accuracy
        if np.argmax(Ytr[nn_index]) == np.argmax(Yte[i]):
            accuracy += 1. / len(Xte)
    print("Done!")
    print("Accuracy:", accuracy)
