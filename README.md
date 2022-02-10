# miRNA-binding snakemake

Snakemake pipeline to run targetscan on custom gtf file.

## Installation
```
git clone git@github.com:MuhammedHasan/miRNA-binding-snakemake.git
```

Create conda environment:
```
conda env create -f environment.yml
```

Run snakemake with your custom config file:
```
snakemake -j 1 --configfile configs/config.yaml 
```

