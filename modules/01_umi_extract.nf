process UMI_EXTRACT {
    container 'biocontainers/umi_tools:1.1.5--py39hf95cd2a_0'
    publishDir "${params.outdir}/01_umi_results", mode:"copy"
    label "small_mem"
    tag "umiExtract on $sample_id"
    input:
        tuple val(sample_id), file(fastq1), file(fastq2)
    output:
        
        tuple val(sample_id), file("${fastq1.baseName}.u1.fastq.gz"),
            file("${fastq2.baseName}.u1.fastq.gz"), emit: u1_fastqs

        path  "versions.yml"                       , emit: versions
    script:
    """
    umi_tools extract -I ${fastq1} --bc-pattern=${params.bcPattern} --3prime --read2-in=${fastq2} --stdout=${fastq1.baseName}.u1.fastq.gz --read2-out=${fastq2.baseName}.u1.fastq.gz
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        umitools: \$( umi_tools --version | sed '/version:/!d; s/.*: //' )
    END_VERSIONS
    """
}

