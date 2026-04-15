#!/bin/sh
#SBATCH --account=nn9036k --job-name=LMppm15DIAsteven
##SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=10
#SBATCH --mem-per-cpu=8G
#SBATCH --time=96:00:00
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=LMppm15DIAsteven.log
#wget "https://release-assets.githubusercontent.com/github-production-release-asset/125283280/c0bccb38-eaa1-4ffc-b752-bb9f361df10e?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-04-14T09%3A29%3A27Z&rscd=attachment%3B+filename%3DDIA-NN-2.5.0-Academia-Linux.zip&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-04-14T08%3A28%3A54Z&ske=2026-04-14T09%3A29%3A27Z&sks=b&skv=2018-11-09&sig=YtZ8jai1sTb1IP62AqWjnXIyF7XSQ%2FPFZrknDv34PDU%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc3NjE1ODk2MSwibmJmIjoxNzc2MTU1MzYxLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.fs2C_SJgzZyZazFqJW16GKH0RQVboLPU7xJ8R9H4BgY&response-content-disposition=attachment%3B%20filename%3DDIA-NN-2.5.0-Academia-Linux.zip&response-content-type=application%2Foctet-stream" -O DIANNv2p5.zip
# sha256sum DIANNv2p5.zip #https://github.com/vdemichev/DiaNN/releases/tag/2.0 05268fb6c778471beb46583400c862529b8ee452a620bb8bfdc8e9cc42eaf695
# unzip DIANNv2p5.zip 
#cp /cluster/projects/nn9036k/diann-2.3.2/camprotR_240512_cRAP_20190401_full_tags.fasta  /cluster/home/ash022/cluster/diann-2.5.0
#rsync -Parv TIMSTOF/LARS/2026/260408_Steven/*.d steven2/
#diann.exe --lib  --threads 12 --verbose 3 --out  --qvalue 0.01 --matrices --out-lib L:\promec\TIMSTOF\LARS\2026\260408_Steven\libV2p5mc2v3dNQ.parquet --gen-spec-lib --predictor --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta L:\promec\TIMSTOF\LARS\2026\260408_Steven\uniprotkb_proteome_UP000006548_2026_04_13.fasta --fasta-search --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 2 --max-pr-charge 4 --min-fr-mz 200 --max-fr-mz 1800 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --rt-profiling --original-mods
#rsync -Parv TIMSTOF/LARS/2026/260408_Steven/libV2p5mc2v3dNQ.predicted.speclib steven2/
#rsync -Parv TIMSTOF/LARS/2026/260408_Steven/*.fasta steven2/
cd /cluster/home/ash022/cluster/diann-2.5.0
#chmod 755 diann-linux
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
module load GCCcore/14.3.0
./diann-linux --f /cluster/home/ash022/scripts/steven2/260408_Steven_1_Slot1-1_1_13417.d --f /cluster/home/ash022/scripts/steven2/260408_Steven_10_Slot1-10_1_13426.d --f /cluster/home/ash022/scripts/steven2/260408_Steven_11_Slot1-11_1_13430.d --f /cluster/home/ash022/scripts/steven2/260408_Steven_12_Slot1-12_1_13431.d --f /cluster/home/ash022/scripts/steven2/260408_Steven_13_Slot1-13_1_13432.d --f /cluster/home/ash022/scripts/steven2/260408_Steven_14_Slot1-14_1_13433.d --f /cluster/home/ash022/scripts/steven2/260408_Steven_15_Slot1-15_1_13434.d --f /cluster/home/ash022/scripts/steven2/260408_Steven_16_Slot1-16_1_13435.d --f /cluster/home/ash022/scripts/steven2/260408_Steven_17_Slot1-17_1_13436.d --f /cluster/home/ash022/scripts/steven2/260408_Steven_18_Slot1-18_1_13437.d --f /cluster/home/ash022/scripts/steven2/260408_Steven_19_Slot1-19_1_13438.d --f /cluster/home/ash022/scripts/steven2/260408_Steven_2_Slot1-2_1_13418.d --f /cluster/home/ash022/scripts/steven2/260408_Steven_20_Slot1-20_1_13439.d --f /cluster/home/ash022/scripts/steven2/260408_Steven_21_Slot1-21_1_13440.d --f /cluster/home/ash022/scripts/steven2/260408_Steven_3_Slot1-3_1_13419.d --f /cluster/home/ash022/scripts/steven2/260408_Steven_4_Slot1-4_1_13420.d --f /cluster/home/ash022/scripts/steven2/260408_Steven_5_Slot1-5_1_13421.d --f /cluster/home/ash022/scripts/steven2/260408_Steven_6_Slot1-6_1_13422.d --f /cluster/home/ash022/scripts/steven2/260408_Steven_7_Slot1-7_1_13423.d --f /cluster/home/ash022/scripts/steven2/260408_Steven_8_Slot1-8_1_13424.d --f /cluster/home/ash022/scripts/steven2/260408_Steven_9_Slot1-9_1_13425.d --lib /cluster/home/ash022/scripts/steven2/libV2p5mc2v3dNQ.predicted.speclib --threads 20 --verbose 1 --out /cluster/home/ash022/scripts/steven2/report.use-quant.parquet --qvalue 0.01 --matrices --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta /cluster/home/ash022/scripts/steven2/uniprotkb_proteome_UP000006548_2026_04_13.fasta --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 2 --max-pr-charge 4 --min-fr-mz 200 --max-fr-mz 1800 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --mass-acc 15 --mass-acc-ms1 15 --use-quant --reanalyse --rt-profiling --original-mods
#dos2unix scratch.slurm
#tail -f BMppm15DIAmix.log 


