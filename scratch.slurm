#!/bin/sh
#SBATCH --account=nn9036k --job-name=resultsTKvep
#SBATCH --time=8:00:00
##SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=20
#SBATCH --mem-per-cpu=8G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=resultsTKvep.log
WORKDIR=$PWD
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
module load parallel/20250922-GCCcore-14.3.0
export LOCAL_DIR="/cluster/projects/nn9036k/TK/sra/fastq"
export WORK_DIR="/cluster/work/users/ash022/work"

compare_file() {
  filepath="$1"
  fname=$(basename "$filepath")

  for match in $(ls -l "$WORK_DIR"/*/*/"$fname" 2>/dev/null | grep -v "^l" | awk '{print $NF}'); do
    if [ -f "$match" ]; then
      echo "=================================================="
      echo "Local file: $filepath"
      echo "Work  file: $match"
      echo "--------------------------------------------------"
      
      c_local=$(zcat "$filepath" | wc -l | awk '{print $1/4}')
      c_work=$(zcat "$match" | wc -l | awk '{print $1/4}')
      echo "Read counts -> Local: $c_local | Work: $c_work"

      if cmp -s <(zcat "$filepath" | sed -n '2~4p') <(zcat "$match" | sed -n '2~4p'); then
        echo "Status: Sequences are IDENTICAL"
      else
        echo "Status: Sequences DIVERGE"
        echo "First sequence difference:"
        diff -u <(zcat "$filepath" | sed -n '2~4p') <(zcat "$match" | sed -n '2~4p') | head -n 10
      fi
      echo ""
    fi
  done
}

export -f compare_file

# Adjust -j (jobs) based on available CPU/IO limits
parallel -k -j 20 compare_file ::: "$LOCAL_DIR"/SRR*.fastq.gz 2>&1 | tee compare_sequences.log
#TK18,SRR31089070,/cluster/projects/nn9036k/TK/sra/fastq/SRR31089070_1.fastq.gz,/cluster/projects/nn9036k/TK/sra/fastq/SRR31089070_2.fastq.gz,NA
#TK16,SRR31089071,/cluster/projects/nn9036k/TK/sra/fastq/SRR31089071_1.fastq.gz,/cluster/projects/nn9036k/TK/sra/fastq/SRR31089071_2.fastq.gz,NA
#TK14,SRR31089072,/cluster/projects/nn9036k/TK/sra/fastq/SRR31089072_1.fastq.gz,/cluster/projects/nn9036k/TK/sra/fastq/SRR31089072_2.fastq.gz,NA
#TK13,SRR31089073,/cluster/projects/nn9036k/TK/sra/fastq/SRR31089073_1.fastq.gz,/cluster/projects/nn9036k/TK/sra/fastq/SRR31089073_2.fastq.gz,NA
#TK12,SRR31089074,/cluster/projects/nn9036k/TK/sra/fastq/SRR31089074_1.fastq.gz,/cluster/projects/nn9036k/TK/sra/fastq/SRR31089074_2.fastq.gz,NA
#TK10,SRR31089075,/cluster/projects/nn9036k/TK/sra/fastq/SRR31089075_1.fastq.gz,/cluster/projects/nn9036k/TK/sra/fastq/SRR31089075_2.fastq.gz,NA
#TK9,SRR31089076,/cluster/projects/nn9036k/TK/sra/fastq/SRR31089076_1.fastq.gz,/cluster/projects/nn9036k/TK/sra/fastq/SRR31089076_2.fastq.gz,NA
#cd /cluster/projects/nn9036k/TK/sra/fastq 
#dos2unix scratch.slurm /cluster/projects/nn9036k/TK/sra/fastq/samples.csv
#sbatch scratch.slurm  
#tail -f resultsTKvep.log
#cat compare_sequences.log 
#==================================================
#Local file: /cluster/projects/nn9036k/TK/sra/fastq/SRR31089072_1.fastq.gz
#Work  file: /cluster/work/users/ash022/work/5c/26f30888ef82ed00b8e528cf145b83/SRR31089072_1.fastq.gz
#--------------------------------------------------
#Read counts -> Local: 79039664 | Work: 79039664
#Status: Sequences are IDENTICAL
#
#==================================================
#Local file: /cluster/projects/nn9036k/TK/sra/fastq/SRR31089072_2.fastq.gz
#Work  file: /cluster/work/users/ash022/work/5c/26f30888ef82ed00b8e528cf145b83/SRR31089072_2.fastq.gz
#--------------------------------------------------
#Read counts -> Local: 79039664 | Work: 79039664
#Status: Sequences are IDENTICAL
#
#==================================================
#Local file: /cluster/projects/nn9036k/TK/sra/fastq/SRR31089073_1.fastq.gz
#Work  file: /cluster/work/users/ash022/work/2a/0b09fb80afdeddb63479c841be4acd/SRR31089073_1.fastq.gz
#--------------------------------------------------
#Read counts -> Local: 87082496 | Work: 87082496
#Status: Sequences are IDENTICAL
#
#==================================================
#Local file: /cluster/projects/nn9036k/TK/sra/fastq/SRR31089073_2.fastq.gz
#Work  file: /cluster/work/users/ash022/work/2a/0b09fb80afdeddb63479c841be4acd/SRR31089073_2.fastq.gz
#--------------------------------------------------
#Read counts -> Local: 87082496 | Work: 87082496
#Status: Sequences are IDENTICAL
#
#==================================================
#Local file: /cluster/projects/nn9036k/TK/sra/fastq/SRR31089074_1.fastq.gz
#Work  file: /cluster/work/users/ash022/work/6d/f85587b387c9b53cb4fdaa4938ad71/SRR31089074_1.fastq.gz
#--------------------------------------------------
#Read counts -> Local: 64016952 | Work: 64016952
#Status: Sequences are IDENTICAL
#
#==================================================
#Local file: /cluster/projects/nn9036k/TK/sra/fastq/SRR31089074_2.fastq.gz
#Work  file: /cluster/work/users/ash022/work/6d/f85587b387c9b53cb4fdaa4938ad71/SRR31089074_2.fastq.gz
#--------------------------------------------------
#Read counts -> Local: 64016952 | Work: 64016952
#Status: Sequences are IDENTICAL

