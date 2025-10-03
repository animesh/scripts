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

def create_barplot(first_digits, total_values, output_file, title):
    digit_counts = Counter(first_digits)
    digits = list(range(1, 10))
    counts = [digit_counts.get(digit, 0) for digit in digits]
    
    # Calculate Benford's Law expected percentages
    benford_expected = [np.log10(1 + (1/digit)) * 100 for digit in digits]
    total_count = sum(counts)
    
    # Calculate expected counts based on Benford's Law
    expected_counts = [(percentage/100) * total_count for percentage in benford_expected]
    
    plt.figure(figsize=(12, 7))
    
    # Create bar chart with observed and expected values
    x_pos = np.arange(len(digits))
    width = 0.35
    
    bars1 = plt.bar(x_pos - width/2, counts, width, color='orange', edgecolor='red', alpha=0.7, label='Observed')
    bars2 = plt.bar(x_pos + width/2, expected_counts, width, color='skyblue', edgecolor='navy', alpha=0.7, label='Benford\'s Law Expected')
    
    plt.xlabel('First Digit')
    plt.ylabel('Frequency')
    plt.title(title)
    plt.xticks(x_pos, digits)
    plt.grid(axis='y', alpha=0.3)
    plt.legend()
    
    # Add count and percentage labels on observed bars
    for bar, count in zip(bars1, counts):
        if count > 0:
            percentage = (count / total_count) * 100
            plt.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.01 * max(max(counts), max(expected_counts)),
                    f'{count}\n({percentage:.1f}%)', ha='center', va='bottom', fontsize=8)
    
    # Add expected percentage labels on expected bars
    for bar, exp_count, exp_percent in zip(bars2, expected_counts, benford_expected):
        if exp_count > 0:
            plt.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.01 * max(max(counts), max(expected_counts)),
                    f'{exp_count:.0f}\n({exp_percent:.1f}%)', ha='center', va='bottom', fontsize=8, color='blue')
    
    valid_digits = sum(counts)
    plt.text(0.98, 0.98, f'Total values: {total_values}\nValid digits: {valid_digits}', 
             transform=plt.gca().transAxes, verticalalignment='top', horizontalalignment='right',
             bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))
    
    plt.tight_layout()
    plt.savefig(output_file, dpi=300, bbox_inches='tight')
    print(f"Plot saved to: {output_file}")
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

digit_counts = Counter(first_digits)
print("\nFirst digit distribution:")
print("Digit | Observed | Expected (Benford)")
print("------|----------|------------------")
for digit in range(1, 10):
    count = digit_counts.get(digit, 0)
    observed_percent = (count / len(first_digits)) * 100 if first_digits else 0
    benford_percent = np.log10(1 + (1/digit)) * 100
    print(f"  {digit}   |   {count:3d}    |    {benford_percent:.1f}%")
    print(f"      | ({observed_percent:.1f}%)   |")

create_barplot(first_digits, len(column_data), output_file, title)