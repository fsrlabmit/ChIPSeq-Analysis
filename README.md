# ChIPSeq-Analysis


**Step 0:** Copy your sequencing run files to your personal directory using the instructions provided in the email from the core. It's best to copy them to a directory with the project name for easy traceability (ie 260904_San/). 

**Step 1:** Now in your personal directory on the server, you should have a directory/folder named after your sequencing run that contains subdirectories for each of your samples. 

<img width="580" height="381" alt="image" src="https://github.com/user-attachments/assets/18769405-2b7a-400e-aa28-0ba08453e998" />

Each sample has a forward R1 and reverse R2 read if you did PE sequencing (which is most common). In order to run our analysis in nf-core, we need to take only the .fastq files from each of the sample directories, compress them, compile them into a dedicated directory with just the compressed files, and make a .txt file that lists all of the gzipped files. The gzip.sh script will do all of this for you. To use it, copy the gzip.sh file to your working directory (the main 260904_San equivalent). The script is going to read through all of the other directories and compress any .fastq files to a new fastqs_only directory while leaving the original .fastq files untouched in their original folder. 

You only need to edit the gzip.sh file to add your email address if you want to be notified when the run finishes. 

Make sure you are in the correct directory (the main one containing all of the subdirectories for your samples) and submit the gzip.sh with the following command:

'sbatch gzip.sh'
