#cd /mnt/promec-ns9036k/raw
#bash $HOME/scripts/runFPTTP.sh /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2025/250214_HISTONE $HOME/scripts
## Monitor the input directory ($1) for new "*.d" folders that have been unchanged for at least 60 minutes, then process them once and mark them as processed to avoid re-running.
PROCESSED_MARKER_DIR="${PWD}/.fprunTTP_processed"
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
	find "$1" -maxdepth 1 -type d -name '*.d' -print0 | while IFS= read -r -d '' i; do
		# skip the parent dir if it accidentally matches
		[ "$i" = "$1" ] && continue
		j=$(basename "$i")
		marker="$PROCESSED_MARKER_DIR/${j}.processed"
		# only process dirs that have been unchanged for at least 60 minutes
		# Determine creation time (prefer birth time; fallback to earliest mtime)
		get_creation_ts() {
			local dir="$1"
			# try birth time (seconds since epoch). returns 0 if unknown.
			birth=$(stat -c %W "$dir" 2>/dev/null || echo 0)
			if [ -n "$birth" ] && [ "$birth" -gt 0 ] 2>/dev/null; then
				printf '%d' "$birth"
				return
			fi
			# fallback: use the directory's modification time (mtime)
			stat -c %Y "$dir" 2>/dev/null || date +%s
		}

		creation_ts=$(get_creation_ts "$i")
		now=$(date +%s)
		age=$(( now - creation_ts ))
		# only consider dirs created within the last hour (<=3600s)
		if [ "$age" -le 3600 ]; then
			# ensure no file inside is newer than creation time
			# get the latest modification time (seconds) among dir and its files
			latest_ts=$(find "$i" -printf '%T@\n' 2>/dev/null | sort -n | tail -n1 | cut -d. -f1)
			# if we couldn't determine latest_ts, fall back to dir mtime
			if [ -z "$latest_ts" ]; then
				latest_ts=$(stat -c %Y "$i" 2>/dev/null || "$creation_ts")
			fi
			# if anything was modified after creation_ts, skip
			if [ "$latest_ts" -gt "$creation_ts" ] 2>/dev/null; then
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
			if [[ "$latest_ts" =~ ^[0-9]+$ ]]; then
				latest_human=$(date -d "@$latest_ts" '+%F %T' 2>/dev/null) || latest_human=n/a
			else
				latest_human=n/a
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
			cp -rf "$i" .
			chmod -R 755 "$j"
			sed "s|RAWDIR|$PWD/$j|" "$2"/fp.manifest.txt > man.1.txt
			k=${j%%.*}
			sed "s|RAWFILE|$k|" man.1.txt > man.2.txt
			cat man.2.txt
			"$FRAGPIPE_BIN" --headless --threads 20 --ram 80 --workflow "$2"/fp.dl.workflow.txt --manifest man.2.txt --workdir "$j".FPv22hum
			ls -ltrh "${k}_calibrated.mzML"
			k2=${k/-/_}
			echo "$k2"
			pep="$j".FPv22hum/"$k2"/"$k".pepXML
			ls -ltrh "$pep"
			wc "$j".FPv22hum/"$k2"/protein.tsv
			"$AA_STAT_BIN" -n 22 --mzml "${k}_calibrated.mzML" --pepxml "$pep" --dir "$j".AA_stat_v2p5p6hum
			echo "$PWD"
			du -kh "$j".AA_stat_v2p5p6hum
			head "$j".FPv22hum/ptm-shepherd-output/global.modsummary.tsv

			# mark as processed
			touch "$marker"
		fi
	done
	sleep $scan_interval
done
