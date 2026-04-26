#python3 genListPRM.py
import pandas as pd
import numpy as np
from openpyxl import Workbook
from openpyxl.styles import (Font, PatternFill, Alignment, Border, Side,
                              GradientFill)
from openpyxl.utils import get_column_letter
from openpyxl.formatting.rule import ColorScaleRule, DataBarRule
import warnings
warnings.filterwarnings("ignore")

# ── 1. LOAD DATA ──────────────────────────────────────────────────────────────
ISNS_FILE = "/home/animeshs/promec/promec/TIMSTOF/LARS/2025/250805_Kamila/DIANNv2p2/report rq.ha..gg_matrix.tsv4118ISNS0.10.50.1BioRemGroups.txt4LFQvsntTestBH.xlsx"
ITNT_FILE = "/home/animeshs/promec/promec/TIMSTOF/LARS/2025/250805_Kamila/DIANNv2p2/report rq.ha..gg_matrix.tsv4118ITNT0.10.50.1BioRemGroups.txt4LFQvsntTestBH.xlsx"
isns = pd.read_excel(ISNS_FILE)
itnt = pd.read_excel(ITNT_FILE)
OUTPUT = "/home/animeshs/promec/promec/TIMSTOF/LARS/2025/250805_Kamila/BCC_PRM_Panel_Recommendations.xlsx"

is_cols = [c for c in isns.columns if c.startswith("IS")]
ns_cols = [c for c in isns.columns if c.startswith("NS")]
it_cols = [c for c in itnt.columns if c.startswith("IT")]
nt_cols = [c for c in itnt.columns if c.startswith("NT")]

isns["n_IS"] = isns[is_cols].notna().sum(axis=1)
isns["n_NS"] = isns[ns_cols].notna().sum(axis=1)
itnt["n_IT"] = itnt[it_cols].notna().sum(axis=1)
itnt["n_NT"] = itnt[nt_cols].notna().sum(axis=1)

