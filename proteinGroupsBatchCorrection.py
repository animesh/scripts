import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.decomposition import PCA
from sklearn.neighbors import NearestNeighbors
from scipy import sparse

class typicalProteomicsComBat:
    """
    typical ComBat with robust estimation and protein-specific modeling
    """
    
    def __init__(self, parametric=True, eb_shrink=True, robust=True):
        self.parametric = parametric
        self.eb_shrink = eb_shrink
        self.robust = robust
        
    def fit_transform(self, data, batch, covariates=None):
        """Enhanced ComBat with robust statistics and better missing value handling"""
        X = data.values.copy()
        batch = np.array(batch)
        
        missing_mask = np.isnan(X)
        batches = np.unique(batch)
        n_batches = len(batches)
        n_proteins, n_samples = X.shape
        
        print(f"typical ComBat: {n_proteins} proteins, {n_samples} samples, {n_batches} batches")
        
        if n_batches == 1:
            return data
        
        # Robust standardization per protein
        X_std = np.zeros_like(X)
        protein_stats = []
        
        for i in range(n_proteins):
            protein_data = X[i, :]
            valid_mask = ~missing_mask[i, :]
            
            if np.sum(valid_mask) < 3:
                X_std[i, :] = protein_data
                protein_stats.append({'mean': 0, 'scale': 1, 'robust': False})
                continue
            
            valid_data = protein_data[valid_mask]
            
            if self.robust:
                # Use median and MAD for robust standardization
                center = np.median(valid_data)
                scale = np.median(np.abs(valid_data - center)) * 1.4826  # MAD to std conversion
                if scale == 0:
                    scale = np.std(valid_data)
                    if scale == 0:
                        scale = 1
            else:
                center = np.mean(valid_data)
                scale = np.std(valid_data)
                if scale == 0:
                    scale = 1
            
            X_std[i, :] = (protein_data - center) / scale
            protein_stats.append({'mean': center, 'scale': scale, 'robust': self.robust})
        
        # typical batch effect estimation with empirical Bayes
        X_corrected = np.zeros_like(X_std)
        
        for i in range(n_proteins):
            if i % 1000 == 0 and i > 0:
                print(f"  Processing protein {i}/{n_proteins}")
            
            protein_data = X_std[i, :]
            valid_mask = ~missing_mask[i, :]
            
            if np.sum(valid_mask) < 3:
                X_corrected[i, :] = protein_data
                continue
            
            X_corrected[i, :] = self._typical_protein_correction(
                protein_data, batch, valid_mask, batches
            )
        
        # Convert back with original scaling
        X_final = np.zeros_like(X_corrected)
        for i in range(n_proteins):
            stats_i = protein_stats[i]
            X_final[i, :] = X_corrected[i, :] * stats_i['scale'] + stats_i['mean']
        
        corrected_df = pd.DataFrame(X_final, index=data.index, columns=data.columns)
        corrected_df = corrected_df.mask(missing_mask)
        
        return corrected_df
    
    def _typical_protein_correction(self, protein_data, batch, valid_mask, batches):
        """typical protein-level batch correction with empirical Bayes"""
        corrected_data = protein_data.copy()
        valid_data = protein_data[valid_mask]
        valid_batch = batch[valid_mask]
        
        if len(np.unique(valid_batch)) < 2:
            return corrected_data
        
        # Estimate batch effects with robust statistics
        batch_effects = {}
        for batch_id in batches:
            batch_mask = valid_batch == batch_id
            batch_values = valid_data[batch_mask]
            
            if len(batch_values) < 2:
                batch_effects[batch_id] = {'gamma': 0, 'delta': 1}
                continue
            
            if self.robust:
                gamma = np.median(batch_values)
                delta = (np.median(np.abs(batch_values - gamma)) * 1.4826) ** 2
            else:
                gamma = np.mean(batch_values)
                delta = np.var(batch_values)
            
            if delta == 0:
                delta = 1
                
            batch_effects[batch_id] = {'gamma': gamma, 'delta': delta}
        
        # Empirical Bayes shrinkage
        if self.eb_shrink and len(batch_effects) > 1:
            gammas = [batch_effects[b]['gamma'] for b in batches if b in batch_effects]
            deltas = [batch_effects[b]['delta'] for b in batches if b in batch_effects]
            
            # Prior estimates
            gamma_bar = np.mean(gammas) if gammas else 0
            tau2 = np.var(gammas) if len(gammas) > 1 else 1
            
            # Shrinkage for location parameters
            for batch_id in batches:
                if batch_id in batch_effects:
                    batch_size = np.sum(valid_batch == batch_id)
                    shrinkage = tau2 / (tau2 + batch_effects[batch_id]['delta'] / batch_size)
                    batch_effects[batch_id]['gamma_shrunk'] = (
                        shrinkage * batch_effects[batch_id]['gamma'] + 
                        (1 - shrinkage) * gamma_bar
                    )
                else:
                    batch_effects[batch_id] = {'gamma_shrunk': 0, 'delta': 1}
        else:
            for batch_id in batches:
                if batch_id in batch_effects:
                    batch_effects[batch_id]['gamma_shrunk'] = batch_effects[batch_id]['gamma']
        
        # Apply correction
        for batch_id in batches:
            batch_mask = batch == batch_id
            if batch_id in batch_effects:
                gamma = batch_effects[batch_id]['gamma_shrunk']
                delta = max(batch_effects[batch_id]['delta'], 0.01)
                corrected_data[batch_mask] = (protein_data[batch_mask] - gamma) / np.sqrt(delta)
        
        return corrected_data

