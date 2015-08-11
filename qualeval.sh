#!/bin/bash

#TEST=-n

# Run various analysis on a genome assembly

error(){
    echo ERROR: "$*"
    exit -1
}

# Configure these:

DATA=/data/genomdata1

# import SFF and Illumina data
ln -s $DATA/LSalSFFfq/*.fq .
ln -s $DATA/LSalAll/inbred*.txt .
ln -s /data/prosjekt/genom/lakselus/Clusters_masked/index.fasta EST.fasta
ln -s /data/genomdata2/LSalFos1/fosmids_{fwd,rev}.fasta .
ln -s /data/genomdata2/CEGMA/cegma-dm.fasta .
ln -s /data/prosjekt/genom/lib/refseq/microbial_all.faa microbial.fasta

# Configure GENOME and ESTS here:

GENOME=nwb16xIIscaf.fasta
EST=EST.fasta

BAC="fosmids_fwd.fasta fosmids_rev.fasta"
PROT="cegma-dm.fasta microbial.fasta"

[ -f $GENOME ] || error "\$GENOME=\"$GENOME\" not found"

# End of configuration

CPUS=`cat /proc/cpuinfo| grep processor | tail -1 | cut -d: -f2 | cut -c2-`
MAKE="make $TEST GENOME=$GENOME -f qualeval.mk -r -j $CPUS --warn-undefined-variables"

[ -z "$GENOME" -o -z "$EST" ] && error "Please configure by setting GENOME and ESTS in run.sh"

BAMS=`ls inbred*.1.txt | grep ".1.txt" | sed -e 's/\.1\.txt/.bam/g'`
FSTATS=`echo $BAMS | sed -e 's/\.bam/.fstat/g'`
STATS=`echo $BAMS | sed -e 's/\.bam/.stats/g'`
BACS=`echo $BAC | sed -e 's/\.fasta/.dna.psl/g'`
ESTS=`echo $EST | sed -e 's/\.fasta/.rna.psl.uniq/g'`
PROTS=`echo $PROT | sed -e 's/\.fasta/.prot.psl.uniq/g'`

$MAKE $GENOME.bwt $BAMS $FSTATS $STATS atcounts $BACS $ESTS $PROTS
$MAKE all.stats all.fstats all.fstat.tab