# ── 2. BIOLOGICAL CATEGORIES ─────────────────────────────────────────────────
# Category → (priority_weight, gene_list)
# Higher weight = kept preferentially when trimming
CATEGORIES = {
    "Type-2 Immunity": (10, [
        "POSTN","ARG1","MRC1","CCL17","CCL22","IL4","IL13","IL5","IL33","TSLP",
        "CXCL12","CLCA1","PDGFRA","IL4R","STAT6","GATA3","IL2RA",
        "CHI3L1","CHI3L2","CHIT1"
    ]),
    "Type-1 Immunity": (9, [
        "IFNG","CXCL10","CXCL9","CXCL11","STAT1","IRF1","IRF7","IFIT1","IFIT3",
        "GBP1","GBP2","MX1","PSMB8","TAP1","B2M","HLA-A","HLA-B","HLA-C",
        "CD8A","GZMB","PRF1","CXCR3"
    ]),
    "Type-3 / Inflammasome": (8, [
        "S100A8","S100A9","S100A12","S100A6","NLRP3","CASP1","IL1B","IL17A",
        "IL6","IL8","CXCL1","CXCL2","CXCL5","MMP8","MMP9","ELANE","MPO","LTF"
    ]),
    "TGFb / Immunosuppression": (10, [
        "TGFB1","TGFB2","TGFB3","LTBP1","LTBP2","TGFBI","SMAD2","SMAD3",
        "CXCL12","FOXP3","PDCD1","CD274","IDO1","HAVCR2","LAG3","TIGIT",
        "CD163","MRC1","ARG1"
    ]),
    "CAF Program": (10, [
        "FAP","ACTA2","PDGFRB","PDGFRA","PDPN","S100A4","VIM","THY1",
        "LRRC15","CXCL12","FGF2","HGF","IGFBP3","IGFBP5","IGFBP7",
        "COL11A1","COL10A1","MMP11","INHBA","SFRP2","SFRP4"
    ]),
    "ECM Remodeling": (9, [
        "COL1A1","COL1A2","COL3A1","COL4A1","COL4A2","COL5A1","COL5A2",
        "COL6A1","COL6A2","COL6A3","COL10A1","COL11A1","COL12A1","COL14A1",
        "FN1","VCAN","TNC","POSTN","THBS1","THBS2","THBS4",
        "MMP2","MMP14","MMP11","MMP1","MMP3","MMP10","MMP13",
        "LOXL1","LOXL2","LOXL3","LOX",
        "FBLN1","FBLN2","FBLN5","ELN","EMILIN1","EMILIN2",
        "LAMB1","LAMB2","LAMC1","HSPG2","BGN","DCN","LUM","ASPN"
    ]),
    "Hedgehog Signaling": (8, [
        "SHH","IHH","DHH","PTCH1","PTCH2","SMO","GLI1","GLI2","GLI3",
        "HHIP","BOC","GAS1","CDON","SUFU","KIF7","STK36"
    ]),
    "Angiogenesis / Vasculature": (7, [
        "VEGFA","VEGFB","VEGFC","VEGFD","KDR","FLT1","PECAM1","CDH5",
        "ANGPT1","ANGPT2","TIE2","THBS1","THBS2","COL18A1","ENDOCAN"
    ]),
    "Complement / Innate": (6, [
        "C1QA","C1QB","C1QC","C3","C4A","C4B","C5","CFB","CFH","CFI",
        "FCN1","FCN2","FCN3","MBL2","MASP1","MASP2","CRP","SAA1","SAA2"
    ]),
    "High-FC Infiltrative Biomarker": (7, [
        # From top differentials IS>NS and IT>NT
        "FAT2","CRACD","CLEC16A","CLK1","FAM76B","TARS3","SIPA1L3",
        "CHIT1","CDH5","TGM2","THBS4","FBLN2","FCN3",
        # CAF-specific high FC
        "FAP"
    ]),
    "High-FC Nodular Biomarker": (7, [
        # NS>IS or NT>IT
        "ALDH1A2","TAGLN3","TUBB8","ADSS1",
        "TYRP1","ART3","FAT4","LFNG","NAALAD2","EPHX3","RBP1","SERPINA12"
    ]),
    "Tumor Markers (BCC)": (6, [
        "KRT5","KRT14","KRT17","KRT6A","KRT6B","TP53","CDKN2A",
        "PTCH1","SHH","SMO","GLI1","GLI2",
        "MKI67","PCNA","CDK4","CDK6","CCND1"
    ]),
    "Lipid / Metabolic Reprogramming": (5, [
        "ALDH1A2","ALDH1A3","ALDH3A1","RBP1","FABP4","FABP5",
        "ACSL4","ACSL1","CPT1A","FASN","ACACA","SCD","HMGCR","LDLR",
        "SLC27A6","PLIN1","PLIN2","PLIN3"
    ]),
}

# ── 3. MERGE DATA ─────────────────────────────────────────────────────────────
def prep(df, grp1, grp2, n1_col, n2_col):
    n1_max = df[n1_col].max()
    n2_max = df[n2_col].max()
    
    # Evidence tier
    def tier(row):
        bh = row["CorrectedPValueBH"]
        fc = abs(row["Log2MedianChange"])
        n1 = row[n1_col]
        n2 = row[n2_col]
        if pd.isna(bh):
            # present/absent - quality depends on how many samples
            max_n = max(n1, n2)
            if max_n >= 3 and min(n1, n2) == 0:
                return "Present/Absent (n≥3)"
            elif max_n >= 2:
                return "Present/Absent (n=1-2)"
            else:
                return "Singleton"
        if bh < 0.05:
            return "BH<0.05"
        if bh < 0.2:
            return "BH<0.20"
        return "Trend"

    df["EvidenceTier"] = df.apply(tier, axis=1)
    
    # Direction
    df["Direction"] = df["Log2MedianChange"].apply(
        lambda x: f"{grp1}>" + grp2 if x > 0 else grp2 + f">{grp1}"
    )
    
    return df[["Gene","Peptides","Log2MedianChange","CorrectedPValueBH",
               "TtestPval",n1_col,n2_col,"EvidenceTier","Direction",
               "grp1CV","grp2CV"]].copy()

