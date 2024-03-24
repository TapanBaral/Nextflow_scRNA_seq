process ALEVIN_QUANTIFY {
  container 'biocontainers/salmon:1.10.1--h7e5ed60_0'
  publishDir "${params.outdir}/04_01_alevin_quant", mode: "copy"
  tag "alevin_quant on ${transcript_index}"
  label "big_mem"
  input:
    tuple val(sample_id), file(fastq1), file(fastq2)
    path transcript_index
    path txp2gene
  output:
    tuple val(sample_id), path("alevin_quant") , emit: alevin_results
    path  "versions.yml"               , emit: versions
  script:
  """
  mkdir -p alevin_quant
  salmon alevin -l ISR -1 ${fastq1} -2 ${fastq2} \
  --chromium -i ${transcript_index} -o alevin_quant \
  --tgMap ${txp2gene} --dumpFeatures 

  cat <<-END_VERSIONS > versions.yml
  "${task.process}":
      salmon: \$(echo \$(salmon --version) | sed -e "s/salmon //g")
  END_VERSIONS
  """
}
