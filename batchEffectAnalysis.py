#https://sequenceanddestroy.substack.com/p/issue-79-modeling-latent-variation?utm_source=post-email-title&publication_id=1508290&post_id=201450642&utm_campaign=email-post-title&isFreemail=true&r=a55q5&triedRedirect=true&utm_medium=email
import numpy as np
import pandas as pd
np.random.seed(42)
n_samples, n_proteins = 200, 100
batches = ['B1','B2','B3','B4']
batch_assignments = np.repeat(batches, n_samples // len(batches))
WT_status = np.array(
    ['WT'] * 40 + ['M'] * 10 + 
    ['WT'] * 25 + ['M'] * 25 + 
    ['WT'] * 10 + ['M'] * 40 + 
    ['WT'] * 25 + ['M'] * 25   
)
data = np.random.randn(n_samples, n_proteins)
WT_effect = (WT_status == 'WT').astype(float)
data[:, :15] += 2.0 * WT_effect[:, None]   # true signal: first 15 proteins
batch_effects = {'B1': 1.5, 'B2': 0.0, 'B3': -1.5, 'B4': 0.0}
for i, b in enumerate(batch_assignments):
    data[i] += batch_effects[b]
protein_cols = [f'prot_{i+1}' for i in range(n_proteins)]
df = pd.DataFrame(data, columns=protein_cols)
df.insert(0, 'batch', batch_assignments)
df.insert(1, 'WT', WT_status)
'''Option 1: Manually Calculate Residuals'''
# Isolate M and WT patients into seperate dfs
WT_neg_list = df.index[df['WT']==0].tolist()
WT_neg_df = df[df.index.isin(WT_neg_list)]
WT_neg_df = WT_neg_df.drop(columns=['batch', 'WT'])
WT_pos_list = df.index[df['WT']==1].tolist()
WT_pos_df = df[df.index.isin(WT_pos_list)]
WT_pos_df = WT_pos_df.drop(columns=['batch', 'WT'])
# Calculate β0 and β1
B0 = WT_neg_df.mean(axis=0)
B1 = WT_pos_df.mean(axis=0) - B0 
# Calculate residuals for M and WT patients
WT_neg_residuals = WT_neg_df - B0- (B1*0)
WT_pos_residuals = WT_pos_df - B0- (B1*1)
# Combine all residuals into a single df
residual_df = pd.concat([WT_pos_residuals, WT_neg_residuals], axis=0, ignore_index=True)
