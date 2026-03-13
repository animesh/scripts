import pandas as pd
# 1. What intensity columns exist in modificationSpecificPeptides.txt?
msp = pd.read_csv('dynamicrangebenchmark/modificationSpecificPeptides.txt', 
                   sep='\t', low_memory=False, nrows=3)
int_cols = [c for c in msp.columns if 'Intensity' in c or 'intensity' in c]
print("modSpecPep intensity cols:", int_cols[:20])
print("shape:", msp.shape)
print("cols sample:", list(msp.columns[:15]))
# 2. Row counts to understand aggregation level
pep = pd.read_csv('dynamicrangebenchmark/peptides.txt', 
                   sep='\t', low_memory=False)
print(f"\npeptides.txt rows: {len(pep)}")

msp2 = pd.read_csv('dynamicrangebenchmark/modificationSpecificPeptides.txt', 
                    sep='\t', low_memory=False)
print(f"modSpecPep rows:   {len(msp2)}")
