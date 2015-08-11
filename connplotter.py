import pylab as cpy
import ConnPlotter as c
import ConnPlotter.examples as cex
sl,sc,sm=cex.simple()
print sl
scp=c.ConnectionPattern(sl,sc)
scp.plot()
cpy.show()