isns_p = prep(isns, "IS", "NS", "n_IS", "n_NS")
itnt_p = prep(itnt, "IT", "NT", "n_IT", "n_NT")

# Rename to unified schema
isns_p.columns = ["Gene","Peptides","FC_IS_NS","BH_IS_NS","Pval_IS_NS",
                   "n_IS","n_NS","EvidTier_IS_NS","Dir_IS_NS","CV_IS","CV_NS"]
itnt_p.columns = ["Gene","Peptides","FC_IT_NT","BH_IT_NT","Pval_IT_NT",
                   "n_IT","n_NT","EvidTier_IT_NT","Dir_IT_NT","CV_IT","CV_NT"]

merged = isns_p.merge(itnt_p, on="Gene", suffixes=("_s","_t"), how="outer")
# Use peptides from either source
merged["Peptides"] = merged["Peptides_s"].combine_first(merged["Peptides_t"])
merged = merged.drop(columns=["Peptides_s","Peptides_t"])

# ── 4. ASSIGN CATEGORIES ──────────────────────────────────────────────────────
def assign_categories(gene):
    cats = [cat for cat, (_, genes) in CATEGORIES.items() if gene in genes]
    return "; ".join(cats) if cats else "Unclassified"

def assign_priority(gene):
    weights = [w for cat, (w, genes) in CATEGORIES.items() if gene in genes]
    return max(weights) if weights else 3

merged["Category"] = merged["Gene"].apply(assign_categories)
merged["CategoryPriority"] = merged["Gene"].apply(assign_priority)

# ── 5. COMPOSITE SCORING FOR PRM PANEL ───────────────────────────────────────
TIER_SCORE = {
    "BH<0.05": 5,
    "BH<0.20": 4,
    "Present/Absent (n≥3)": 4,  # reliable group-level binary
    "Present/Absent (n=1-2)": 2,
    "Singleton": 0,
    "Trend": 1,
}

def evidence_score(row):
    s = 0
    for col in ["EvidTier_IS_NS","EvidTier_IT_NT"]:
        val = row.get(col)
        if pd.notna(val):
            s += TIER_SCORE.get(val, 0)
    return s

def fc_score(row):
    s = 0
    for col in ["FC_IS_NS","FC_IT_NT"]:
        fc = row.get(col)
        if pd.notna(fc):
            afc = abs(fc)
            if afc >= 3:   s += 3
            elif afc >= 1.5: s += 2
            elif afc >= 0.5: s += 1
    return s

def peptide_score(row):
    p = row.get("Peptides", 0)
    if pd.isna(p): return 0
    p = int(p)
    if p >= 10: return 4
    if p >= 5:  return 3
    if p >= 2:  return 2
    if p >= 1:  return 1
    return 0

def consistency_score(row):
    """Reward concordance between stroma and tumor comparisons."""
    fc1 = row.get("FC_IS_NS")
    fc2 = row.get("FC_IT_NT")
    if pd.isna(fc1) or pd.isna(fc2): return 0
    if (fc1 > 0.3 and fc2 > 0.3) or (fc1 < -0.3 and fc2 < -0.3):
        return 2  # same direction in both compartments
    return 0

merged["ScoreEvidence"] = merged.apply(evidence_score, axis=1)
merged["ScoreFC"]       = merged.apply(fc_score, axis=1)
merged["ScorePeptide"]  = merged.apply(peptide_score, axis=1)
merged["ScoreConsist"]  = merged.apply(consistency_score, axis=1)
merged["ScoreBio"]      = merged["CategoryPriority"]

