#Rscript diffExprPlots.r "L:/promec/Animesh/Kamila/Help_with_poster_for_Eadv_conference/BCC_PRM90_final for LARS.xlsx" 0.5 0.5 Gene
#setup####
#install.packages("readxl")
#install.packages("svglite")
#install.packages("ggplot2")
args = commandArgs(trailingOnly=TRUE)
inpW <- args[1]
#inpW<-"L:/promec/Animesh/Kamila/Help_with_poster_for_Eadv_conference/BCC_PRM90_final for LARS.xlsx"
selThr <- args[2]
#selThr<-0.5
selThrFC <- args[3]
#selThrFC<-0.5
labelS <- args[4]
#labelS<-"Gene"
print(args)

#data####
data <- readxl::read_xlsx(inpW, sheet=1)
data <- data.frame(data)
data[,"ID"] <- data[,labelS]

#volcano -- Stroma####
data[,"log2Stroma_FC"]    <- log2(data[,"Stroma_FC"])
data[,"log10Stroma_padj"] <- log10(data[,"Stroma_padj"]) * (-1)
significance <- data$Stroma_padj < selThr & abs(data$log2Stroma_FC) > selThrFC
sum(significance, na.rm=TRUE)
dsub <- subset(data, significance)
p <- ggplot2::ggplot(data, ggplot2::aes(log2Stroma_FC, log10Stroma_padj)) +
  ggplot2::geom_point(ggplot2::aes(color=significance))
p <- p +
  ggplot2::theme_bw(base_size=8) +
  ggplot2::geom_text(data=dsub, ggplot2::aes(label=ID),
                     hjust=0, vjust=0, size=1,
                     position=ggplot2::position_jitter(width=0.5, height=0.1)) +
  ggplot2::scale_fill_gradient(low="white", high="darkblue") +
  ggplot2::xlab("Log2 Median Change") +
  ggplot2::ylab("-Log10 P-value") +
  ggplot2::xlim(-15, 15) +
  ggplot2::ylim(.Machine$double.eps, 4.99999999999999)
ggplot2::ggsave(paste0(inpW, selThr, selThrFC, labelS, ".Stroma.VolcanoTest.svg"),
                width=10, height=8, dpi=300, p)
print(p)

#volcano -- Tumor####
data[,"log2Tumor_FC"]    <- log2(data[,"Tumor_FC"])
data[,"log10Tumor_padj"] <- log10(data[,"Tumor_padj"]) * (-1)
significance <- data$Tumor_padj < selThr & abs(data$log2Tumor_FC) > selThrFC
sum(significance, na.rm=TRUE)
dsub <- subset(data, significance)
p <- ggplot2::ggplot(data, ggplot2::aes(log2Tumor_FC, log10Tumor_padj)) +
  ggplot2::geom_point(ggplot2::aes(color=significance))
p <- p +
  ggplot2::theme_bw(base_size=8) +
  ggplot2::geom_text(data=dsub, ggplot2::aes(label=ID),
                     hjust=0, vjust=0, size=1,
                     position=ggplot2::position_jitter(width=0.5, height=0.1)) +
  ggplot2::scale_fill_gradient(low="white", high="darkblue") +
  ggplot2::xlab("Log2 Median Change") +
  ggplot2::ylab("-Log10 P-value") +
  ggplot2::xlim(-15, 15) +
  ggplot2::ylim(.Machine$double.eps, 4.99999999999999)
ggplot2::ggsave(paste0(inpW, selThr, selThrFC, labelS, ".Tumor.VolcanoTest.svg"),
                width=10, height=8, dpi=300, p)
print(p)

#--------------------------------------------------------------------
# SHARED SETUP for heatmap + scatter
# (log2Tumor_FC and log2Stroma_FC already computed above)
#--------------------------------------------------------------------

# Sentinel FC values: G10/G45/G80 have Tumor_FC=100 (detected-only, no real ratio)
# and G22/G69 have FC=0.01 (lost). Cap at log2(20) = 4.32 for display.
FC_cap <- log2(20)

# Process factor order (alphabetical keeps groups stable across runs)
proc_order <- sort(unique(data$Process[!is.na(data$Process)]))

# Shared 12-color palette for Process groups
proc_colors <- setNames(
  colorRampPalette(c(
    "#E41A1C","#377EB8","#4DAF4A","#984EA3",
    "#FF7F00","#A65628","#F781BF","#666666",
    "#66C2A5","#FC8D62","#8DA0CB","#E78AC3"
  ))(length(proc_order)),
  proc_order
)

