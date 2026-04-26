#python3 genListPRM.py

import pandas as pd
import numpy as np
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.utils import get_column_letter
import warnings; warnings.filterwarnings("ignore")

# ── LOAD ORIGINAL PANEL ───────────────────────────────────────────────────────
orig = pd.read_excel('/home/animeshs/promec/promec/TIMSTOF/LARS/2025/250805_Kamila/DIANNv2p2/BCC_PRM90_final_format.xlsx')
OUTPUT = "/home/animeshs/promec/promec/TIMSTOF/LARS/2025/250805_Kamila/BCC_PRM_Final_90.xlsx"


# ── REMOVALS with reasons ──────────────────────────────────────────────────────
REMOVE = {
    # --- Phosphosites not in discovery data (DIA-NN infini-search) ---
    "STAT1_pY701":  ("Phospho", "Not detected in phospho discovery data; STAT1 protein already on panel; remove redundant undetected phosphosite"),
    "STAT2_pY690":  ("Phospho", "Not detected in phospho discovery data; STAT2 protein already on panel"),
    "STAT3_pY705":  ("Phospho", "Not detected in phospho discovery data; STAT3 protein already on panel"),
    "STAT5_pY694":  ("Phospho", "Not detected in phospho discovery data; no STAT5 protein on panel either; very low detectability in FFPE"),
    "STAT6_pY641":  ("Phospho", "Not detected in phospho discovery data; STAT6 protein already on panel"),
    # --- Proteins with no signal in either LFQ comparison ---
    "MMP9":   ("ECM", "Tumor FC=0.84 BH=0.99, Stroma FC=0.77 BH=0.91 — no signal in either compartment; MMP9 is neutrophil/macrophage-derived, not CAF-specific in BCC"),
    "ITGB1":  ("ECM", "Tumor FC=0.89 BH=0.69, Stroma FC=0.85 BH=0.88 — no differential; integrin β1 is ubiquitous and provides no BCC-specific information"),
    "CDH1":   ("Tumor", "Tumor FC=0.94 BH=0.94 — no signal; BCC are basaloid and do not prominently express E-cadherin; poor marker choice for this biology"),
    "EPCAM":  ("Tumor", "Tumor FC=1.11 BH=0.91 — no signal; EpCAM is not differential between infiltrative and nodular BCC"),
    "NFKB1":  ("Hedgehog", "Tumor FC=1.04 BH=1.00, Stroma FC=1.09 BH=0.89 — essentially zero differential in both compartments; CHUK (IKKα) is the more relevant partner already showing BH=0.039 in stroma"),
    "JAK1":   ("Type1", "Tumor FC=1.01 BH=0.77 — no change; replace with FOXP3 which has direct BCC TME literature evidence for Treg enrichment"),
    "CXCL14": ("ECM", "Tumor FC=0.77 BH=0.91, Stroma FC=1.07 BH=0.95 — no differential; CXCL14 is poorly characterized in BCC context"),
    "PDGFRB": ("ECM", "Tumor FC=0.88 BH=0.93, Stroma FC=0.87 BH=0.84 — no differential; replace with INHBA which has direct published evidence in BCC invasive niche"),
}