merged["TotalScore"] = (merged["ScoreEvidence"] * 2
                        + merged["ScoreFC"] * 2
                        + merged["ScorePeptide"]
                        + merged["ScoreConsist"]
                        + merged["ScoreBio"])

# ── 6. BUILD CANDIDATE PANEL ──────────────────────────────────────────────────
# Inclusion criteria:
# A. BH significant in either comparison (BH<0.2)
# B. Group-level present/absent (n≥3) with |FC|>5 in either comparison
# C. In a biological category AND has some evidence (trend at minimum, ≥2 peptides)
# D. Explicitly listed in the hypothesis-driven seed list

SEED_FORCED = {
    # Core hypothesis proteins always included
    "POSTN","ARG1","TGFB1","CXCL12","CCL17","MRC1",
    "THBS1","TNC","MMP14","VCAN","COL10A1","COL11A1",
    "FAP","ACTA2","FN1","COL1A1","COL3A1",
    "S100A8","S100A9",
    "STAT1","CXCL10","CXCL9",
    "CD8A","CD163","FOXP3","GATA3",
    "GLI1","GLI2","PTCH1","SMO",
    "MMP2","MMP11","LOXL2",
    "FBLN2","THBS4","CDH5","TGM2",
    "ALDH1A2","RBP1",
}

def include(row):
    gene = row["Gene"]
    if gene in SEED_FORCED:
        return True
    # BH significant
    bh1 = row.get("BH_IS_NS")
    bh2 = row.get("BH_IT_NT")
    if (pd.notna(bh1) and bh1 < 0.2) or (pd.notna(bh2) and bh2 < 0.2):
        return True
    # Group-level present/absent with big FC
    t1 = row.get("EvidTier_IS_NS","")
    t2 = row.get("EvidTier_IT_NT","")
    fc1 = row.get("FC_IS_NS", 0) or 0
    fc2 = row.get("FC_IT_NT", 0) or 0
    if ("Present/Absent (n≥3)" in str(t1) and abs(fc1) > 5) or \
       ("Present/Absent (n≥3)" in str(t2) and abs(fc2) > 5):
        return True
    # In category + has reasonable peptides + some trend
    if row["Category"] != "Unclassified" and row["Peptides"] >= 2 and row["TotalScore"] >= 12:
        return True
    return False

candidates = merged[merged.apply(include, axis=1)].copy()
candidates = candidates.sort_values("TotalScore", ascending=False)
print(f"Candidate panel size: {len(candidates)}")

# ── 7. TRIMMING LOGIC ─────────────────────────────────────────────────────────
TARGET = 80

# Ensure minimum category coverage (at least 3 proteins per major category)
CATEGORY_MIN = {
    "Type-2 Immunity": 3,
    "Type-1 Immunity": 3,
    "Type-3 / Inflammasome": 2,
    "TGFb / Immunosuppression": 3,
    "CAF Program": 3,
    "ECM Remodeling": 4,
    "Hedgehog Signaling": 2,
    "High-FC Infiltrative Biomarker": 3,
    "High-FC Nodular Biomarker": 3,
    "Tumor Markers (BCC)": 2,
}

def get_cats(category_str):
    if pd.isna(category_str) or category_str == "Unclassified":
        return []
    return [c.strip() for c in category_str.split(";")]

# Greedy selection maintaining category minimums, then filling by score
selected = []
cat_count = {c: 0 for c in CATEGORY_MIN}

# Pass 1: SEED_FORCED proteins always in
for _, row in candidates.iterrows():
    if row["Gene"] in SEED_FORCED:
        selected.append(row["Gene"])
        for c in get_cats(row["Category"]):
            if c in cat_count:
                cat_count[c] += 1

