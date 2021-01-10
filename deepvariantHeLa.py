#Comprehensive mapping of mutations to the SARS-CoV-2 receptor-binding domain that affect recognition by polyclonal human serum antibodies #https://www.biorxiv.org/content/10.1101/2020.12.31.425021v1.full.pdf
#download https://github.com/saketkc/pysradb
#!pip install -U pysradb
#!pysradb metadata SAMN17185313 #https://www.ncbi.nlm.nih.gov/biosample/?term=SAMN17185313
#!pysradb metadata PRJNA639956 #https://www.ncbi.nlm.nih.gov/bioproject/PRJNA639956
#!pysradb download -p PRJNA639956
#https://jbloomlab.github.io/dms_variants/installation.html
#!pip install dms_variants #failed; fix comment out "-Wno-error=declaration-after-statement" in "setup.py"
#!git clone https://github.com/animesh/dms_variants
#!python setup.py install
#eg: https://jbloomlab.github.io/dms_variants/codonvariant_sim_data.html
import collections
import itertools
import random
import tempfile
import time
import warnings
import pandas as pd
from plotnine import *
import scipy
#!pip install dmslogo
import dmslogo  # used for preference logo plots
import dms_variants.binarymap
import dms_variants.codonvarianttable
import dms_variants.globalepistasis
import dms_variants.plotnine_themes
import dms_variants.simulate
from dms_variants.constants import CBPALETTE, CODONS_NOSTOP
seed = 42  # random number seed
genelength = 30  # gene length in codons
libs = ['lib_1', 'lib_2']  # distinct libraries of gene
variants_per_lib = 500 * genelength  # variants per library
avgmuts = 2.0  # average codon mutations per variant
bclen = 16  # length of nucleotide barcode for each variant
variant_error_rate = 0.005  # rate at which variant sequence mis-called
avgdepth_per_variant = 200  # average per-variant sequencing depth
lib_uniformity = 5  # uniformity of library pre-selection
noise = 0.02  # random noise in selections
bottlenecks = {  # bottlenecks from pre- to post-selection
        'tight_bottle': variants_per_lib * 5,
        'loose_bottle': variants_per_lib * 100,
        }
random.seed(seed)
pd.set_option('display.max_columns', 20)
pd.set_option('display.width', 500)
warnings.simplefilter('ignore')
theme_set(dms_variants.plotnine_themes.theme_graygrid())
geneseq = ''.join(random.choices(CODONS_NOSTOP, k=genelength))
print(f"Wildtype gene of {genelength} codons:\n{geneseq}")
