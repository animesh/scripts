import pygame, numpy
pygame.mixer.pre_init(frequency=96000,size=-16,channels=1)
pygame.init()
a = numpy.random.randn(96000*128)
a = a.astype(numpy.int16)
sound = pygame.sndarray.make_sound(a)
print sound.get_length()
ca = sound.play()
while ca.get_busy():
   pygame.time.delay(1)
