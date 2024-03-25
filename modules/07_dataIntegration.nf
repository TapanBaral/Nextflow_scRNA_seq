process DATAINTEGRATION {

    container 'nf-core/seurat:4.3.0'

    publishDir "${params.outdir}/07_data_integration", mode: 'copy'

    input:
    val(sample_id), path(input_dir)
    val(output_dir)
    path rmd

    output:
    path 'integratedData/report.html',      emit: htmlReport
    path 'integratedData/*.rds',            emit: integratedDataRDS
    path "versions.yml",                    emit: versions

    script:
    """
    my_integration_script.R ${input_dir} ${output_dir}
    """
}