# ── ADDITIONS with full reasoning ─────────────────────────────────────────────
# Format: Gene → (Process, New_biology_process, Tumor_peps, Tumor_FC, Tumor_padj, Stroma_peps, Stroma_FC, Stroma_padj, reason)
ADD = {
    # ★ HIGHEST PRIORITY — directly evidenced in BCC literature
    "INHBA": ("ECM", "Core_CAF_invasive_matrix",
              11, 1.81, 0.18, 11, 2.24, 0.09,
              "★ TOP ADDITION. Encodes Activin A. Nat Commun 2022 (BCC multi-omics): INHBA is the highest pseudotime-correlated gene in highly infiltrative BCC tumor clusters, outranking TGFB1. Clin Cancer Res 2023 (BCC cemiplimab resistance): Activin A-mediated CAF and macrophage polarization is the key mechanism of CD8 T-cell exclusion in immunosuppressive BCC niches. IPA: INHBA is in the CAF program category with 11 peptides and upward trend in both IS stroma (FC=2.24) and IT tumor (FC=1.81). Directly connects CAF activation → Treg recruitment → immunotherapy resistance."),

    "SPP1":  ("Type2", "Type2_regulatory_immune_shaping",
              7, 1.93, 0.22, 6, 1.41, 0.54,
              "SPP1 (Osteopontin). scRNA iBCC 2023 (ScienceDirect): SPP1+CXCL9/10high macrophages specifically identified in iBCC, mediating BAFF signaling with plasma cells and linked to proinflammatory/angiogenic functions. SPP1 is also a canonical M2 macrophage marker and a TGFB1 downstream target. 7 peptides in tumor LFQ data. Important for macrophage subtype contexture in infiltrative BCC."),

    "MDK":   ("Tumor", "Tumor_compartment_control",
              5, 2.67, 0.08, 4, 1.58, 0.45,
              "Midkine (MDK). scRNA iBCC 2023 (ScienceDirect): MDK signals derived from malignant basal cells are markedly increased in iBCC, and MDK expression was identified as an independent factor predicting infiltration depth. 5 peptides tumor, trending higher in IT (FC=2.67, BH=0.08 — borderline). Strong external validation for iBCC-specific aggressiveness."),

    "FOXP3": ("Type2", "Type2_regulatory_immune_shaping",
              np.nan, np.nan, np.nan, np.nan, np.nan, np.nan,
              "Canonical Treg master transcription factor. BCC TME review (Ann Dermatol 2023): Tregs constitute ~45% of CD4+ cells in the BCC TME (vs ~8-20% in normal skin), the highest ratio of any skin cancer. FOXP3 is the definitive Treg marker, and the immunosuppressive axis CXCL12→Treg recruitment→CD8 T-cell exclusion is central to the hypothesis. Not detected in discovery LFQ (low abundance expected), but essential hypothesis-driven PRM target. Include with note: targeted PRM assay design required."),

    "LAIR1": ("Type2", "Type2_regulatory_immune_shaping",
              3, 1.49, 0.38, 2, 1.22, 0.63,
              "Leukocyte-associated Ig-like receptor 1. Clin Cancer Res 2023 BCC paper: LAIR1 RNA FISH co-localised with CD163 and INHBA in the immunosuppressive peritumoral BCC niche. LAIR1 is a collagen-binding inhibitory receptor expressed on NK cells, macrophages, and T cells that suppresses cytotoxic activity when engaged by collagen-rich ECM. Directly connects the ECM remodeling story (high collagen) to immune suppression. 3 peptides in tumor LFQ."),

    "CXCL13": ("Type1", "Type1_IFN_constrained_antitumor",
               np.nan, np.nan, np.nan, np.nan, np.nan, np.nan,
               "B-cell attracting chemokine. scRNA iBCC 2023: T follicular helper-like cells highly expressing CXCL13 specifically identified in iBCC. Also present in IPA ISNS upstream regulator analysis as a downstream target of TGFB1 and LPS. CXCL13 marks tertiary lymphoid structures (TLS) which can predict immunotherapy response in solid tumors. Not detected in discovery LFQ (low cytokine abundance), but hypothesis-driven. Important for immune contexture characterisation."),

    "KRT14": ("Tumor", "Tumor_compartment_control",
              31, 0.58, 0.06, 29, 0.71, 0.84,
              "KRT14 is a basal keratinocyte marker and the canonical counterpart to KRT5 in BCC identity. IPA ITNT: Keratinization pathway is significantly INHIBITED in IT vs NT (z=-2.12), with KRT14 as a named pathway molecule. Tumor BH=0.06 (approaching significance), FC=0.58 (lower in IT). 31 peptides. KRT14 and KRT5 together define the nodular BCC identity — their combined downregulation in infiltrative BCC is a robust finding supported by IPA, LFQ trends, and phospho data (KRT5 phosphosites also lower in IS stroma)."),

    "LOXL2": ("ECM", "Core_CAF_invasive_matrix",
              8, 1.42, 0.43, 7, 1.89, 0.29,
              "Lysyl oxidase-like 2. LOX (the related family member) is already on the panel, but LOXL2 is more specific to activated CAFs and more potently upregulated by TGFβ in desmoplastic stroma. Multiple studies link LOXL2 to CAF-mediated ECM stiffening and invasion. 8 peptides in tumor LFQ, FC trend upward in both compartments. Replaces PDGFRB which showed no signal."),

    "SERPINE2": ("ECM", "Core_CAF_invasive_matrix",
                 8, 1.63, 0.24, 8, 2.11, 0.18,
                 "PAI-2 / Protease Nexin 1. TGFB1 target gene confirmed in IPA ISNS upstream regulator analysis (SERPINE2 listed as TGFB1 downstream target). 8 peptides, FC upward trend in IS stroma (FC=2.11, BH=0.18) — approaches significance. Serine protease inhibitor that shapes the pericellular proteolytic environment in CAF-rich stroma. Complement to POSTN/CCN2 in the fibrotic niche story."),

    "CCN2":  ("ECM", "Core_CAF_invasive_matrix",
              5, 1.71, 0.35, 5, 2.08, 0.22,
              "CCN2 (Connective Tissue Growth Factor, CTGF). The canonical downstream effector of TGFB1 in fibrotic tissue. Confirmed in IPA ISNS upstream regulator analysis as a TGFB1 target. 5 peptides in both compartments with upward trend. CCN2 coordinates matrix production, angiogenesis, and CAF maintenance; it is routinely co-expressed with POSTN and periostin in desmoplastic tumors. TGFB1 → CCN2 → POSTN axis captures the full fibrotic programme."),

    "WNT5A": ("Hedgehog", "Hedgehog_NFkB_BCC_bridge",
              3, 1.58, 0.47, 3, 1.93, 0.41,
              "Non-canonical WNT ligand. Confirmed in IPA ISNS as a TGFB1 and TP63 target gene. Non-canonical WNT5A signalling is known to crosstalk with Hedgehog/GLI in BCC and to promote invasion and EMT. Connects the Hedgehog pathway (GLI1, PTCH1 already on list) with TGFβ-CAF biology. 3 peptides only — include with awareness of borderline detectability."),

    "SFRP1": ("Hedgehog", "Hedgehog_NFkB_BCC_bridge",
              4, 1.34, 0.61, 4, 1.55, 0.52,
              "Secreted Frizzled-Related Protein 1. scRNA BCC 2023 Nat Commun: SFRP1 marks the EMT-associated malignant basal subtype 2 (TNC+SFRP1+CHGA+) specifically enriched in highly invasive BCC clusters. SFRP1 is a WNT inhibitor secreted by CAFs that paradoxically promotes invasion through modifying WNT signaling balance. SFRP2 is already in our category list; SFRP1 adds the specific invasive BCC cell-intrinsic angle."),

    "COL4A1": ("ECM", "Core_CAF_invasive_matrix",
               14, 1.87, 0.28, 14, 2.31, 0.19,
               "Type IV collagen, alpha 1. Basement membrane component. Confirmed in IPA ISNS Collagen Degradation pathway (p=2.08e-7) molecule list. 14 peptides in both compartments, upward trend. Basement membrane remodeling (COL4 breakdown) is mechanistically upstream of tumor invasion. Complements COL1A1, COL10A1, COL11A1 with basement membrane specificity."),

    "PTPN23_pS1283": ("Phospho", "Inflammation_activation_phospho",
                      np.nan, np.nan, np.nan, np.nan, np.nan, np.nan,
                      "IS stroma-specific phosphosite. Detected in 2/9 IS samples, 0/10 NS, 0 IT, 0 NT. PTPN23 is a ubiquitin-binding tyrosine phosphatase controlling endosomal trafficking and EGFR recycling — its phosphorylation in IS stroma is sparse but IS-exclusive. Include with caution, mark as exploratory."),
}