#--------------------------------------------------------------------
# BUBBLE HEATMAP
# Rows = genes grouped by Process
# x    = Tumor | Stroma compartment
# fill = log2 FC (diverging: blue=down, white=1, red=up) -- log2 scale
#        so FC=2 and FC=0.5 get equal-but-opposite color intensity
# size = 1 - padj  (padj=0 -> big; padj=1 -> invisible; NA -> tiny dot)
#--------------------------------------------------------------------

# Reshape to long format -- base R only, no extra dependencies
d_tumor <- data.frame(
  Gene        = data$Gene,
  Process     = data$Process,
  Compartment = "Tumor",
  log2FC      = data$log2Tumor_FC,
  padj        = data$Tumor_padj,
  stringsAsFactors = FALSE
)
d_stroma <- data.frame(
  Gene        = data$Gene,
  Process     = data$Process,
  Compartment = "Stroma",
  log2FC      = data$log2Stroma_FC,
  padj        = data$Stroma_padj,
  stringsAsFactors = FALSE
)
d_long <- rbind(d_tumor, d_stroma)

# Remove rows with no FC at all (e.g. Phospho rows with no measurements)
d_long <- d_long[!is.na(d_long$Process), ]

# Cap log2FC for color display; track which points were capped
d_long$log2FC_disp <- pmin(pmax(d_long$log2FC, -FC_cap), FC_cap)
d_long$capped      <- !is.na(d_long$log2FC) & abs(d_long$log2FC) > FC_cap

# Size: 1 - padj so that low padj = big bubble.
# NA padj (gene measured but no stat test) -> minimal dot (0.05) so row stays visible.
d_long$size_val <- ifelse(is.na(d_long$padj), 0.05, 1 - d_long$padj)

# Order genes by Process then gene name (top of plot = last alphabetically within Process)
gene_order <- data$Gene[order(match(data$Process, proc_order), data$Gene)]
gene_order  <- unique(gene_order[!is.na(gene_order)])
d_long$Gene        <- factor(d_long$Gene,        levels = rev(gene_order))
d_long$Process     <- factor(d_long$Process,     levels = proc_order)
d_long$Compartment <- factor(d_long$Compartment, levels = c("Tumor","Stroma"))

p_heat <- ggplot2::ggplot(
  d_long[!is.na(d_long$log2FC_disp), ],
  ggplot2::aes(x = Compartment, y = Gene)
) +
  # Main bubbles: filled circles, size = 1-padj, fill = log2FC
  ggplot2::geom_point(
    ggplot2::aes(fill = log2FC_disp, size = size_val),
    shape = 21, color = "grey40", stroke = 0.3, na.rm = TRUE
  ) +
  # Triangle overlay on capped sentinel points so they are visually distinct
  ggplot2::geom_point(
    data = d_long[!is.na(d_long$log2FC_disp) & d_long$capped, ],
    ggplot2::aes(x = Compartment, y = Gene),
    shape = 17, color = "black", size = 1.2, na.rm = TRUE
  ) +
  # Diverging color: blue = down, white = no change (log2FC=0, FC=1), red = up
  ggplot2::scale_fill_gradient2(
    low      = "#2166AC",
    mid      = "white",
    high     = "#B2182B",
    midpoint = 0,
    na.value = "grey90",
    name     = "log2 FC\n(cap \u00b1log2(20))",
    guide    = ggplot2::guide_colorbar(barheight = 8, barwidth = 0.8)
  ) +
  # Size: 1 - padj; legend shows back-converted padj values for readability
  ggplot2::scale_size_area(
    max_size = 5,
    breaks   = c(0.05, 0.50, 0.90, 0.95, 0.99),
    labels   = c("NA", "0.50", "0.10", "0.05", "0.01"),
    name     = "padj\n(bubble size)"
  ) +
  # Group rows by Process; free_y + space="free_y" keeps panels proportional
  ggplot2::facet_grid(Process ~ ., scales = "free_y", space = "free_y") +
  ggplot2::theme_bw(base_size = 8) +
  ggplot2::theme(
    strip.text.y      = ggplot2::element_text(angle = 0, hjust = 0,
                                              size = 6, face = "bold"),
    strip.background  = ggplot2::element_rect(fill = "grey91", color = "grey65"),
    axis.text.y       = ggplot2::element_text(size = 5),
    panel.spacing.y   = ggplot2::unit(0.8, "mm"),
    panel.grid.major  = ggplot2::element_line(color = "grey92"),
    legend.key.size   = ggplot2::unit(3, "mm"),
    legend.position   = "right"
  ) +
  ggplot2::xlab("") +
  ggplot2::ylab("Gene set member")

