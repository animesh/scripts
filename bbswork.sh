#!/bin/sh

prefix=/home/animesh/export/nest2.1.9349pre/neuron/nrn
exec_prefix=/home/animesh/export/nest2.1.9349pre/neuron/nrn/x86_64
NRNBIN=${exec_prefix}/bin
ARCH=x86_64
NEURONHOME=/home/animesh/export/nest2.1.9349pre/neuron/nrn/share/nrn

cd $1

if [ -x ${ARCH}/special ] ; then
	program="./${ARCH}/special"
else
	program="${NRNBIN}/nrniv"
fi

hostname
pwd
shift
shift
echo "time $program $*"
time $program $*

