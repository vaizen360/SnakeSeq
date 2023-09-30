# SnakeSeq
A ChIP sequencing Pipeline Designed for Individual Strand Sequencing Analysis
The purposes of this pipeline is to be able to individually process forward and reverse strands in a large dataset of ChiP sequencing reads to be able to assess whether there is particular strandedness in your results. 

The pipeline is built in snakemake and requires you to have downloaded snakemake, fastp, bowtie2, samtools, and deeptools. The reference genome used for alignment in the bowtie2 rule is the hg38 reference genome but can easily be modified with a separate file. 

This pipeline also runs in conda version 23.5.0 and python version 3.9.16. It requires a specific conda environment in order for the fastp rule to be able to run. This environment is included in the pipeline. The output of this workflow are three bigwig files: reverse strand, forward strand, and both strands. These bigwig files can then be further processed and visualized using deeptools, separately. 
