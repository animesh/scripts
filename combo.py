import math
combo = { }
for i in range(1,101):
    print "%f" % ( math.fmod (100, i )  )
    for j in range(1,101):
        roll= i+j
        #print "%d" % ( roll )
        combo.setdefault( roll, 0 )
        combo[roll] += 1
for n in range(2,201):
    print "%d %.2f%%" % ( n, combo[n]/math.pi )
