process INDEX_SALMON {
  container 'biocontainers/salmon:1.10.1--h7e5ed60_0'
  cpus params.cpus
  memory params.memory
  publishDir "${params.outdir}/04_00_salmon_index", mode: "copy"
  tag "indexing"
  label "big_mem"
  input:
    path transcriptome
    each kmer
  output:
    path "index"              , emit: index
    path "versions.yml", emit: versions
  script:
  """
  
  salmon index --gencode --threads ${task.cpus}  -t ${transcriptome} -i index -k ${kmer}

  cat <<-END_VERSIONS > versions.yml
  "${task.process}":
      salmon: \$(echo \$(salmon --version) | sed -e "s/salmon //g")
  END_VERSIONS
  """
}
