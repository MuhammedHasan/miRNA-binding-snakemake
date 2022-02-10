import pyranges as pr


gr_gtf = pr.read_gtf(snakemake.input['gtf'])
gr_gtf = gr_gtf[gr_gtf.gene_type == 'protein_coding']

df_exons = gr_gtf[gr_gtf.Feature == 'exon'].df

last_exon = df_exons[['transcript_id', 'exon_number']].groupby(
    'transcript_id').max().set_index('exon_number', append=True).index

df_exons = df_exons.set_index(['transcript_id', 'exon_number']).loc[last_exon]

gr_last_exons = pr.PyRanges(df_exons.reset_index())
gr_last_exons.seq = pr.get_fasta(gr_last_exons, snakemake.input['fasta'])
df_last_exons = gr_last_exons.df

df_last_exons['ncbi_tax_id'] = snakemake.params['ncbi_tax_id']
df_last_exons[['transcript_id', 'ncbi_tax_id', 'seq']] \
    .to_csv(snakemake.output['utr_seqs'], header=False, index=False, sep='\t')