# ── ASSEMBLE FINAL PANEL ──────────────────────────────────────────────────────
REMOVED_GENES = set(REMOVE.keys())
ADDED_GENES   = set(ADD.keys())

final_keep = orig[~orig['Gene'].isin(REMOVED_GENES)].copy()
final_keep['Change']  = 'KEEP'
final_keep['ChangeReason'] = ''

# Add new rows
new_rows = []
for gene, vals in ADD.items():
    if gene in orig['Gene'].values:
        continue  # already present (safety check)
    process, nbp, tp, tfc, tpadj, sp, sfc, spadj, reason = vals
    new_rows.append({
        'Gene': gene, 'Process': process, 'New_biology_process': nbp,
        'Tumor_peptides': tp, 'Tumor_FC': tfc, 'Tumor_padj': tpadj,
        'Stroma_peptides': sp, 'Stroma_FC': sfc, 'Stroma_padj': spadj,
        'Change': 'ADD', 'ChangeReason': reason
    })

new_df = pd.DataFrame(new_rows)
final = pd.concat([final_keep, new_df], ignore_index=True)

# Mark PTPN23 as already present if it was kept
if 'PTPN23_pS1283' not in ADD:
    pass

# Sort: phospho first, then by process, gene
def sort_key(row):
    order = {'Phospho':0,'Biomarker':1,'ECM':2,'Hedgehog':3,'Metabolism':4,
             'Tumor':5,'Type1':6,'Type2':7,'Type3':8}
    return (order.get(row['Process'], 9), row['Gene'])

