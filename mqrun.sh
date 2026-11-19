#!/bin/bash
# Usage:
#   bash mqrun.sh <MaxQuantCmd.dll> <raw_dir/> <param_xml_in_cwd> <cpus_per_job> <fdr> <outdir>
#curl -s --list-only --ftp-ssl-reqd --user "anonymous:user@example.com" "ftp://massive-ftp.ucsd.edu/v07/MSV000094602/raw/raw_file/" | tr -d '\r' | grep -i '\.raw$' | while IFS= read -r f; do echo "=== $f ==="; curl -# -C - -O --ftp-ssl-reqd --user "anonymous:user@example.com" "ftp://massive-ftp.ucsd.edu/v07/MSV000094602/raw/raw_file/$f"; done
#mkdir miriam
#rsync -Parv /nird/datapeak/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/Animesh/Miriam/Proteomes/*.raw miriam/
#rsync -Parv /nird/datapeak/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/Animesh/Miriam/Proteomes/Proteome\ from\ uniprot/* miriam/
#bash mqrun.sh   /cluster/home/ash022/scripts/MaxQuant_v2.8.1.0/bin/MaxQuantCmd.dll   "$PWD/miriam/"   mqpar.xml   5   0.01   /cluster/home/ash022/scripts/mqpar.xml.1795119949.results

set -euo pipefail

if [ "$#" -lt 6 ]; then
    echo "Usage: $0 <MaxQuantCmd.dll> <DATADIR/> <PARAMFILE> <CPU> <FDR> <OUTDIR>" >&2
    exit 1
fi

MAXQUANTCMD="$1"
DATADIR="${2%/}"
PARAMFILE="$3"
CPU="$4"
FDR="$5"
WRITEDIR="${6%/}"

SEARCHTEXT="TestFile.raw"
SEARCHTEXT4="Fdr>0.01"

LDIR="$PWD"
mkdir -p "${WRITEDIR}"

mapfile -t RAW_FILES < <(find "${DATADIR}" -maxdepth 1 -type f -name "*.raw" | sort)
NUM_FILES="${#RAW_FILES[@]}"

if [ "${NUM_FILES}" -eq 0 ]; then
    echo "No .raw files found in ${DATADIR}" >&2
    exit 1
fi

for raw_path in "${RAW_FILES[@]}"; do
    raw_base="$(basename "${raw_path}")"
    sample_id="${raw_base%%.*}"
    sample_dir="${WRITEDIR}/${sample_id}"
    mkdir -p "${sample_dir}"

    if [ ! -f "${sample_dir}/${raw_base}" ]; then
        cp "${raw_path}" "${sample_dir}/"
    fi

    tmp_xml="$(mktemp "${sample_dir}/${sample_id}.XXXXXX.xml")"
    sed \
        -e "s|${SEARCHTEXT}|${sample_dir}/${raw_base}|g" \
        -e "s|${SEARCHTEXT4}|Fdr>${FDR}|g" \
        "${LDIR}/${PARAMFILE}" > "${tmp_xml}"
    mv "${tmp_xml}" "${sample_dir}/${sample_id}.xml"
done

RAW_LIST_ENTRIES="$(printf '  "%s"\n' "${RAW_FILES[@]}")"
ARRAY_MAX=$((NUM_FILES - 1))
JOB_SCRIPT="${WRITEDIR}/submit_mq_array.sbatch"

cat <<EOF > "${JOB_SCRIPT}"
#!/bin/bash
#SBATCH --account=nn9036k
#SBATCH --job-name=MQ_${PARAMFILE%.*}
#SBATCH --time=24:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=${CPU}
#SBATCH --mem-per-cpu=8G
#SBATCH --array=0-${ARRAY_MAX}
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=${WRITEDIR}/mq_%A_%a.out
#SBATCH --error=${WRITEDIR}/mq_%A_%a.err

set -euo pipefail

module load GCCcore/14.3.0
module load dotNET-Core/8.0.411

RAW_LIST=(
${RAW_LIST_ENTRIES}
)

raw_path="\${RAW_LIST[\$SLURM_ARRAY_TASK_ID]}"
raw_base="\$(basename "\${raw_path}")"
sample_id="\${raw_base%%.*}"
sample_dir="${WRITEDIR}/\${sample_id}"
xml_file="\${sample_dir}/\${sample_id}.xml"

echo "Running on node: \$SLURM_NODELIST | Job: \${SLURM_ARRAY_JOB_ID}_\${SLURM_ARRAY_TASK_ID} | CPUs: \$SLURM_CPUS_PER_TASK"
echo "Sample: \${sample_id} | XML: \${xml_file}"

cd "\${sample_dir}"
dotnet "${MAXQUANTCMD}" "\${xml_file}"
EOF

sbatch "${JOB_SCRIPT}"
echo "Submitted ${NUM_FILES} array jobs (indices 0..${ARRAY_MAX}). Results & logs: ${WRITEDIR}"