//
// 
//
include { PREFASTQC } from '../modules/00_pre_fastqc.nf'

workflow FASTQC_CHECK {
  take:
  raw_reads_ch

  main:

 

  /*
   * FastQ QC using FASTQC
   */
  PREFASTQC(raw_reads_ch)
  fastqc_zip     = PREFASTQC.out.zip
  fastqc_html    = PREFASTQC.out.html

  fastqc_zip
      .map { it -> [ it[1] ] }
      .set { fastqc_zip_only }
  fastqc_html
      .map { it -> [ it[1] ] }
      .set { fastqc_html_only }

  fastqc_multiqc = Channel.empty()
  fastqc_multiqc = fastqc_multiqc.mix( fastqc_zip_only, fastqc_html_only )
  fastqc_version = PREFASTQC.out.versions

  emit:
  fastqc_zip
  fastqc_html
  fastqc_version
  fastqc_multiqc
}