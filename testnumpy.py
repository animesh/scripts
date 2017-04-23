import numpy
A = numpy.zeros(10, dtype=numpy.complex128)
eps1 = numpy.complex128([12.0 + 0.1j])
eps2 = numpy.complex128([1.0 + 0.1j])
print type(eps1), eps1
print type(eps2), eps2
print A.dtype
A[0] = A[0] + (eps1 - eps2)[0]