# Pass 2: Fill category minimums
for _, row in candidates.iterrows():
    if row["Gene"] in selected:
        continue
    if len(selected) >= TARGET:
        break
    for c in get_cats(row["Category"]):
        if c in CATEGORY_MIN and cat_count.get(c, 0) < CATEGORY_MIN[c]:
            selected.append(row["Gene"])
            for cc in get_cats(row["Category"]):
                if cc in cat_count:
                    cat_count[cc] += 1
            break

# Pass 3: Fill to TARGET by score, excluding singletons and unclassified low-evidence
for _, row in candidates.iterrows():
    if row["Gene"] in selected:
        continue
    if len(selected) >= TARGET:
        break
    if row["EvidTier_IS_NS"] == "Singleton" and row["EvidTier_IT_NT"] == "Singleton":
        continue
    if row["Category"] == "Unclassified" and row["TotalScore"] < 15:
        continue
    selected.append(row["Gene"])

print(f"Final panel size: {len(selected)}")

# Annotate panel membership
candidates["PanelStatus"] = candidates["Gene"].apply(
    lambda g: "SELECTED" if g in selected else "TRIMMED"
)
candidates["TrimReason"] = candidates.apply(
    lambda row: (
        "" if row["PanelStatus"] == "SELECTED"
        else "Low evidence (singleton)" if (
            row["EvidTier_IS_NS"] == "Singleton" and
            row["EvidTier_IT_NT"] == "Singleton"
        )
        else "Unclassified + low score" if (
            row["Category"] == "Unclassified" and row["TotalScore"] < 15
        )
        else "Score below threshold for target panel size"
    ),
    axis=1,
)

# ── 8. WHAT TO REMOVE FROM A USER-SUPPLIED LIST ───────────────────────────────
# Simple rule-based suggestions
def removal_reason(row):
    reasons = []
    peps = row["Peptides"]
    if pd.isna(peps) or peps < 2:
        reasons.append("≤1 unique peptide (PRM unreliable)")
    # Redundancy: same pathway, lower score
    fc_s = row["ScoreFC"]
    ev_s = row["ScoreEvidence"]
    if ev_s == 0:
        reasons.append("No statistical evidence in either comparison")
    if pd.isna(row["FC_IS_NS"]) and pd.isna(row["FC_IT_NT"]):
        reasons.append("Not quantified in either dataset")
    if row["EvidTier_IS_NS"] == "Singleton" and pd.isna(row.get("EvidTier_IT_NT")):
        reasons.append("Singleton detection only")
    return "; ".join(reasons) if reasons else "Consider removing: lower priority given panel size"

candidates["RemovalSuggestion"] = candidates.apply(
    lambda row: removal_reason(row) if row["PanelStatus"] == "TRIMMED" else "Keep", axis=1
)

# ── 9. EXPORT TO EXCEL ────────────────────────────────────────────────────────

panel_cols = [
    "Gene","Peptides","Category","CategoryPriority",
    "FC_IS_NS","BH_IS_NS","EvidTier_IS_NS","Dir_IS_NS","n_IS","n_NS",
    "FC_IT_NT","BH_IT_NT","EvidTier_IT_NT","Dir_IT_NT","n_IT","n_NT",
    "ScoreEvidence","ScoreFC","ScorePeptide","ScoreConsist","ScoreBio","TotalScore",
    "PanelStatus","TrimReason","RemovalSuggestion"
]

selected_df  = candidates[candidates["PanelStatus"]=="SELECTED"][panel_cols].sort_values("TotalScore",ascending=False)
trimmed_df   = candidates[candidates["PanelStatus"]=="TRIMMED"][panel_cols].sort_values("TotalScore",ascending=False)

# Category summary
cat_summary = []
for cat, (pri, genes) in CATEGORIES.items():
    in_selected = [g for g in genes if g in selected]
    in_cands = [g for g in genes if g in candidates["Gene"].values]
    cat_summary.append({
        "Category": cat,
        "Priority": pri,
        "Genes_In_Selected_Panel": "; ".join(in_selected),
        "N_Selected": len(in_selected),
        "N_Candidates": len(in_cands),
        "All_Category_Genes": "; ".join(genes),
    })
