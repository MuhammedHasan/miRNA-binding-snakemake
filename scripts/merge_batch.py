import pandas as pd
from tqdm import tqdm


pd.concat([
    pd.read_csv(i, sep='\t')
    for i in tqdm(snakemake.input['chunk'])
]).to_parquet(snakemake.output['pred'], index=False)
