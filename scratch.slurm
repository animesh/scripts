#!/bin/sh
#SBATCH --account=nn9036k --job-name=bitpep
#SBATCH --partition=bigmem
#SBATCH --time=48:00:00
#SBATCH --ntasks=1 --cpus-per-task=32
#SBATCH --mem-per-cpu=32G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=bitpepLOG
WORKDIR=$PWD
cd ${WORKDIR}
echo "we are running from this directory: $SLURM_SUBMIT_DIR"
echo " the name of the job is: $SLURM_JOB_NAME"
echo "Th job ID is $SLURM_JOB_ID"
echo "The job was run on these nodes: $SLURM_JOB_NODELIST"
echo "Number of nodes: $SLURM_JOB_NUM_NODES"
echo "We are using $SLURM_CPUS_ON_NODE cores"
echo "We are using $SLURM_CPUS_ON_NODE cores per node"
echo "Total of $SLURM_NTASKS cores"
#git clone http://github.com/animesh/bit-pep
cd /cluster/home/ash022/scripts/bit-pep
#mkdir /cluster/projects/nn9036k/.cargo
#ln -s /cluster/projects/nn9036k/.cargo /cluster/home/ash022/.cargo
#curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
#/cluster/projects/nn9036k/.cargo/bin/cargo build --release
#wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz
#wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_trembl.fasta.gz
#gunzip *.gz
#ls -ltrh *.fasta
#cat uniprot_sprot.fasta >>  uniprot_trembl.fasta
#ls -ltrh *.fasta
#grep "^>" uniprot_trembl.fasta | wc #150006383 1613357187 19023878916
#tail *.fasta
#cp  /nird/datapeak/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2026/260729_Orivio/260909/combined/txt/peptides.txt .
/cluster/projects/nn9036k/.cargo/bin/cargo run --bin bit-pep -- run-prot uniprot_trembl.fasta -p peptides.txt -j 64 -m 1000
#perl /cluster/home/ash022/scripts/pep2protmap.pl /cluster/home/ash022/scripts/bit-pep/uniprot_trembl.fasta /cluster/home/ash022/scripts/bit-pep/peptides.txt 1 > /cluster/home/ash022/scripts/bit-pep/peptides.mapped.txt