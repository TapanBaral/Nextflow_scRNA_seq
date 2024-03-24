process ALEVINQC {
  publishDir "${params.outdir}/04_02_alevinQCReport", mode: "copy"
    tag "$sample_id"
    label 'process_low'

    //The alevinqc 1.14.0 container is broken, missing some libraries - thus reverting this to previous 1.12.1 version
    conda "bioconda::bioconductor-alevinqc=1.12.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bioconductor-alevinqc:1.12.1--r41h9f5acd7_0' :
        'biocontainers/bioconductor-alevinqc:1.12.1--r41h9f5acd7_0' }"

    input:
    tuple val(sample_id), path(alevin_results)

    output:
    tuple val(sample_id), path("alevin_report_${sample_id}.html"), emit: report
    path  "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${sample_id}"
    """
    
     #!/usr/bin/env Rscript
    require(alevinQC)
     alevinQCReport(
        baseDir = "${alevin_results}",
        sampleId = "${sample_id}",
        outputFile = "alevin_report_${sample_id}.html",
        outputFormat = "html_document",
        outputDir = ".",
        forceOverwrite = TRUE
    )
    
    yaml::write_yaml(
        list(
            '${task.process}'=list(
                'alevinqc' = paste(packageVersion('alevinQC'), collapse='.')
            )
        ),
        "versions.yml"
    )
  
    """
}

