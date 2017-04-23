import pygame, time, random, Numeric, pygame, pygame.sndarray
sample_rate = 44100

def sine_array_onecycle(hz, peak):
  #Compute one cycle of an N-Hz sine wave with given peak amplitude
  length = sample_rate / float(hz)
  omega = Numeric.pi * 2 / length
  xvalues = Numeric.arange(int(length)) * omega
  return (peak * Numeric.sin(xvalues)).astype(Numeric.Int16)

def sine_array(hz, peak, n_samples = sample_rate):
  #Compute N samples of a sine wave with given frequency and peak amplitude (defaults to one second).

  return Numeric.resize(sine_array_onecycle(hz, peak), (n_samples,))

def waves(*chord):
  #Compute the harmonic series for a vector of frequencies
  #Create square-like waves by adding odd-numbered overtones for each fundamental tone in the chord
  #the amplitudes of the overtones are inverse to their frequencies.
  h=9
  ot=3
  harmonic=sine_array(chord[0],4096)
  while (ot<h):
        if (ot*chord[0])<(sample_rate/2):
            harmonic=harmonic+(sine_array(chord[0]*ot, 4096/(2*ot)))
        else: 
            harmonic=harmonic+0
            ot+=2
  for i in range(1,len(chord)):
    harmonic+=(sine_array(chord[i], 4096))
  
    
    if (ot*chord[i])<(sample_rate/2):
      harmonic=harmonic+(sine_array(chord[i]*ot, 4096/(2*ot)))
    else: 
      harmonic=harmonic+0
    ot+=2    
  return harmonic

def play_for(sample_array, ms):
  #Play the sample array as a sound for N ms.
  pygame.mixer.pre_init(sample_rate, -16, 1) # 44.1kHz, 16-bit signed, mono
  pygame.init()
  sound = pygame.sndarray.make_sound(sample_array)
  sound.play(-1)
  pygame.time.delay(ms)
  sound.stop()

def main():
  #Play a single sine wave, followed by a chord with overtones.
  
  pygame.mixer.pre_init(sample_rate, -16, 1) # 44.1kHz, 16-bit signed, mono
  pygame.init()
  play_for(sine_array(440, 4096), 2500)
  play_for(waves(440,550,660,770,880), 5000)


if __name__ == '__main__': main()