ggplot2::ggsave(
  paste0(inpW, selThr, selThrFC, labelS, ".BubbleHeatmap.svg"),
  width = 7, height = 13, dpi = 300, p_heat
)
print(p_heat)

#--------------------------------------------------------------------
# QUADRANT SCATTER (bonus plot)
# x = log2 Tumor FC,  y = log2 Stroma FC
# Color by Process group, size by best significance across compartments
#
# Quadrant meaning:
#   Q1 (right, up)   -- up in BOTH compartments
#   Q2 (left, up)    -- up in Stroma only
#   Q3 (left, down)  -- down in BOTH
#   Q4 (right, down) -- up in Tumor only
# Shaded bands highlight compartment-discordant regions (Q2, Q4).
#--------------------------------------------------------------------

d_quad <- data[!is.na(data$log2Tumor_FC) & !is.na(data$log2Stroma_FC), ]
d_quad$best_padj <- pmin(d_quad$Tumor_padj, d_quad$Stroma_padj, na.rm = TRUE)
d_quad$sig_size  <- -log10(d_quad$best_padj + 1e-10)
d_quad$Process   <- factor(d_quad$Process, levels = proc_order)

# Label genes that clear the same log2FC threshold used in the volcanoes
thr_log2FC <- as.numeric(selThrFC)
d_label <- d_quad[
  !is.na(d_quad$log2Tumor_FC) &
    !is.na(d_quad$log2Stroma_FC) &
    (abs(d_quad$log2Tumor_FC) > thr_log2FC | abs(d_quad$log2Stroma_FC) > thr_log2FC),
]

p_quad <- ggplot2::ggplot(
  d_quad,
  ggplot2::aes(x = log2Tumor_FC, y = log2Stroma_FC)
) +
  # Shaded quadrants: compartment-discordant changes
  ggplot2::annotate("rect",
                    xmin = -FC_cap, xmax = 0, ymin = 0, ymax = FC_cap,
                    fill = "#D1E5F0", alpha = 0.35) +   # Stroma-up / Tumor-down or neutral
  ggplot2::annotate("rect",
                    xmin = 0, xmax = FC_cap, ymin = -FC_cap, ymax = 0,
                    fill = "#FDDBC7", alpha = 0.35) +   # Tumor-up / Stroma-down or neutral
  ggplot2::geom_hline(yintercept = 0, linetype = "dashed",
                      color = "grey45", linewidth = 0.4) +
  ggplot2::geom_vline(xintercept = 0, linetype = "dashed",
                      color = "grey45", linewidth = 0.4) +
  # Points colored by Process, sized by significance
  ggplot2::geom_point(
    ggplot2::aes(color = Process, size = sig_size),
    alpha = 0.78
  ) +
  # Labels only for genes clearing the FC threshold
  ggplot2::geom_text(
    data = d_label,
    ggplot2::aes(label = Gene, color = Process),
    size = 1.8, hjust = -0.15, vjust = 0.5, show.legend = FALSE,
    position = ggplot2::position_jitter(width = 0.04, height = 0.04)
  ) +
  ggplot2::scale_color_manual(values = proc_colors, name = "Process") +
  ggplot2::scale_size_continuous(
    name   = "-log10(best padj)",
    range  = c(1.0, 5.5)
  ) +
  # Quadrant annotations
  ggplot2::annotate("text", x = -FC_cap * 0.85, y =  FC_cap * 0.90,
                    label = "Stroma up\nTumor neutral/down", size = 2, color = "#1D6FA5", hjust = 0) +
  ggplot2::annotate("text", x =  FC_cap * 0.10, y = -FC_cap * 0.90,
                    label = "Tumor up\nStroma neutral/down", size = 2, color = "#C4501A", hjust = 0) +
  ggplot2::xlim(-FC_cap, FC_cap) +
  ggplot2::ylim(-FC_cap, FC_cap) +
  ggplot2::xlab("log2 Tumor FC") +
  ggplot2::ylab("log2 Stroma FC") +
  ggplot2::ggtitle("Compartment comparison: Tumor vs Stroma log2 FC") +
  ggplot2::theme_bw(base_size = 8) +
  ggplot2::theme(
    legend.key.size = ggplot2::unit(3, "mm"),
    plot.title      = ggplot2::element_text(size = 8)
  )

ggplot2::ggsave(
  paste0(inpW, selThr, selThrFC, labelS, ".QuadrantScatter.svg"),
  width = 9, height = 7, dpi = 300, p_quad
)
print(p_quad)