final = final.sort_values(by=['Process','Gene']).reset_index(drop=True)

print(f"Original:  {len(orig)} entries")
print(f"Removed:   {len(REMOVE)} entries")
print(f"Added:     {len(ADD)} entries (incl. PTPN23_pS1283 already present)")
print(f"Final:     {len(final)} entries")
print(f"\nREMOVED:")
for g, (proc, r) in REMOVE.items():
    print(f"  REMOVE {g} [{proc}]: {r[:80]}")
print(f"\nADDED:")
for g in ADD:
    print(f"  ADD    {g}")

# ── CHANGE SUMMARY TABLE ──────────────────────────────────────────────────────
changes = []
for g, (proc, r) in REMOVE.items():
    changes.append({'Gene':g, 'Process':proc, 'Action':'REMOVE', 'Reason': r})
for g, vals in ADD.items():
    changes.append({'Gene':g, 'Process':vals[0], 'Action':'ADD', 'Reason': vals[8]})
change_df = pd.DataFrame(changes)

# ── EXCEL OUTPUT ──────────────────────────────────────────────────────────────
wb = Workbook()

# ─── Colors ───
HDR   = PatternFill("solid", fgColor="1F3864")
ADD_F = PatternFill("solid", fgColor="E2EFDA")   # green = add
REM_F = PatternFill("solid", fgColor="FCE4D6")   # red = remove
KEP_F = PatternFill("solid", fgColor="FFFFFF")   # white = keep
PHO_F = PatternFill("solid", fgColor="EBF3FB")   # light blue = phospho
thin  = Side(style="thin", color="D0D0D0")
bdr   = Border(left=thin, right=thin, top=thin, bottom=thin)

PTYPE_FILLS = {
    'Phospho':    PatternFill("solid", fgColor="EBF3FB"),
    'Biomarker':  PatternFill("solid", fgColor="FFF2CC"),
    'ECM':        PatternFill("solid", fgColor="E2EFDA"),
    'Hedgehog':   PatternFill("solid", fgColor="FCE4D6"),
    'Metabolism': PatternFill("solid", fgColor="F4ECFF"),
    'Tumor':      PatternFill("solid", fgColor="FFF2CC"),
    'Type1':      PatternFill("solid", fgColor="DDEBF7"),
    'Type2':      PatternFill("solid", fgColor="FCE4D6"),
    'Type3':      PatternFill("solid", fgColor="EDEDED"),
}

def hdr_cell(ws, row, col, val):
    c = ws.cell(row=row, column=col, value=val)
    c.font = Font(color="FFFFFF", bold=True, size=10)
    c.fill = HDR
    c.alignment = Alignment(horizontal="center", wrap_text=True)
    c.border = bdr
    return c

def data_cell(ws, row, col, val, fill=None, bold=False, size=9, align="left"):
    if pd.isna(val): val = ""
    if isinstance(val, float) and val == val: val = round(val, 4)
    c = ws.cell(row=row, column=col, value=val)
    c.font = Font(bold=bold, size=size)
    c.fill = fill or KEP_F
    c.alignment = Alignment(horizontal=align, wrap_text=(align=="left"))
    c.border = bdr
    return c

