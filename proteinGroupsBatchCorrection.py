import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler
from scipy import stats
import warnings
warnings.filterwarnings('ignore')

class ProteomicsComBat:
    """
    ComBat batch correction specifically designed for proteomics data
    Handles missing values and log-transformed intensity data
    """
    
    def __init__(self, parametric=True, mean_only=False):
        self.parametric = parametric
        self.mean_only = mean_only
        self.design_matrix = None
        self.batch_info = None
        
    def fit_transform(self, data, batch, mod=None):
        """
        Apply ComBat batch correction to proteomics data
        
        Parameters:
        -----------
        data : pd.DataFrame
            Protein intensity matrix (proteins x samples)
        batch : array-like
            Batch labels for each sample
        mod : pd.DataFrame, optional
            Model matrix for covariates to preserve
            
        Returns:
        --------
        corrected_data : pd.DataFrame
            Batch-corrected protein intensities
        """
        
        # Convert to numpy for computation
        X = data.values.copy()
        batch = np.array(batch)
        
        # Handle missing values
        missing_mask = np.isnan(X)
        
        # Get batch information
        batches = np.unique(batch)
        n_batches = len(batches)
        n_proteins, n_samples = X.shape
        
        print(f"Processing {n_proteins} proteins across {n_samples} samples in {n_batches} batches")
        
        if n_batches == 1:
            print("Only one batch detected, returning original data")
            return data
            
        # Create design matrix
        batch_design = pd.get_dummies(pd.Series(batch)).values
        
        if mod is not None:
            design = np.column_stack([mod.values, batch_design])
        else:
            design = np.column_stack([np.ones(n_samples), batch_design])
            
        # Standardize data (handling missing values)
        X_std = np.zeros_like(X)
        for i in range(n_proteins):
            protein_data = X[i, :]
            valid_mask = ~missing_mask[i, :]
            
            if np.sum(valid_mask) < 3:  # Need at least 3 valid values
                X_std[i, :] = protein_data
                continue
                
            valid_data = protein_data[valid_mask]
            mean_val = np.mean(valid_data)
            std_val = np.std(valid_data)
            
            if std_val == 0:
                X_std[i, :] = protein_data - mean_val
            else:
                X_std[i, :] = (protein_data - mean_val) / std_val
        
        # Apply batch correction protein by protein
        X_corrected = np.zeros_like(X_std)
        
        for i in range(n_proteins):
            if i % 500 == 0:
                print(f"Processing protein {i+1}/{n_proteins}")
                
            protein_data = X_std[i, :]
            valid_mask = ~missing_mask[i, :]
            
            if np.sum(valid_mask) < 3:
                X_corrected[i, :] = protein_data
                continue
                
            # Estimate batch effects for this protein
            X_corrected[i, :] = self._correct_protein(protein_data, batch, valid_mask, batches)
        
        # Convert back to DataFrame
        corrected_df = pd.DataFrame(X_corrected, 
                                  index=data.index, 
                                  columns=data.columns)
        
        # Restore missing values
        corrected_df = corrected_df.mask(missing_mask)
        
        return corrected_df
    
    def _correct_protein(self, protein_data, batch, valid_mask, batches):
        """Correct batch effects for a single protein"""
        
        corrected_data = protein_data.copy()
        valid_data = protein_data[valid_mask]
        valid_batch = batch[valid_mask]
        
        # Estimate batch parameters
        batch_means = []
        batch_vars = []
        
        for batch_id in batches:
            batch_mask = valid_batch == batch_id
            batch_values = valid_data[batch_mask]
            
            if len(batch_values) < 2:
                batch_means.append(0)
                batch_vars.append(1)
            else:
                batch_means.append(np.mean(batch_values))
                batch_vars.append(np.var(batch_values))
        
        batch_means = np.array(batch_means)
        batch_vars = np.array(batch_vars)
        
        # Empirical Bayes shrinkage
        overall_mean = np.mean(batch_means)
        overall_var = np.mean(batch_vars)
        
        # Simple shrinkage
        shrinkage = 0.1
        gamma_hat = (1 - shrinkage) * batch_means + shrinkage * overall_mean
        delta_hat = (1 - shrinkage) * batch_vars + shrinkage * overall_var
        delta_hat = np.maximum(delta_hat, 0.01)
        
        # Apply correction
        for i, batch_id in enumerate(batches):
            batch_mask = batch == batch_id
            corrected_data[batch_mask] = (protein_data[batch_mask] - gamma_hat[i]) / np.sqrt(delta_hat[i])
        
        return corrected_data

