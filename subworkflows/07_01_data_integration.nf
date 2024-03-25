include { DATAINTEGRATION   } from '../modules/07_dataIntegration.nf'

workflow GETINTEGRATEDRDS {
    take:

    rds_objects
    rmd

    main:
    ch_versions = Channel.empty()
    DATAINTEGRATION(
        rds_objects,
        rmd
    )
    
}