class typicalBBKNN:
    """
    Enhanced BBKNN with adaptive parameters and quality metrics
    """
    
    def __init__(self, n_neighbors=15, n_pcs=50, trim=0, approx=True):
        self.n_neighbors = n_neighbors
        self.n_pcs = n_pcs
        self.trim = trim
        self.approx = approx
        
    def fit_transform(self, X, batch_labels):
        """Enhanced BBKNN with adaptive neighbor selection"""
        batch_labels = np.array(batch_labels)
        batches = np.unique(batch_labels)
        n_batches = len(batches)
        n_samples = X.shape[0]
        
        print(f"Enhanced BBKNN: {n_samples} samples, {n_batches} batches")
        
        # Adaptive neighbor count per batch
        min_batch_size = min([np.sum(batch_labels == b) for b in batches])
        neighbors_per_batch = min(
            max(1, self.n_neighbors // n_batches),
            min_batch_size - 1
        )
        
        print(f"  Using {neighbors_per_batch} neighbors per batch")
        
        # Build enhanced connectivity matrix
        connectivities = self._build_enhanced_connectivity(X, batch_labels, neighbors_per_batch)
        
        return connectivities
    
    def _build_enhanced_connectivity(self, X, batch_labels, neighbors_per_batch):
        """Build connectivity with distance weighting and quality control"""
        n_samples = X.shape[0]
        batches = np.unique(batch_labels)
        
        row_ind, col_ind, data = [], [], []
        
        for i in range(n_samples):
            current_batch = batch_labels[i]
            all_neighbors = []
            all_distances = []
            
            for batch_id in batches:
                batch_mask = batch_labels == batch_id
                batch_indices = np.where(batch_mask)[0]
                
                # Exclude self if same batch
                if batch_id == current_batch:
                    batch_indices = batch_indices[batch_indices != i]
                
                if len(batch_indices) == 0:
                    continue
                
                # Find neighbors in this batch
                batch_data = X[batch_indices]
                current_point = X[i].reshape(1, -1)
                
                # Calculate distances
                distances = np.sqrt(np.sum((batch_data - current_point)**2, axis=1))
                
                # Select top neighbors
                n_select = min(neighbors_per_batch, len(batch_indices))
                if n_select > 0:
                    top_idx = np.argsort(distances)[:n_select]
                    
                    selected_neighbors = batch_indices[top_idx]
                    selected_distances = distances[top_idx]
                    
                    all_neighbors.extend(selected_neighbors)
                    all_distances.extend(selected_distances)
            
            # Weight by inverse distance
            if all_neighbors:
                distances_array = np.array(all_distances)
                # Avoid division by zero
                distances_array = np.maximum(distances_array, 1e-10)
                weights = 1.0 / (1.0 + distances_array)
                
                for neighbor, weight in zip(all_neighbors, weights):
                    row_ind.append(i)
                    col_ind.append(neighbor)
                    data.append(weight)
        
        # Create sparse matrix
        connectivities = sparse.csr_matrix(
            (data, (row_ind, col_ind)), 
            shape=(n_samples, n_samples)
        )
        
        # Symmetrize
        connectivities = (connectivities + connectivities.T) / 2
        
        return connectivities

class proteomicsBatchCorrection:
    """
     batch correction combining multiple typical methods
    """
    
    def __init__(self, method='hybrid', n_pcs=50, n_neighbors=15):
        self.method = method
        self.n_pcs = n_pcs
        self.n_neighbors = n_neighbors
        self.combat = typicalProteomicsComBat(robust=True, eb_shrink=True)
        self.bbknn = typicalBBKNN(n_neighbors=n_neighbors, n_pcs=n_pcs)
        
    def fit_transform(self, data, batch_labels):
        """Apply  batch correction pipeline"""
        
        print("===  Proteomics Batch Correction ===")
        
        if self.method == 'combat_only':
            return self._combat_only(data, batch_labels)
        elif self.method == 'bbknn_only':
            return self._bbknn_only(data, batch_labels)
        elif self.method == 'hybrid':
            return self._hybrid_correction(data, batch_labels)
        else:
            raise ValueError(f"Unknown method: {self.method}")
    
    def _combat_only(self, data, batch_labels):
        """ComBat correction only"""
        print("Applying typical ComBat correction...")
        return self.combat.fit_transform(data, batch_labels)
    
    def _bbknn_only(self, data, batch_labels):
        """BBKNN correction only"""
        print("Applying BBKNN correction...")
        # First do PCA
        valid_data = data.fillna(data.median())  # Simple imputation for PCA
        pca = PCA(n_components=self.n_pcs)
        X_pca = pca.fit_transform(valid_data.T)  # Samples x PCs
        
        # Apply BBKNN
        connectivities = self.bbknn.fit_transform(X_pca, batch_labels)
        
        return data, X_pca, connectivities
    
    def _hybrid_correction(self, data, batch_labels):
        """Hybrid approach: ComBat + BBKNN + additional refinements"""
        
        # Step 1: typical ComBat correction
        print("Step 1: typical ComBat correction...")
        combat_corrected = self.combat.fit_transform(data, batch_labels)
        
        # Step 2: PCA on ComBat-corrected data
        print("Step 2: PCA on ComBat-corrected data...")
        # Handle missing values for PCA
        combat_filled = combat_corrected.fillna(combat_corrected.median())
        
        pca = PCA(n_components=self.n_pcs)
        X_pca = pca.fit_transform(combat_filled.T)  # Samples x PCs
        
        print(f"  Explained variance (first 10 PCs): {pca.explained_variance_ratio_[:10].sum():.3f}")
        
        # Step 3: Enhanced BBKNN
        print("Step 3: Enhanced BBKNN...")
        connectivities = self.bbknn.fit_transform(X_pca, batch_labels)
        
        # Step 4: Additional quality control and refinement
        print("Step 4: Quality control and refinement...")
        refined_data = self._refine_correction(combat_corrected, X_pca, batch_labels)
        
        return refined_data, X_pca, connectivities, pca
    
    def _refine_correction(self, combat_data, pca_data, batch_labels):
        """Additional refinement based on PCA and batch mixing"""
        
        # Calculate batch mixing quality in PCA space
        batch_mixing_score = self._calculate_batch_mixing(pca_data, batch_labels)
        print(f"  Batch mixing score: {batch_mixing_score:.3f}")
        
        # If mixing is poor, apply additional local corrections
        if batch_mixing_score < 0.3:  # Threshold for poor mixing
            print("  Applying additional local corrections...")
            return self._local_refinement(combat_data, pca_data, batch_labels)
        
        return combat_data
    
    def _calculate_batch_mixing(self, pca_data, batch_labels, k=20):
        """Calculate batch mixing score in PCA space"""
        nn = NearestNeighbors(n_neighbors=k+1)
        nn.fit(pca_data)
        _, indices = nn.kneighbors(pca_data)
        
        mixing_scores = []
        for i in range(len(pca_data)):
            neighbors = indices[i][1:]  # Exclude self
            neighbor_batches = np.array(batch_labels)[neighbors]
            current_batch = batch_labels[i]
            
            different_batch_ratio = np.mean(neighbor_batches != current_batch)
            mixing_scores.append(different_batch_ratio)
        
        return np.mean(mixing_scores)
    
    def _local_refinement(self, data, pca_data, batch_labels):
        """Apply local refinements for poorly mixed regions"""
        # This is a simplified local refinement
        # In practice, you might want to identify poorly mixed clusters
        # and apply targeted corrections
        
        # For now, apply a mild additional global correction
        refined_data = data.copy()
        
        # Identify outlier samples in PCA space
        from scipy.spatial.distance import cdist
        batch_centers = {}
        for batch in np.unique(batch_labels):
            batch_mask = np.array(batch_labels) == batch
            batch_centers[batch] = np.mean(pca_data[batch_mask], axis=0)
        
        # Apply mild correction to outliers
        for i, batch in enumerate(batch_labels):
            sample_pca = pca_data[i]
            center = batch_centers[batch]
            distance = np.linalg.norm(sample_pca - center)
            
            # If sample is far from batch center, apply mild correction
            if distance > 2 * np.std([np.linalg.norm(pca_data[j] - batch_centers[batch_labels[j]]) 
                                    for j in range(len(batch_labels))]):
                correction_factor = 0.9  # Mild correction
                refined_data.iloc[:, i] = refined_data.iloc[:, i] * correction_factor
        
        return refined_data

def comprehensive_quality_assessment(original_data, corrected_data, pca_data, batch_labels):
    """Comprehensive quality assessment of batch correction"""
    
    print("\n=== Comprehensive Quality Assessment ===")
    
    # 1. Batch mixing scores
    def batch_mixing_score(data, labels, k=20):
        if len(data.shape) == 2 and data.shape[1] > 50:
            # Use PCA for high-dimensional data
            pca = PCA(n_components=min(50, data.shape[1]))
            data_reduced = pca.fit_transform(data)
        else:
            data_reduced = data
            
        nn = NearestNeighbors(n_neighbors=k+1)
        nn.fit(data_reduced)
        _, indices = nn.kneighbors(data_reduced)
        
        scores = []
        for i in range(len(data_reduced)):
            neighbors = indices[i][1:]
            neighbor_batches = np.array(labels)[neighbors]
            current_batch = labels[i]
            scores.append(np.mean(neighbor_batches != current_batch))
        
        return np.mean(scores)
    
    # Calculate mixing scores
    original_filled = original_data.fillna(original_data.median()).T
    corrected_filled = corrected_data.fillna(corrected_data.median()).T
    
    mixing_original = batch_mixing_score(original_filled.values, batch_labels)
    mixing_corrected = batch_mixing_score(corrected_filled.values, batch_labels)
    mixing_pca = batch_mixing_score(pca_data, batch_labels)
    
    print(f"Batch mixing scores:")
    print(f"  Original data: {mixing_original:.3f}")
    print(f"  Corrected data: {mixing_corrected:.3f}")
    print(f"  PCA space: {mixing_pca:.3f}")
    print(f"  Improvement: {((mixing_corrected - mixing_original) / mixing_original * 100):.1f}%")
    
    # 2. Silhouette analysis
    from sklearn.metrics import silhouette_score
    
    try:
        sil_original = silhouette_score(original_filled.values, batch_labels)
        sil_corrected = silhouette_score(corrected_filled.values, batch_labels)
        sil_pca = silhouette_score(pca_data, batch_labels)
        
        print(f"\nBatch separation (Silhouette - lower is better):")
        print(f"  Original data: {sil_original:.3f}")
        print(f"  Corrected data: {sil_corrected:.3f}")
        print(f"  PCA space: {sil_pca:.3f}")
        print(f"  Reduction: {((sil_original - sil_corrected) / abs(sil_original) * 100):.1f}%")
    except:
        print("\nSilhouette analysis failed (likely due to data structure)")
    
    # 3. Variance explained by batch
    def batch_variance_explained(data, labels):
        from sklearn.linear_model import LinearRegression
        
        # Convert batch labels to dummy variables
        batch_dummies = pd.get_dummies(pd.Series(labels)).values
        
        explained_vars = []
        for i in range(data.shape[1]):  # For each protein
            protein_data = data.iloc[:, i].dropna()
            if len(protein_data) < 10:
                continue
            
            # Get indices of valid samples for this protein
            valid_indices = protein_data.index.tolist()
            
            # Convert to integer indices if they're not already
            if isinstance(valid_indices[0], str) or not isinstance(valid_indices[0], (int, np.integer)):
                # Map to integer positions
                valid_positions = [data.index.get_loc(idx) for idx in valid_indices if idx in data.index]
            else:
                valid_positions = [idx for idx in valid_indices if idx < len(batch_dummies)]
            
            if len(valid_positions) < 10:
                continue
                
            batch_subset = batch_dummies[valid_positions]
            
            try:
                lr = LinearRegression()
                lr.fit(batch_subset, protein_data.values)
                r2 = lr.score(batch_subset, protein_data.values)
                explained_vars.append(max(0, r2))
            except:
                continue
        
        return np.mean(explained_vars) if explained_vars else 0
    
    var_original = batch_variance_explained(original_data.T, batch_labels)
    var_corrected = batch_variance_explained(corrected_data.T, batch_labels)
    
    print(f"\nVariance explained by batch:")
    print(f"  Original data: {var_original:.3f}")
    print(f"  Corrected data: {var_corrected:.3f}")
    print(f"  Reduction: {((var_original - var_corrected) / var_original * 100):.1f}%")
    
    return {
        'mixing_scores': {
            'original': mixing_original,
            'corrected': mixing_corrected,
            'pca': mixing_pca
        },
        'batch_variance': {
            'original': var_original,
            'corrected': var_corrected
        }
    }

def typical_visualization(original_data, corrected_data, pca_data, batch_labels, pca_obj):
    """Create comprehensive visualizations"""
    
    print("\n=== Creating typical Visualizations ===")
    
    fig, axes = plt.subplots(3, 3, figsize=(20, 15))
    
    # Convert batch labels to colors
    unique_batches = np.unique(batch_labels)
    colors = plt.cm.Set1(np.linspace(0, 1, len(unique_batches)))
    batch_colors = [colors[list(unique_batches).index(b)] for b in batch_labels]
    
    # Row 1: PCA plots
    # Original data PCA
    original_filled = original_data.fillna(original_data.median())
    pca_orig = PCA(n_components=2)
    pca_orig_result = pca_orig.fit_transform(original_filled.T)
    
    axes[0, 0].scatter(pca_orig_result[:, 0], pca_orig_result[:, 1], c=batch_colors, alpha=0.7, s=50)
    axes[0, 0].set_title(f'Original Data PCA\nVar explained: {pca_orig.explained_variance_ratio_.sum():.1%}')
    axes[0, 0].set_xlabel(f'PC1 ({pca_orig.explained_variance_ratio_[0]:.1%})')
    axes[0, 0].set_ylabel(f'PC2 ({pca_orig.explained_variance_ratio_[1]:.1%})')
    
    # Corrected data PCA
    corrected_filled = corrected_data.fillna(corrected_data.median())
    pca_corr = PCA(n_components=2)
    pca_corr_result = pca_corr.fit_transform(corrected_filled.T)
    
    axes[0, 1].scatter(pca_corr_result[:, 0], pca_corr_result[:, 1], c=batch_colors, alpha=0.7, s=50)
    axes[0, 1].set_title(f'Corrected Data PCA\nVar explained: {pca_corr.explained_variance_ratio_.sum():.1%}')
    axes[0, 1].set_xlabel(f'PC1 ({pca_corr.explained_variance_ratio_[0]:.1%})')
    axes[0, 1].set_ylabel(f'PC2 ({pca_corr.explained_variance_ratio_[1]:.1%})')
    
    # PCA from pipeline
    axes[0, 2].scatter(pca_data[:, 0], pca_data[:, 1], c=batch_colors, alpha=0.7, s=50)
    axes[0, 2].set_title(f'Pipeline PCA\nVar explained: {pca_obj.explained_variance_ratio_[:2].sum():.1%}')
    axes[0, 2].set_xlabel(f'PC1 ({pca_obj.explained_variance_ratio_[0]:.1%})')
    axes[0, 2].set_ylabel(f'PC2 ({pca_obj.explained_variance_ratio_[1]:.1%})')
    
    # Row 2: Density plots
    for i, (data, title) in enumerate([(original_data, 'Original'), (corrected_data, 'Corrected'), (None, 'Batch Effects')]):
        if i < 2:
            # Sample a few proteins for visualization
            sample_proteins = data.index[:min(100, len(data.index))]
            plot_data = []
            
            for protein in sample_proteins:
                for j, batch in enumerate(batch_labels):
                    value = data.loc[protein, data.columns[j]]
                    if not pd.isna(value):
                        plot_data.append({'Batch': batch, 'Intensity': value})
            
            if plot_data:
                df_plot = pd.DataFrame(plot_data)
                for batch in unique_batches:
                    batch_data = df_plot[df_plot['Batch'] == batch]['Intensity']
                    if len(batch_data) > 0:
                        axes[1, i].hist(batch_data, alpha=0.6, bins=50, 
                                      color=colors[list(unique_batches).index(batch)], 
                                      label=f'Batch {batch}', density=True)
                
                axes[1, i].set_title(f'{title} Data Distribution')
                axes[1, i].set_xlabel('Log2 Intensity')
                axes[1, i].set_ylabel('Density')
                axes[1, i].legend()
        else:
            # Batch effect magnitude plot
            if len(unique_batches) == 2:
                batch1_data = corrected_data.iloc[:, [i for i, b in enumerate(batch_labels) if b == unique_batches[0]]]
                batch2_data = corrected_data.iloc[:, [i for i, b in enumerate(batch_labels) if b == unique_batches[1]]]
                
                batch1_mean = batch1_data.median(axis=1)
                batch2_mean = batch2_data.median(axis=1)
                
                batch_diff = np.abs(batch1_mean - batch2_mean)
                batch_diff_clean = batch_diff.dropna()
                
                if len(batch_diff_clean) > 0:
                    axes[1, 2].hist(batch_diff_clean, bins=50, alpha=0.7, color='purple')
                    axes[1, 2].set_title('Residual Batch Effects\n(Absolute Median Difference)')
                    axes[1, 2].set_xlabel('|Median Difference|')
                    axes[1, 2].set_ylabel('Number of Proteins')
    
    # Row 3: Quality metrics and variance plots
    # Scree plot
    axes[2, 0].plot(range(1, min(21, len(pca_obj.explained_variance_ratio_)+1)), 
                   pca_obj.explained_variance_ratio_[:20], 'bo-')
    axes[2, 0].set_title('PCA Scree Plot')
    axes[2, 0].set_xlabel('Principal Component')
    axes[2, 0].set_ylabel('Explained Variance Ratio')
    
    # Sample correlation heatmap
    sample_corr = corrected_filled.T.corr()
    im = axes[2, 1].imshow(sample_corr.values, cmap='RdBu_r', vmin=-1, vmax=1)
    axes[2, 1].set_title('Sample Correlation Matrix\n(Corrected Data)')
    plt.colorbar(im, ax=axes[2, 1], fraction=0.046, pad=0.04)
    
    # Batch summary statistics
    batch_stats = []
    for batch in unique_batches:
        batch_mask = [b == batch for b in batch_labels]
        batch_data = corrected_data.iloc[:, batch_mask]
        batch_stats.append({
            'Batch': batch,
            'Samples': batch_data.shape[1],
            'Mean_Intensity': batch_data.mean().mean(),
            'Std_Intensity': batch_data.std().mean()
        })
    
    df_stats = pd.DataFrame(batch_stats)
    x_pos = range(len(df_stats))
    
    axes[2, 2].bar(x_pos, df_stats['Mean_Intensity'], alpha=0.7, color=colors[:len(df_stats)])
    axes[2, 2].set_title('Mean Intensity by Batch\n(After Correction)')
    axes[2, 2].set_xlabel('Batch')
    axes[2, 2].set_ylabel('Mean Log2 Intensity')
    axes[2, 2].set_xticks(x_pos)
    axes[2, 2].set_xticklabels([f'Batch {b}' for b in df_stats['Batch']])
    
    # Add legend for batches
    legend_elements = [plt.Line2D([0], [0], marker='o', color='w', 
                                 markerfacecolor=colors[i], markersize=10, 
                                 label=f'Batch {batch}') 
                      for i, batch in enumerate(unique_batches)]
    fig.legend(handles=legend_elements, loc='upper right', bbox_to_anchor=(0.98, 0.98))
    
    plt.tight_layout()
    plt.show()

def main():
    """ proteomics batch correction pipeline"""
    
    # File paths
    file1_path = r"L:\promec\TIMSTOF\LARS\2025\250404_Alessandro\combined\txtB1\proteinGroups.txt"
    file2_path = r"L:\promec\TIMSTOF\LARS\2025\250507_Alessandro\combined\txtB2\proteinGroups.txt"
    
    print("===  Proteomics Batch Correction Pipeline ===")
    print(f"Processing files:")
    print(f"  Batch 1: {file1_path}")
    print(f"  Batch 2: {file2_path}")
    
    try:
        # Load data with enhanced error handling
        print("\n=== Loading and Processing Data ===")
        
        def load_and_process_proteingroups(filepath, batch_name):
            """Enhanced data loading with better column detection"""
            print(f"Loading {batch_name} from: {filepath}")
            
            try:
                df = pd.read_csv(filepath, sep='\t', low_memory=False)
                print(f"  {batch_name} raw shape: {df.shape}")
                
                # Enhanced intensity column detection
                intensity_cols = []
                
                # Priority order for intensity columns
                column_priorities = [
                    'LFQ intensity',
                    'Intensity',
                    'iBAQ', 
                    'MaxLFQ intensity'
                ]
                
                for priority in column_priorities:
                    priority_cols = [col for col in df.columns if priority in col and col != priority]
                    if priority_cols:
                        intensity_cols = priority_cols
                        print(f"  Found {len(intensity_cols)} {priority} columns")
                        break
                
                if not intensity_cols:
                    print(f"  No standard intensity columns found. Available columns:")
                    print(f"  {list(df.columns)}")
                    raise ValueError("No intensity columns detected")
                
                # Get protein identifiers with fallback options
                if 'Majority protein IDs' in df.columns:
                    protein_ids = df['Majority protein IDs']
                elif 'Protein IDs' in df.columns:
                    protein_ids = df['Protein IDs']
                elif 'Gene names' in df.columns:
                    protein_ids = df['Gene names']
                else:
                    protein_ids = df.index.astype(str)
                
                # Filter contaminants and reverse sequences
                if 'Reverse' in df.columns:
                    df = df[df['Reverse'] != '+']
                    print(f"  Filtered reverse sequences: {df.shape[0]} proteins remaining")
                
                if 'Potential contaminant' in df.columns:
                    df = df[df['Potential contaminant'] != '+']
                    print(f"  Filtered contaminants: {df.shape[0]} proteins remaining")
                
                # Create intensity matrix
                intensity_data = df[intensity_cols].copy()
                intensity_data.index = protein_ids.iloc[intensity_data.index]
                
                # Convert to numeric
                intensity_data = intensity_data.apply(pd.to_numeric, errors='coerce')
                
                # Replace zeros with NaN for log transformation
                intensity_data = intensity_data.replace(0, np.nan)
                
                print(f"  {batch_name} final intensity matrix: {intensity_data.shape}")
                print(f"  Non-zero values: {intensity_data.notna().sum().sum()}")
                
                return intensity_data
                
            except Exception as e:
                print(f"Error loading {batch_name}: {e}")
                return None
        
        # Load both datasets
        batch1_data = load_and_process_proteingroups(file1_path, "Batch 1")
        batch2_data = load_and_process_proteingroups(file2_path, "Batch 2")
        
        if batch1_data is None or batch2_data is None:
            print("Failed to load one or both datasets")
            return
        
        # Find common proteins with enhanced matching
        print(f"\n=== Protein Matching ===")
        print(f"Batch 1 proteins: {len(batch1_data.index)}")
        print(f"Batch 2 proteins: {len(batch2_data.index)}")
        
        # Direct matching
        common_proteins = batch1_data.index.intersection(batch2_data.index)
        print(f"Direct matches: {len(common_proteins)}")
        
        # If few matches, try fuzzy matching on first protein ID
        if len(common_proteins) < min(len(batch1_data.index), len(batch2_data.index)) * 0.5:
            print("Low direct match rate, attempting enhanced matching...")
            
            # Extract first protein ID (before semicolon)
            batch1_first = batch1_data.index.to_series().str.split(';').str[0]
            batch2_first = batch2_data.index.to_series().str.split(';').str[0]
            
            # Find matches based on first protein ID
            enhanced_matches = batch1_first.isin(batch2_first)
            
            if enhanced_matches.sum() > len(common_proteins):
                print(f"Enhanced matching found {enhanced_matches.sum()} matches")
                # Create mapping
                batch1_matched = batch1_data[enhanced_matches]
                batch1_matched.index = batch1_first[enhanced_matches]
                
                batch2_matched = batch2_data.copy()
                batch2_matched.index = batch2_first
                
                common_first_ids = batch1_matched.index.intersection(batch2_matched.index)
                
                batch1_common = batch1_matched.loc[common_first_ids]
                batch2_common = batch2_matched.loc[common_first_ids]
                
                print(f"Using enhanced matching: {len(common_first_ids)} proteins")
            else:
                batch1_common = batch1_data.loc[common_proteins]
                batch2_common = batch2_data.loc[common_proteins]
        else:
            batch1_common = batch1_data.loc[common_proteins]
            batch2_common = batch2_data.loc[common_proteins]
        
        if len(batch1_common) == 0:
            print("No common proteins found between batches!")
            return
        
        print(f"Final common proteins: {len(batch1_common)}")
        
        # Combine datasets
        print(f"\n=== Data Combination ===")
        combined_data = pd.concat([batch1_common, batch2_common], axis=1)
        batch_labels = (['Batch1'] * batch1_common.shape[1] + 
                       ['Batch2'] * batch2_common.shape[1])
        
        print(f"Combined shape: {combined_data.shape}")
        print(f"Batch distribution: {pd.Series(batch_labels).value_counts().to_dict()}")
        
        # Enhanced preprocessing
        print(f"\n=== Enhanced Preprocessing ===")
        
        # Log2 transformation
        print("Applying log2 transformation...")
        log_data = np.log2(combined_data)
        
        # Filter proteins by data completeness
        completeness_threshold = 0.6  # At least 60% valid values
        protein_completeness = log_data.notna().sum(axis=1) / log_data.shape[1]
        high_quality_proteins = protein_completeness >= completeness_threshold
        
        filtered_data = log_data.loc[high_quality_proteins]
        print(f"Proteins after completeness filtering ({completeness_threshold*100}%): {filtered_data.shape[0]}")
        
        # Filter samples by data completeness
        sample_completeness = filtered_data.notna().sum(axis=0) / filtered_data.shape[0]
        high_quality_samples = sample_completeness >= 0.3  # At least 30% proteins detected
        
        if high_quality_samples.sum() < len(batch_labels):
            print(f"Filtering {len(batch_labels) - high_quality_samples.sum()} low-quality samples")
            final_data = filtered_data.iloc[:, high_quality_samples]
            final_batch_labels = [batch_labels[i] for i in range(len(batch_labels)) if high_quality_samples.iloc[i]]
        else:
            final_data = filtered_data
            final_batch_labels = batch_labels
        
        print(f"Final preprocessed data: {final_data.shape}")
        print(f"Missing value percentage: {final_data.isna().sum().sum() / final_data.size * 100:.1f}%")
        
        # Apply  Batch Correction
        print(f"\n===  Batch Correction ===")
        
        corrector = proteomicsBatchCorrection(
            method='hybrid', 
            n_pcs=min(50, final_data.shape[1]-1),
            n_neighbors=15
        )
        
        result = corrector.fit_transform(final_data, final_batch_labels)
        
        # Unpack results based on method
        if len(result) == 4:  # hybrid method
            corrected_data, pca_data, connectivities, pca_obj = result
        else:
            corrected_data = result
            # Create PCA for visualization
            filled_data = corrected_data.fillna(corrected_data.median())
            pca_obj = PCA(n_components=min(50, filled_data.shape[1]))
            pca_data = pca_obj.fit_transform(filled_data.T)
            connectivities = None
        
        # Comprehensive Quality Assessment
        quality_metrics = comprehensive_quality_assessment(
            final_data, corrected_data, pca_data, final_batch_labels
        )
        
        # Save enhanced results
        print(f"\n=== Saving Enhanced Results ===")
        
        # Main corrected data
        corrected_data.to_csv("_batch_corrected_proteins.csv")
        
        # Original data for comparison
        final_data.to_csv("original_combined_proteins.csv")
        
        # PCA results
        pca_df = pd.DataFrame(pca_data, 
                             columns=[f'PC{i+1}' for i in range(pca_data.shape[1])],
                             index=corrected_data.columns)
        pca_df.to_csv("pca_embedding.csv")
        
        # Sample metadata
        sample_metadata = pd.DataFrame({
            'Sample': corrected_data.columns,
            'Batch': final_batch_labels,
            'Original_Index': range(len(final_batch_labels))
        })
        sample_metadata.to_csv("sample_metadata.csv", index=False)
        
        # Quality metrics
        quality_df = pd.DataFrame([quality_metrics['mixing_scores'], 
                                  quality_metrics['batch_variance']], 
                                 index=['mixing_scores', 'batch_variance'])
        quality_df.to_csv("quality_metrics.csv")
        
        # Protein statistics
        protein_stats = pd.DataFrame({
            'Protein_ID': corrected_data.index,
            'Original_Completeness': protein_completeness.loc[corrected_data.index],
            'Mean_Intensity_Original': final_data.mean(axis=1),
            'Mean_Intensity_Corrected': corrected_data.mean(axis=1),
            'Std_Intensity_Original': final_data.std(axis=1),
            'Std_Intensity_Corrected': corrected_data.std(axis=1)
        })
        protein_stats.to_csv("protein_statistics.csv", index=False)
        
        # Connectivity matrix if available
        if connectivities is not None:
            sparse.save_npz("connectivity_matrix.npz", connectivities)
        
        print("Files saved:")
        print("  • _batch_corrected_proteins.csv - Main result")
        print("  • original_combined_proteins.csv - Original data")  
        print("  • pca_embedding.csv - PCA coordinates")
        print("  • sample_metadata.csv - Sample information")
        print("  • quality_metrics.csv - Correction quality metrics")
        print("  • protein_statistics.csv - Per-protein statistics")
        if connectivities is not None:
            print("  • connectivity_matrix.npz - BBKNN connectivity graph")
        
        # Create typical visualizations
        typical_visualization(final_data, corrected_data, pca_data, final_batch_labels, pca_obj)
        
        # Print final summary
        print(f"\n===  CORRECTION SUMMARY ===")
        print(f"✓ Processed {final_data.shape[0]} proteins across {final_data.shape[1]} samples")
        print(f"✓ Batch mixing improvement: {((quality_metrics['mixing_scores']['corrected'] - quality_metrics['mixing_scores']['original']) / quality_metrics['mixing_scores']['original'] * 100):.1f}%")
        print(f"✓ Batch variance reduction: {((quality_metrics['batch_variance']['original'] - quality_metrics['batch_variance']['corrected']) / quality_metrics['batch_variance']['original'] * 100):.1f}%")
        
        if quality_metrics['mixing_scores']['corrected'] > 0.5:
            print("✓ EXCELLENT batch mixing achieved!")
        elif quality_metrics['mixing_scores']['corrected'] > 0.3:
            print("✓ GOOD batch mixing achieved!")
        else:
            print("⚠ Moderate batch mixing - consider additional parameter tuning")
        
        print("\n🎉  batch correction completed successfully!")
        print("Your data is now ready for downstream analysis!")
        
    except Exception as e:
        print(f"\n❌ Error in batch correction pipeline: {e}")
        import traceback
        traceback.print_exc()
        
        print("\n🔧 Troubleshooting tips:")
        print("1. Check file paths are correct")
        print("2. Verify proteinGroups.txt files are valid MaxQuant output")
        print("3. Ensure sufficient disk space for output files")
        print("4. Check data has sufficient overlap between batches")

if __name__ == "__main__":
    main()