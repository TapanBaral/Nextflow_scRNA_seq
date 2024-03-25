process DATAINTEGRATION {
    tag "$rds_object"
    label 'process_medium'
    container 'nf-core/seurat:4.3.0'

    publishDir "${params.outdir}/07_data_integration", mode: 'copy'

    input:
    path(rds_object)

    output:
    path 'integratedData/report.html',      emit: htmlReport
    path 'integratedData/*.rds',            emit: integratedDataRDS
    path "versions.yml",                    emit: versions

    script:
    """
    mkdir results
    data_integration.R ${rds_object} results
    """
}
