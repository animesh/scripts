#bash compareFastq.sh "/cluster/projects/nn9036k/TK/TK10*.fq.gz" "/cluster/projects/nn9036k/TK/sra/fastq/SRR31089075*"  --dry-run
# Always use cluster scratch, never /tmp
TMPDIR="/cluster/work/users/$USER/tmp"
mkdir -p "$TMPDIR"
set -euo pipefail
usage() {
    echo "Usage: $0 <reads_pattern> <sra_pattern> [--dry-run]"
    exit 1
}

if [[ $# -lt 2 ]]; then usage; fi

READS_PATTERN="$1"
SRA_PATTERN="$2"
DRYRUN=0
if [[ "${3:-}" == "--dry-run" ]]; then
    DRYRUN=1
    echo "### DRY RUN MODE ENABLED ###"
fi

COUNTFILE=$(dirname "$READS_PATTERN")/"read_counts.txt"
DIFFDIR=$(dirname "$READS_PATTERN")/"diff_out"
mkdir -p "$DIFFDIR"

echo "Reads pattern : $READS_PATTERN"
echo "SRA pattern   : $SRA_PATTERN"
echo

# ------------------------------
# LOAD FILE LISTS
# ------------------------------
mapfile -t READ_FILES < <(ls $READS_PATTERN)
mapfile -t SRA_FILES  < <(ls $SRA_PATTERN)

declare -A SRA_MAP

# index SRA R1/R2
for f in "${SRA_FILES[@]}"; do
    bn=$(basename "$f")
    if [[ "$bn" =~ ^(.+)_([12])\.f(ast)?q\.gz$ ]]; then
        sample="${BASH_REMATCH[1]}"
        rn="${BASH_REMATCH[2]}"
        SRA_MAP["$sample.$rn"]="$f"
    else
        echo "WARNING: unrecognized SRA name: $bn"
    fi
done

# ------------------------------
# MATCH READ FILES TO SRA FILES
# ------------------------------
declare -A READ_TO_SRA

for f in "${READ_FILES[@]}"; do
    bn=$(basename "$f")

    if [[ "$bn" =~ ^(.+)_([12])\.fq\.gz$ ]]; then
        sample="${BASH_REMATCH[1]}"
        rn="${BASH_REMATCH[2]}"
    else
        echo "Skipping unrecognized read file: $bn"
        continue
    fi

    # find matching SRA sample (same R1/R2 only)
    found=""
    for key in "${!SRA_MAP[@]}"; do
        s_prefix="${key%.*}"
        s_rn="${key##*.}"
        if [[ "$s_rn" == "$rn" ]]; then
            found="$key"
        fi
    done

    if [[ -z "$found" ]]; then
        echo "ERROR: no SRA R$rn match for $bn"
        continue
    fi

    READ_TO_SRA["$f"]="${SRA_MAP[$found]}"
    echo "MATCH: $bn  <==>  $(basename "${SRA_MAP[$found]}")"
done

echo
echo "Total matched pairs: ${#READ_TO_SRA[@]}"
echo

# -----------------------------------
# PARALLEL COMMAND GENERATION
# -----------------------------------
COUNT_JOBS=()
DIFF_JOBS=()

for f1 in "${!READ_TO_SRA[@]}"; do
    f2="${READ_TO_SRA[$f1]}"

    basename1=$(basename "$f1")
    rn=$(echo "$basename1" | grep -o "_[12]\.fq\.gz" | tr -dc '12')

    # count job
    COUNT_JOBS+=(
        "i=$rn; \
         c1=\$(pigz -dc $f1 | awk 'END {print NR/4}'); \
         c2=\$(pigz -dc $f2 | awk 'END {print NR/4}'); \
         diff=\$((c2 - c1)); \
         echo \"$basename1: reads=\$c1  ref=$(basename $f2) ref_reads=\$c2  difference=\$diff\" >> $COUNTFILE"
    )

    # diff job
    DIFF_JOBS+=(
        "comm -23 \
            <(pigz -dc $f1 | sed -n '2~4p' | sort -T $TMPDIR) \
            <(pigz -dc $f2 | sed -n '2~4p' | sort -T $TMPDIR) \
            > $DIFFDIR/${basename1}.diff"
    )
done

# -----------------------------------
# RUN PARALLEL
# -----------------------------------
echo "### Commands to be executed ###"
echo
printf "Count job:\n"
printf "  parallel :::\n"
for j in "${COUNT_JOBS[@]}"; do
    printf "    '%s'\n" "$j"
done
echo

printf "Diff job:\n"
printf "  parallel :::\n"
for j in "${DIFF_JOBS[@]}"; do
    printf "    '%s'\n" "$j"
done
echo "----------------------------------"

if [[ $DRYRUN -eq 1 ]]; then
    echo "DRY RUN: not executing parallel jobs."
    exit 0
fi

# run in parallel
parallel --joblog parallel_counts.log ::: "${COUNT_JOBS[@]}"
parallel --joblog parallel_diffs.log  ::: "${DIFF_JOBS[@]}"

echo "DONE. Output:"
echo "  Counts → $COUNTFILE"
echo "  Diffs  → $DIFFDIR/"
