#!/usr/bin/env nextflow

nextflow.enable.dsl = 2



include { scRNAseq } from './workflow/scRNASeq.nf'



workflow scRNASEQ_WF{

    scRNAseq()
}

workflow{
    scRNASEQ_WF()
}
workflow.onComplete {
    log.info("Done! Open the following report in your browser --> ${params.outdir}/multiqc/multiqc_data/multiqc_report.html\n")
}



