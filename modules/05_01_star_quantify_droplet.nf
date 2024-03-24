process STAR_QUANTIFY_DROPLET {
  cpus params.cpus
  publishDir "${params.outdir}/05_01_star_quant", mode: "copy"
  tag "$sample_id "
  label "big_mem"
  input:
    path index
    tuple val(sample_id), file(fastq1), file(fastq2)
    path whitelist
  output:
    tuple val(sample_id), path("*")
    tuple val(sample_id), path('10X_quantify/STAR/*d.out.bam')            , emit: bam
    tuple val(sample_id), path('10X_quantify/STAR/*Log.final.out')        , emit: log_final
    tuple val(sample_id), path('10X_quantify/STAR/*Log.out')              , emit: log_out
    tuple val(sample_id), path('10X_quantify/STAR/*Log.progress.out')     , emit: log_progress
    tuple val(sample_id), path('10X_quantify/STAR/*.tab')                 , optional:true, emit: tab
    tuple val(sample_id), path('10X_quantify/STAR/*_Solo.out')            , emit: counts
    path "versions.yml"                                                   , emit: versions

  script:
  """
  
  STAR --runThreadN ${task.cpus} --genomeDir ${index} \
  --readFilesIn ${fastq1} ${fastq2} \
  --readFilesCommand zcat \
  --outFilterScoreMinOverLread 0 --outFilterMatchNminOverLread 0 --outFilterMatchNmin 0 --outFilterMismatchNmax 2 \
  --outFileNamePrefix 10X_quantify/STAR/${sample_id}_ \
  --soloType CB_UMI_Simple \
  --soloBarcodeReadLength 0 \
  --soloCBwhitelist <(gzip -cdf $whitelist) \
  --outSAMattributes GX GN \
  --outSAMtype BAM SortedByCoordinate 

  if [ -d 10X_quantify/STAR/${sample_id}_Solo.out ]; then
        # Backslashes still need to be escaped (https://github.com/nextflow-io/nextflow/issues/67)
        find 10X_quantify/STAR/${sample_id}_Solo.out \\( -name "*.tsv" -o -name "*.mtx" \\) -exec gzip {} \\;
    fi

  cat <<-END_VERSIONS > versions.yml
  "${task.process}":
      star: \$(STAR --version | sed -e "s/STAR_//g")
      samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
      gawk: \$(echo \$(gawk --version 2>&1) | sed 's/^.*GNU Awk //; s/, .*\$//')
  END_VERSIONS
  """
  
}

