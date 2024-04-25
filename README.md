# SnakeSeq
#Introduction
A ChIP sequencing Pipeline Designed for Individual Strand Sequencing Analysis

The purposes of this pipeline is to be able to individually process forward and reverse strands in a large dataset of ChiP (Chromatin Immuno Precipitation) NGS sequencing reads to be able to assess whether there is particular strandedness in your results. 

#Requirements:
The pipeline is built in snakemake and requires you to have downloaded the following packages:
1.snakemake: Workflow management system that produces a snakefile, almost like a makefile. In order for the snakefile to run, you need snakemake. https://snakemake.github.io/
2.fastp: trims adaptors after NGS sequencing.https://github.com/OpenGene/fastp
3. bowtie2: Aligns your sequence reads to a reference genome. In this case we used hg38. Depending on your experiment and interests, the reference genome file that you use can vary, but you will need to download that file separately and place it in the same path as this snakefile. https://github.com/BenLangmead/bowtie2
4.samtools: Allows you to manipulate and sort through your now aligned reads and outputs a bam file. https://github.com/samtools/samtools
For the purposes of this workflow, we wanted three files: 1) A file with all the aligned reads, 2) two files per forward read, separated by flags of our interest. In this case we chose 99 and 147, 3) two files per reverse read, separated by flags of our interest. In this case we chose 83 and 163. Changing which flags you use can be completed by going into Choosing which flags to use can be determined using the following link: https://broadinstitute.github.io/picard/explain-flags.html 
5.deeptools: 

This pipeline also runs in conda version 23.5.0 and python version 3.9.16. It requires a specific conda environment in order for the fastp rule to be able to run. This environment is included in the pipeline. The output of this workflow are three bigwig files: reverse strand, forward strand, and both strands. These bigwig files can then be further processed and visualized using deeptools, separately. 

#Running:
