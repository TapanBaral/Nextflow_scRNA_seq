# WORKFLOW FOR SINGLE CELL RNA-SEQ DATA ANALYSIS

Here is a description of the Nextflow pipeline for single-cell RNA-seq data analysis that includes the key features and steps of the pipeline:

This pipeline is designed for analyzing single-cell RNA-seq data from paired-end fastq.gz files generated from 10X or SmartSeq2 platforms. The user can choose between STAR or Salmon alignment tools for read quantification. The final output of the pipeline is a data integration rds Seurat object, which can be used for downstream analysis.

The pipeline consists of the following steps:

1. Quality check: The pipeline performs a quality check of 2.the input files using FastQC.
2. UMI extraction: The UMIs (unique molecular identifiers) are extracted from the reads using UMI-tools.
3. Quality filtering: The reads are filtered for bad quality using Fastp.
4. Post-processing: The filtered reads are processed using FastQC again.
5. Alignment and quantification: The reads are aligned and quantified using either STAR or Salmon alignment tools.
6. Data integration: The final output of the pipeline is a data integration rds Seurat object, which is created using Seurat CCA for data integration.


 ## Input files 
   A TAB delimited sample information <a href="https://github.com/TapanBaral/Nextflow_scRNA_seq/blob/main/Assets/sampleInfo.txt"> file </a>.
   Reference Genome and transcriptome fasta file and gtf file
   A whitelist <a href="https://kb.10xgenomics.com/hc/en-us/articles/360031133451-Why-is-there-a-discrepancy-in-the-3M-february-2018-txt-barcode-whitelist"> file </a>.

   A Manifest.tsv <a href="https://kb.10xgenomics.com/hc/en-us/articles/360031133451-Why-is-there-a-discrepancy-in-the-3M-february-2018-txt-barcode-whitelist"> file </a> for plate based quantification.  

   Based on the resources number of threads and memmory can be allocated to the pipeline 


## SET UP NEXTFLOW


Follow the <a href="https://www.nextflow.io/docs/latest/getstarted.html" target="_blank">Nextflow</a>  installation instructions to install Nextflow on your system.

###  IMPORT THE WORKFLOW 
```{bash}
 nextflow pull TapanBaral/Nextflow_scRNA_seq -r master
```


## PARAMETERS AND INPUTS
Commands:  nextflow run TapanBaral/Nextflow_scRNA_seq [--help]
  #### Sample Information File:                        
     --inputfiles                      A TAB delimited without header file, first column sample name, second column full path to the    read1  and 3rd column full path to the read2
  #### QC checks:
     --skip_pre_fastqc                  Skip pre-fastqc                                     [default: false]
     --skip_post_fastqc                 Skip post-fastqc                                    [default: false]

  #### UMI extraction:
     --skip_umi_extract                 Skip UMI extraction                                 [default: false]
     --bcPattern <pattern>              Barcode pattern for UMI extraction  from 3' end     [default: XNNNNNCX]

  #### Trimming of FASTQ files:
     --skip_fastp                       Skip trimming of FASTQ files                        [default: false]

  #### Set reference files:
     --transcriptome <path>             Path to the transcriptome FASTA file (For aligner: salmon)
     --genome_fasta <path>              Path to the genome FASTA file (For aligner: STAR)
     --transcript_gtf <path>            Path to the annotation GTF file
     --txp2gene <path>                  Path to the transcript-to-gene mapping file
     --star_index <path>                Path to STAR index   (Optional)                    
     --salmon_index <path>              Path to Salmon index (Optional) 

  #### Alignment parameters:
     --aligner <name>                   The name of the aligner to use                      [default: star]
     --protocol <name>                  The name of the alignment protocol to use           [default: droplet]
     --whitelist <path>                 Path to the cell barcode whitelist file  
     --manifest <path>                  Path to the sample manifest file , a three column TAB delimitted file without header, column 1:                                 name of read1, column 2: name of the read2 and column 3: name of the sample

  #### Run parameters:
     --outdir <path>                    Output directory                                    [default: OutPut]
     --cpus <number>                    Number of CPUs to use                               [default: 6]
     --memory <size>                    Amount of memory to use                             [default: 16g]


## Ensure all input files are prepared and available

## RUN SALMON  ALIGNER

```{bash}
 nextflow  run TapanBaral/Nextflow_scRNA_seq --inputfiles $baseDir/sapmleInfo.txt --transcript_fasta $baseDir/ref/human/ensembl/Homo_sapiens.GRCh38.cdna.all.fa --gtf $baseDir/ref/human/ensembl/Homo_sapiens.GRCh38.109_chr1.gtf --aligner 'salmon'  --outdir OutPut_SALMON -profile docker --txp2gene $baseDir/txp2gene1.tsv   --skip_fastp true --skip_umi_extract true   --skip_post_fastqc true
```


## RUN STAR  ALIGNER, DROPLET 
```{bash}
 nextflow  run TapanBaral/Nextflow_scRNA_seq --inputfiles $baseDir/sapmleInfo.txt --genome_fasta $baseDir/ref/human/ensembl/Homo_sapiens.GRCh38.dna.chromosome.1.fa --gtf $baseDir/ref/human/ensembl/Homo_sapiens.GRCh38.109_chr1.gtf --aligner 'star'  --outdir OutPut_STAR -profile docker --txp2gene $baseDir/txp2gene1.tsv   --skip_fastp true --skip_umi_extract true --protocol 'droplet' --whitelist $baseDir/10x_V3_barcode_whitelist.txt.gz -resume --skip_post_fastqc true
```

## RUN STAR  ALIGNER, PLATE
```{bash}
 nextflow  run TapanBaral/Nextflow_scRNA_seq --inputfiles $baseDir/sapmleInfo.txt --genome_fasta $baseDir/ref/human/ensembl/Homo_sapiens.GRCh38.dna.chromosome.1.fa --gtf $baseDir/ref/human/ensembl/Homo_sapiens.GRCh38.109_chr1.gtf --aligner 'star'  --outdir OutPut_STAR -profile docker --txp2gene $baseDir/txp2gene1.tsv   --skip_fastp true --skip_umi_extract true --protocol 'plate' --manifest $baseDir/manifest.tsv -resume --skip_post_fastqc true
```