cat_df = pd.DataFrame(cat_summary).sort_values("Priority", ascending=False)

wb = Workbook()

# ─ Colors ─
HDR_FILL   = PatternFill("solid", fgColor="1F3864")
SEL_FILL   = PatternFill("solid", fgColor="E2EFDA")
TRIM_FILL  = PatternFill("solid", fgColor="FCE4D6")
TIER_FILLS = {
    "BH<0.05":               PatternFill("solid", fgColor="375623"),
    "BH<0.20":               PatternFill("solid", fgColor="70AD47"),
    "Present/Absent (n≥3)":  PatternFill("solid", fgColor="4472C4"),
    "Present/Absent (n=1-2)":PatternFill("solid", fgColor="9DC3E6"),
    "Trend":                 PatternFill("solid", fgColor="FFD966"),
    "Singleton":             PatternFill("solid", fgColor="FF0000"),
}
TIER_FONTS = {
    "BH<0.05":               Font(color="FFFFFF", bold=True),
    "BH<0.20":               Font(color="FFFFFF"),
    "Present/Absent (n≥3)":  Font(color="FFFFFF", bold=True),
    "Present/Absent (n=1-2)":Font(color="000000"),
    "Trend":                 Font(color="000000"),
    "Singleton":             Font(color="FFFFFF", bold=True),
}

thin = Side(style="thin", color="BFBFBF")
border = Border(left=thin, right=thin, top=thin, bottom=thin)

def write_sheet(ws, df, title, fill_rows=True):
    ws.title = title
    headers = list(df.columns)
    for ci, h in enumerate(headers, 1):
        cell = ws.cell(row=1, column=ci, value=h)
        cell.font = Font(color="FFFFFF", bold=True, size=10)
        cell.fill = HDR_FILL
        cell.alignment = Alignment(horizontal="center", wrap_text=True)
        cell.border = border

    tier_cols_is = [headers.index(c)+1 for c in ["EvidTier_IS_NS"] if c in headers]
    tier_cols_it = [headers.index(c)+1 for c in ["EvidTier_IT_NT"] if c in headers]
    status_col   = headers.index("PanelStatus")+1 if "PanelStatus" in headers else None
    gene_col     = headers.index("Gene")+1

    for ri, (_, row) in enumerate(df.iterrows(), 2):
        row_fill = None
        if fill_rows and status_col:
            status = row.get("PanelStatus","")
            row_fill = SEL_FILL if status == "SELECTED" else TRIM_FILL

        for ci, h in enumerate(headers, 1):
            val = row[h]
            if pd.isna(val): val = ""
            if isinstance(val, float) and val == val:
                val = round(val, 4)
            cell = ws.cell(row=ri, column=ci, value=val)
            cell.border = border
            cell.alignment = Alignment(wrap_text=False, vertical="center")

            if ci == gene_col:
                cell.font = Font(bold=True, size=10)
            else:
                cell.font = Font(size=9)

            if ci in tier_cols_is or ci in tier_cols_it:
                tier_val = str(val)
                if tier_val in TIER_FILLS:
                    cell.fill = TIER_FILLS[tier_val]
                    cell.font = TIER_FONTS[tier_val]
                elif row_fill:
                    cell.fill = row_fill
            elif row_fill:
                cell.fill = row_fill

    # Column widths
    col_widths = {
        "Gene": 14, "Peptides": 9, "Category": 40, "CategoryPriority": 10,
        "FC_IS_NS": 11, "BH_IS_NS": 11, "EvidTier_IS_NS": 22, "Dir_IS_NS": 10,
        "FC_IT_NT": 11, "BH_IT_NT": 11, "EvidTier_IT_NT": 22, "Dir_IT_NT": 10,
        "n_IS": 6,"n_NS": 6,"n_IT": 6,"n_NT": 6,
        "ScoreEvidence": 10,"ScoreFC": 8,"ScorePeptide": 10,
        "ScoreConsist": 10,"ScoreBio": 8,"TotalScore": 10,
        "PanelStatus": 12,"TrimReason": 40,"RemovalSuggestion": 50,
    }
    for ci, h in enumerate(headers, 1):
        ws.column_dimensions[get_column_letter(ci)].width = col_widths.get(h, 12)

    ws.freeze_panes = "B2"
    ws.auto_filter.ref = f"A1:{get_column_letter(len(headers))}{len(df)+1}"
    ws.row_dimensions[1].height = 40

    # Conditional color scale on TotalScore column
    if "TotalScore" in headers:
        ts_col = get_column_letter(headers.index("TotalScore")+1)
        ws.conditional_formatting.add(
            f"{ts_col}2:{ts_col}{len(df)+1}",
            ColorScaleRule(
                start_type="min", start_color="FFFFFF",
                mid_type="percentile", mid_value=50, mid_color="FFEB84",
                end_type="max", end_color="63BE7B"
            )
        )

