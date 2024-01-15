cd /cluster/home/ash022/scripts/TKSB
module load SAMtools/1.17-GCC-12.2.0
samtools mpileup -f ../hg38v110/genome.fa TK16_R1_.sort.bam > TK16_R1_.sort.bamoutput.pileup 2>t #https://decodingbiology.substack.com/p/a-diy-guide-genomic-variant-analysis?utm_source=substack&utm_medium=email except for -u
module load BCFtools/1.17-GCC-12.2.0
bcftools call -mv -Ov -o variants.vcf TK16_R1_.sort.bamoutput.pileup
table_annovar.pl variants.vcf humandb/ -buildver hg38 -out annotated_variants -remove -protocol refGene -operation g
bcftools filter -i 'QUAL > 20' && DP > 10' variants.vcf > filtered_variants.vcf
bcftools mpileup -f ../hg38v110/genome.fa TK16_R1_.sort.bam | bcftools call -mv -Ov -o TK16_R1_.sort.bam.vcf
bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\n' filtered_variants.vcf > variants_table.txt

import pandas as pd
from scipy.stats import chi2_contingency
variants = pd.read_csv('variants_table.txt', sep='\t', header=None, names=['CHROM', 'POS', 'REF', 'ALT'])

phenotypes = pd.read_csv('phenotypes.csv')

merged_data = pd.merge(variants, phenotypes, on='SampleID')
contingency_table = pd.crosstab(merged_data['ALT'], merged_data['Phenotype'])
chi2, p = chi2_contingency(contingency_table)
print(f'Chi-square: {chi2}, p-value: {p}')
#https://github.com/trinityrnaseq/bamsifter/tree/devel
bamsifter [-c max_coverage] [-i max_identical_cigar_pos] [-o out.bam] [--FLAGS] <in.bam>
#https://samtools.github.io/bcftools/howtos/variant-calling.html
bcftools mpileup -f ../hg38v110/genome.fa TK16_R1_.sort.bam | bcftools call -mv -Ob -o TK16_R1_.sort.bam.bcf
Note: none of --samples-file, --ploidy or --ploidy-file given, assuming all sites are diploid
[mpileup] 1 samples in 1 input files
[mpileup] maximum number of reads per input file set to -d 250 #INCREASE?bcftools mpileup --max-depth 
bcftools mpileup -Ou -f reference.fa alignments.bam | bcftools call -mv -Ob -o calls.bcf #binary out?
#can be made more sensitive or restrictive by using a different prior. Stricter calls are obtained by using smaller value, more benevolent calls are obtained by using bigger value. The default is bcftools call -P 1.1e-3
#bcftools view -i '%QUAL>=20' calls.bcf
https://github.com/animesh/e2b-cookbook/tree/main/guides/ai-github-developer-py