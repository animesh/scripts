#!/bin/bash
set -e
set -o pipefail

name=Mammals

package=package$name
seqs=sim$name.seqs.tar.gz
annots=sim$name.annots.tar.gz
ancestor=sim$name.ancestor.maf.tar.gz
burnin=sim$name.burnin.maf.tar.gz

curl -O "http://compbio.soe.ucsc.edu/alignathon/{README.txt,data/sim$name.annots.tar.gz,data/sim$name.seqs.tar.gz,data/sim$name.ancestor.maf.tar.gz,data/sim$name.burnin.maf.tar.gz}"
echo "af3a5cc5cef58344dc9136db72b1e572  sim$name.annots.tar.gz
a554a2151b3bbe269c2dcf6e07030ab7  sim$name.seqs.tar.gz
adcfaf0a3334d56fa3268445bad851af  sim$name.ancestor.maf.tar.gz
59851dd154341b30f00670e5d2445804  sim$name.burnin.maf.tar.gz" > md5sum.txt
md5sum --check md5sum.txt
rm md5sum.txt
mkdir -p $package/annotations $package/predictions $package/sequences $package/truths
mv README.txt $package/

mv $seqs $package/sequences
pushd $package/sequences
tar -xvzf $seqs
rm $seqs
popd

mv $annots $package/annotations
pushd $package/annotations
tar -xvzf $annots
rm $annots
popd

mv $ancestor $package/truths
mv $burnin $package/truths
pushd $package/truths
tar -xvzf $ancestor
tar -xvzf $burnin
rm $ancestor $burnin
popd

