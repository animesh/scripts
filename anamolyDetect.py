#python anamolyDetect.py "Z:\Download\proteinGroups.txt" 51
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import re
import sys
import os
from collections import Counter
import argparse

def extract_first_digit(value):
    str_value = str(value)
    match = re.search(r'[1-9]', str_value)
    if match:
        return int(match.group())
    return None

def read_and_extract_column(file_path, column_index, has_header=True):
    try:
        if has_header:
            df = pd.read_csv(file_path, sep='\t', low_memory=False)
            if column_index >= len(df.columns):
                raise IndexError(f"Column index {column_index} is out of range. File has {len(df.columns)} columns.")
            column_data = df.iloc[:, column_index].tolist()
            column_name = df.columns[column_index]
        else:
            df = pd.read_csv(file_path, sep='\t', header=None, low_memory=False)
            if column_index >= len(df.columns):
                raise IndexError(f"Column index {column_index} is out of range. File has {len(df.columns)} columns.")
            column_data = df.iloc[:, column_index].tolist()
            column_name = None
        return column_data, column_name
    except FileNotFoundError:
        print(f"Error: File '{file_path}' not found.")
        sys.exit(1)
    except Exception as e:
        print(f"Error reading file: {e}")
        sys.exit(1)

def create_barplot(first_digits, total_values, output_file, title, column_data):
    digit_counts = Counter(first_digits)
    digits = list(range(1, 10))
    counts = [digit_counts.get(digit, 0) for digit in digits]
    
    # Calculate Benford's Law expected percentages
    benford_expected = [np.log10(1 + (1/digit)) * 100 for digit in digits]
    total_count = sum(counts)
    
    # Calculate expected counts based on Benford's Law
    expected_counts = [(percentage/100) * total_count for percentage in benford_expected]
    
    # Generate uniform random data in same range as original data
    numeric_values = []
    for value in column_data:
        try:
            if pd.notna(value) and str(value).strip() != '':
                num_val = float(str(value))
                if num_val > 0:  # Only positive values for first digit analysis
                    numeric_values.append(num_val)
        except (ValueError, TypeError):
            continue
    
    if numeric_values:
        min_val = min(numeric_values)
        max_val = max(numeric_values)
        # Generate same number of random values as we have valid first digits
        np.random.seed(42)  # For reproducible results
        random_values = np.random.uniform(min_val, max_val, len(first_digits))
        
        # Generate log10-uniform random data (as per Benford's Law theory)
        log_min = np.log10(min_val)
        log_max = np.log10(max_val)
        log_uniform_values = 10 ** np.random.uniform(log_min, log_max, len(first_digits))
        
        # Extract first digits from both types of random values
        random_first_digits = []
        log_uniform_first_digits = []
        for val in random_values:
            first_digit = extract_first_digit(val)
            if first_digit is not None:
                random_first_digits.append(first_digit)
        
        for val in log_uniform_values:
            first_digit = extract_first_digit(val)
            if first_digit is not None:
                log_uniform_first_digits.append(first_digit)
        
        random_digit_counts = Counter(random_first_digits)
        log_uniform_digit_counts = Counter(log_uniform_first_digits)
        random_counts = [random_digit_counts.get(digit, 0) for digit in digits]
        log_uniform_counts = [log_uniform_digit_counts.get(digit, 0) for digit in digits]
    else:
        random_values = []
        log_uniform_values = []
        random_counts = [0] * 9
        log_uniform_counts = [0] * 9
    
    plt.figure(figsize=(16, 8))
    
    # Create bar chart with observed and two types of random values
    x_pos = np.arange(len(digits))
    width = 0.25
    
    bars1 = plt.bar(x_pos - width, counts, width, color='orange', edgecolor='red', alpha=0.7, label='Observed Data')
    bars3 = plt.bar(x_pos, log_uniform_counts, width, color='lightgreen', edgecolor='darkgreen', alpha=0.7, label='Log10-Uniform Random')
    bars4 = plt.bar(x_pos + width, random_counts, width, color='lightcoral', edgecolor='darkred', alpha=0.7, label='Uniform Random')
    
    # Add Benford's Law expected as black dots
    dots = plt.scatter(x_pos, expected_counts, color='black', s=100, zorder=5, alpha=0.4, label='Benford\'s Law Expected')
    
    plt.xlabel('First Digit')
    plt.ylabel('Frequency')
    plt.title(title)
    plt.xticks(x_pos, digits)
    plt.grid(axis='y', alpha=0.3)
    plt.legend()
    
    # Add count and percentage labels on observed bars
    max_height = max(max(counts), max(expected_counts), max(random_counts), max(log_uniform_counts))
    for bar, count in zip(bars1, counts):
        if count > 0:
            percentage = (count / total_count) * 100
            plt.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.01 * max_height,
                    f'{count}\n({percentage:.1f}%)', ha='center', va='bottom', fontsize=6)
    
    # Add expected percentage labels below black dots
    for i, (exp_count, exp_percent) in enumerate(zip(expected_counts, benford_expected)):
        if exp_count > 0:
            plt.text(x_pos[i], exp_count - 0.03 * max_height,
                    f'{exp_count:.0f}\n({exp_percent:.1f}%)', ha='center', va='top', fontsize=6, color='black', 
                    bbox=dict(boxstyle='round,pad=0.2', facecolor='white', alpha=0.8))
    
    # Add random percentage labels on random bars
    random_total = sum(random_counts)
    for bar, random_count in zip(bars4, random_counts):
        if random_count > 0 and random_total > 0:
            percentage = (random_count / random_total) * 100
            plt.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.01 * max_height,
                    f'{random_count}\n({percentage:.1f}%)', ha='center', va='bottom', fontsize=6, color='darkred')
    
    # Add log-uniform percentage labels on log-uniform bars
    log_uniform_total = sum(log_uniform_counts)
    for bar, log_uniform_count in zip(bars3, log_uniform_counts):
        if log_uniform_count > 0 and log_uniform_total > 0:
            percentage = (log_uniform_count / log_uniform_total) * 100
            plt.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.01 * max_height,
                    f'{log_uniform_count}\n({percentage:.1f}%)', ha='center', va='bottom', fontsize=6, color='darkgreen')
    
    valid_digits = sum(counts)
    random_digits = sum(random_counts)
    log_uniform_digits = sum(log_uniform_counts)
    plt.text(0.98, 0.98, f'Total values: {total_values}\nValid digits: {valid_digits}\nRandom digits: {random_digits}\nLog10-uniform: {log_uniform_digits}', 
             transform=plt.gca().transAxes, verticalalignment='top', horizontalalignment='right',
             bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))
    
    plt.tight_layout()
    plt.savefig(output_file, dpi=300, bbox_inches='tight')
    print(f"Plot saved to: {output_file}")
    plt.close()
    
    # Create overlaying histogram for observed vs random values
    if numeric_values:
        hist_output_file = output_file.replace('.png', '_histogram.png')
        
        plt.figure(figsize=(12, 6))
        
        # Create histogram with both distributions
        plt.hist(numeric_values, bins=50, alpha=0.7, color='orange', edgecolor='red', 
                label=f'Observed Values (n={len(numeric_values)})', density=True)
        plt.hist(random_values, bins=50, alpha=0.7, color='lightcoral', edgecolor='darkred',
                label=f'Uniform Random (n={len(random_values)})', density=True)
        plt.hist(log_uniform_values, bins=50, alpha=0.7, color='lightgreen', edgecolor='darkgreen',
                label=f'Log10-Uniform Random (n={len(log_uniform_values)})', density=True)
        
        plt.xlabel('Value')
        plt.ylabel('Density')
        plt.title(f'Distribution Comparison: Observed vs Random Sampling\n{title}')
        plt.legend()
        plt.grid(axis='y', alpha=0.3)
        
        # Add statistics text box
        obs_mean = np.mean(numeric_values)
        obs_std = np.std(numeric_values)
        rand_mean = np.mean(random_values)
        rand_std = np.std(random_values)
        log_uniform_mean = np.mean(log_uniform_values)
        log_uniform_std = np.std(log_uniform_values)
        
        stats_text = f'Observed: μ={obs_mean:.2e}, σ={obs_std:.2e}\nUniform: μ={rand_mean:.2e}, σ={rand_std:.2e}\nLog10-Uniform: μ={log_uniform_mean:.2e}, σ={log_uniform_std:.2e}'
        plt.text(0.98, 0.98, stats_text, transform=plt.gca().transAxes, 
                verticalalignment='top', horizontalalignment='right',
                bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))
        
        plt.tight_layout()
        plt.savefig(hist_output_file, dpi=300, bbox_inches='tight')
        print(f"Histogram saved to: {hist_output_file}")
        plt.close()
        
        # Create log2-transformed histogram
        log_hist_output_file = output_file.replace('.png', '_log2_histogram.png')
        
        # Apply log2 transformation (adding small epsilon to avoid log(0))
        epsilon = 1e-10
        log_numeric_values = np.log2(np.array(numeric_values) + epsilon)
        log_random_values = np.log2(np.array(random_values) + epsilon)
        log_log_uniform_values = np.log2(np.array(log_uniform_values) + epsilon)
        
        plt.figure(figsize=(12, 6))
        
        # Create log2 histogram with all three distributions
        plt.hist(log_numeric_values, bins=50, alpha=0.7, color='orange', edgecolor='red', 
                label=f'Observed Log2 Values (n={len(log_numeric_values)})', density=True)
        plt.hist(log_random_values, bins=50, alpha=0.7, color='lightcoral', edgecolor='darkred',
                label=f'Uniform Random Log2 (n={len(log_random_values)})', density=True)
        plt.hist(log_log_uniform_values, bins=50, alpha=0.7, color='lightgreen', edgecolor='darkgreen',
                label=f'Log10-Uniform Random Log2 (n={len(log_log_uniform_values)})', density=True)
        
        plt.xlabel('Log2(Value)')
        plt.ylabel('Density')
        plt.title(f'Log2-Transformed Distribution Comparison\n{title}')
        plt.legend()
        plt.grid(axis='y', alpha=0.3)
        
        # Add log2 statistics text box
        log_obs_mean = np.mean(log_numeric_values)
        log_obs_std = np.std(log_numeric_values)
        log_rand_mean = np.mean(log_random_values)
        log_rand_std = np.std(log_random_values)
        log_log_uniform_mean = np.mean(log_log_uniform_values)
        log_log_uniform_std = np.std(log_log_uniform_values)
        
        log_stats_text = f'Observed Log2: μ={log_obs_mean:.2f}, σ={log_obs_std:.2f}\nUniform Log2: μ={log_rand_mean:.2f}, σ={log_rand_std:.2f}\nLog10-Uniform Log2: μ={log_log_uniform_mean:.2f}, σ={log_log_uniform_std:.2f}'
        plt.text(0.98, 0.98, log_stats_text, transform=plt.gca().transAxes, 
                verticalalignment='top', horizontalalignment='right',
                bbox=dict(boxstyle='round', facecolor='lightblue', alpha=0.8))
        
        plt.tight_layout()
        plt.savefig(log_hist_output_file, dpi=300, bbox_inches='tight')
        print(f"Log2 histogram saved to: {log_hist_output_file}")
        plt.close()

