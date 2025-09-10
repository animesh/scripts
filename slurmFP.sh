#bash slurmFP.sh /nird/projects/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/Elite/LARS/2018/mai/Vibeke\ V
#wget https://rest.uniprot.org/uniprotkb/stream?download=true&format=fasta&query=%28%28taxonomy_id%3A2%29+AND+%28reviewed%3Atrue%29%29
#cat /mnt/z/Download/uniprotkb_proteome_UP000005640_2025_09_09.fasta /mnt/z/Download/uniprotkb_proteome_UP000254098_2025_09_09.fasta /mnt/z/Download/uniprotkb_taxonomy_id_2_AND_reviewed_tr_2025_09_10.fasta > /mnt/z/Download/human_strepV_bacR.fasta
DATADIR="$1"
CURRENTEPOCTIME=$(date +%s)
SLURM="scratch.slurm"
WRITEDIRFULL=$(basename "$DATADIR")
WRITEDIR="${WRITEDIRFULL//[^[:alnum:]]/}"

echo "Processing directory: $DATADIR"
echo "Work directory: $WRITEDIR"

# Create work directory
mkdir -p "$WRITEDIR"

# List raw files (for verification)
ls -ltrh "$DATADIR"/*.raw

# Copy raw files using rsync (handles spaces properly)
rsync -Parv "$DATADIR"/*.raw "$WRITEDIR"/

# Create file listing
ls -ltrh "$DATADIR"/*.raw > "$WRITEDIR/files.txt"

# Convert line endings if needed
dos2unix "$SLURM" 2>/dev/null || true

# Process each raw file
for rawfile in "$PWD/$WRITEDIR"/*.raw; do
    if [[ -f "$rawfile" ]]; then
        echo "Processing: $rawfile"
        
        # Generate manifest file
        sed "s|RAWDATA|$rawfile|" fp.manifest.txt > "$rawfile.$CURRENTEPOCTIME.manifest.txt"
        
        # Generate SLURM script
        sed "s|RAWDATA|$rawfile.$CURRENTEPOCTIME|g" "$SLURM" > "$rawfile.$CURRENTEPOCTIME.slurm"
        
        # Uncomment the line below to submit jobs automatically
        sbatch "$rawfile.$CURRENTEPOCTIME.slurm"
    fi
done

echo "Processing complete. Generated files in: $WRITEDIR"
