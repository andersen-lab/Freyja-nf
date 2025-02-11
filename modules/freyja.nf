process FREYJA_VARIANTS {
    cpus 4
    memory '8 GB'
    
    publishDir "${params.output}/variants", mode: 'copy'

    input:
    val sra_accession
    path input_bam
    path bam_index
    path ref

    output:
    tuple val(sra_accession), path("${sra_accession}.tsv"), path("${sra_accession}.depths")

    script:
    """
    freyja variants ${input_bam} --variants ${sra_accession}.tsv --depths ${sra_accession}.depths --ref ${ref}
    """
}

process FREYJA_DEMIX {
    cpus 4
    memory '8 GB'

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
    """
    freyja demix ${variants} ${depths} --eps ${eps} --output ${sample_id}.demix.tsv --barcodes ${barcodes}
    """
}

process FREYJA_COVARIANTS {
    cpus 4
    memory '8 GB'
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
    freyja covariants ${input_bam} ${params.min_site} ${params.max_site} --ref-genome ${ref} --output ${sra_accession}.covariants.tsv --annot ${annot}
    """
}