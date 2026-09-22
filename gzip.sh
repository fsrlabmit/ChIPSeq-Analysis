```bash
#!/bin/bash

###############################################################################
# FASTQ COMPRESSION
#
# Run this script from the project directory:
#
#     sbatch gzip.sh
#
# Uncompressed FASTQ files anywhere under the project directory will be
# compressed and saved in:
#
#     fastqs_only/
#
# A list of the resulting .fastq.gz files will also be saved as:
#
#     fastqs_only/fastqs_only_file_list.txt
#
# ORIGINAL FASTQ FILES ARE NOT DELETED.
###############################################################################


############################ EDIT THESE #######################################

# Enter your email address:
#SBATCH --mail-user=your_email@institution.edu

# Change this only if your FASTQ files use a different naming pattern:
FASTQ_PATTERN="*.fastq"

###############################################################################
# DO NOT EDIT BELOW THIS LINE
###############################################################################

#SBATCH -N 1
#SBATCH --cpus-per-task=8
#SBATCH --job-name=fastq_compress
#SBATCH --mail-type=END,FAIL
#SBATCH --output=gzip_%j.out
#SBATCH --error=gzip_%j.err

set -euo pipefail

PROJECT_DIR="${SLURM_SUBMIT_DIR:-$PWD}"
OUT_DIR="$PROJECT_DIR/fastqs_only"

mkdir -p "$OUT_DIR"

# Check that pigz is available.
if ! command -v pigz >/dev/null 2>&1; then
    echo "ERROR: pigz is not available on this compute node."
    exit 1
fi

echo "Project: $PROJECT_DIR"
echo "Output:  $OUT_DIR"
echo "Using:   $(which pigz)"

# Find FASTQ files, excluding the output directory.
find "$PROJECT_DIR" \
    -type f \
    -name "$FASTQ_PATTERN" \
    ! -path "$OUT_DIR/*" \
    > "/tmp/fastq_list_${SLURM_JOB_ID}.txt"

# Compress up to 4 FASTQ files simultaneously, using 2 threads per file.
compress_one() {
    f="$1"
    base=$(basename "$f")
    out="$OUT_DIR/${base}.gz"

    if [[ -f "$out" ]] && gzip -t "$out" 2>/dev/null; then
        echo "Skipping: $base"
        return
    fi

    echo "Compressing: $base"
    pigz -p 2 -c "$f" > "$out"
    gzip -t "$out"
}

export OUT_DIR
export -f compress_one

xargs -n 1 -P 4 bash -c 'compress_one "$1"' _ \
    < "/tmp/fastq_list_${SLURM_JOB_ID}.txt"

rm -f "/tmp/fastq_list_${SLURM_JOB_ID}.txt"

# Generate final list of compressed FASTQs.
find "$OUT_DIR" \
    -maxdepth 1 \
    -type f \
    -name "*.fastq.gz" \
    -printf "%f\n" \
    | sort > "$OUT_DIR/fastqs_only_file_list.txt"

echo
echo "Compression complete."
echo "Compressed FASTQs: $(find "$OUT_DIR" -maxdepth 1 -name "*.fastq.gz" | wc -l)"
echo "File list: $OUT_DIR/fastqs_only_file_list.txt"
```
