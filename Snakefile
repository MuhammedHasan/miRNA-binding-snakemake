from pathlib import Path

configfile: "configs/config.yaml"


rule all:
    input:
        config['targetscan_pred']


rule download_miRNA_family:
    params:
        output_dir = str(Path(config['miRNA_families']).parent)
    threads: 1
    resources:
        mem_gb = 4
    output:
        config['miRNA_families']
    shell:
        "wget http://www.targetscan.org/vert_80/vert_80_data_download/miR_Family_Info.txt.zip -O {output}.zip && unzip -o {output} -d{params.output_dir}"


rule download_mirbase_gff:
    params:
        mirbase_specie_id = config['mirbase_specie_id']
    output:
        config['mirbase_gff']
    shell:
        "wget --no-check-certificate https://www.mirbase.org/ftp/CURRENT/genomes/{params.mirbase_specie_id}.gff3 -O {output}"


rule gencode_miRNA_mapping:
    input:
        families = config['miRNA_families'],
        mirbase = config['mirbase_gff'],
        gencode_gtf = config['gencode_gtf']
    params:
        ncbi_tax_id = config['ncbi_tax_id']
    output:
        families = config['miRNA_gencode'],
        partial = config['miRNA_gencode'] + '_partial.csv'
    script:
        "./scripts/gencode_miRNA_mapping.py"


rule extract_utr_seqs:
    input:
        fasta = config['fasta'],
        gtf = config['gtf']
    params:
        ncbi_tax_id = config['ncbi_tax_id']
    threads: 1
    resources:
        mem_gb = 8
    output:
        utr_seqs = config['utr_seqs']
    script:
        "./scripts/utr_seqs.py"


rule batch_utr_seqs:
    input:
        utr_seqs = config['utr_seqs']
    params:
        batch_size = config['batch_size']
    threads: 1
    resources:
        mem_gb = 8
    output:
        batch = dynamic(config['batch_utr_seqs'])
    script:
        "./scripts/utr_seq_batch.py"


rule targetscan:
    input:
        miRNA_families = config['miRNA_gencode'],
        utr_seqs = config['batch_utr_seqs']
    threads: 1
    resources:
        mem_gb = 8
    output:
        pred = config['batch_targetscan_pred']
    shell:
        "./scripts/targetscan_70.pl {input.miRNA_families} {input.utr_seqs} {output.pred}"


rule merge_targetscan:
    input:
        chunk = dynamic(config['batch_targetscan_pred'])
    threads: 1
    resources:
        mem_gb = 32
    output:
        pred = config['targetscan_pred']
    script:
        "./scripts/merge_batch.py"
