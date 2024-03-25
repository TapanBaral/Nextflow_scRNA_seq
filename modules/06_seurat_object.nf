process MTX_TO_SEURAT {
    tag "$sample_id"
    label 'process_medium'
    publishDir "${params.outdir}/06_matrix_rds_output", mode: "copy"
    conda "r-seurat"
    container "nf-core/seurat:4.3.0"

    input:
    // inputs from cellranger nf-core module does not come in a single sample dir
    // for each sample, the sub-folders and files come directly in array.
    tuple val(sample_id), path(inputs)

    output:
    path "${sample_id}/*.rds", emit: seuratObjects
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def aligner = params.aligner
    if (params.aligner == "salmon") {
        matrix   = "*alevin_quant/alevin/quants_mat.gz"
        barcodes = "*alevin_quant/alevin/quants_mat_rows.txt"
        features = "*alevin_quant/alevin/quants_mat_cols.txt"
    } else if (params.aligner == 'star') {
        matrix   = "*_Solo.out/Gene*/filtered/matrix.mtx.gz"
        barcodes = "*_Solo.out/Gene*/filtered/barcodes.tsv.gz"
        features = "*_Solo.out/Gene*/filtered/features.tsv.gz"
    }
    """
    mkdir ${sample_id}
    """

   

    
    """
    mtx_to_seurat.R \\
        $matrix \\
        $barcodes \\
        $features \\
        ${sample_id}/${sample_id}_matrix.rds \\
        ${aligner}
    """

    stub:
    """
    mkdir ${sample_id}
    touch ${sample_id}/${sample_id}_matrix.rds
    touch versions.yml
    """
}

