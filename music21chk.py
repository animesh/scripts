from music21 import *
import random
keyDetune = []
for i in range(0, 127):
    keyDetune.append(random.randint(-30, 30))

sBach = corpus.parse('bach/bwv7.7')
sBach.show('text')
sBach[0].show('text')


#svn checkout http://music21.googlecode.com/svn/trunk/ music21-read-only