# Sheet 1: Selected panel
ws1 = wb.active
write_sheet(ws1, selected_df, "SELECTED Panel (≤80)")

# Sheet 2: Trimmed
ws2 = wb.create_sheet("TRIMMED - Consider Removing")
write_sheet(ws2, trimmed_df, "TRIMMED - Consider Removing")

# Sheet 3: Category coverage
ws3 = wb.create_sheet("Category Coverage")
ws3.title = "Category Coverage"
for ci, h in enumerate(cat_df.columns, 1):
    cell = ws3.cell(row=1, column=ci, value=h)
    cell.font = Font(color="FFFFFF", bold=True); cell.fill = HDR_FILL
    cell.alignment = Alignment(horizontal="center", wrap_text=True)
for ri, (_, row) in enumerate(cat_df.iterrows(), 2):
    for ci, h in enumerate(cat_df.columns, 1):
        val = row[h]
        if pd.isna(val): val = ""
        ws3.cell(row=ri, column=ci, value=val).border = border
ws3.column_dimensions["A"].width = 30
ws3.column_dimensions["C"].width = 60
ws3.column_dimensions["F"].width = 80
ws3.column_dimensions["D"].width = 12
ws3.column_dimensions["E"].width = 14
ws3.row_dimensions[1].height = 35

