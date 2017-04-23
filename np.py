from NeuroPy import NeuroPy
#from pyeeg import *
#import pyglet
npo=NeuroPy('/dev/ttyS25')
eegcoll = []

def npacb(attention_value):
	print attention_value
	return None

npo.setCallBack("attention",npacb)

npo.start()

i=1
while i<100:
	eegcoll.append(npo.rawValue)
	if(npo.meditation>50): 
		print npo.meditation, npo.rawValue,  npo.blinkStrength, npo.poorSignal, npo.midGamma, npo.lowGamma, npo.highBeta, npo.lowBeta, npo.highAlpha, npo.lowAlpha, npo.theta, npo.delta
		i+=1
		#song = pyglet.media.load('../SkyDrive/musicmix/18 - unknown 18 - Track 18 (1).ogg')
		#song.play()
		#pyglet.app.run()

#print hurst(eegcoll[:])


#source libs
#sudo apt-get install python-csoundac
#git clone git://github.com/shimpe/canon-generator
#wget http://web.mit.edu/music21/blank.xml
#sudo apt-get install python-pyaudio
#sudo apt-get install lilypond
#sudo apt-get install musescore
#sudo apt-get install python-matplotlib
#sudo apt-get install python-pygame
#git clone https://code.google.com/p/pyeeg/
#easy_install pyglet
#git clone git://github.com/lihas/NeuroPy
#https://raw.github.com/devsnd/matrix-curses/master/matrix-curses.py
#http://www.coderedux.com/music-theory/circle-of-fifths-part-one
