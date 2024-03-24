
include { POSTQC   } from '../modules/03_post_fastqc.nf'

workflow POSTQC_CHECK {
take:
  trimmed_read_ch

main:
   /*
   * FastQ QC using postqc
   */
  POSTQC ( trimmed_read_ch )
  postqc_zip     = POSTQC.out.zip
  postqc_html    = POSTQC.out.html

  postqc_zip
      .map { it -> [ it[1] ] }
      .set { postqc_zip_only }
  postqc_html
      .map { it -> [ it[1] ] }
      .set { postqc_html_only }

  postqc_multiqc = Channel.empty()
  postqc_multiqc = postqc_multiqc.mix( postqc_zip_only, postqc_html_only )
  postqc_version = POSTQC.out.versions

  emit:
  postqc_zip
  postqc_html
  postqc_version
  postqc_multiqc
}