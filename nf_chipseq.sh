#!/bin/bash
#SBATCH -N 1
#SBATCH -n 16
#SBATCH --mail-type=END
#SBATCH --job-name=chipseq
# HELLOOOOOOO TODO: Remove one '#' and change the email address below to your own
## SBATCH --mail-user=YOUR_USERNAME@mit.edu

module add miniconda3/v4
source /home/software/conda/miniconda3/bin/condainit
conda activate nf-core
module add singularity/3.10.4

# Go to working directory
#####HELLLOOOOOOOOO CHANGE THIS!!!!
cd /net/bmc-lab2/data/lab/sanchezrivera/hcevasco/260903San/

# Run nf-core chipseq
# HELLOOOOOOOOO THINGS HERE NEED TO BE ADJUSTED. I RAN THIS AGAINST THE MOUSE GENOME version m38 SO THAT'S WHAT'S IN THE FILES --fasta --gtf and --macs_gsize correspond to
# If you're running it against human genome, you need to swap out these files.
# you can also explore the --genome flag option in nf-core but for reproducibility, it's best to use your own build and keep it consistent
# gsize here is from the second table here https://deeptools.readthedocs.io/en/develop/content/feature/effectiveGenomeSize.html and is based on a read length of 150 (150 SE)

nextflow run nf-core/chipseq -r 2.1.0 -profile singularity,ki_luria \
--input samplesheet.csv \
--fasta /net/bmc-lab2/data/lab/sanchezrivera/hcevasco/ref_genomes/GRCm38.primary_assembly.genome.fa.gz \
--gtf /net/bmc-lab2/data/lab/sanchezrivera/hcevasco/ref_genomes/gencode.vM25.primary_assembly.annotation.gtf.gz \
--save_reference \
--macs_gsize 2410055689 \
--blacklist /net/bmc-lab2/data/lab/sanchezrivera/hcevasco/ref_genomes/mm10-blacklist.v2.bed \
--narrow_peak \
--outdir ./chipseq_results_narrow_peak
-resume
