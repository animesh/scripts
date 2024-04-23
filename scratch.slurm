#!/bin/sh
#SBATCH --account=nn9036k --job-name=testMQ
#SBATCH --time=94:00:00
##SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=20
#SBATCH --mem-per-cpu=4G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=testLog
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
module purge
module --ignore-cache load MaxQuant/2.5.2.0 
dotnet --version
#maxquantcmd -c mqpar.tmp.xml
#maxquantcmd -n mqpar.tmp.xml
#wget https://github.com/animesh/RawRead/raw/master/171010_Ip_Hela_ugi.raw
#wget "https://datashare.biochem.mpg.de/s/qe1IqcKbz2j2Ruf/download?path=%2FDiscoveryLibraries&files=homo_sapiens.zip" -O MQ_DIA.zip
#unzip MQ_DIA.zip
#sed "s?example.fasta?$PWD/UP000005640_9606.fasta?" mqpar.tmp.xml  > mqpar.tmp2.xml
#sed "s?file.example.RAW?$PWD/171010_Ip_Hela_ugi.raw?" mqpar.tmp2.xml  > mqpar.tmp.xml
maxquantcmd mqpar.tmp.xml
