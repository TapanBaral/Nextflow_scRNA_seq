/*
IMPORT MODULES/SUBWORKFLOWS
*/

include { FASTQC_CHECK      } from '../subworkflows/00_01_pre_fastqc.nf'
include { MULTIQC           } from '../modules/multiqc.nf'
include { UMI_EXTRACT       } from '../modules/01_umi_extract.nf'
include { FASTP_CHECK       } from '../subworkflows/02_01_fastp.nf'
include { POSTQC_CHECK      } from  '../subworkflows/03_01_post_fastqc.nf'
include { SCRNASEQ_ALEVIN   } from '../subworkflows/04_00_salmon.nf'
include { SCRNASEQ_STAR     } from '../subworkflows/05_00_star.nf'
include { MTX_CONVERSION    } from '../subworkflows/06_matrix_to_rds.nf'


// INPUT FASTQ FILES , PASS IT INTO THE CHANNEL
// INPUT FILES SHOULD BE IN 3 COULMNS TAB DELIMITED TEXT FILE WITHOUT A HEADER, EACH LINE CONTAINING THE SAMPLE NAME, ABSOULUTE PATH 
// TO THE READ1 AND READ2

if (params.inputfiles) {
        Channel
            .fromPath(params.inputfiles)
            .splitCsv(header: ['sample_id', 'fastq1', 'fastq2'], sep: "\t")
            .map{ row-> tuple(row.sample_id, file(row.fastq1), file(row.fastq2)) }
            .set { input_files }
}

// define all channels

def raw_reads_ch               = (input_files)
def transcriptome_ch           = params.transcript_fasta ? file(params.transcript_fasta) : []
def genome_fasta_ch            = Channel.value(params.genome_fasta ? file(params.genome_fasta) : [])
def kmer_ch                    = Channel.of(31)
def txp2gene_ch                = params.txp2gene ? file(params.txp2gene) : []
def whitelist_ch               = params.whitelist ? file(params.whitelist) : []
def manifest_ch                = params.manifest ? file(params.manifest) : []
def gtf_ch                     = params.gtf ? file(params.gtf) : []
def salmon_index_ch            = params.salmon_index ? file(params.salmon_index) : []
def star_index_ch              = params.star_index ? file(params.star_index) : []
ch_versions     = Channel.empty()

if (params.help) {
    log.info params.help_message
    exit 0
}

workflow scRNAseq {

        //Define the channels to collect outputs  and metadata
        ch_versions     = Channel.empty()
        ch_mtx_matrices = Channel.empty()

        if (!params.skip_pre_fastqc) {
        FASTQC_CHECK ( raw_reads_ch )
        ch_versions       = ch_versions.mix(FASTQC_CHECK.out.fastqc_version)
        ch_multiqc_fastqc = FASTQC_CHECK.out.fastqc_zip
         }else {
        ch_multiqc_fastqc = Channel.empty()
        }
        //Extract UMI barcode from a read and add it to the read name, leaving any sample barcode in place
        if(!params.skip_umi_extract){
            UMI_EXTRACT(raw_reads_ch)
            umi_ch = UMI_EXTRACT.out.u1_fastqs
        }else{
            umi_ch = raw_reads_ch
        }
        // Filter fastq files
        if(!params.skip_fastp){
            FASTP_CHECK(umi_ch)
            trimmed_read_ch  = FASTP_CHECK.out.trimmed_fastqs
            ch_versions      = ch_versions.mix(FASTP_CHECK.out.fastp_version)
        } else {
            trimmed_read_ch  = umi_ch
        }
        //post QC
        if (!params.skip_post_fastqc) {
        FASTQC_CHECK ( trimmed_read_ch )
        ch_versions       = ch_versions.mix(POSTQC_CHECK.out.postqc_version)
        ch_multiqc_post_fastqc = POSTQC_CHECK.out.fastqc_zip
         }else {
        ch_multiqc_post_fastqc = Channel.empty()
        }

        if(params.aligner == "salmon"){
		SCRNASEQ_ALEVIN(
			salmon_index_ch,
			transcriptome_ch,
			kmer_ch,
			trimmed_read_ch,
			txp2gene_ch
		)
        ch_mtx_matrices = ch_mtx_matrices.mix(SCRNASEQ_ALEVIN.out.alevin_results)
        }else{
            SCRNASEQ_STAR(
                star_index_ch,
                genome_fasta_ch,
                gtf_ch,
                trimmed_read_ch,
                whitelist_ch,
                manifest_ch

            )
            ch_mtx_matrices = ch_mtx_matrices.mix(SCRNASEQ_STAR.out.star_counts)
        }

        MTX_CONVERSION(
            ch_mtx_matrices
        )
        
}




