#The purpose of this code is to process a large dataset of ChIP
#Sequencing files, from trimming to producing three separate bigwig files, 
#one for both the forward and reverse strand reads, and two separate for 
#the reverse and forward strands. These bigwig files can further be processed
#and visualized using deeptools, separately. 

## Define base path here
base_path = "/Users/valeriaaizen/Documents/code/notebooks/snakemake-attempt/"

# activate conda environment
conda: "/Users/valeriaaizen/myenv_86.yaml"

# Define list of sample names
samples = ["M28B_150k", "M31A_150k"]

#Rule all with all the target files
rule all:
	input:
		expand(base_path + "bigwig/{sample}_forward.bw", sample=samples),
		expand(base_path + "bigwig/{sample}_reverse.bw", sample=samples),
		expand(base_path + "bigwig/{sample}.bw", sample=samples)

# Define other rules for the workflow below

#First rule utilizes fastp to trim the adaptor sequences and any bad reads from the fastq files. 
#The output should produce a trimmed read1 and read2 (R1 and R2) file in a new folder "trimmed" in the 
#snakemake attempt directory. It will also produce a jsonlog and html link with a summary of the reads.

#This specific fastp rule is able to identify reads with a quality score 
#lower than 10 and and remove them from the dataset, treat the dataset as interleaved and not include duplicates. 

rule fastp_adaptors:
	input:
		R1 = (base_path + "testfiles/{sample}_1.fq"),
		R2 = (base_path + "testfiles/{sample}_2.fq")

	output:
		R1_final = (base_path + "trimmed/{sample}_1_final.fq"),
		R2_final = (base_path + "trimmed/{sample}_2_final.fq"),
        	jsonlog = (base_path + "trimmed/{sample}_jsonlog.json"),
		htmllog = (base_path + "trimmed/{sample}_htmllog.html")
	shell:
		"""
		fastp -w 8 --dont_eval_duplication -i {input.R1} -I {input.R2} -t 10 -F 10 -o {output.R1_final} -O {output.R2_final} --detect_adapter_for_pe -j {output.jsonlog} -h {output.htmllog}
		"""

#Now we want to try to take the final trimmed and processed fastq file versions and align them to a reference genome - in this case hg38. This will produce
#A "sam all file including both the forward and the reverse reads"
#The Genome provided here is hg38 but can be modified to be any reference genome file of interest. 
rule bowtie2:
	input:
		R1_final = (base_path + "trimmed/{sample}_1_final.fq"),
		R2_final = (base_path + "trimmed/{sample}_2_final.fq")
	output:
		aligned_sam = (base_path + "align/{sample}_aligned.sam")
	shell:
		"""
		bowtie2 -p 16 --very-sensitive-local -x /Users/valeriaaizen/Documents/code/notebooks/snakemake-attempt/Genomes/hg38/hg38 -1 {input.R1_final} -2 {input.R2_final} -S {output.aligned_sam}
		"""
#Now that we have a sam file from bowtie2 where our sequencing reads are aligned to the hg38 reference genome, we want to sort
#the aligned reads using samtools. The output should be a bam all file. 
rule samtools_sort:
	input:
		aligned_sam = (base_path + "align/{sample}_aligned.sam")
	output:
		aligned_bam = (base_path + "bam/{sample}_all.bam")
	threads: 16
	shell:
		"""
		samtools sort -@ {threads} -o {output.aligned_bam} {input.aligned_sam}
		"""
#Samtools will now sort four times, separately, the forward reads from the reverse and then merge them
#For reference, the samtools flags for the reverse and forward reads are not in the original fastq files - these
#flags now exist in the aligned sam file created in the bowtie2 rule
rule samtools_sort99:
	input:
		aligned_sam = (base_path + "align/{sample}_aligned.sam")
	output:
		aligned_99_bam = (base_path + "bam/{sample}_flag99.bam")
	shell:
		"""
		samtools view -h -F 99 {input.aligned_sam} > {output.aligned_99_bam}
		"""

rule samtools_sort147:
	input:
		aligned_sam = (base_path + "align/{sample}_aligned.sam")
	output:
		aligned_147_bam = (base_path + "bam/{sample}_flag147.bam")
	shell:
		"""
		samtools view -h -F 147 {input.aligned_sam} > {output.aligned_147_bam}
		"""

rule samtools_sort83:
	input:
		aligned_sam = (base_path + "align/{sample}_aligned.sam")
	output:
		aligned_83_bam = (base_path + "bam/{sample}_flag83.bam")
	shell:
		"""
		samtools view -h -F 83 {input.aligned_sam} > {output.aligned_83_bam}
		"""
