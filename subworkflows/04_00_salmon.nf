
// INCLUDE MODULES

include {  INDEX_SALMON    } from '../modules/04_00_salmon_index.nf'
include {  ALEVIN_QUANTIFY } from '../modules/04_01_alevin_quantify.nf'
include {  ALEVINQC        } from '../modules/04_02_alevin_QC_report.nf'

def multiqc_report    = []

workflow SCRNASEQ_ALEVIN {
    take:
    salmon_index
    transcriptome
    genome
    kmer
    trimmed_read
    txp2gene
  

    main:
    ch_versions = Channel.empty()
  
 	
    /*
    * Build salmon index
    */
    if (!salmon_index) {
        INDEX_SALMON( transcriptome, kmer )
        salmon_index = INDEX_SALMON.out.index
        ch_versions = ch_versions.mix(INDEX_SALMON.out.versions)
    }else{
        salmon_index = salmon_index
        ch_versions =  Channel.empty()
    }
        

            /*
            * Perform quantification with salmon alevin
            */
            ALEVIN_QUANTIFY (
            trimmed_read,
            salmon_index,
            txp2gene
            )

            /*
            * Run QC report module  
            */
            ALEVINQC( ALEVIN_QUANTIFY.out.alevin_results )
            ch_versions = ch_versions.mix(ALEVINQC.out.versions)

    emit:
    ch_versions
    alevin_results = ALEVIN_QUANTIFY.out.alevin_results
    alevinqc = ALEVINQC.out.report
}
 
   
    

