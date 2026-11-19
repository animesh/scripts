# %% [markdown]
# AlphaGenome v2 Biological Variant Analysis for Mouse Enh13 -> Sox9 (mm10)

# %%
import os
import sys
import pandas as pd
import matplotlib.pyplot as plt

# 1. Load ~/.env if present and check for API key
try:
    import dotenv
    dotenv.load_dotenv(os.path.expanduser("~/.env"))
    dotenv.load_dotenv()
except ImportError:
    pass

api_key = os.environ.get("ALPHAGENOME_API_KEY") or os.environ.get("ALPHA_GENOME_API_KEY")

if not api_key:
    print("\n[ERROR] ALPHAGENOME_API_KEY environment variable is not set!")
    print("Please set it in your terminal or ~/.env before running this script.")
    sys.exit(1)

print("Importing AlphaGenome v2 libraries...")
from alphagenome.data import gene_annotation
from alphagenome.data import genome
from alphagenome.data import transcript as transcript_utils
from alphagenome.models.v2 import dna_client
from alphagenome.models.v2 import variant_scorers
from alphagenome.visualization import plot_components

# %%
# 2. Initialize AlphaGenome v2 client and select biologically relevant mouse condition
# UBERON:0000473 (testis) has observed RNA-seq, DNase, CAGE, ChIP-histone, and ChIP-TF
# and is the primary tissue where Enh13 drives Sox9 expression.
print("Initializing AlphaGenome v2 DNA model client...")
dna_model = dna_client.create(api_key)
organism = dna_client.Organism.MUS_MUSCULUS

condition = os.environ.get("ALPHAGENOME_CONDITION", "UBERON:0000473")
condition_tag = condition.replace(":", "_")
print(f"Using mouse condition: {condition}")

# %%
# 3. Define Enh13 interval, shifted 1 Mb Enh13+Sox9 window, and variants (mm10)
# Full Enh13 interval in mm10 (557 bp): chr11:112,217,281-112,217,837 (0-based, end-exclusive)
ENH13_INTERVAL = genome.Interval("chr11", 112_217_281 - 1, 112_217_837)
sequence_length = dna_client.SEQUENCE_LENGTH_1MB  # 1,048,576 bp

# Shift 1 Mb window downstream so it spans BOTH Enh13 (~112.217 Mb) AND Sox9 (~112.782 Mb)
ENH13_SOX9_INTERVAL = genome.Interval("chr11", 112_000_000, 112_000_000 + sequence_length)
print(f"Enh13 interval:      {ENH13_INTERVAL} (width: {ENH13_INTERVAL.width})")
print(f"Enh13+Sox9 1Mb span: {ENH13_SOX9_INTERVAL} (width: {ENH13_SOX9_INTERVAL.width})")

# Variants (1-based coordinates)
variants = {
    "plus1bp": genome.Variant(
        chromosome="chr11",
        position=112_217_433,
        reference_bases="A",
        alternate_bases="AT",
    ),
    "del3bp": genome.Variant(
        chromosome="chr11",
        position=112_217_433,
        reference_bases="ACAA",
        alternate_bases="A",
    ),
}

# Use organism-filtered recommended scorers, keeping ONLY differential (REF vs ALT) scorers
# so baseline ACTIVE scorers do not drown out true variant effects.
all_mouse_scorers = list(variant_scorers.get_recommended_scorers(organism))
diff_scorers = [
    s for s in all_mouse_scorers
    if "ACTIVE" not in str(s).upper()
]
print(f"Using {len(diff_scorers)} differential mouse scorers (excluded {len(all_mouse_scorers) - len(diff_scorers)} baseline ACTIVE scorers).")

# %%
# 4. Score both variants across the Enh13 + Sox9 1 Mb locus
modalities_of_interest = [
    "RNA_SEQ",
    "CAGE",
    "ATAC",
    "DNASE",
    "CHIP_HISTONE",
    "CHIP_TF",
    "METHYLATION",
]