rule samtools_sort163:
	input:
		aligned_sam = (base_path + "align/{sample}_aligned.sam")
	output:
		aligned_163_bam = (base_path + "bam/{sample}_flag163.bam")
	shell:
		"""
		samtools view -h -F 163 {input.aligned_sam} > {output.aligned_163_bam}
		"""
#Now that we have separated the sorted sam file into four different bam files with forward and reverse reads
#We want to concatenate all the forward bam files together and all the reverse bam files together. So in the 
#End we should have reverse, forward, and TOTAL bam files.  
rule merge_99147:
	input:
		bam99 = (base_path + "bam/{sample}_flag99.bam"),
		bam147 = (base_path + "bam/{sample}_flag147.bam")
	output:
		bam_forward = (base_path + "bam/{sample}_forward.bam")
	shell:
		"""
		samtools merge {output.bam_forward} {input.bam99} {input.bam147} 
		"""

rule merge_83163:
	input:
		bam83=(base_path + "bam/{sample}_flag83.bam"),
		bam163=(base_path + "bam/{sample}_flag163.bam")
	output:
		bam_reverse=(base_path + "bam/{sample}_reverse.bam")
	shell:
		"""
		samtools merge {output.bam_reverse} {input.bam83} {input.bam163} 
		"""
#From the above rules, we now have the following three files: a bam file, a merged reverse reads bam file, and a 
#merged forward reads bam file. All three have already been sorted, but we still need to index all three before we 
#Can start using deeptools. Each needs to be indexed separately in the following three rules. 
rule samtools_indexall:
	input:
		aligned_bam = (base_path + "bam/{sample}_all.bam")
	output:
		bai_all = (base_path + "bam/{sample}_all.bam.bai")
	shell:
		"""
		samtools index {input.aligned_bam} {output.bai_all}
		"""
rule samtools_indexforward:
	input:
		bam_forward = (base_path + "bam/{sample}_forward.bam")
	output:
		bai_forward = (base_path + "bam/{sample}_forward.bam.bai")
	shell:
		"""
		samtools index {input.bam_forward} {output.bai_forward}
		"""
rule samtools_indexreverse:
	input:
		bam_reverse = (base_path + "bam/{sample}_reverse.bam")
	output:
		bai_reverse = (base_path + "bam/{sample}_reverse.bam.bai")
	shell:
		"""
		samtools index {input.bam_reverse} {output.bai_reverse}
		"""
#From the above rules, we now have three indexed bam files i.e. three bai files. One for the forward strand, one for 
#The reverse strand, and one total indexed bam file. We want to take these indexed files and now create them into 
#bigwig files that can be read and manipulated within deeptools to create heatmaps, matrixes, etc. 
rule deeptools_bigwigall:
	input:
		aligned_bam = (base_path + "bam/{sample}_all.bam"),
		bai_all = (base_path + "bam/{sample}_all.bam.bai")
	output:
		bigwig_all = (base_path + "bigwig/{sample}.bw")
	params:
		num_threads=4,
		bin_size=50
	shell:
		"""
		bamCoverage \
			--bam {input.aligned_bam} \
			--outFileName {output.bigwig_all} \
			--binSize {params.bin_size} \
			--normalizeUsing RPKM
		"""

#Bigwig for forward strand
rule deeptools_bigwigforward:
	input:
		bam_forward = (base_path + "bam/{sample}_forward.bam"),
		bai_forward = (base_path + "bam/{sample}_forward.bam.bai")
	output:
		bigwig_forward = (base_path + "bigwig/{sample}_forward.bw")
	params:
		num_threads=4,
		bin_size=50
	shell:
		"""
		 bamCoverage \
			--bam {input.bam_forward} \
			--outFileName {output.bigwig_forward} \
			--binSize {params.bin_size} \
			--normalizeUsing RPKM
		"""

#Bigwig for reverse strand
rule deeptools_bigwigreverse:
	input:
		bam_reverse = (base_path + "bam/{sample}_reverse.bam"),
		bai_reverse = (base_path + "bam/{sample}_reverse.bam.bai")
	output:
		bigwig_reverse = (base_path + "bigwig/{sample}_reverse.bw")
	params:
		num_threads=4,
		bin_size=50
	shell:
		"""
		 bamCoverage \a
			--bam {input.bam_reverse} \
			--outFileName {output.bigwig_reverse} \
			--binSize {params.bin_size} \
			--normalizeUsing RPKM
		"""






