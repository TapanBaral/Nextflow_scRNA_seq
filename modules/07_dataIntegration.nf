process DATAINTEGRATION {

    container 'nf-core/seurat:4.3.0'

    publishDir "${params.outdir}/07_data_integration", mode: 'copy'

    input:
    val(sample_id),path(inputs)
    path rmd

    output:
    path 'integratedData/report.html',              emit: htmlReport
    path "integratedData/*.rds",                    emit: integratedDataRDS
    path "versions.yml",                            emit: versions

    """
    mkdir integratedData
    Rscript -e "rmarkdown::render('${rmd}', intermediates_dir = 'seurat_object' , output_dir = 'integratedData')"
    """
}