for name, variant in variants.items():
    print(f"\n=== Scoring variant (v2 differential): {name} ({variant}) ===")

    try:
        scores = dna_model.score_variant(
            interval=ENH13_SOX9_INTERVAL,
            variant=variant,
            variant_scorers=diff_scorers,
            organism=organism,
            condition=condition,
        )

        df_scores = variant_scorers.tidy_scores(scores)
        if df_scores is None or df_scores.empty:
            print(f"[WARN] No scores returned for {name} under condition={condition}.")
            continue

        # Save all differential scores
        all_csv = f"Enh13_{name}_{condition_tag}_v2_diff_scores.csv"
        df_scores.to_csv(all_csv, index=False)
        print(f"Saved: {all_csv} ({df_scores.shape[0]} rows)")

        # Filter for Sox9
        if "gene_name" in df_scores.columns:
            df_sox9 = df_scores[
                df_scores["gene_name"].astype(str).str.upper() == "SOX9"
            ].copy()
            sox9_csv = f"Enh13_{name}_{condition_tag}_v2_SOX9_rows.csv"
            df_sox9.to_csv(sox9_csv, index=False)
            print(f"Saved: {sox9_csv} ({df_sox9.shape[0]} rows)")
            if not df_sox9.empty:
                print("  Top Sox9 differential effects:")
                cols = [c for c in ("output_type", "variant_scorer", "track_name", "raw_score") if c in df_sox9.columns]
                print(
                    df_sox9.reindex(df_sox9["raw_score"].abs().sort_values(ascending=False).index)
                    .head(5)[cols]
                    .to_string(index=False)
                )

        # Filter for selected regulatory modalities
        df_interest = (
            df_scores[df_scores["output_type"].isin(modalities_of_interest)].copy()
            if "output_type" in df_scores.columns
            else df_scores.copy()
        )

        # Top differential TF ChIP-seq hits (identifies gained/lost TF motifs)
        if "output_type" in df_interest.columns:
            df_tf = df_interest[df_interest["output_type"] == "CHIP_TF"]
            if not df_tf.empty:
                print("  Top differential TF ChIP-seq hits:")
                tf_cols = [c for c in ("transcription_factor", "raw_score", "imputation_mode") if c in df_tf.columns]
                print(
                    df_tf.reindex(df_tf["raw_score"].abs().sort_values(ascending=False).index)
                    .head(5)[tf_cols]
                    .to_string(index=False)
                )

        # Modality max absolute differential impact summary
        if not df_interest.empty and "output_type" in df_interest.columns:
            modality_summary = (
                df_interest.assign(abs_raw=df_interest["raw_score"].abs())
                .groupby("output_type")
                .agg(
                    max_abs_score=("abs_raw", "max"),
                    max_pos_score=("raw_score", "max"),
                    min_neg_score=("raw_score", "min"),
                    n_tracks=("raw_score", "size"),
                )
                .sort_values("max_abs_score", ascending=False)
                .reset_index()
            )
            mod_csv = f"Enh13_{name}_{condition_tag}_v2_modality_summary.csv"
            modality_summary.to_csv(mod_csv, index=False)
            print("  Modality differential summary:")
            print(modality_summary.to_string(index=False))

    except Exception as e:
        print(f"[ERROR] Failed to score variant {name}: {e}")

# %%
# 5. Load transcripts and plot REF vs ALT tracks around Enh13
print("\nLoading transcript annotation from Gencode mm10...")
MM10_GTF_FEATHER = (
    "https://storage.googleapis.com/alphagenome/reference/gencode/"
    "mm10/gencode.vM23.annotation.gtf.gz.feather"
)

try:
    gtf = pd.read_feather(MM10_GTF_FEATHER)
    gtf_transcript = gene_annotation.filter_transcript_support_level(
        gene_annotation.filter_protein_coding(gtf),
        ["1"],
    )
    gtf_longest = gene_annotation.filter_to_longest_transcript(gtf_transcript)
    transcript_extractor = transcript_utils.TranscriptExtractor(gtf_longest)

    # Regional plotting interval (± 20kb around Enh13 center)
    enh13_center = (112_217_281 + 112_217_837) // 2
    enh13_plot_interval = genome.Interval(
        "chr11",
        enh13_center - 20_000,
        enh13_center + 20_000,
    )
    enh13_transcripts = transcript_extractor.extract(enh13_plot_interval)
    print("Transcript annotation loaded successfully.")

    for name, variant in variants.items():
        print(f"Generating tracks plot (v2, {condition}) for {name}...")

        try:
            output = dna_model.predict_variant(
                interval=ENH13_SOX9_INTERVAL,
                variant=variant,
                organism=organism,
                condition=condition,
                requested_outputs=[
                    dna_client.OutputType.RNA_SEQ,
                    dna_client.OutputType.CAGE,
                    dna_client.OutputType.ATAC,
                    dna_client.OutputType.DNASE,
                    dna_client.OutputType.CHIP_HISTONE,
                    dna_client.OutputType.CHIP_TF,
                ],
            )
            ref = output.reference
            alt = output.alternate

            components_local = [
                plot_components.TranscriptAnnotation(enh13_transcripts)
            ]

            for label, attr in [("ATAC", "atac"), ("DNASE", "dnase"), ("CAGE", "cage")]:
                ref_track = getattr(ref, attr, None)
                alt_track = getattr(alt, attr, None)
                if ref_track is not None and alt_track is not None:
                    components_local.append(
                        plot_components.OverlaidTracks(
                            tdata={"REF": ref_track, "ALT": alt_track},
                            colors={"REF": "dimgrey", "ALT": "red"},
                            ylabel_template=f"{label}: {{biosample_name}} ({{strand}})\n{{name}}",
                        )
                    )

            fig = plot_components.plot(
                components=components_local,
                interval=enh13_plot_interval,
                annotations=[plot_components.VariantAnnotation([variant])],
            )

            plot_file = f"Enh13_{name}_{condition_tag}_v2_local_tracks.png"
            fig.savefig(plot_file, dpi=300, bbox_inches="tight")
            plt.close(fig)
            print(f"Saved tracks plot to: {plot_file}")

        except Exception as e:
            print(f"[ERROR] Failed to plot variant {name}: {e}")

except Exception as e:
    print(f"[ERROR] Failed to load/process transcript annotations: {e}")

print("\nAlphaGenome v2 biological analysis pipeline finished.")
