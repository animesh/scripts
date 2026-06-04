#!/bin/bash
#rsync -Parv /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2026/260408_Steven/260408_Steven_*.d /mnt/promec-ns9036k/steven/ 
#rsync -Parv /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2026/260211_Steven/260211_Steven_*.d /mnt/promec-ns9036k/steven/ 
#rsync -Parv /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2026/260408_Steven/*.fasta /mnt/promec-ns9036k/steven/ 
#rsync -Parv /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2026/260408_Steven/*.speclib /mnt/promec-ns9036k/steven/ 
usage() {
    echo "Usage: $0 -d <data_dir> -l <spectral_lib> -f <fasta_file>"
    echo "  -d  directory containing .d files"
    echo "  -l  spectral library (.speclib or .parquet)"
    echo "  -f  FASTA file"
    echo "  -h  show this help"
    exit 1
}

DIANN=/mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/diann-2.2.0/diann-linux

DATA_DIR=""
LIB=""
FASTA=""

while getopts "d:l:f:h" opt; do
    case $opt in
        d) DATA_DIR="$OPTARG" ;;
        l) LIB="$OPTARG" ;;
        f) FASTA="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done

# validate
[[ -z "$DATA_DIR" || -z "$LIB" || -z "$FASTA" ]] && { echo "ERROR: -d, -l, and -f are all required"; usage; }
[[ -d "$DATA_DIR" ]] || { echo "ERROR: data dir not found: $DATA_DIR"; exit 1; }
[[ -f "$LIB" ]]      || { echo "ERROR: lib file not found: $LIB"; exit 1; }
[[ -f "$FASTA" ]]    || { echo "ERROR: fasta not found: $FASTA"; exit 1; }

for i in "$DATA_DIR"/*.d; do
    [[ -e "$i" ]] || { echo "WARNING: no .d files found in $DATA_DIR"; break; }
    echo "Processing: $i"
    "$DIANN" \
        --f "$i" \
        --lib "$LIB" \
        --threads 80 \
        --verbose 1 \
        --out "$i.report.ppm15.parquet" \
        --qvalue 0.01 \
        --matrices \
        --out-lib "$i.report-lib.ppm15.parquet" \
        --gen-spec-lib \
        --reannotate \
        --fasta "$FASTA" \
        --met-excision \
        --min-pep-len 7 \
        --max-pep-len 30 \
        --min-pr-mz 300 \
        --max-pr-mz 1800 \
        --min-pr-charge 1 \
        --max-pr-charge 4 \
        --cut K*,R* \
        --missed-cleavages 2 \
        --unimod4 \
        --var-mods 3 \
        --var-mod UniMod:35,15.994915,M \
        --var-mod UniMod:1,42.010565,*n \
        --mass-acc 15.0 \
        --mass-acc-ms1 15.0 \
        --direct-quant \
        --window 5 \
        --peptidoforms \
        --rt-profiling
done