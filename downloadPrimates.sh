#!/bin/bash
set -e
set -o pipefail

name=Primates

package=package$name
seqs=sim$name.seqs.tar.gz
annots=sim$name.annots.tar.gz
ancestor=sim$name.ancestor.maf.tar.gz
burnin=sim$name.burnin.maf.tar.gz

curl -O "http://compbio.soe.ucsc.edu/alignathon/{README.txt,data/sim$name.annots.tar.gz,data/sim$name.seqs.tar.gz,data/sim$name.ancestor.maf.tar.gz,data/sim$name.burnin.maf.tar.gz}"
echo "7d337b5e4f7c6eeb8eeeda95c2c21271  sim$name.annots.tar.gz
d817e8739c10a0ddfcbe37200545b7f9  sim$name.seqs.tar.gz
71038100cd6bee1900d140174b80a96e  sim$name.ancestor.maf.tar.gz
eb814de4287ed186927b2ee4fcbcfc02  sim$name.burnin.maf.tar.gz" > md5sum.txt
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

