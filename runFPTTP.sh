#cd /mnt/promec-ns9036k/raw
#bash $HOME/scripts/runFPTTP.sh /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/Raw $HOME/scripts
## Monitor the input directory ($1) for new "*.d" folders that were touched within the last 1 hour
## and that have been stable (no content changes) for at least 60 seconds, then process them once
## and mark them as processed to avoid re-running.
#export FRAGPIPE_BIN=/full/path/to/fragpipe
#export AA_STAT_BIN=/full/path/to/AA_stat
#nohup bash ~/scripts/runFPTTP.sh /path/to/watch ~/scripts > ~/runFPTTP.log 2>&1 &
#ls -l .fprunTTP_processed/
#tail -f ~/runFPTTP.log
#PROCDIR="${PWD}/.fprunTTP_processed"; if [ -d "$PROCDIR" ]; then rm -vf "$PROCDIR"/*.processed 2>/dev/null || true; ls -lA "$PROCDIR"; else echo "No marker dir: $PROCDIR"; fi
#touch /mnt/.../250213_200ngHelaQC_DDA_A_Slot1-54_1_9544.d
# wait >=60s, then run monitor (foreground)
## Monitor the input directory ($1) for new "*.d" folders that were touched within the last 1 hour
## and that have been stable (no content changes) for at least 60 seconds, then process them once
## and mark them as processed to avoid re-running.
## Monitor the input directory ($1) recursively for new "*.d" folders that were touched within the last 1 hour
## and that have been stable (no content changes) for at least 60 seconds, then process them once
## and mark them as processed to avoid re-running.
## Monitor the input directory ($1) recursively for new "*.d" folders that were touched within the last 1 hour
## and that have been stable (no content changes) for at least 60 seconds, then process them once
## and mark them as processed to avoid re-running.
PROCESSED_MARKER_DIR="$(pwd -P)/.fprunTTP_processed"
mkdir -p "$PROCESSED_MARKER_DIR"
scan_interval=60

# Tools (can be overridden by environment)
FRAGPIPE_BIN="${HOME}/fragpipe/bin/fragpipe"
AA_STAT_BIN="${HOME}/.local/bin/AA_stat"

# ensure manifest and workflow exist
if [ ! -f "$2/fp.manifest.txt" ] || [ ! -f "$2/fp.dl.workflow.txt" ]; then
	echo "ERROR: manifest or workflow missing in $2"
	echo "Expected: $2/fp.manifest.txt and $2/fp.dl.workflow.txt"
	exit 1
fi
while true; do
	find "$1" -mindepth 1 -type d -name '*.d' -print0 | while IFS= read -r -d '' i; do
		# skip the parent dir if it accidentally matches
		[ "$i" = "$1" ] && continue
		j=$(basename "$i")
		marker="$PROCESSED_MARKER_DIR/${j}.processed"
		# Trigger when the directory is touched (use directory mtime)
		creation_ts=$(stat -c %Y "$i" 2>/dev/null || date +%s)
		now=$(date +%s)
		age=$(( now - creation_ts ))
		# only consider dirs created within the last hour (<=3600s)
		if [ "$age" -le 3600 ]; then
			# (Trigger based on directory mtime only) show dir mtime
			mtime_human=$(date -d "@$creation_ts" '+%F %T' 2>/dev/null || echo n/a)
			echo "  dir mtime: $mtime_human"
			# compute latest modification time among dir and contents
			latest_ts=$(find "$i" -printf '%T@\n' 2>/dev/null | sort -n | tail -n1 | cut -d. -f1)
			if [ -z "$latest_ts" ]; then
				latest_ts=$(stat -c %Y "$i" 2>/dev/null || "$creation_ts")
			fi
			latest_human=$(date -d "@$latest_ts" '+%F %T' 2>/dev/null || echo n/a)
			echo "  latest content modification: $latest_human"
			# require directory to be stable for at least 60 seconds
			stable_threshold=$(( now - 60 ))
			if [ "$latest_ts" -gt "$stable_threshold" ] 2>/dev/null; then
				echo "  skipping: directory changed within last 60s (latest: $latest_human)"
				continue
			fi
			# skip if already processed
			if [ -f "$marker" ]; then
				continue
			fi
			echo "Processing: $i"
			d=$(dirname "$i")
			if [[ "$creation_ts" =~ ^[0-9]+$ ]]; then
				creation_human=$(date -d "@$creation_ts" '+%F %T' 2>/dev/null) || creation_human=n/a
			else
				creation_human=n/a
			fi
			echo "  dir: $i"
			echo "  basename: $j"
			echo "  created: $creation_human (age ${age}s)"
			echo "  latest modification: $latest_human"
			echo "  processed marker: $marker"
			echo "  manifest: $2/fp.manifest.txt"
			echo "  workflow: $2/fp.dl.workflow.txt"

			# verify required executables
			if [ ! -x "$FRAGPIPE_BIN" ]; then
				echo "ERROR: fragpipe not found or not executable at $FRAGPIPE_BIN — skipping $i"
				continue
			fi
			if [ ! -x "$AA_STAT_BIN" ]; then
				echo "ERROR: AA_stat not found or not executable at $AA_STAT_BIN — skipping $i"
				continue
			fi
			# copy working folder to current dir and set permissions (handle spaces)
			cp -a -- "$i" .
			chmod -R 755 -- "$j"

			# create an ephemeral manifest with correct RAWDIR/RAWFILE substitutions
			k=${j%%.*}
			man_final=$(mktemp /tmp/fp.manifest.XXXXXX)
			awk -v RAWDIR="$(printf '%s/%s' "$PWD" "$j")" -v RAWFILE="$k" '{ gsub("RAWDIR",RAWDIR); gsub("RAWFILE",RAWFILE); print }' "$2"/fp.manifest.txt > "$man_final"

			# show and run FragPipe
			echo "RUN: $FRAGPIPE_BIN --headless --threads 20 --ram 80 --workflow $2/fp.dl.workflow.txt --manifest $man_final --workdir $j.FPv22hum"
			"$FRAGPIPE_BIN" --headless --threads 20 --ram 80 --workflow "$2"/fp.dl.workflow.txt --manifest "$man_final" --workdir "$j".FPv22hum
			frag_rc=$?

			# cleanup manifest temp
			rm -f "$man_final"

			if [ "$frag_rc" -ne 0 ]; then
				echo "ERROR: FragPipe failed with exit code $frag_rc for $j; writing .failed marker and skipping AA_stat"
				failed_marker="$PROCESSED_MARKER_DIR/${j}.failed"
				printf '%s\n' "$(date +%s)" > "$failed_marker" 2>/dev/null || echo "ERROR: cannot write $failed_marker" >&2
				continue
			fi

			# expected output files
			k2=${k/-/_}
			pep="$j".FPv22hum/"$k2"/"$k".pepXML

			# run AA_stat
			echo "RUN: $AA_STAT_BIN -n 22 --mzml ${k}_calibrated.mzML --pepxml $pep --dir $j.AA_stat_v2p5p6hum"
			"$AA_STAT_BIN" -n 22 --mzml "${k}_calibrated.mzML" --pepxml "$pep" --dir "$j".AA_stat_v2p5p6hum
			aa_rc=$?

			# mark as processed only on success of both steps
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
		fi
	done
	sleep $scan_interval
done
