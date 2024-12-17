process FREYJA_VARIANTS {
    publishDir "${params.output}/variants", mode: 'copy'

    input:
    val sra_accession
    path input_bam
    path bam_index
    path ref

    output:
    tuple val(sra_accession), path("${sra_accession}.variants.tsv"), path("${sra_accession}.depths.tsv")

    script:
    """
    freyja variants ${input_bam} --variants ${sra_accession}.variants.tsv --depths ${sra_accession}.depths.tsv --ref ${ref}
    """
}

process FREYJA_DEMIX {
    publishDir "${params.output}/demix", mode: 'copy'
    errorStrategy {task.attempt <= maxRetries  ? 'retry' : 'ignore' }
    maxRetries 1

    input:
    tuple val(sample_id), path(variants), path(depths)
    val eps
    path barcodes

    output:
    path "${sample_id}.demix.tsv"

    script:
    def depthCutoff = 0 + (task.attempt - 1) * 10
    """
    freyja demix ${variants} ${depths} --eps ${eps} --output ${sample_id}.demix.tsv --depthcutoff ${depthCutoff} --relaxedmrca --barcodes ${barcodes}
    """
}

process FREYJA_COVARIANTS {
    publishDir "${params.output}/covariants", mode: 'copy'
    
    input:
    val sra_accession
    path input_bam
    path bam_index
    path ref
    path annot

    output:
    path "${sra_accession}.covariants.tsv"

    script:
    """
    freyja covariants ${input_bam} ${params.min_site} ${params.max_site} --output ${sra_accession}.covariants.tsv --annot ${annot}
    """
}