import numpy as np
import pandas as pd


df = pd.read_csv(snakemake.input['utr_seqs'], sep='\t', header=None)

batch_size = snakemake.params['batch_size']
batch_ids = np.arange(len(df)) // batch_size


for batch_number, df_batch in df.groupby(batch_ids):
    path = snakemake.output['batch'].replace(
        '__snakemake_dynamic__', str(batch_number))
    df_batch.to_csv(path, header=None, index=False, sep='\t')
