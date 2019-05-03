#!/bin/bash
set -e
set -o pipefail
curl -O "http://compbio.soe.ucsc.edu/alignathon/{README.txt,data/flys.fa.tar.gz}"
echo -e "ccf6eebe6f899efae70e4018c06daa1f  flys.fa.tar.gz" > md5sum.txt
md5sum --check md5sum.txt
rm md5sum.txt
mkdir -p packageFlys/annotations packageFlys/predictions packageFlys/sequences packageFlys/truths
mv README.txt packageFlys/
mv flys.fa.tar.gz packageFlys/sequences
pushd packageFlys/sequences
tar -xvzf flys.fa.tar.gz
rm flys.fa.tar.gz
popd


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

