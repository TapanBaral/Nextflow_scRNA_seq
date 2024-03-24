
include {  TRIM } from '../modules/02_fastp.nf'

workflow FASTP_CHECK {
take:
  umi_ch

main:
 TRIM(umi_ch)
   fastp_json     = TRIM.out.json
   fastp_html    = TRIM.out.html

   fastp_json
      .map { it -> [ it[1] ] }
      .set { fastp_json_only }
   fastp_html
      .map { it -> [ it[1] ] }
      .set { fastp_html_only }
    
    fastp_multiqc = Channel.empty()
    fastp_multiqc = fastp_multiqc.mix( fastp_json_only, fastp_html_only )
    fastp_version = TRIM.out.versions

    emit:
    fastp_json
    fastp_html
    fastp_version
    fastp_multiqc
    trimmed_fastqs = TRIM.out.trimmed_fastqs

}