parser = argparse.ArgumentParser(description='Extract first digits from a column and create bar plot')
parser.add_argument('file_path', nargs='?', default="https://zenodo.org/records/14557756/files/proteinGroups.txt?download=1", 
                    help='Path to tab-separated text file or URL (default: Zenodo proteinGroups.txt)')
parser.add_argument('column_index', type=int, nargs='?', default=51, help='Column index to extract (1-based, default: 51)')
parser.add_argument('--no-header', action='store_true', help='File has no header row')
parser.add_argument('--output', '-o', help='Output file path for saving the plot')
parser.add_argument('--title', '-t', help='Title for the plot')

args = parser.parse_args()

# Handle the case where user wants to use default file with custom column
# Usage: python script.py 52 (means default file, column 52)
if args.file_path.isdigit() and len(sys.argv) == 2:
    args.column_index = int(args.file_path)
    args.file_path = "https://zenodo.org/records/14557756/files/proteinGroups.txt?download=1"

column_index_zero_based = args.column_index - 1
print(f"Reading file: {args.file_path}")
print(f"Extracting column index: {args.column_index} (1-based)")

has_header = not args.no_header
column_data, column_name = read_and_extract_column(args.file_path, column_index_zero_based, has_header)
#column_data, column_name = read_and_extract_column("Z:\\Download\\proteinGroups.txt", 50, )

