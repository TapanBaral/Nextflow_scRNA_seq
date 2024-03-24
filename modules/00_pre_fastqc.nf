process PREFASTQC {
 container 'biocontainers/fastqc:0.12.1--hdfd78af_0'

 cpus params.cpus
 publishDir "${params.outdir}/00_pre_fastqc_results", mode: "copy"
 tag "QC on $sample_id"
 label "small_mem"
 input:
 tuple val(sample_id), file(fastq1), file(fastq2)
 
 output:
    path("*.html"), emit: html
    path("*.zip") , emit: zip
    path  "versions.yml"           , emit: versions

 when:
    task.ext.when == null || task.ext.when
 script:
 """
 
 fastqc ${fastq1} ${fastq2} -t ${task.cpus}

cat <<-END_VERSIONS > versions.yml
"${task.process}":
fastqc: \$( fastqc --version | sed '/FastQC v/!d; s/.*v//' )
END_VERSIONS
 """
}
