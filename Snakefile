from pathlib import Path

configfile: "configs/config.yaml"


rule all:
    input:
        config['targetscan_pred']


rule download_miRNA_family:
    params:
        output_dir = str(Path(config['miRNA_families']).parent)
    output:
        config['miRNA_families']
    shell:
        "wget http://www.targetscan.org/vert_80/vert_80_data_download/miR_Family_Info.txt.zip -O {output}.zip && unzip -o {output} -d{params.output_dir}"


rule extract_utr_seqs:
    input:
        fasta = config['fasta'],
        gtf = config['gtf']
    params:
        ncbi_tax_id = config['ncbi_tax_id']
    output:
        utr_seqs = config['utr_seqs']
    script:
        "./scripts/utr_seqs.py"


rule targetscan:
    input:
        miRNA_families = config['miRNA_families'],
        utr_seqs = config['utr_seqs']
    output:
        pred = config['targetscan_pred']
    shell:
        "./scripts/targetscan_70.pl {input.miRNA_families} {input.utr_seqs} {output.pred}"


# TODO:
# rule map_miRNA_to_gene_id
