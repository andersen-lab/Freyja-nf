set -ex

for dir in $(ls /home/jolevy/Projects/NICD-Raw-Data/fastqs); do
    nextflow run main.nf -entry fastq -profile docker --fastq_dir ${dir} -resume &
    BACK_PID=$!
    echo "Waiting for process $BACK_PID to finish..."
    wait $BACK_PID
done