def load_proteingroups_data(file_path):
    """
    Load MaxQuant proteinGroups.txt file
    """
    try:
        # Read the data
        df = pd.read_csv(file_path, sep='\t', low_memory=False)
        
        print(f"Loaded data shape: {df.shape}")
        print(f"Columns: {list(df.columns)}")
        
        return df
        
    except Exception as e:
        print(f"Error loading data: {e}")
        return None

def extract_intensity_data(df):
    """
    Extract intensity columns from proteinGroups data
    """
    # Look for intensity columns (typically start with "Intensity" or "LFQ intensity")
    intensity_cols = [col for col in df.columns if 'Intensity' in col and 'L' not in col]
    lfq_cols = [col for col in df.columns if 'LFQ intensity' in col]
    
    if lfq_cols:
        print(f"Found {len(lfq_cols)} LFQ intensity columns")
        intensity_cols = lfq_cols
    elif intensity_cols:
        print(f"Found {len(intensity_cols)} intensity columns")
    else:
        print("No intensity columns found, looking for columns with 'intensity' (case insensitive)")
        intensity_cols = [col for col in df.columns if 'intensity' in col.lower()]
    
    print(f"Using columns: {intensity_cols}")
    
    # Extract protein identifiers
    if 'Protein IDs' in df.columns:
        protein_ids = df['Protein IDs']
    elif 'Majority protein IDs' in df.columns:
        protein_ids = df['Majority protein IDs']
    else:
        protein_ids = df.index
    
    # Create intensity matrix
    intensity_data = df[intensity_cols].copy()
    intensity_data.index = protein_ids
    
    # Convert to numeric and handle zeros (replace with NaN for log transformation)
    intensity_data = intensity_data.apply(pd.to_numeric, errors='coerce')
    intensity_data = intensity_data.replace(0, np.nan)
    
    return intensity_data

def preprocess_proteomics_data(intensity_data, min_valid_per_protein=0.5, log_transform=True):
    """
    Preprocess proteomics intensity data
    """
    print("Preprocessing proteomics data...")
    
    # Calculate valid value percentage per protein
    valid_percentage = intensity_data.notna().sum(axis=1) / intensity_data.shape[1]
    
    # Filter proteins with insufficient valid values
    proteins_to_keep = valid_percentage >= min_valid_per_protein
    filtered_data = intensity_data.loc[proteins_to_keep].copy()
    
    print(f"Filtered from {intensity_data.shape[0]} to {filtered_data.shape[0]} proteins")
    print(f"(kept proteins with ≥{min_valid_per_protein*100}% valid values)")
    
    # Log transform if specified
    if log_transform:
        print("Applying log2 transformation...")
        filtered_data = np.log2(filtered_data)
    
    return filtered_data

