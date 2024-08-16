# GCTA GRM
gcta64 --make-grm --bfile Cattle_geno --threads 12 --out gg

# Extract ~80% of phenotypes as tranining for 20 times.
for i in {1..20}; do
    (
        head -n 1 Cattle.csv
        tail -n +2 Cattle.csv | sort -R | head -n 4000
    ) > training_$i.csv 
    perl -e 'while(<>){@c=split /,/; chomp $c[-1]; @c = map {$_ eq "" ? "NA" : $_} @c; print join (" ", 0,@c), "\n";}' < training_$i.csv > training_$i.txt
done

trt=scs
mpheno=3

for i in {1..20}; do
# 1. GWAS
    gcta64 --mlma --grm gg --pheno training_$i.txt --threads 12 --mpheno $mpheno --bfile Cattle_geno --out $i.gcta
# 2. GWABLUP weights
    perl -e '$_=<>; while(<>) {chomp; @c=split /\s+/; print "@c[6..7]\n"}' < $i.gcta.mlma > $i.lrt
    julia gwablup_wgts.jl $i.lrt 0.001 5
    (
        echo "SNP,Weight"
        paste <(cut -f2 Cattle_geno.bim) <(cut -f1 gwablup_wgts.out) | sed 's/\t/,/'
    ) > $i.snp.csv
# 3. Fast GWABLUP with SLEMM
    slemm --reml --max_her 0.9 --phenotype training_$i.csv --trait $trt --bfile Cattle_geno --snp_info $i.snp.csv --snp_weight Weight --num_threads 12 --out $i
    slemm --pred --snp_estimate $i.reml.snp.csv --bfile Cattle_geno --out gwablup_$i.csv
# SLEMM --iter_weighting
    slemm --reml --max_her 0.9 --phenotype training_$i.csv --trait $trt --bfile Cattle_geno --snp_info $i.snp.csv --iter_weighting --num_threads 12 --out $i
    slemm --pred --snp_estimate $i.reml.snp.csv --bfile Cattle_geno --out slemm_$i.csv
done

# Other window sizes
for i in {1..20}; do
    julia gwablup_wgts.jl $i.lrt 0.001 41
    (
        echo "SNP,Weight"
        paste <(cut -f2 Cattle_geno.bim) <(cut -f1 gwablup_wgts.out) | sed 's/\t/,/'
    ) > $i.snp.csv

    slemm --reml --max_her 0.85 --phenotype training_$i.csv --trait $trt --bfile Cattle_geno --snp_info $i.snp.csv --snp_weight Weight --num_threads 12 --out $i
    slemm --pred --snp_estimate $i.reml.snp.csv --bfile Cattle_geno --out gwablup_$i.csv

    slemm --reml --max_her 0.85 --phenotype training_$i.csv --trait $trt --bfile Cattle_geno --snp_info $i.snp.csv --iter_weighting --window_size 80 --num_threads 12 --out $i
    slemm --pred --snp_estimate $i.reml.snp.csv --bfile Cattle_geno --out slemm_$i.csv
done

