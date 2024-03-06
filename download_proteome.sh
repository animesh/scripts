#bash download_fasta.sh
#   5192   74865  670432
#   4416   55550  513224
#   4042    8084  117218
#EcolHIsTagsSyn.fasta:>sp|A5A627|TISB_ECOLI Small toxic protein TisB OS=Escherichia coli (strain K12) OX=83333 GN=tisB PE=1 SV=1
#EcolHIsTagsSyn.fasta:>sp|sufA5A627|TISB_ECOLI Small toxic protein TisB OS=Escherichia coli (strain K12) OX=83333 GN=tisB PE=1 SV=1
#EcolHIsTagsSyn.fasta:>sp|preA5A627V2|TISB_ECOLI Small toxic protein TisB OS=Escherichia coli (strain K12) OX=83333 GN=tisB PE=1 SV=1
#EcoliK12-iso-mar24.fasta:>sp|A5A627|TISB_ECOLI Small toxic protein TisB OS=Escherichia coli (strain K12) OX=83333 GN=tisB PE=1 SV=1
#EcolHIsTagsSyn.fasta:>sp|Q1R4J5|ATPL_ECOUT ATP synthase subunit c OS=Escherichia coli (strain UTI89 / UPEC) OX=364106 GN=atpE PE=3 SV=1
#EcolHIsTagsSyn.fasta:>sp|Q1R4J5|ATPL_ECOUT ATP synthase subunit c OS=Escherichia coli (strain UTI89 / UPEC) OX=364106 GN=atpE PE=3 SV=1
#EcoliUTI89-iso-mar24.fasta:>sp|Q1R4J5|ATPL_ECOUT ATP synthase subunit c OS=Escherichia coli (strain UTI89 / UPEC) OX=364106 GN=atpE PE=3 SV=1
#EcolHIsTagsSyn.fasta:>sp|C4ZZ16|ATP6_ECOBW ATP synthase subunit a OS=Escherichia coli (strain K12 / MC4100 / BW2952) OX=595496 GN=atpB PE=3 SV=1
#EcolHIsTagsSyn.fasta:>sp|preC4ZZ16|ATP6_ECOBW ATP synthase subunit a OS=Escherichia coli (strain K12 / MC4100 / BW2952) OX=595496 GN=atpB PE=3 SV=1
#EcolHIsTagsSyn.fasta:>sp|sufC4ZZ16|ATP6_ECOBW ATP synthase subunit a OS=Escherichia coli (strain K12 / MC4100 / BW2952) OX=595496 GN=atpB PE=3 SV=1
#grep "A5A627" promec/promec/HF/Lars/2024/Charlotte_Synnøve/Escherichia\ coli\ \(sp_tr_canonical\ TaxID\=562\).fasta
#cd promec/promec/HF/Lars/2024/Charlotte_Synnøve/
#wget "https://rest.uniprot.org/uniprotkb/stream?compressed=true&format=fasta&query=%28%28proteome%3AUP000001952%29%29" -O EcoliUTI89-iso-mar24.fasta
grep "A5A627" EcoliUTI89-iso-mar24.fasta
#wget "https://rest.uniprot.org/uniprotkb/stream?format=fasta&query=%28%28proteome%3AUP000001952%29%29" -O EcoliUTI89-iso-mar24.fasta
grep "^>" EcoliUTI89-iso-mar24.fasta  | wc
#wget "https://rest.uniprot.org/uniprotkb/stream?format=fasta&includeIsoform=true&query=%28%28proteome%3AUP000000625%29%29" -O EcoliK12-iso-mar24.fasta
grep "^>" EcoliK12-iso-mar24.fasta  | wc
#wget "https://rest.uniprot.org/uniparc/stream?format=fasta&query=%28%28upid%3AUP000001478%29%29" -O EcoliK12MC4100BW2952-iso-mar24.fasta
grep "^>" EcoliK12MC4100BW2952-iso-mar24.fasta  | wc
grep "A5A627" *.fasta
grep "Q1R4J5" *.fasta
grep "C4ZZ16" *.fasta
#but https://www.uniprot.org/uniprotkb/C4ZZ16/entry#sequences is there?
