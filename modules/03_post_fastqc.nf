process POSTQC {
 container 'biocontainers/fastqc:0.12.1--hdfd78af_0'

 cpus params.cpus
 publishDir "${params.outdir}/03_postQC_results", mode: "copy"
 tag "QC on $sample_id"
 label "small_mem"
 input:
 tuple val(sample_id), file(fastq1), file(fastq2)
 output:
    //path("postQC_results")
    tuple val(sample_id), path("*.html"), emit: html
    tuple val(sample_id), path("*.zip") , emit: zip
    path  "versions.yml"           , emit: versions
 script:
 """
 
 fastqc ${fastq1} ${fastq2} -t {task.cpus}

 
cat <<-END_VERSIONS > versions.yml
"${task.process}":
fastqc: \$( fastqc --version | sed '/FastQC v/!d; s/.*v//' )
END_VERSIONS

 """
}
