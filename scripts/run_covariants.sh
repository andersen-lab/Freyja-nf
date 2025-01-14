
for file in outputs/bam/*.sorted.bam; do
    sample=$(basename $file .sorted.bam)
    echo "Processing sample $sample"
    if [ ! -f "outputs/covariants/${sample}.covariants.tsv" ]; then
        freyja covariants $file 21563 25384 --output outputs/covariants/${sample}.covariants.tsv --ref-genome data/NC_045512_Hu-1.fasta --annot data/NC_045512_Hu-1.gff
    fi
done