#wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/009/914/755/GCF_009914755.1_T2T-CHM13v2.0/GCF_009914755.1_T2T-CHM13v2.0_genomic.gtf.gz
#wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/009/914/755/GCF_009914755.1_T2T-CHM13v2.0/GCF_009914755.1_T2T-CHM13v2.0_genomic.fna.gz
#gunzip GCF_009914755.1_T2T-CHM13v2.0_genomic.gtf.gz GCF_009914755.1_T2T-CHM13v2.0_genomic.fna.gz
module load STAR/2.7.10b-GCC-11.3.0
STAR --runThreadN 40 \
	--runMode genomeGenerate \
	--genomeDir index_len150 \
	--genomeFastaFiles GCF_009914755.1_T2T-CHM13v2.0_genomic.fna \
	--sjdbGTFfile GCF_009914755.1_T2T-CHM13v2.0_genomic.gtf \
	--sjdbOverhang 149

