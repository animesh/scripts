import pandas as pd, numpy as np

pep = pd.read_csv('dynamicrangebenchmark/peptides.txt', sep='\t', low_memory=False)
msp = pd.read_csv('dynamicrangebenchmark/modificationSpecificPeptides.txt', sep='\t', low_memory=False)

# How many peptide sequences appear in both with different intensities?
int_cols_pep = [c for c in pep.columns if c.startswith('Intensity ')]
int_cols_msp = [c for c in msp.columns if c.startswith('Intensity ')]

# Total signal — should be identical if charge-collapsed sums are preserved
print("peptides.txt total signal:   ", pep[int_cols_pep].sum().sum())
print("modSpecPep total signal:      ", msp[int_cols_msp].sum().sum())

# Sequences that appear more than once in modSpecPep (i.e. have modifications)
dup_seqs = msp[msp.duplicated('Sequence', keep=False)]['Sequence'].nunique()
print(f"\nSequences with >1 modification state in modSpecPep: {dup_seqs}")
print(f"Extra rows vs peptides.txt: {len(msp) - len(pep)}")

import pandas as pd, numpy as np
pg = pd.read_csv('dynamicrangebenchmark/proteinGroups.txt', sep='\t', low_memory=False)
int_cols = [c for c in pg.columns if c.startswith('Intensity ') and not c.startswith('LFQ')]
lfq_cols = [c for c in pg.columns if c.startswith('LFQ intensity')]
print('proteinGroups Intensity cols:', int_cols)
print('ratio LFQ/Intensity per protein (median):')
ratio = pg[lfq_cols].replace(0,np.nan).values / pg[int_cols].replace(0,np.nan).values
print(np.nanmedian(ratio))
