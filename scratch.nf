#/cluster/home/ash022/bin/nextflow
nextflow run nf-core/quantms -r dev -profile test --input project.sdrf.tsv --database protein.fasta
#nextflow run nf-core/xxx -profile test,docker
process perlStuff {
"""
    #!/usr/bin/env perl

    print 'Hi there!' . '\n';
"""}

process pyStuff {
"""
    #!/usr/bin/env python

    x = 'Hello'
    y = 'world!'
    print "%s - %s" % (x,y)
"""}
