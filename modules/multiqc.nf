process MULTIQC {
  container 'quay.io/hdc-workflows/multiqc-fastqc:latest'
  publishDir "${params.outdir}/06_multiqc", mode:"copy"
  tag "multiqc"
  label "small_mem"
  input:
    path(postQC_results)
  output:
    val("multiqc_report.html")
    path("multiqc_data")
  script:
  """
  mkdir -p multiqc_data
  multiqc -o multiqc_data ${postQC_results}
  """
}
