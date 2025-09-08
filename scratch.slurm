#!/bin/sh
#SBATCH --account=nn9036k --job-name=RAWDATA
##SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=20
#SBATCH --mem-per-cpu=4G
#SBATCH --time=24:00:00
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=RAWDATA.FP.out
export PATH=$PATH:$PWD
echo "we are running from this directory: $SLURM_SUBMIT_DIR"
echo " the name of the job is: $SLURM_JOB_NAME"
echo "Th job ID is $SLURM_JOB_ID"
echo "The job was run on these nodes: $SLURM_JOB_NODELIST"
echo "Number of nodes: $SLURM_JOB_NUM_NODES"
echo "We are using $SLURM_CPUS_ON_NODE cores"
echo "We are using $SLURM_CPUS_ON_NODE cores per node"
echo "Total of $SLURM_NTASKS cores"
module purge
#cd /cluster/home/ash022/cluster/
#wget "https://release-assets.githubusercontent.com/github-production-release-asset/91836776/f3e24de2-5732-4882-b939-fd49a505a945?sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-09-01T09%3A21%3A28Z&rscd=attachment%3B+filename%3DFragPipe-23.1-linux.zip&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-09-01T08%3A20%3A49Z&ske=2025-09-01T09%3A21%3A28Z&sks=b&skv=2018-11-09&sig=iQFL5AeSDFx8mdmz5VeYPrTtuJVoa0ra4tvrTaHBnoM%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc1NjcxNTk5NSwibmJmIjoxNzU2NzE1Njk1LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.9E-tukHrfmW-CtbmfepcoRORMNy3-rSjWdM9-XmEkBk&response-content-disposition=attachment%3B%20filename%3DFragPipe-23.1-linux.zip&response-content-type=application%2Foctet-stream" -O fp.zip
#unzip fp.zip
#module spider java
module load Java/21.0.2
java --version
module load dotNET-SDK/7.0.408-linux-x64
dotnet --version
conda activate mono
#./fragpipe-23.1/bin/fragpipe
#rm -rf /cluster/home/ash022/.config/FragPipe/
#cat fp.man.txt.fp-manifest
#/cluster/home/ash022/scripts/240827_Bead_test/dda/240827_Beads_3A_Slot2-19_1_8128.d                     DDA
/cluster/home/ash022/cluster/fragpipe-23.1/bin/fragpipe --headless --threads 20 --ram 80 --workflow fp.workflow.txt --manifest RAWDATA.manifest.txt --workdir RAWDATA.FP.result
#diff /cluster/projects/nn9036k/scripts/FPv23p1bead/ptm-shepherd-output/global.modsummary.tsv /cluster/projects/nn9036k/scripts/FPv23p1bead2/ptm-shepherd-output/global.modsummary.tsv
