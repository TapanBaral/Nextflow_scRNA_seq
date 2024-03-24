process TRIM {
    container 'biocontainers/fastp:0.23.4--h5f740d0_0'
    cpus params.cpus
    memory params.memory
    tag "${sample_id}"
    publishDir "${params.outdir}/02_fastp/", mode:"copy"

    label "small_mem"

    input:
        
        tuple val(sample_id), file(fastq1), file(fastq2)

    output:
        tuple val(sample_id), file("${fastq1.baseName}.trimmed.fq.gz"),
            file("${fastq2.baseName}.trimmed.fq.gz"), emit: trimmed_fastqs
        file("${sample_id}.fastp_stats.json")
        file("${sample_id}.fastp_stats.html")
        tuple val(sample_id), path("*.html"), emit: html
        tuple val(sample_id), path("*.json") , emit: json
        path  "versions.yml"           , emit: versions
        

    """
    # --input_files needs to be forced, otherwise it is inherited from profile in tests
    fastp \
    --in1 ${fastq1} \
    --in2 ${fastq2} \
    --out1 ${fastq1.baseName}.trimmed.fq.gz \
    --out2 ${fastq2.baseName}.trimmed.fq.gz \
    --json ${sample_id}.fastp_stats.json \
    --html ${sample_id}.fastp_stats.html \
    --thread ${params.cpus}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fastp: \$(fastp --version 2>&1 | sed -e "s/fastp //g")
    END_VERSIONS
   """
}

