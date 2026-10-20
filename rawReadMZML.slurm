#!/bin/bash
set -euo pipefail

[ $# -lt 1 ] && { echo "Usage: $0 /path/to/data"; exit 1; }

# Convert input to absolute path to satisfy Apptainer bind requirements
INPUT_DIR=$(realpath "$1")
SIF_IMAGE="./tdf2mzml.sif"

# Pull container image once on the login node ahead of time
if [ ! -f "$SIF_IMAGE" ]; then
    echo "Pulling Apptainer SIF image on login node..."
    apptainer pull "$SIF_IMAGE" docker://mfreitas/tdf2mzml:latest
fi

for d_path in "$INPUT_DIR"/*.d; do
    [ -d "$d_path" ] || continue
    name=$(basename "$d_path" .d)

    sbatch <<EOF
#!/bin/bash
#SBATCH --account=nn9036k 
#SBATCH --job-name=tdf2mzml_${name}
#SBATCH --output=${INPUT_DIR}/${name}_%j.out
#SBATCH --error=${INPUT_DIR}/${name}_%j.err
#SBATCH --time=04:00:00
##SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL

echo "Job started on \$(hostname) at \$(date)"

apptainer exec --bind "${INPUT_DIR}:${INPUT_DIR}" "${SIF_IMAGE}" tdf2mzml -i "${d_path}" -o "${INPUT_DIR}/${name}.mzML"

echo "Job finished at \$(date)"
EOF
done

echo "Submitted jobs for all .d directories found in $INPUT_DIR"