# Sheet 4: Scoring legend
ws4 = wb.create_sheet("Legend & Methods")
legend = [
    ["BCC PRM Panel Design - Methods & Scoring"],
    [],
    ["EVIDENCE TIER (ScoreEvidence per comparison)"],
    ["BH<0.05",               "5 pts", "Significant after FDR correction"],
    ["BH<0.20",               "4 pts", "Borderline significant (≤20% FDR)"],
    ["Present/Absent (n≥3)",  "4 pts", "Detected in ≥3 samples in one group, 0 in other = reliable binary biomarker"],
    ["Present/Absent (n=1-2)","2 pts", "Detected in 1-2 samples only - treat with caution for PRM"],
    ["Trend",                 "1 pt",  "BH≥0.2 but nominally tested"],
    ["Singleton",             "0 pts", "Detected in 1 sample total - do not include in PRM"],
    [],
    ["FOLD CHANGE SCORE (per comparison, additive)"],
    ["|log2FC| ≥ 3",  "3 pts"],
    ["|log2FC| ≥ 1.5","2 pts"],
    ["|log2FC| ≥ 0.5","1 pt"],
    [],
    ["PEPTIDE SCORE (PRM reliability proxy)"],
    ["≥10 unique peptides","4 pts","Multiple SRM transitions possible"],
    ["≥5",                 "3 pts"],
    ["≥2",                 "2 pts","Minimum for valid PRM confirmation"],
    ["1",                  "1 pt", "Single peptide - confirmatory only"],
    ["0",                  "0 pts","No peptide-level data - high risk"],
    [],
    ["CONSISTENCY SCORE"],
    ["Same direction in BOTH stroma AND tumor comparisons","2 pts","Most robust biological signal"],
    [],
    ["BIOLOGICAL PRIORITY (CategoryPriority)"],
    ["10","Highest (TGFb, CAF, Type-2 core)"],
    ["9", "High (Type-1, ECM)"],
    ["8", "Medium-high (Type-3, Hedgehog)"],
    ["7", "Medium (Biomarker candidates)"],
    ["6 and below","Lower"],
    [],
    ["TOTAL SCORE = 2×ScoreEvidence + 2×ScoreFC + ScorePeptide + ScoreConsist + ScoreBio"],
    [],
    ["TRIMMING STRATEGY"],
    ["1. All SEED_FORCED proteins always included (core hypothesis)"],
    ["2. Category minimum coverage enforced (≥2-4 per major pathway)"],
    ["3. Remaining slots filled by descending TotalScore"],
    ["4. Singletons excluded"],
    ["5. Unclassified proteins with TotalScore < 15 excluded"],
    [],
    ["KEY ASSUMPTIONS TO VALIDATE"],
    ["A. NaN BH for seed proteins (CXCL10, FAP, CD8A) = detected in very few samples → fragile; confirm by IHC first"],
    ["B. POSTN, ARG1, COL10A1 trend upward in I but do NOT reach BH<0.2 → power issue (n=9 per group)"],
    ["C. Peptide count = proxy for PRM suitability; actual transition selection requires in silico digestion"],
    ["D. Stroma and tumor comparisons are on DIFFERENT sample pairs - concordance strengthens but is not proof"],
    ["E. Type-3/inflammasome markers (S100A8/9) show NO directional bias here - check if this matches IHC"],
    ["F. GLI2 present in all samples IT and NT with BH=0.34 and FC=-0.58 - Hedgehog not strongly differential at protein level"],
]
for ri, row_data in enumerate(legend, 1):
    for ci, val in enumerate(row_data, 1):
        cell = ws4.cell(row=ri, column=ci, value=val)
        if ri == 1:
            cell.font = Font(bold=True, size=13, color="1F3864")
        elif row_data and row_data[0] in ["EVIDENCE TIER (ScoreEvidence per comparison)",
                                           "FOLD CHANGE SCORE (per comparison, additive)",
                                           "PEPTIDE SCORE (PRM reliability proxy)",
                                           "CONSISTENCY SCORE","BIOLOGICAL PRIORITY (CategoryPriority)",
                                           "TRIMMING STRATEGY","KEY ASSUMPTIONS TO VALIDATE",
                                           "TOTAL SCORE = 2×ScoreEvidence + 2×ScoreFC + ScorePeptide + ScoreConsist + ScoreBio"]:
            cell.font = Font(bold=True, size=10, color="1F3864")
            if ci == 1:
                cell.fill = PatternFill("solid", fgColor="D9E1F2")
        else:
            cell.font = Font(size=9)
ws4.column_dimensions["A"].width = 55
ws4.column_dimensions["B"].width = 15
ws4.column_dimensions["C"].width = 70

wb.save(OUTPUT)
print(f"\nSaved to {OUTPUT}")
print(f"Selected panel: {len(selected_df)} proteins")
print(f"Trimmed: {len(trimmed_df)} proteins")
print("\nCategory coverage in selected panel:")
for _, row in cat_df.iterrows():
    if row["N_Selected"] > 0:
        print(f"  {row['Category']}: {row['N_Selected']} proteins")

print("\nTop 20 selected proteins by score:")
print(selected_df[["Gene","Category","TotalScore","EvidTier_IS_NS","EvidTier_IT_NT",
                    "FC_IS_NS","FC_IT_NT","Peptides"]].head(20).to_string(index=False))
