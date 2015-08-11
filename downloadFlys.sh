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
