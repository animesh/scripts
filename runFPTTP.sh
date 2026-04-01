#!/usr/bin/env bash
# Monitor a folder recursively for new "*.d" directories and process them
# Conditions: touched within last 1 hour AND stable (no content changes) for 60s
#cd /mnt/promec-ns9036k/raw
#bash $HOME/scripts/runFPTTP.sh /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/Raw $HOME/scripts
#export FRAGPIPE_BIN=/full/path/to/fragpipe
#export AA_STAT_BIN=/full/path/to/AA_stat
#export CASANOVO_BIN=/full/path/to/casanovo
#nohup bash ~/scripts/runFPTTP.sh /path/to/watch ~/scripts > ~/runFPTTP.log 2>&1 &
#ls -l .fprunTTP_processed/
#tail -f ~/runFPTTP.log
#PROCDIR="${PWD}/.fprunTTP_processed"; if [ -d "$PROCDIR" ]; then rm -vf "$PROCDIR"/*.processed 2>/dev/null || true; ls -lA "$PROCDIR"; else echo "No marker dir: $PROCDIR"; fi
#touch /mnt/.../250213_200ngHelaQC_DDA_A_Slot1-54_1_9544.d
# wait >=60s, then run monitor (foreground)

PROCESSED_MARKER_DIR="$(pwd -P)/.fprunTTP_processed"
mkdir -p "$PROCESSED_MARKER_DIR"
scan_interval=60

# Tools (can be overridden by environment)
FRAGPIPE_BIN="${FRAGPIPE_BIN:-${HOME}/fragpipe/bin/fragpipe}"
AA_STAT_BIN="${AA_STAT_BIN:-${HOME}/.local/bin/AA_stat}"
CASANOVO_BIN="${CASANOVO_BIN:-${HOME}/.local/bin/casanovo}"

usage() {
    echo "Usage: $0 <watch_dir> <scripts_dir_with_manifest_and_workflow>"
    exit 2
}

if [ "$#" -lt 2 ]; then
    usage
fi

WATCH_DIR="$1"
SCRIPTS_DIR="$2"

if [ ! -d "$WATCH_DIR" ]; then
    echo "ERROR: watch dir not found: $WATCH_DIR" >&2
    exit 1
fi

if [ ! -f "$SCRIPTS_DIR/fp.manifest.txt" ] || [ ! -f "$SCRIPTS_DIR/fp.dl.workflow.txt" ]; then
    echo "ERROR: manifest or workflow missing in $SCRIPTS_DIR" >&2
    echo "Expected: $SCRIPTS_DIR/fp.manifest.txt and $SCRIPTS_DIR/fp.dl.workflow.txt" >&2
    exit 1
fi

echo "Watching: $WATCH_DIR (scan every ${scan_interval}s). Markers: $PROCESSED_MARKER_DIR"

while true; do
    find "$WATCH_DIR" -mindepth 1 -type d -name '*.d' -print0 | while IFS= read -r -d '' i; do
        [ -d "$i" ] || continue
        [ "$i" != "$WATCH_DIR" ] || continue
        j=$(basename "$i")
        marker="$PROCESSED_MARKER_DIR/${j}.processed"

        creation_ts=$(stat -c %Y "$i" 2>/dev/null || date +%s)
        now=$(date +%s)
        age=$(( now - creation_ts ))

        if [ "$age" -gt 3600 ]; then
            # older than 1 hour: skip
            continue
        fi

        mtime_human=$(date -d "@$creation_ts" '+%F %T' 2>/dev/null || echo n/a)
        latest_ts=$(find "$i" -printf '%T@\n' 2>/dev/null | sort -n | tail -n1 | cut -d. -f1)
        latest_ts=${latest_ts:-$creation_ts}
        latest_human=$(date -d "@$latest_ts" '+%F %T' 2>/dev/null || echo n/a)

        echo "\nChecking: $i"
        echo "  dir mtime: $mtime_human"
        echo "  latest content modification: $latest_human"

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
            echo "ERROR: fragpipe not found or not executable at $FRAGPIPE_BIN — skipping $i" >&2
            continue
        fi

        aa_available=0
        if [ -x "$AA_STAT_BIN" ]; then
            aa_available=1
        else
            echo "WARN: AA_stat not found at $AA_STAT_BIN — AA_stat will be skipped (optional)"
        fi

        casanovo_available=0
        if [ -x "$CASANOVO_BIN" ]; then
            casanovo_available=1
        else
            echo "WARN: casanovo not found at $CASANOVO_BIN — will skip de novo step"
        fi

        # copy working folder locally and set permissions
        cp -a -- "$i" .
        chmod -R 755 -- "$j"

        k=${j%%.*}
        man_final=$(mktemp /tmp/fp.manifest.XXXXXX)
        awk -v RAWDIR="$(printf '%s/%s' "$PWD" "$j")" -v RAWFILE="$k" '{ gsub("RAWDIR",RAWDIR); gsub("RAWFILE",RAWFILE); print }' "$SCRIPTS_DIR"/fp.manifest.txt > "$man_final"

        # run FragPipe
        echo "RUN: $FRAGPIPE_BIN --headless --threads 20 --ram 80 --workflow $SCRIPTS_DIR/fp.dl.workflow.txt --manifest $man_final --workdir ${j}.FPv22hum"
        "$FRAGPIPE_BIN" --headless --threads 20 --ram 80 --workflow "$SCRIPTS_DIR"/fp.dl.workflow.txt --manifest "$man_final" --workdir "${j}.FPv22hum"
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
            "$AA_STAT_BIN" -n 22 --mzml "${k}_calibrated.mzML" --pepxml "$pep" --dir "${j}.AA_stat_v2p5p6hum"
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
