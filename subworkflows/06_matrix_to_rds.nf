include { MTX_TO_SEURAT   } from '../modules/06_seurat_object.nf'


workflow MTX_CONVERSION { 

    take:
    mtx_matrices


    main:
    ch_versions = Channel.empty()

        //
        // Convert matrix do seurat
        //
        MTX_TO_SEURAT (
            mtx_matrices
        )

        emit:
        seurat_matrix = MTX_TO_SEURAT.out.seuratObjects
}

