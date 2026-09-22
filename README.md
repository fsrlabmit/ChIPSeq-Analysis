# ChIPSeq-Analysis


**Step 0: Copy your sequencing data to your personal folder** 
\
Copy your sequencing run files to your personal directory using the instructions provided in the email from the core. It's best to copy them to a directory with the project name for easy traceability (ie 260904_San/). 

**Step 1: Compress all of the .fastq files into a separate directory for easy access** 
\
Now in your personal directory on the server, you should have a directory/folder named after your sequencing run that contains subdirectories for each of your samples. 

<img width="580" height="381" alt="image" src="https://github.com/user-attachments/assets/18769405-2b7a-400e-aa28-0ba08453e998" />

Each sample has a forward R1 and reverse R2 read if you did PE sequencing (which is most common). In order to run our analysis in nf-core, we need to take only the .fastq files from each of the sample directories, compress them, compile them into a dedicated directory with just the compressed files, and make a .txt file that lists all of the gzipped files. The gzip.sh script will do all of this for you. To use it, copy the gzip.sh file to your working directory (the main 260904_San equivalent). The script is going to read through all of the other directories and compress any .fastq files to a new fastqs_only directory while leaving the original .fastq files untouched in their original folder. 

You only need to edit the [gzip.sh file](gzip.sh) to add your email address if you want to be notified when the run finishes. 

Make sure you are in the correct directory (the main one containing all of the subdirectories for your samples) and submit the gzip.sh with the following command:

`sbatch gzip.sh`

This will take a bit to run but you should see parallel processes start to run on the cluster by calling 

`squeue -u` followed by your kerb

**Step 2: Install nf-core conda environment** Once you have your fastqs_only folder now with all the gzipped files in them, we can run the nf-core chip seq pipeline. 

First, you will need to make a nf-core conda environment using the instructions provided here by the core: https://igb.mit.edu/mini-courses/advanced-utilization-of-igb-computational-resources/running-nextflow-nf-core-pipelines#installing-nf-core-nextflow 

Nextflow and nf-core are installed through Conda, so we'll want to make sure we activate the Conda module before starting:

```
srun --pty bash # Start an interactive session on a compute node

module load miniconda3/v4

source /home/software/conda/miniconda3/bin/condainit
```
They also require us to have specific channels configured:
```
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge
```
Once these channels have been added, we can go along with the installation:
```
conda create --name nf-core
conda activate nf-core
conda install python=3.12 nf-core=2.13.1 nextflow=24.10.4
```

**Step 3: Prepare nf-core_chipseq.sh pipeline**
\
To run the pipeline, there are a few components you need to set up first. To begin, download the samplesheet.csv and replace the file paths and names with those of your samples. Also change which antibodies are used and which input controls each sample should be analyzed against. If you have a lot of samples, there's probably a way to upload a screenshot of your fastqs_only folder and have AI fill this out for you. 
\
An example of what the sheet should look like:
<img width="889" height="115" alt="image" src="https://github.com/user-attachments/assets/2296fe78-1606-4e02-9a2c-80dbdaeea573" />

You also need to copy the nf-core_chipseq.sh file to your directory and change several parts so they are specific to your pipeline run. I've commented things like "HELLOOOOOOO" where you need to edit.
```
# HELLOOOOOOO TODO: Remove one '#' and change the email address below to your own
## SBATCH --mail-user=YOUR_USERNAME@mit.edu
```

```# Go to working directory
#####HELLLOOOOOOOOO CHANGE THIS!!!!
cd /net/bmc-lab2/data/lab/sanchezrivera/hcevasco/260903San/

# Run nf-core chipseq
# HELLOOOOOOOOO THINGS HERE NEED TO BE ADJUSTED. I RAN THIS AGAINST THE MOUSE GENOME SO THAT IS WHAT THE FILES IN -- fasta --gtf and --macs_gsize correspond to
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
```

Note that you need to edit your email address, the path to the working directory, and change many of the file paths in the actual nextflow command list. See the commend about using the correct genome for your samples. Reference genomes that we have used in the lab are in the ref_genomes folder in this repository. 



