# SnakeSeq: A ChIP sequencing Pipeline Designed for Individual Strand Sequencing Analysis

**Introduction**

The purposes of this pipeline is to be able to individually process forward and reverse strands in a large dataset of ChiP (Chromatin Immuno Precipitation) NGS sequencing reads to be able to assess whether there is particular strandedness in your results. 

**Requirements:**

The pipeline is built in snakemake and requires you to have downloaded the following packages:

1. [Snakemake]( https://snakemake.github.io/): Workflow management system that produces a snakefile, almost like a makefile. In order for the snakefile to run, you need snakemake
2. [fastp](https://github.com/OpenGene/fastp): trims adaptors after NGS sequencing
3. [bowtie2](https://github.com/BenLangmead/bowtie2): Aligns your sequence reads to a [reference genome](https://genome.ucsc.edu/cgi-bin/hgTracks?db=hg38&lastVirtModeType=default&lastVirtModeExtraState=&virtModeType=default&virtMode=0&nonVirtPosition=&position=chr2%3A25160915%2D25168903&hgsid=2170215356_UFUKgCaa5CsokWmNMWDYF1RhwZAf). In this case we used hg38, but depending on your experiment and interests, the reference genome file that you use can vary, but you will need to download that file separately and place it in the same path as this snakefile.
4. [deeptools](https://github.com/deeptools/deepTools): There should now be three indexed bam files - one for both strand reads, one for the forward strand, and one for the reverse strand. For our purposes, we defined a separate rule for each bam file for deeptools to create a bigwig file.Bigwig files can then be further manipulated within deeptools to create heatmaps and matrixes. 
5. [Samtools](https://github.com/samtools/samtools): Allows you to manipulate and sort through your now aligned reads and outputs a bam file. 

  For the purposes of this workflow, we wanted three files: 

  1. A file with all the aligned reads,
  2. Two files per forward read, separated by flags of our interest. In this case we chose 99 and 147,
  3. Two files per reverse read, separated by flags of our interest. In this case we chose 83 and 163. Changing which flags you use can be completed by going into samtools_sort     rules. Choosing which flags to use can be determined using the following [link](https://broadinstitute.github.io/picard/explain-flags.html)


**Running:**

Conda version 23.5.0 and python version 3.9.16. This code was run on an M1 13.4.1 macOS Ventura system, which initially was not compatible with downloading fastp. If you have arm64 architecture instead of x86, as most newer mac computers do, you may need to create a separate conda environment. The yaml file to configure your workspace to run the snakefile is included in the repository. 

To run the snakefile, activate the myenv_86 conda environment in terminal, and then use ```snakemake --cores 4```

The following workflow image demonstrates the dependencies of the rules and the order in which they would be executed. If you'd like to create your own workflow image, you can use '''snakemake --dag|dot - Tpng>workflow_dag.png'''

![workflow_dag](https://github.com/vaizen360/SnakeSeq/assets/134992475/45ab08c3-107c-40f6-b15e-8db57d1785e2)
