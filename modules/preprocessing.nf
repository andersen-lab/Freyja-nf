/*
 *  Alignment and primer trimming
 */

process MINIMAP2 {
    input:
    tuple val(sample_id), val(primer_scheme), path(reads)
    path ref

    output:
    path "${sample_id}.bam"

    script:
    """
    minimap2 -ax sr ${ref} ${reads} | samtools view -bS - > ${sample_id}.bam   
    """
}


process SAMTOOLS_1 {
    input:
    path bamfile

    output:
    val bamfile.baseName
    path "${bamfile.baseName}.sorted.bam"
    path "${bamfile.baseName}.sorted.bam.bai"

    script:
    """
    samtools sort -o ${bamfile.baseName}.sorted.bam ${bamfile}
    samtools index ${bamfile.baseName}.sorted.bam
    """
}

process IVAR_TRIM {
    input:
    val sra_accession
    path sorted_bam
    path bam_index
    path bedfile

    output:
    val sra_accession
    path "${sra_accession}.trimmed.bam"

    script:
    """
    ivar trim -i ${sorted_bam} -b ${bedfile} -p ${sra_accession}.trimmed.bam -q ${params.min_quality} -m ${params.min_read_length} -s ${params.sliding_window_width} -e -x ${params.primer_offset}
    """
}

process SAMTOOLS_2 {
    publishDir "${params.output}/bam", mode: 'copy'
    input:
    val sra_accession
    path bamfile

    output:
    val sra_accession
    path "${sra_accession}.sorted.bam"
    path "${sra_accession}.sorted.bam.bai"

    script:
    """
    samtools sort -o ${sra_accession}.sorted.bam ${bamfile}
    samtools index ${sra_accession}.sorted.bam
    """
}
