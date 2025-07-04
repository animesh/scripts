import statsmodels.api as sm


fig, ax = plt.subplots(figsize=(12, 4))
fig.gca().spines["top"].set_color("lightgray")
fig.gca().spines["right"].set_color("lightgray")
sm.graphics.tsa.plot_acf(
    dfc["count"], lags=2*60, ax=ax, title="Autocorellation Function"
)
plt.ylim(-0.1, 1.1)
fig.show()

from NeuroPy import NeuroPy
#import winsound 		 
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from pyo import *
s = Server().boot()

npo=NeuroPy('/dev/rfcomm0',57600)

npo.start()
def npacb(sigval):
    print sigval
    return None

#npo.setCallBack("rawValue",npacb)
npo.setCallBack("attention",npacb)

freqeeg = 512

def crtfrearray(feeg):
    eegcoll = []
    cnteeg=0
    while cnteeg<feeg:
        eegcoll.append(npo.rawValue)
        cnteeg+=1
    freqs = np.fft.fftfreq(len(eegcoll))
    idx=np.argmax(np.abs(np.array(eegcoll))**2)
    freq=freqs[idx]
    freqhz=abs(freq*freqeeg)
    if freqhz>40 and freqhz<freqeeg:
        print freqhz
	#a = Sine(int(freqhz)*10, 0, 0.1).out()
	#a.setFreq(int(freqhz))
        #winsound.Beep(int(freqhz),int(freqhz))
    return eegcoll

#x = np.arange(0, 2*np.pi, 0.01)
#y = np.sin(x)
x=np.arange(0,freqeeg,1)
y=np.array(crtfrearray(freqeeg))
a = Sine(440, 0, 0.1).out()
s.start()
#s.gui(locals())

fig, axes = plt.subplots(nrows=2)

styles = ['r-', 'k-']
def plot(ax, style):
    return ax.plot(x, y, style, animated=True)[0]
lines = [plot(ax, style) for ax, style in zip(axes, styles)]

def animate(i):
    for j, line in enumerate(lines, start=1):
        line.set_ydata(np.fft.fft(np.array(crtfrearray(freqeeg)))*j)
	a = Sine(int(np.median(np.fft.fft(np.array(crtfrearray(freqeeg))))+10)*100, 0, 0.1).out()
	#line.set_ydata((y)*j+i/10)
    return lines


ani = animation.FuncAnimation(fig, animate, xrange(1, freqeeg), interval=1, blit=True)
plt.show()

#source
#c:\Python27\pythonw.exe c:\Users\animeshs\misccb\neuroplay.py
#http://stackoverflow.com/questions/3694918/how-to-extract-frequency-associated-with-fft-values-in-python
#http://stackoverflow.com/questions/8955869/why-is-plotting-with-matplotlib-so-slow
#http://askubuntu.com/a/252235
#sudo mv /etc/bluetooth/rfcomm.conf /etc/bluetooth/rfcomm.conf.temp
#sudo vim /etc/bluetooth/rfcomm.conf
#rfcomm0 {
#        bind no;
#        device 9C:B7:0D:89:E5:88;
#        channel 1;
#        comment "Serial Port";
#        }
#sudo rfcomm connect 0
    