# ═══ SHEET 1: FINAL PANEL ════════════════════════════════════════════════════
ws1 = wb.active
ws1.title = "FINAL Panel (90)"

COLS = ['Gene','Process','New_biology_process',
        'Tumor_peptides','Tumor_FC','Tumor_padj',
        'Stroma_peptides','Stroma_FC','Stroma_padj',
        'Change','ChangeReason']
WIDTHS = [20, 12, 35, 12, 10, 10, 14, 10, 10, 8, 70]

for ci, h in enumerate(COLS, 1):
    hdr_cell(ws1, 1, ci, h)
    ws1.column_dimensions[get_column_letter(ci)].width = WIDTHS[ci-1]
ws1.row_dimensions[1].height = 36

for ri, (_, row) in enumerate(final.iterrows(), 2):
    chg = row.get('Change','KEEP')
    proc = str(row.get('Process',''))
    base_fill = ADD_F if chg=='ADD' else (REM_F if chg=='REMOVE' else PTYPE_FILLS.get(proc, KEP_F))

    for ci, col in enumerate(COLS, 1):
        val = row.get(col, "")
        is_gene = (ci == 1)
        data_cell(ws1, ri, ci, val, fill=base_fill, bold=is_gene, size=9,
                  align="center" if ci in [4,5,6,7,8,9,10] else "left")

ws1.freeze_panes = "B2"
ws1.auto_filter.ref = f"A1:{get_column_letter(len(COLS))}{len(final)+1}"

# ═══ SHEET 2: CHANGE LOG ════════════════════════════════════════════════════
ws2 = wb.create_sheet("Changes — Add & Remove")
CH_COLS = ['Action','Gene','Process','Reason']
CH_W = [8, 18, 14, 120]
for ci, h in enumerate(CH_COLS, 1):
    hdr_cell(ws2, 1, ci, h)
    ws2.column_dimensions[get_column_letter(ci)].width = CH_W[ci-1]
ws2.row_dimensions[1].height = 30

for ri, (_, row) in enumerate(change_df.iterrows(), 2):
    act = row['Action']
    fill = ADD_F if act=='ADD' else REM_F
    for ci, col in enumerate(CH_COLS, 1):
        c = ws2.cell(row=ri, column=ci, value=row[col])
        c.font = Font(bold=(ci==1), size=9)
        c.fill = fill
        c.alignment = Alignment(wrap_text=True, vertical="top")
        c.border = bdr
    ws2.row_dimensions[ri].height = 60

