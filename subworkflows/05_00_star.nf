

//INCLDE MODULES
include { INDEX_STAR             } from '../modules/05_00_star_index.nf'
include { STAR_QUANTIFY_DROPLET  } from '../modules/05_01_star_quantify_droplet.nf'
include { STAR_QUANTIFY_PLATE    } from '../modules/05_02_star_quantify_plate.nf'

workflow SCRNASEQ_STAR{
    take:
    star_index
    genome_fasta
    gtf
    trimmed_read
    whitelist
    manifest
    main:
    ch_versions = Channel.empty()
     /*
     * Build salmon index
    */
    if (!star_index) {
        INDEX_STAR( genome_fasta, gtf )
        star_index = INDEX_STAR.out.index
        ch_versions = ch_versions.mix(INDEX_STAR.out.versions)
    }else{
        star_index = star_index
        ch_versions =  Channel.empty()
    }
    /*
     * Quantification 
     *
     *quantified = STAR_QUANTIFY_DROPLET (trimmed_read, star_index, whitelist)
     */
    if(params.protocol  == "droplet"){
        STAR_QUANTIFY_DROPLET(
            star_index,
            trimmed_read,
            whitelist
        )
     //STAR DROPLET RESULTS
    star_result = STAR_QUANTIFY_DROPLET.out.tab
    star_counts = STAR_QUANTIFY_DROPLET.out.counts
    star_multiqc = STAR_QUANTIFY_DROPLET.out.log_final

    }else{
       STAR_QUANTIFY_PLATE(
            star_index,
            trimmed_read,
            manifest
       ) 
    //STAR PLATE RESULTS
    star_result   = STAR_QUANTIFY_PLATE.out.tab
    star_counts   = STAR_QUANTIFY_PLATE.out.counts
    star_multiqc  = STAR_QUANTIFY_PLATE.out.log_final

    }
emit:
    ch_versions
    star_index
    star_result
    star_counts
    star_multiqc 
}