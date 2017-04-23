def hcf(a,b):
	if(b>a):
		a=a^b
		b=a^b
		a=a^b
	print a,b
	while(b>0):
		c=a%b
		a=b
		b=c
	return a
print hcf(1729,13*15*100)