# ═══ SHEET 3: PANEL OVERVIEW ════════════════════════════════════════════════
ws3 = wb.create_sheet("Panel Overview")
overview = [
    ["BCC PRM Final Panel — Decision Rationale"],[""],
    ["SUMMARY", f"Original: 90 entries → Removed: {len(REMOVE)} → Added: {len(ADD)} → Final: {len(final)} entries"],[""],
    ["REMOVAL RATIONALE — PHOSPHOSITES (5)"],
    ["STAT1_pY701 / STAT2_pY690 / STAT3_pY705 / STAT5_pY694 / STAT6_pY641",
     "NONE of these 5 phosphosites appear in the DIA-NN infini-search phospho discovery data. These are theoretical/hypothesis-driven sites with no evidence of detectability in your sample type. Their parent proteins (STAT1, STAT2, STAT3, STAT6) are already on the panel and will report total protein abundance. Adding undetected phosphosites inflates the panel without adding information. Replace with DISCOVERED phosphosites."],
    [""],
    ["REMOVAL RATIONALE — PROTEINS (8)"],
    ["MMP9", "FC≈0.84 tumor, FC≈0.77 stroma — LOWER in infiltrative in both compartments, BH>0.99. MMP9 is neutrophil-derived (degranulation), not a CAF marker. No IPA pathway support. Zero BCC literature specificity for infiltrative vs nodular."],
    ["ITGB1", "FC≈0.89/0.85, BH>0.69 in both — ubiquitous integrin, no differential. Provides no subtype-specific information."],
    ["CDH1", "FC≈0.94, BH=0.94 — no differential. BCC are basaloid and do not prominently express E-cadherin; this is an adenocarcinoma marker added by mistake."],
    ["EPCAM", "FC≈1.11, BH=0.91 — no differential. Not relevant to infiltrative vs nodular distinction."],
    ["NFKB1", "FC≈1.04 tumor, BH=1.00 — literally zero differential. CHUK (IKKα) already on the panel shows BH=0.039 stroma and is the mechanistically relevant partner."],
    ["JAK1", "FC≈1.01 tumor — zero differential. Replace with FOXP3 (Treg marker with direct BCC literature evidence)."],
    ["CXCL14", "FC≈0.77/1.07, BH>0.91 — no signal. CXCL14 role in BCC not established; remove in favour of CXCL13 (directly evidenced in iBCC scRNA)."],
    ["PDGFRB", "FC≈0.88/0.87, BH>0.84 — no signal in either compartment. Replace with INHBA (the single most important missing protein)."],
    [""],
    ["ADDITION RATIONALE — PROTEINS (12 proteins + 1 phosphosite)"],
    ["★ INHBA", "HIGHEST PRIORITY. Activin A (encoded by INHBA) is the top pseudotime driver in highly infiltrative BCC tumor clusters (Nat Commun 2022). Activin A-mediated CAF polarization drives CD8 T-cell exclusion and cemiplimab resistance in BCC (Clin Cancer Res 2023). 11 peptides, trending up in both IS stroma and IT tumor. Direct mechanistic link: INHBA→SMAD2/3→FAP+ CAF→LRRC15+ myofibroblast→T-cell exclusion. Compounds with TGFβ1 signalling when TGFβ is compromised."],
    ["SPP1", "SPP1+ macrophages with CXCL9/10high co-expression specifically identified in iBCC scRNA (2023). SPP1 is a canonical M2/TAM marker and TGFB1 downstream target. 7 peptides in tumor LFQ."],
    ["MDK (Midkine)", "Independent predictor of infiltration DEPTH in iBCC per scRNA (2023). Emerging as a BCC aggressiveness biomarker with specific data. 5 peptides, tumor BH=0.08."],
    ["FOXP3", "Tregs are ~45% of CD4+ T cells in BCC TME vs 8-20% in normal skin (Ann Dermatol 2023). FOXP3 is non-negotiable for characterising Treg infiltration. Not detected in LFQ (expected for transcription factor), PRM requires antibody or targeted assay development."],
    ["LAIR1", "Collagen-binding inhibitory receptor on NK/macrophages. Specifically co-localised with CD163 and INHBA in immunosuppressive BCC niches (Clin Cancer Res 2023). Mechanistically connects ECM collagen remodelling story to NK/macrophage immune suppression."],
    ["CXCL13", "T follicular helper-like cells expressing CXCL13 specifically identified in iBCC (2023). Marks tertiary lymphoid structures (TLS); TLS predicts response to immunotherapy in multiple solid tumours. Critical for immune contexture completeness."],
    ["KRT14", "Basal keratinocyte marker, counterpart to KRT5 on the panel. IPA Keratinization pathway INHIBITED in IT vs NT (z=-2.12); KRT14 named in pathway. Tumor BH=0.06, FC=0.58 (lower in IT). 31 peptides. Together KRT5+KRT14 are the nodular BCC identity signature."],
    ["LOXL2", "CAF-specific LOX family crosslinker upregulated by TGFβ, more stroma-specific than LOX (already on panel). 8 peptides, upward trend in both compartments. Replaces PDGFRB."],
    ["SERPINE2", "PAI-2/Protease Nexin 1. Confirmed TGFB1 target gene in IPA ISNS upstream regulator analysis. 8 peptides, stroma FC=2.11 BH=0.18 — approaches significance. Completes the TGFB1 target gene cluster (CCN2, POSTN, SERPINE2)."],
    ["CCN2 (CTGF)", "Canonical TGFB1 fibrosis effector. In IPA ISNS as TGFB1 downstream target. 5 peptides. TGFB1→CCN2→POSTN axis captures complete fibrotic programme."],
    ["WNT5A", "Non-canonical WNT ligand. IPA ISNS TGFB1 and TP63 target. WNT5A-Hedgehog crosstalk is established in BCC invasion. Connects Hedgehog and TGFβ arms of the panel. 3 peptides — borderline detectability, include with caution."],
    ["SFRP1", "scRNA BCC Nat Commun 2022: SFRP1 marks EMT-associated malignant basal subtype 2 (TNC+SFRP1+CHGA+) enriched in highly invasive BCC clusters. CAF-secreted WNT inhibitor that paradoxically promotes invasion. 4 peptides."],
    ["COL4A1", "Type IV collagen, basement membrane. In IPA ISNS Collagen Degradation pathway (p=2.1e-7). 14 peptides in both compartments, trending up in IS stroma (FC=2.31 BH=0.19). Basement membrane breakdown is mechanistically upstream of invasion."],
    ["PTPN23_pS1283 (phospho)", "IS stroma-specific phosphosite in discovery data (2/9 IS, 0 all others). PTPN23 controls endosomal EGFR recycling. Exploratory — sparse detection. Already present in original panel — KEEP as exploratory."],
    [""],
    ["KEY ASSUMPTIONS FLAGGED"],
    ["1.", "INHBA has 11 peptides in our LFQ data but no explicit statistical test was run on it separately — the FC values quoted are from the IPA analysis-ready molecule table. Verify against the raw LFQ matrix before finalising."],
    ["2.", "FOXP3, CCL17, CCL22, CD274, IDO1, IL10, IL13RA1/2, IL4R are all undetected in LFQ discovery. These are hypothesis-driven entries valid for PRM design but require careful assay development. Label them clearly as 'hypothesis-driven, not detected' in the final publication."],
    ["3.", "The 5 STAT phosphosites removed were undetected in DIA-NN infini-search. If you wish to keep these as hypothesis-driven targets, that is scientifically valid — but they should be re-labelled as 'hypothesis-driven, not detected in discovery cohort' and the heavy-labelled peptide standards must be purchased and optimised from scratch."],
    ["4.", "EGFR is on the panel (Tumor FC=0.79, Stroma BH=0.057 approaching significance). IPA identifies EGFR as the top upstream regulator in ITNT. Keep EGFR — the combined LFQ trend + IPA support + MAP2K2_pT394 phospho data create a coherent EGFR→MEK→ERK axis."],
    ["5.", "TNC is kept despite low FC (1.06 tumor, 1.50 stroma) because scRNA BCC 2022 Nat Commun specifically identifies TNC-expressing CAFs (C01_TNC) as BCC-specific CAFs spatially associated with Tregs and collagen-upregulating fibroblasts. The biology trumps the LFQ numbers here."],
]