def combine_batches_and_correct(file1_path, file2_path):
    """
    Main function to load, combine, and batch-correct two proteinGroups files
    """
    
    print("=== Loading Batch 1 Data ===")
    df1 = load_proteingroups_data(file1_path)
    if df1 is None:
        return None, None
    
    print("\n=== Loading Batch 2 Data ===")
    df2 = load_proteingroups_data(file2_path)
    if df2 is None:
        return None, None
    
    print("\n=== Extracting Intensity Data ===")
    intensity1 = extract_intensity_data(df1)
    intensity2 = extract_intensity_data(df2)
    
    print(f"Batch 1 intensity data shape: {intensity1.shape}")
    print(f"Batch 2 intensity data shape: {intensity2.shape}")
    
    # Find common proteins
    common_proteins = intensity1.index.intersection(intensity2.index)
    print(f"\nFound {len(common_proteins)} common proteins between batches")
    
    if len(common_proteins) == 0:
        print("No common proteins found! Check protein ID formats.")
        return None, None
    
    # Subset to common proteins
    intensity1_common = intensity1.loc[common_proteins]
    intensity2_common = intensity2.loc[common_proteins]
    
    # Combine data
    print("\n=== Combining Data ===")
    combined_intensity = pd.concat([intensity1_common, intensity2_common], axis=1)
    
    # Create batch labels
    batch_labels = ['Batch1'] * intensity1_common.shape[1] + ['Batch2'] * intensity2_common.shape[1]
    
    print(f"Combined data shape: {combined_intensity.shape}")
    print(f"Samples per batch: Batch1={intensity1_common.shape[1]}, Batch2={intensity2_common.shape[1]}")
    
    # Preprocess
    print("\n=== Preprocessing ===")
    processed_data = preprocess_proteomics_data(combined_intensity, 
                                              min_valid_per_protein=0.7, 
                                              log_transform=True)
    
    print(f"Final processed data shape: {processed_data.shape}")
    
    # Apply batch correction
    print("\n=== Applying ComBat Batch Correction ===")
    combat = ProteomicsComBat()
    corrected_data = combat.fit_transform(processed_data, batch_labels)
    
    return processed_data, corrected_data, batch_labels

def plot_batch_correction_results(original_data, corrected_data, batch_labels):
    """
    Visualize batch correction results
    """
    
    # Convert batch labels to numeric for coloring
    batch_numeric = [0 if b == 'Batch1' else 1 for b in batch_labels]
    
    fig, axes = plt.subplots(2, 2, figsize=(15, 12))
    
    # PCA before correction
    # Remove samples with too many missing values for PCA
    sample_valid_counts = original_data.notna().sum(axis=0)
    valid_samples = sample_valid_counts >= original_data.shape[0] * 0.5
    
    if valid_samples.sum() < 4:
        print("Not enough valid samples for PCA visualization")
        return
    
    # Subset data for PCA
    pca_data_orig = original_data.loc[:, valid_samples].fillna(0)  # Fill NaN with 0 for PCA
    pca_batch_labels = np.array(batch_labels)[valid_samples]
    pca_batch_numeric = np.array(batch_numeric)[valid_samples]
    
    pca = PCA(n_components=2)
    pca_orig = pca.fit_transform(pca_data_orig.T)  # Transpose for samples x proteins
    
    axes[0, 0].scatter(pca_orig[:, 0], pca_orig[:, 1], c=pca_batch_numeric, cmap='Set1', alpha=0.7)
    axes[0, 0].set_title('PCA Before Batch Correction')
    axes[0, 0].set_xlabel(f'PC1 ({pca.explained_variance_ratio_[0]:.1%} variance)')
    axes[0, 0].set_ylabel(f'PC2 ({pca.explained_variance_ratio_[1]:.1%} variance)')
    
    # PCA after correction
    pca_data_corr = corrected_data.loc[:, valid_samples].fillna(0)
    pca = PCA(n_components=2)
    pca_corr = pca.fit_transform(pca_data_corr.T)
    
    axes[0, 1].scatter(pca_corr[:, 0], pca_corr[:, 1], c=pca_batch_numeric, cmap='Set1', alpha=0.7)
    axes[0, 1].set_title('PCA After Batch Correction')
    axes[0, 1].set_xlabel(f'PC1 ({pca.explained_variance_ratio_[0]:.1%} variance)')
    axes[0, 1].set_ylabel(f'PC2 ({pca.explained_variance_ratio_[1]:.1%} variance)')
    
    # Boxplot comparison - sample a few proteins
    n_proteins_to_plot = min(5, original_data.shape[0])
    sample_proteins = original_data.index[:n_proteins_to_plot]
    
    # Before correction
    plot_data_orig = []
    for protein in sample_proteins:
        for i, batch in enumerate(batch_labels):
            value = original_data.loc[protein, original_data.columns[i]]
            if not np.isnan(value):
                plot_data_orig.append({'Protein': protein, 'Batch': batch, 'Intensity': value})
    
    df_plot_orig = pd.DataFrame(plot_data_orig)
    if len(df_plot_orig) > 0:
        sns.boxplot(data=df_plot_orig, x='Protein', y='Intensity', hue='Batch', ax=axes[1, 0])
        axes[1, 0].set_title('Sample Protein Intensities - Before Correction')
        axes[1, 0].tick_params(axis='x', rotation=45)
    
    # After correction
    plot_data_corr = []
    for protein in sample_proteins:
        for i, batch in enumerate(batch_labels):
            value = corrected_data.loc[protein, corrected_data.columns[i]]
            if not np.isnan(value):
                plot_data_corr.append({'Protein': protein, 'Batch': batch, 'Intensity': value})
    
    df_plot_corr = pd.DataFrame(plot_data_corr)
    if len(df_plot_corr) > 0:
        sns.boxplot(data=df_plot_corr, x='Protein', y='Intensity', hue='Batch', ax=axes[1, 1])
        axes[1, 1].set_title('Sample Protein Intensities - After Correction')
        axes[1, 1].tick_params(axis='x', rotation=45)
    
    plt.tight_layout()
    plt.show()