if args.output:
    output_file = args.output
else:
    if args.file_path.startswith('http'):
        # For URL, use current directory with default filename
        if column_name:
            safe_column_name = re.sub(r'[^\w\-_\.]', '_', column_name)
            output_file = f"proteinGroups_column_{safe_column_name}_first_digit_distribution.png"
        else:
            output_file = f"proteinGroups_column_{args.column_index}_first_digit_distribution.png"
    else:
        # For local file, use same directory as input file
        file_dir = os.path.dirname(args.file_path)
        base_name = os.path.splitext(os.path.basename(args.file_path))[0]
        if column_name:
            safe_column_name = re.sub(r'[^\w\-_\.]', '_', column_name)
            output_file = os.path.join(file_dir, f"{base_name}_column_{safe_column_name}_first_digit_distribution.png")
        else:
            output_file = os.path.join(file_dir, f"{base_name}_column_{args.column_index}_first_digit_distribution.png")

if args.title:
    title = args.title
else:
    if column_name:
        title = f"First Digit Distribution - {column_name}"
    else:
        title = f"First Digit Distribution - Column {args.column_index}"

print(f"Extracted {len(column_data)} values from column {args.column_index}")
if column_name:
    print(f"Column name: {column_name}")

first_digits = []
for value in column_data:
    first_digit = extract_first_digit(value)
    if first_digit is not None:
        first_digits.append(first_digit)

