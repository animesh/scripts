#!/bin/sh
#SBATCH --account=nn9036k --job-name=MQSLURMNAME
#SBATCH --time=160:00:00
#SBATCH --ntasks=1 --cpus-per-task=20
#SBATCH --mem-per-cpu=4G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=MQSLURMLOG

WORKDIR=MQWD
cd ${WORKDIR}
export PATH=$PATH:$PWD
echo "we are running from this directory: $SLURM_SUBMIT_DIR"
echo " the name of the job is: $SLURM_JOB_NAME"
echo "Th job ID is $SLURM_JOB_ID"
echo "The job was run on these nodes: $SLURM_JOB_NODELIST"
echo "Number of nodes: $SLURM_JOB_NUM_NODES"
echo "We are using $SLURM_CPUS_ON_NODE cores"
echo "We are using $SLURM_CPUS_ON_NODE cores per node"
echo "Total of $SLURM_NTASKS cores"
export LMOD_DISABLE_SAME_NAME_AUTOSWAP=no
module load Boost/1.83.0-GCC-13.2.0
/cluster/projects/nn9036k/dotnet80303/dotnet --version
/cluster/projects/nn9036k/dotnet80303/dotnet MQCMD MQPARF
#wget "https://maxquant.org/p/maxquant/MaxQuant_v2.6.5.0.zip?md5=uRZ4Ewa19iwWbyF6VQ1fAg&expires=1729602702"
#unzip MaxQuant_v2.6.5.0.zip\?md5\=uRZ4Ewa19iwWbyF6VQ1fAg\&expires\=1729602702
#mv MaxQuant_v2.6.5.0 /cluster/projects/nn9036k/.
#rsync -Parv login.nird-lmd.sigma2.no:PD/TIMSTOF/LARS/2024/241002_zrimac/mqpar.xml mqparTTP.phoSTY.xml
#mkdir phoSTY
#mkdir phoSTY/dda
#rsync -Parv login.nird-lmd.sigma2.no:PD/TIMSTOF/LARS/2024/241002_zrimac/*dda*d phoSTY/dda/
#vim mqparTTPdda.xml
#vim mqparTTPdia.xml
#bash slurmMQrunTTP.sh /cluster/projects/nn9036k/MaxQuant_v2.6.3.0/bin/MaxQuantCmd.dll phoSTY/dda /cluster/projects/nn9036k/FastaDB/uniprotkb_proteome_UP000005640_2024_04_18.fasta mqparTTPdda.xml scratch.slurm
#mkdir phoSTY/dia
#rsync -Parv login.nird-lmd.sigma2.no:PD/TIMSTOF/LARS/2024/241002_zrimac/*dia*d phoSTY/dia/
#bash slurmMQrunTTP.sh /cluster/projects/nn9036k/MaxQuant_v2.6.5.0/bin/MaxQuantCmd.dll phoSTY/dia /cluster/projects/nn9036k/FastaDB/uniprotkb_proteome_UP000005640_2024_04_18.fasta mqparTTPdia.xml scratch.slurm

