#dos2unix scratch.slurm  slurmDIANN.sh
#bash slurmDIANN.sh /cluster/projects/nn9036k/scrbkup/paola
#scancel $(squeue -u "$USER" -h -o "%i")
#!/bin/bash

DATADIR=${1:-"/cluster/projects/nn9036k/scrbkup/paola"}
SEARCHTEXT="TestFile.d"
CURRENTEPOCTIME=$(date +%s)
WRITEFILE="$CURRENTEPOCTIME.report"

echo "$WRITEFILE"

for i in "$DATADIR"/*.d; do 
  [ -d "$i" ] || continue
  echo "$i"
  sed "s|$SEARCHTEXT|$i|g" scratch.slurm > "$i.$WRITEFILE.tmp"
  sed "s|WRITEFILE|$WRITEFILE|g" "$i.$WRITEFILE.tmp" > "$i.$WRITEFILE.slurm"
  sbatch "$i.$WRITEFILE.slurm" /cluster/projects/nn9036k/diann-2.7.0 UP000005640_9606.fasta "$DATADIR"
  rm -f "$i.$WRITEFILE.tmp"
done

echo "$WRITEFILE"
ls -ltrh "$DATADIR"/*"$WRITEFILE.slurm"
squeue -u "$USER"