print(f"Found {len(first_digits)} valid first digits")

if not first_digits:
    print("No valid first digits found in the data!")
    sys.exit(1)

# Generate uniform random data for comparison
numeric_values = []
for value in column_data:
    try:
        if pd.notna(value) and str(value).strip() != '':
            num_val = float(str(value))
            if num_val > 0:  # Only positive values for first digit analysis
                numeric_values.append(num_val)
    except (ValueError, TypeError):
        continue

random_first_digits = []
log_uniform_first_digits = []
if numeric_values:
    min_val = min(numeric_values)
    max_val = max(numeric_values)
    # Generate same number of random values as we have valid first digits
    np.random.seed(42)  # For reproducible results
    random_values = np.random.uniform(min_val, max_val, len(first_digits))
    
    # Generate log10-uniform random data (as per Benford's Law theory)
    log_min = np.log10(min_val)
    log_max = np.log10(max_val)
    log_uniform_values = 10 ** np.random.uniform(log_min, log_max, len(first_digits))
    
    # Extract first digits from both types of random values
    for val in random_values:
        first_digit = extract_first_digit(val)
        if first_digit is not None:
            random_first_digits.append(first_digit)
    
    for val in log_uniform_values:
        first_digit = extract_first_digit(val)
        if first_digit is not None:
            log_uniform_first_digits.append(first_digit)
else:
    random_values = []
    log_uniform_values = []

digit_counts = Counter(first_digits)
random_digit_counts = Counter(random_first_digits)
log_uniform_digit_counts = Counter(log_uniform_first_digits)
print("\nFirst digit distribution:")
print("Digit | Observed | Expected (Benford) | Log10-Uniform | Uniform Random")
print("------|----------|--------------------|--------------|--------------")
for digit in range(1, 10):
    count = digit_counts.get(digit, 0)
    random_count = random_digit_counts.get(digit, 0)
    log_uniform_count = log_uniform_digit_counts.get(digit, 0)
    observed_percent = (count / len(first_digits)) * 100 if first_digits else 0
    random_percent = (random_count / len(random_first_digits)) * 100 if random_first_digits else 0
    log_uniform_percent = (log_uniform_count / len(log_uniform_first_digits)) * 100 if log_uniform_first_digits else 0
    benford_percent = np.log10(1 + (1/digit)) * 100
    print(f"  {digit}   |   {count:3d}    |    {benford_percent:.1f}%         |   {log_uniform_count:3d}        |   {random_count:3d}")
    print(f"      | ({observed_percent:.1f}%)   |                    | ({log_uniform_percent:.1f}%)      | ({random_percent:.1f}%)")

create_barplot(first_digits, len(column_data), output_file, title, column_data)