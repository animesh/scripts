#bash $HOME/scripts/runFPTTP.sh /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/MIRTA/JonCooper  ~/scripts 60 '20260513_TO*.d'
# Monitor a folder recursively for new dirs matching a glob pattern and process them
# Conditions: touched within last MAX_AGE_DAYS days AND stable (no content changes) for 60s
#
# Usage:
#   bash runFPTTP.sh <watch_dir> <scripts_dir> [max_age_days] [glob_pattern]
#
# Examples:
#   bash runFPTTP.sh /data/raw ~/scripts
#   bash runFPTTP.sh /data/raw ~/scripts 1 '*.d'
#   bash runFPTTP.sh /data/raw ~/scripts 0.5 '250213_*_DDA_*.d'
#
# nohup bash ~/scripts/runFPTTP.sh /path/to/watch ~/scripts > ~/runFPTTP.log 2>&1 &
# tail -f ~/runFPTTP.log
# ls -l .fprunTTP_processed/
# PROCDIR="${PWD}/.fprunTTP_processed"; if [ -d "$PROCDIR" ]; then rm -vf "$PROCDIR"/*.processed 2>/dev/null || true; ls -lA "$PROCDIR"; else echo "No marker dir: $PROCDIR"; fi

PROCESSED_MARKER_DIR="$(pwd -P)/.fprunTTP_processed"
mkdir -p "$PROCESSED_MARKER_DIR"
scan_interval=60

# Tools (can be overridden by environment)
FRAGPIPE_BIN="${FRAGPIPE_BIN:-${HOME}/fragpipe/bin/fragpipe}"
AA_STAT_BIN="${AA_STAT_BIN:-${HOME}/.local/bin/AA_stat}"
CASANOVO_BIN="${CASANOVO_BIN:-${HOME}/.local/bin/casanovo}"

# ---------------------------------------------------------------------------
usage() {
    echo ""
    echo "Usage: $0 <watch_dir> <scripts_dir> [max_age_days] [glob_pattern]"
    echo ""
    echo "  watch_dir      : directory to monitor recursively"
    echo "  scripts_dir    : directory containing fp.manifest.txt and fp.dl.workflow.txt"
    echo "  max_age_days   : skip dirs older than this many days (default: 1)"
    echo "                   fractional values accepted, e.g. 0.5 for 12 hours"
    echo "  glob_pattern   : name pattern to match dirs (default: *.d)"
    echo "                   MUST be quoted to prevent shell expansion:"
    echo "                   good:  '250213_*_DDA_*.d'"
    echo "                   bad :   250213_*_DDA_*.d   (shell expands * before script sees it)"
    echo ""
    echo "Examples:"
    echo "  $0 /data/raw ~/scripts"
    echo "  $0 /data/raw ~/scripts 1 '*.d'"
    echo "  $0 /data/raw ~/scripts 0.5 '250213_*_DDA_*.d'"
    echo ""
    exit 2
}

