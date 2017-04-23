#!/bin/bash

err(){ 
  echo $*
  exit -1
}

[ -f "$GENOME" ] || err "GENOME=\"$GENOME\" not found"

make -j -f qualeval.mk `echo $* | sed -e 's/.bam/.bam.bai/g'`

for rd in `grep '^>' $GENOME | cut -c2- | cut -f1 -d' '`; do
	mkdir -p plots/$rd
	for f in $*; do
		samtools view $f $rd | cut -f 4,9 > plots/$rd/$f.dat
	done
done