# Example usage with your data files
def main():
    """
    Main execution function - modify file paths to match your data location
    """
    
    # Replace these with your actual file paths
    file1_path = "L:\\promec\\TIMSTOF\\LARS\\2025\\250404_Alessandro\\combined\\txtB1\\proteinGroups.txt"     
    file2_path = "L:\\promec\\TIMSTOF\\LARS\\2025\\250507_Alessandro\\combined\\txtB2\\proteinGroups.txt" 

    print("=== Proteomics Batch Correction Pipeline ===")
    print("IMPORTANT: Update the file paths in the main() function to match your data location")
    print(f"Looking for files:")
    print(f"  - {file1_path}")
    print(f"  - {file2_path}")
    print()
    
    # Process the data
    original_data, corrected_data, batch_labels = combine_batches_and_correct(file1_path, file2_path)
    
    if original_data is not None and corrected_data is not None:
        print("\n=== Batch Correction Completed Successfully! ===")
        print(f"Final dataset: {corrected_data.shape[0]} proteins × {corrected_data.shape[1]} samples")
        
        # Save results
        print("\n=== Saving Results ===")
        corrected_data.to_csv("batch_corrected_proteins.csv")
        original_data.to_csv("original_combined_proteins.csv")
        
        pd.DataFrame({'Sample': corrected_data.columns, 'Batch': batch_labels}).to_csv("sample_batch_info.csv", index=False)
        
        print("Files saved:")
        print("  - batch_corrected_proteins.csv (corrected data)")
        print("  - original_combined_proteins.csv (original combined data)")
        print("  - sample_batch_info.csv (batch information)")
        
        # Create visualizations
        print("\n=== Creating Visualizations ===")
        plot_batch_correction_results(original_data, corrected_data, batch_labels)
        
        # Calculate some basic statistics
        print("\n=== Batch Correction Statistics ===")
        
        # Calculate median absolute deviation between batches before/after
        batch1_cols = [i for i, b in enumerate(batch_labels) if b == 'Batch1']
        batch2_cols = [i for i, b in enumerate(batch_labels) if b == 'Batch2']
        
        # Before correction
        orig_batch1_median = original_data.iloc[:, batch1_cols].median(axis=1)
        orig_batch2_median = original_data.iloc[:, batch2_cols].median(axis=1)
        orig_diff = np.abs(orig_batch1_median - orig_batch2_median)
        orig_mad = np.nanmedian(orig_diff)
        
        # After correction  
        corr_batch1_median = corrected_data.iloc[:, batch1_cols].median(axis=1)
        corr_batch2_median = corrected_data.iloc[:, batch2_cols].median(axis=1)
        corr_diff = np.abs(corr_batch1_median - corr_batch2_median)
        corr_mad = np.nanmedian(corr_diff)
        
        print(f"Median absolute difference between batches:")
        print(f"  Before correction: {orig_mad:.3f}")
        print(f"  After correction:  {corr_mad:.3f}")
        print(f"  Reduction: {((orig_mad - corr_mad) / orig_mad * 100):.1f}%")
        
    else:
        print("\n=== Batch Correction Failed ===")
        print("Please check your file paths and data format.")

if __name__ == "__main__":
    # Actually run the main function
    main()