# ---------------------------------------------------------------------------
# Glob pattern safeguard
# ---------------------------------------------------------------------------
validate_glob() {
    local pat="$1"

    # Guard 1: pattern contains no wildcard characters at all
    case "$pat" in
        *\**|*\?*|*\[*) : ;;   # has at least one wildcard - ok
        *)
            echo "WARN: glob_pattern '$pat' contains no wildcards (* ? [])."
            echo "      This matches only an exact directory name."
            echo "      If you intended a wildcard pattern, make sure to quote it:"
            echo "      e.g.  $0 ... '*.d'  or  '250213_*_DDA_*.d'"
            ;;
    esac

    # Guard 2: pattern contains a path separator - almost certainly pre-expanded
    case "$pat" in
        */*)
            echo "WARN: glob_pattern '$pat' contains a '/' path separator."
            echo "      The shell may have expanded a wildcard before passing it to this script."
            echo "      Always quote your glob pattern: '$0 ... \"*.d\"'"
            ;;
    esac

    # Guard 3: pattern looks like an absolute path - definitely pre-expanded
    case "$pat" in
        /*)
            echo "ERROR: glob_pattern '$pat' looks like an absolute path - this is almost"
            echo "       certainly a shell pre-expansion. Re-run with the pattern quoted."
            exit 1
            ;;
    esac

    # Guard 4: multiple tokens reached us as one arg only if IFS split - cannot happen
    # but we can check for embedded newlines which would be very suspicious
    case "$pat" in
        *$'\n'*)
            echo "ERROR: glob_pattern contains a newline - something is wrong with quoting."
            exit 1
            ;;
    esac
}

# ---------------------------------------------------------------------------
# Convert days (possibly fractional) to integer seconds via awk
# ---------------------------------------------------------------------------
days_to_seconds() {
    local days="$1"
    # validate that it looks like a positive number
    if ! echo "$days" | grep -qE '^[0-9]+(\.[0-9]+)?$'; then
        echo "ERROR: max_age_days must be a positive number (e.g. 1, 0.5, 2.5). Got: '$days'" >&2
        exit 1
    fi
    awk -v d="$days" 'BEGIN { printf "%d\n", d * 86400 }'
}

# ---------------------------------------------------------------------------
if [ "$#" -lt 2 ]; then
    usage
fi

WATCH_DIR="$1"
SCRIPTS_DIR="$2"
MAX_AGE_DAYS="${3:-1}"
GLOB_PATTERN="${4:-*.d}"

# Convert days to seconds
MAX_AGE=$(days_to_seconds "$MAX_AGE_DAYS")

# Validate glob pattern
validate_glob "$GLOB_PATTERN"

if [ ! -d "$WATCH_DIR" ]; then
    echo "ERROR: watch dir not found: $WATCH_DIR" >&2
    exit 1
fi

if [ ! -f "$SCRIPTS_DIR/fp.manifest.txt" ] || [ ! -f "$SCRIPTS_DIR/fp.dl.workflow.txt" ]; then
    echo "ERROR: manifest or workflow missing in $SCRIPTS_DIR" >&2
    echo "Expected: $SCRIPTS_DIR/fp.manifest.txt and $SCRIPTS_DIR/fp.dl.workflow.txt" >&2
    exit 1
fi

echo ""
echo "runFPTTP starting"
echo "  watch_dir    : $WATCH_DIR"
echo "  scripts_dir  : $SCRIPTS_DIR"
echo "  glob_pattern : $GLOB_PATTERN"
echo "  max_age      : ${MAX_AGE_DAYS} day(s) = ${MAX_AGE}s"
echo "  scan_interval: ${scan_interval}s"
echo "  markers      : $PROCESSED_MARKER_DIR"
echo ""

# ---------------------------------------------------------------------------
while true; do
    find "$WATCH_DIR" -mindepth 1 -type d -name "$GLOB_PATTERN" -print0 | while IFS= read -r -d '' i; do
        [ -d "$i" ] || continue
        [ "$i" != "$WATCH_DIR" ] || continue
        j=$(basename "$i")
        marker="$PROCESSED_MARKER_DIR/${j}.processed"

        creation_ts=$(stat -c %Y "$i" 2>/dev/null || date +%s)
        now=$(date +%s)
        age=$(( now - creation_ts ))

        if [ "$age" -gt "$MAX_AGE" ]; then
            # older than MAX_AGE_DAYS: skip silently
            continue
        fi

        mtime_human=$(date -d "@$creation_ts" '+%F %T' 2>/dev/null || echo n/a)
        latest_ts=$(find "$i" -printf '%T@\n' 2>/dev/null | sort -n | tail -n1 | cut -d. -f1)
        latest_ts=${latest_ts:-$creation_ts}
        latest_human=$(date -d "@$latest_ts" '+%F %T' 2>/dev/null || echo n/a)

        echo ""
        echo "Checking: $i"
        echo "  dir mtime              : $mtime_human"
        echo "  latest content mtime   : $latest_human"
        echo "  age                    : ${age}s (max allowed: ${MAX_AGE}s / ${MAX_AGE_DAYS}d)"

        stable_threshold=$(( now - 60 ))
        if [ "$latest_ts" -gt "$stable_threshold" ] 2>/dev/null; then
            echo "  skipping: directory changed within last 60s (latest: $latest_human)"
            continue
        fi

        if [ -f "$marker" ]; then
            echo "  already processed (marker exists): $marker"
            continue
        fi

        echo "Processing: $i"

        # sanity checks for binaries
        if [ ! -x "$FRAGPIPE_BIN" ]; then
            echo "ERROR: fragpipe not found or not executable at $FRAGPIPE_BIN - skipping $i" >&2
            continue
        fi

        aa_available=0
        if [ -x "$AA_STAT_BIN" ]; then
            aa_available=1
        else
            echo "WARN: AA_stat not found at $AA_STAT_BIN - AA_stat will be skipped (optional)"
        fi

        casanovo_available=0
        if [ -x "$CASANOVO_BIN" ]; then
            casanovo_available=1
        else
            echo "WARN: casanovo not found at $CASANOVO_BIN - will skip de novo step"
        fi

        # copy working folder locally and set permissions
        cp -a -- "$i" .
        chmod -R 755 -- "$j"

        k=${j%%.*}
        man_final=$(mktemp /tmp/fp.manifest.XXXXXX)
        awk -v RAWDIR="$(printf '%s/%s' "$PWD" "$j")" -v RAWFILE="$k" \
            '{ gsub("RAWDIR",RAWDIR); gsub("RAWFILE",RAWFILE); print }' \
            "$SCRIPTS_DIR"/fp.manifest.txt > "$man_final"

        # run FragPipe
        echo "RUN: $FRAGPIPE_BIN --headless --threads 20 --ram 80 --workflow $SCRIPTS_DIR/fp.dl.workflow.txt --manifest $man_final --workdir ${j}.FPv22hum"
        "$FRAGPIPE_BIN" --headless --threads 20 --ram 80 \
            --workflow "$SCRIPTS_DIR"/fp.dl.workflow.txt \
            --manifest "$man_final" \
            --workdir "${j}.FPv22hum"
        frag_rc=$?
        rm -f "$man_final"

        if [ "$frag_rc" -ne 0 ]; then
            echo "ERROR: FragPipe failed with exit code $frag_rc for $j; writing .failed marker"
            failed_marker="$PROCESSED_MARKER_DIR/${j}.failed"
            printf '%s\n' "$(date +%s)" > "$failed_marker" 2>/dev/null || echo "ERROR: cannot write $failed_marker" >&2
            continue
        fi

        # run casanovo (optional)
        if [ "$casanovo_available" -eq 1 ]; then
            mzml_file="${k}_calibrated.mzML"
            cas_out_dir="${j}.DNv5p1p2"
            echo "RUN: $CASANOVO_BIN sequence $mzml_file --output_dir $cas_out_dir"
            "$CASANOVO_BIN" sequence "$mzml_file" --output_dir "$cas_out_dir"
            cas_rc=$?
            if [ "$cas_rc" -ne 0 ]; then
                echo "ERROR: casanovo failed (exit $cas_rc) for $j; writing .failed marker"
                failed_marker="$PROCESSED_MARKER_DIR/${j}.failed"
                printf '%s\n' "$(date +%s)" > "$failed_marker" 2>/dev/null || echo "ERROR: cannot write $failed_marker" >&2
                continue
            fi
        else
            echo "Skipping casanovo for $j (not installed)"
        fi

        # run AA_stat (optional)
        k2=${k/-/_}
        pep="$j.FPv22hum/$k2/$k.pepXML"
        aa_rc=0
        if [ "$aa_available" -eq 1 ]; then
            echo "RUN: $AA_STAT_BIN -n 22 --mzml ${k}_calibrated.mzML --pepxml $pep --dir ${j}.AA_stat_v2p5p6hum"
            "$AA_STAT_BIN" -n 22 --mzml "${k}_calibrated.mzML" --pepxml "$pep" \
                --dir "${j}.AA_stat_v2p5p6hum"
            aa_rc=$?
        else
            echo "Skipping AA_stat for $j (not installed)"
            aa_rc=0
        fi

        mkdir -p "$PROCESSED_MARKER_DIR" 2>/dev/null || true
        if [ "$aa_rc" -ne 0 ]; then
            echo "ERROR: AA_stat failed with exit code $aa_rc for $j; writing .failed marker"
            failed_marker="$PROCESSED_MARKER_DIR/${j}.failed"
            printf '%s\n' "$(date +%s)" > "$failed_marker" 2>/dev/null || echo "ERROR: cannot write $failed_marker" >&2
        else
            if printf '%s\n' "$(date +%s)" > "$marker" 2>/dev/null; then
                echo "  marked processed: $marker"
            else
                echo "ERROR: failed to write marker: $marker" >&2
            fi
        fi

    done

    sleep $scan_interval
done