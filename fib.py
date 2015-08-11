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
