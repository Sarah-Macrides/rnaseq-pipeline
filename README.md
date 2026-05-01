# RNA-seq Pipeline

## Dataset

This pipeline was built following the 
[Nextflow RNA-seq training](https://training.nextflow.io/nf4_science/rnaseq/) 
and tested on the provided tutorial dataset.

### Data description

- **Reads** (`reads/`): FASTQ files from six samples, reduced to a small 
  genomic region to limit file size. Each sample has paired-end reads 
  (two files per sample). This pipeline processes them as **single-end** reads.

- **Reference genome** (`genome.fa`): a small region of human chromosome 20 
  (hg19/b37 assembly).

- **Samplesheets** (`single-end.csv`, `paired-end.csv`): CSV files listing 
  sample identifiers and paths to the input FASTQ files.

## Pipeline Overview

\`\`\`mermaid
graph LR
    A[FASTQ] --> B[FastQC]
    A --> C[Trim Galore]
    C --> D[HISAT2]
    C --> E[FastQC post-trim]
    D --> F[featureCounts]
    B & E & D & F --> G[MultiQC Report]
\`\`\`


## Tools

| Tool | Version | Purpose |
|------|---------|---------|
| FastQC | 0.12.1 | Raw reads quality control |
| Trim Galore | 0.6.10 | Adapter trimming |
| HISAT2 | 2.2.1 | Spliced alignment to genome |
| SAMtools | 1.19 | BAM conversion |
| featureCounts | 2.0.6 | Read quantification |
| MultiQC | 1.21 | Aggregated QC report |

---


## References

- Himes et al. (2014). RNA-Seq transcriptome profiling identifies 
  CRISPLD2 as a glucocorticoid responsive gene. *PLOS ONE*.
- Kim et al. (2019). Graph-based genome alignment with HISAT2. 
  *Nature Biotechnology*.
- Ewels et al. (2016). MultiQC: summarize analysis results. 
  *Bioinformatics*.