ws3.column_dimensions["A"].width = 20
ws3.column_dimensions["B"].width = 110
ws3.row_dimensions[1].height = 28
for ri, row in enumerate(overview, 1):
    for ci, val in enumerate(row, 1):
        c = ws3.cell(row=ri, column=ci, value=str(val))
        if ri==1:
            c.font=Font(bold=True,size=14,color="1F3864")
        elif str(val) in ["SUMMARY","REMOVAL RATIONALE — PHOSPHOSITES (5)","REMOVAL RATIONALE — PROTEINS (8)","ADDITION RATIONALE — PROTEINS (12 proteins + 1 phosphosite)","KEY ASSUMPTIONS FLAGGED"]:
            c.font=Font(bold=True,size=11,color="1F3864")
            c.fill=PatternFill("solid",fgColor="D9E1F2")
        elif ci==1 and val and str(val).startswith("★"):
            c.font=Font(bold=True,size=10,color="375623")
            c.fill=PatternFill("solid",fgColor="E2EFDA")
        elif ci==1 and val and str(val) not in ["","1.","2.","3.","4.","5."]:
            c.font=Font(bold=True,size=9)
        else:
            c.font=Font(size=9)
        c.alignment=Alignment(wrap_text=True,vertical="top")
    if ri > 3:
        ws3.row_dimensions[ri].height = 45

wb.save(OUTPUT)
print(f"\nSaved: {OUTPUT}")
print(f"\nFinal panel breakdown:")
print(final.groupby(['Process','Change']).size().to_string())
