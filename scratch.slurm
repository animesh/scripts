#!/bin/sh
#SBATCH --account=nn9036k --job-name=spritzTK
##SBATCH --partition=bigmem
#SBATCH --time=160:00:00
#SBATCH --ntasks=1 --cpus-per-task=20
#SBATCH --mem-per-cpu=8G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=spritzTKlog.%j 
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
#export LMOD_DISABLE_SAME_NAME_AUTOSWAP=no
module load GCCcore/14.3.0
#/cluster/projects/nn9036k/dotnet80303/dotnet 
module load dotNET-Core/8.0.411
dotnet --version
#docker run --rm -it --user=root --name spritz-1789281049 -v "F:\spritz:/app/spritz/results/" -v "F:\resources:/app/spritz/resources" smithlab/spritz:0.3.14 conda run --no-capture-output --live-stream dotnet SpritzCMD.dll --threads 8 --analysisDirectory=/app/spritz/results/ --reference="release-97,homo_sapiens,human,GRCh38" --analyzeVariants --analyzeIsoforms --doQuantification --sraAccessionPairedEnd=SRR31089074,SRR31089073,SRR31089072
#apptainer registry login -u animesh docker://ghcr.io
#Password / Token: 
#INFO:    Token stored in /cluster/home/ash022/.docker/config.json
#INFO:    Token stored in /cluster/home/ash022/.apptainer/remote.yaml
#wget https://github.com/smith-chem-wisc/Spritz/releases/download/0.3.14/SpritzCMD.zip
#unzip SpritzCMD.zip -d spritz_cli
#cd /cluster/home/ash022/scripts/Spritz/spritz_cli/Spritz/SpritzCMD/bin/x64/Release/net10.0
#conda install -c conda-forge dotnet-runtime -y
#dotnet SpritzCMD.dll   -a=$WORK/spritz-analysis   -r="release-116,homo_sapiens,human,GRCh38"   -s=SRR629563
mkdir -p Spritz resources && apptainer exec -e --writable-tmpfs --pwd /app/spritz \
  --env XDG_CACHE_HOME=/app/spritz/results/.cache \
  --env CONDA_PKGS_DIRS=/app/spritz/results/.conda_pkgs \
  --env SNAKEMAKE_CONDA_PREFIX=/app/spritz/results/.snakemake_conda \
  -B "$PWD/Spritz:/app/spritz/results/" \
  -B "$PWD/resources:/app/spritz/resources" \
  docker://smithlab/spritz:0.3.14 \
  /opt/conda/bin/conda run --no-capture-output --live-stream dotnet SpritzCMD.dll \
  --threads 20 \
  --analysisDirectory=/app/spritz/results/ \
  --reference="release-97,homo_sapiens,human,GRCh38" \
  --analyzeVariants --analyzeIsoforms --doQuantification \
  --sraAccessionPairedEnd=SRR31089074,SRR31089073,SRR31089072
  