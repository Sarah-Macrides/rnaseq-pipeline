process FASTQC {
    input:
    path fastq_files

    output:
    path  "*.html" , emit: report 
    path "*.zip",    emit: zip
    
    script:
    """
    fastqc ${fastq_files}
    """
}

process TRIM_GALORE {

    input:
    tuple path(read1), path(read2)

    output:
    tuple path("*_val_1.fq.gz"), path("*_val_2.fq.gz"), emit: trimmed_reads
    path "*_trimming_report.txt", emit: trimming_reports
    path "*_val_1_fastqc.{zip,html}", emit: fastqc_reports_1
    path "*_val_2_fastqc.{zip,html}", emit: fastqc_reports_2

    script:
    """
    trim_galore --fastqc --paired ${read1} ${read2}
    """

}

process HISAT2_ALIGN {


    input:
    tuple path(read1), path(read2)
    path index_zip

    output:
    path "${read1.simpleName}.bam", emit: bam
    path "${read1.simpleName}.hisat2.log", emit: log

    script:
    """
    tar -xzvf ${index_zip}
    hisat2 -x ${index_zip.simpleName} -1 ${read1} -2 ${read2} \
        --new-summary --summary-file ${read1.simpleName}.hisat2.log | \
        samtools view -bS -o ${read1.simpleName}.bam
    """
}

process MULTIQC {

    input:
    path "*"
    val output_name

    output:
    path "${output_name}_multiqc_report.html", emit: multiqc_report
    path "${output_name}_multiqc_report_data/", emit: data

    script:
    """
    multiqc . -n ${output_name}_multiqc_report.html
    """
}

workflow {

    fastq_files = channel.fromPath(params.input)
        .splitCsv(header: true)
        .map { row -> [file(row.fastq_1), file(row.fastq_2)] }
       

    
    FASTQC(fastq_files)

    TRIM_GALORE(fastq_files)
    
    HISAT2_ALIGN(TRIM_GALORE.out.trimmed_reads, file(params.hisat2_index_zip))

    multiqc_files_ch = channel.empty().mix(
        FASTQC.out.zip,
        FASTQC.out.report,
        TRIM_GALORE.out.trimming_reports,
        TRIM_GALORE.out.fastqc_reports_1,
        TRIM_GALORE.out.fastqc_reports_2,
        HISAT2_ALIGN.out.log,
    ).view()

    multiqc_files_list = multiqc_files_ch.collect().view()

    MULTIQC(multiqc_files_list, params.report_id)

    publish:

    // fastqc outputs
    first_report = FASTQC.out.report
    first_zip    = FASTQC.out.zip

    // trim_galore outputs
    trimmed_fastq = TRIM_GALORE.out.trimmed_reads
    trimming_fastqc_1 = TRIM_GALORE.out.fastqc_reports_1
    trimming_fastqc_2 = TRIM_GALORE.out.fastqc_reports_2


    // hisat2 outputs
    bam_files = HISAT2_ALIGN.out.bam
    log_files = HISAT2_ALIGN.out.log

    // MultiQC outputs
    multiqc_report = MULTIQC.out.multiqc_report
    data = MULTIQC.out.data
}

output {
    first_report {
        path 'fastaqc_reports'
    }
    first_zip {
        path 'fastaqc_zips'
    }
    trimmed_fastq {
        path 'TRIM_GALORE/trimmed_fastq'
    }
    trimming_fastqc_1 {
        path 'TRIM_GALORE/fastqc_reports'
    }
    trimming_fastqc_2 {
        path 'TRIM_GALORE/fastqc_reports'
    }
    bam_files {
        path 'HISAT2/bam_files'
    }
    log_files {
        path 'HISAT2/log_files'
    }
    multiqc_report {
        path 'MULTIQC/reports'
    }
    data {
        path 'MULTIQC/data'
    }
}