#!/usr/bin/env nextflow
nextflow.enable.dsl=2

/*
 * Automated pipeline for Freyja analysis of NICD data
 */

baseDir = file("$baseDir")
fastq_dir = file(params.fastq_dir)
ref = file(params.ref)
bedfile = file("${baseDir}/data/bedfiles/ARTICv5.3.2.bed")
barcodes = file("${baseDir}/data/barcodes/usher_barcodes.feather")
annot = file(params.annot)

include {
    MINIMAP2;
    SAMTOOLS_1;
    SAMTOOLS_2;
    IVAR_TRIM;
} from "./modules/preprocessing.nf"

include {
    FREYJA_VARIANTS;
    FREYJA_DEMIX;
    FREYJA_COVARIANTS;
} from "./modules/freyja.nf"


workflow fastq {
    Channel
    .fromFilePairs("${params.fastq_dir}/*/*_R{1,2}_001.fastq.gz")
    .map { k, v -> tuple(k, v[1], v[0]) }
    .set { fastq_ch }

    preprocessing(fastq_ch)
}


workflow preprocessing {
    take: known_primer_fastq_ch

    main:
    MINIMAP2(known_primer_fastq_ch, ref)
    SAMTOOLS_1(MINIMAP2.out)
    IVAR_TRIM(SAMTOOLS_1.out, bedfile)
    SAMTOOLS_2(IVAR_TRIM.out)

    freyja(SAMTOOLS_2.out)
}

workflow freyja {
    take:
    sra_accession
    input_bam
    bam_index
    
    main:
    FREYJA_VARIANTS(sra_accession, input_bam, bam_index, ref)
        .collect()
        .map { it[1] }
        .set { variants_ch }

    FREYJA_DEMIX(FREYJA_VARIANTS.out, params.eps, barcodes)
        .collect()
        .set { demix_ch }

    FREYJA_COVARIANTS(sra_accession, input_bam, bam_index, ref, annot)
        .collect()
        .set { covariants_ch }
}

