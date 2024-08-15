# gwablup_vs_slemm
Comparative benchmarking of GWABLUP and SLEMM for genomic prediction

## References
[GWABLUP](https://gsejournal.biomedcentral.com/articles/10.1186/s12711-024-00881-y)  
[SLEMM](https://academic.oup.com/bioinformatics/article/39/3/btad127/7075542)

## Introduction
- [SLEMM](https://github.com/jiang18/slemm) has a function for fast window-based SNP-weigthing for genomic prediction.
- GWABLUP is also ba

## Dataset
- Dairy bulls (https://doi.org/10.1534/g3.114.016261)
  - Three traits: milk (mkg), fat percentage (fpro), and somatic cell score (scs)
  - 5024 individuals and 42552 SNPs after quality control
  - Pre-processed data (Cattle_geno and Cattle.csv) can be found in the current directory.

## Validation
- Repeated random subsampling validation
  - 80% as training, and the remaining 20% as validaiton
  - 20 replicates

## Fast implementation of GWABLUP

