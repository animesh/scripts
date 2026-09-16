#Rscript diffExprPlots.r "L:/promec/Animesh/Kamila/Help_with_poster_for_Eadv_conference/BCC_PRM90_final for LARS.xlsx" 0.5 0.5 Gene
#setup####
#install.packages("readxl")
#install.packages("svglite")
#install.packages("ggplot2")
#install.packages("ggrepel")
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

# Axis caps -- change here to propagate everywhere
VOLCANO_FC_CAP   <- 3   # log2 FC axis limit for volcano plots
VOLCANO_PADJ_CAP <- 2   # -log10(padj) axis limit for volcano plots
SCATTER_FC_CAP   <- 2.6 # log2 FC axis limit for quadrant scatter

#data####
data <- readxl::read_xlsx(inpW, sheet=1)
data <- data.frame(data)
data[,"ID"] <- data[,labelS]

#volcano -- Stroma####
data[,"log2Stroma_FC"]       <- log2(data[,"Stroma_FC"])
data[,"log10Stroma_padj"]    <- -log10(data[,"Stroma_padj"])
data[,"log10Stroma_padj_plot"] <- pmin(data[,"log10Stroma_padj"], VOLCANO_PADJ_CAP)
data[,"log2Stroma_FC_plot"]    <- pmin(pmax(data[,"log2Stroma_FC"], -VOLCANO_FC_CAP), VOLCANO_FC_CAP)
stroma_capped  <- (!is.na(data[,"log2Stroma_FC"]) & abs(data[,"log2Stroma_FC"]) > VOLCANO_FC_CAP) |
  (!is.na(data[,"log10Stroma_padj"]) & (data[,"log10Stroma_padj"] > VOLCANO_PADJ_CAP |
                                          is.infinite(data[,"log10Stroma_padj"])))
stroma_missing <- is.na(data[,"log2Stroma_FC"]) | is.na(data[,"log10Stroma_padj"])
cat("Stroma volcano: capped:", sum(stroma_capped, na.rm=TRUE), "\n")
if (any(stroma_capped, na.rm=TRUE)) print(data[stroma_capped, c(labelS,"Stroma_FC","Stroma_padj","log2Stroma_FC","log10Stroma_padj")])
cat("Stroma volcano: missing:", sum(stroma_missing, na.rm=TRUE), "\n")
if (any(stroma_missing, na.rm=TRUE)) print(data[stroma_missing, c(labelS,"Stroma_FC","Stroma_padj","log2Stroma_FC","log10Stroma_padj")])
significance <- data$Stroma_padj < as.numeric(selThr) & abs(data$log2Stroma_FC) > as.numeric(selThrFC)
cat("Stroma significant:", sum(significance, na.rm=TRUE), "\n")
dsub <- subset(data, significance)
# dsub uses capped plot coords so labels anchor to the clipped point positions
dsub[,"log2Stroma_FC_plot"]    <- pmin(pmax(dsub[,"log2Stroma_FC"], -VOLCANO_FC_CAP), VOLCANO_FC_CAP)
dsub[,"log10Stroma_padj_plot"] <- pmin(dsub[,"log10Stroma_padj"], VOLCANO_PADJ_CAP)
p <- ggplot2::ggplot(data[!stroma_missing, ],
                     ggplot2::aes(log2Stroma_FC_plot, log10Stroma_padj_plot)) +
  ggplot2::geom_point(ggplot2::aes(color=significance[!stroma_missing]), na.rm=TRUE) +
  # Triangle markers on capped points so they are visually identified
  ggplot2::geom_point(
    data = data[!stroma_missing & stroma_capped, ],
    ggplot2::aes(x=log2Stroma_FC_plot, y=log10Stroma_padj_plot,
                 shape="Capped (|log2FC| > 3 or -log10(padj) > 2)"),
    color="black", size=2, na.rm=TRUE
  ) +
  ggplot2::scale_shape_manual(
    values = c("Capped (|log2FC| > 3 or -log10(padj) > 2)" = 17),
    name   = "Note"
  ) +
  ggrepel::geom_text_repel(data=dsub, ggplot2::aes(label=ID),
                           size=3, max.overlaps=Inf,
                           box.padding=0.3, point.padding=0.2,
                           segment.size=0.3, segment.color="grey60",
                           min.segment.length=0.2) +
  ggplot2::scale_fill_gradient(low="white", high="darkblue") +
  ggplot2::xlab("Log2 Median Change") +
  ggplot2::ylab("-Log10 P-value") +
  ggplot2::theme_bw(base_size=8) +
  ggplot2::coord_cartesian(xlim=c(-VOLCANO_FC_CAP, VOLCANO_FC_CAP),
                           ylim=c(.Machine$double.eps, VOLCANO_PADJ_CAP))
ggplot2::ggsave(paste0(inpW, selThr, selThrFC, labelS, ".Stroma.VolcanoTest.svg"),
                width=10, height=8, dpi=300, p)
print(p)

#volcano -- Tumor####
data[,"log2Tumor_FC"]       <- log2(data[,"Tumor_FC"])
data[,"log10Tumor_padj"]    <- -log10(data[,"Tumor_padj"])
data[,"log10Tumor_padj_plot"] <- pmin(data[,"log10Tumor_padj"], VOLCANO_PADJ_CAP)
data[,"log2Tumor_FC_plot"]    <- pmin(pmax(data[,"log2Tumor_FC"], -VOLCANO_FC_CAP), VOLCANO_FC_CAP)
tumor_capped  <- (!is.na(data[,"log2Tumor_FC"]) & abs(data[,"log2Tumor_FC"]) > VOLCANO_FC_CAP) |
  (!is.na(data[,"log10Tumor_padj"]) & (data[,"log10Tumor_padj"] > VOLCANO_PADJ_CAP |
                                         is.infinite(data[,"log10Tumor_padj"])))
tumor_missing <- is.na(data[,"log2Tumor_FC"]) | is.na(data[,"log10Tumor_padj"])
cat("Tumor volcano: capped:", sum(tumor_capped, na.rm=TRUE), "\n")
if (any(tumor_capped, na.rm=TRUE)) print(data[tumor_capped, c(labelS,"Tumor_FC","Tumor_padj","log2Tumor_FC","log10Tumor_padj")])
cat("Tumor volcano: missing:", sum(tumor_missing, na.rm=TRUE), "\n")
if (any(tumor_missing, na.rm=TRUE)) print(data[tumor_missing, c(labelS,"Tumor_FC","Tumor_padj","log2Tumor_FC","log10Tumor_padj")])
significance <- data$Tumor_padj < as.numeric(selThr) & abs(data$log2Tumor_FC) > as.numeric(selThrFC)
cat("Tumor significant:", sum(significance, na.rm=TRUE), "\n")
dsub <- subset(data, significance)
dsub[,"log2Tumor_FC_plot"]    <- pmin(pmax(dsub[,"log2Tumor_FC"], -VOLCANO_FC_CAP), VOLCANO_FC_CAP)
dsub[,"log10Tumor_padj_plot"] <- pmin(dsub[,"log10Tumor_padj"], VOLCANO_PADJ_CAP)
p <- ggplot2::ggplot(data[!tumor_missing, ],
                     ggplot2::aes(log2Tumor_FC_plot, log10Tumor_padj_plot)) +
  ggplot2::geom_point(ggplot2::aes(color=significance[!tumor_missing]), na.rm=TRUE) +
  ggplot2::geom_point(
    data = data[!tumor_missing & tumor_capped, ],
    ggplot2::aes(x=log2Tumor_FC_plot, y=log10Tumor_padj_plot,
                 shape="Capped (|log2FC| > 3 or -log10(padj) > 2)"),
    color="black", size=2, na.rm=TRUE
  ) +
  ggplot2::scale_shape_manual(
    values = c("Capped (|log2FC| > 3 or -log10(padj) > 2)" = 17),
    name   = "Note"
  ) +
  ggrepel::geom_text_repel(data=dsub, ggplot2::aes(label=ID),
                           size=3, max.overlaps=Inf,
                           box.padding=0.3, point.padding=0.2,
                           segment.size=0.3, segment.color="grey60",
                           min.segment.length=0.2) +
  ggplot2::scale_fill_gradient(low="white", high="darkblue") +
  ggplot2::xlab("Log2 Median Change") +
  ggplot2::ylab("-Log10 P-value") +
  ggplot2::theme_bw(base_size=8) +
  ggplot2::coord_cartesian(xlim=c(-VOLCANO_FC_CAP, VOLCANO_FC_CAP),
                           ylim=c(.Machine$double.eps, VOLCANO_PADJ_CAP))
ggplot2::ggsave(paste0(inpW, selThr, selThrFC, labelS, ".Tumor.VolcanoTest.svg"),
                width=10, height=8, dpi=300, p)
print(p)

#--------------------------------------------------------------------
# SHARED SETUP for heatmap + scatter
#--------------------------------------------------------------------
FC_cap     <- log2(20)
proc_order <- sort(unique(data$Process[!is.na(data$Process)]))
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
#--------------------------------------------------------------------
d_tumor <- data.frame(
  Gene=data$Gene, Process=data$Process, Compartment="Tumor",
  log2FC=data$log2Tumor_FC, padj=data$Tumor_padj, stringsAsFactors=FALSE
)
d_stroma <- data.frame(
  Gene=data$Gene, Process=data$Process, Compartment="Stroma",
  log2FC=data$log2Stroma_FC, padj=data$Stroma_padj, stringsAsFactors=FALSE
)
d_long <- rbind(d_tumor, d_stroma)
d_long <- d_long[!is.na(d_long$Process), ]
d_long$log2FC_disp <- pmin(pmax(d_long$log2FC, -FC_cap), FC_cap)
d_long$capped      <- !is.na(d_long$log2FC) & abs(d_long$log2FC) > FC_cap
d_long$size_val    <- ifelse(is.na(d_long$padj), 0.05, pmax(1 - d_long$padj, 0.01))
gene_order <- data$Gene[order(match(data$Process, proc_order), data$Gene)]
gene_order <- unique(gene_order[!is.na(gene_order)])
d_long$Gene        <- factor(d_long$Gene,        levels=rev(gene_order))
d_long$Process     <- factor(d_long$Process,     levels=proc_order)
d_long$Compartment <- factor(d_long$Compartment, levels=c("Tumor","Stroma"))

p_heat <- ggplot2::ggplot(
  d_long[!is.na(d_long$log2FC_disp), ],
  ggplot2::aes(x=Compartment, y=Gene)
) +
  ggplot2::geom_point(
    ggplot2::aes(fill=log2FC_disp, size=size_val),
    shape=21, color="grey40", stroke=0.3, na.rm=TRUE
  ) +
  ggplot2::geom_point(
    data=d_long[!is.na(d_long$log2FC_disp) & d_long$capped, ],
    ggplot2::aes(x=Compartment, y=Gene,
                 shape="Extreme value: FC >= 20 or FC <= 0.05\n(color shows direction; true magnitude unknown)"),
    color="black", size=1.5, na.rm=TRUE
  ) +
  ggplot2::scale_shape_manual(
    values=c("Extreme value: FC >= 20 or FC <= 0.05\n(color shows direction; true magnitude unknown)"=17),
    name="Note"
  ) +
  ggplot2::scale_fill_gradient2(
    low="#2166AC", mid="white", high="#B2182B", midpoint=0, na.value="grey90",
    name="Fold change (log2, capped at +/-log2(20))\nBlue = down, White = unchanged, Red = up"
  ) +
  ggplot2::scale_size_area(
    max_size=5,
    breaks=c(0.05, 0.50, 0.90, 0.95, 0.99),
    labels=c("NA / 1.0","0.50","0.10","0.05","0.01"),
    name="Adj. p-value (bubble size; larger = more significant)"
  ) +
  ggplot2::scale_x_discrete(expand=ggplot2::expansion(add=0.6)) +
  ggplot2::facet_grid(Process ~ ., scales="free_y", space="free_y") +
  ggplot2::guides(
    fill  = ggplot2::guide_colorbar(order=1, barwidth=10, barheight=0.6,
                                    title.position="top", title.hjust=0),
    size  = ggplot2::guide_legend(order=2, title.position="top", title.hjust=0,
                                  label.position="bottom", nrow=1),
    shape = ggplot2::guide_legend(order=3, title.position="top", title.hjust=0)
  ) +
  ggplot2::theme_bw(base_size=8) +
  ggplot2::theme(
    strip.text.y    = ggplot2::element_text(angle=0, hjust=0, size=6, face="bold"),
    strip.background= ggplot2::element_rect(fill="grey91", color="grey65"),
    axis.text.y     = ggplot2::element_text(size=5),
    panel.spacing.y = ggplot2::unit(0.8,"mm"),
    panel.grid.major= ggplot2::element_line(color="grey92"),
    legend.key.size = ggplot2::unit(3,"mm"),
    legend.position = "bottom",
    legend.box      = "vertical",
    legend.margin   = ggplot2::margin(t=2, unit="mm"),
    legend.title    = ggplot2::element_text(size=6),
    legend.text     = ggplot2::element_text(size=6)
  ) +
  ggplot2::labs(x="", y="Gene set member", caption=NULL)

ggplot2::ggsave(paste0(inpW, selThr, selThrFC, labelS, ".BubbleHeatmap.svg"),
                width=5, height=14, dpi=300, p_heat)
print(p_heat)

#--------------------------------------------------------------------
# QUADRANT SCATTER
#--------------------------------------------------------------------
d_quad <- data[!is.na(data$log2Tumor_FC) & !is.na(data$log2Stroma_FC), ]
d_quad$best_padj <- pmin(d_quad$Tumor_padj, d_quad$Stroma_padj, na.rm=TRUE)
missing_padj <- is.na(d_quad$Tumor_padj) & is.na(d_quad$Stroma_padj)
cat("Quadrant scatter: missing both padj:", sum(missing_padj), "\n")
if (any(missing_padj)) print(d_quad[missing_padj, c(labelS,"Tumor_padj","Stroma_padj","log2Tumor_FC","log2Stroma_FC")])
d_quad$sig_size <- -log10(d_quad$best_padj + 1e-10)
d_quad$sig_size[missing_padj] <- 0
d_quad$log2Tumor_FC_plot  <- pmin(pmax(d_quad$log2Tumor_FC,  -SCATTER_FC_CAP), SCATTER_FC_CAP)
d_quad$log2Stroma_FC_plot <- pmin(pmax(d_quad$log2Stroma_FC, -SCATTER_FC_CAP), SCATTER_FC_CAP)
d_quad$capped <- abs(d_quad$log2Tumor_FC) > SCATTER_FC_CAP | abs(d_quad$log2Stroma_FC) > SCATTER_FC_CAP
cat("Quadrant scatter: capped:", sum(d_quad$capped, na.rm=TRUE), "\n")
if (any(d_quad$capped, na.rm=TRUE)) print(d_quad[d_quad$capped, c(labelS,"log2Tumor_FC","log2Stroma_FC")])
d_quad$Process <- factor(d_quad$Process, levels=proc_order)
thr_log2FC <- as.numeric(selThrFC)
d_label <- d_quad[
  !is.na(d_quad$log2Tumor_FC) & !is.na(d_quad$log2Stroma_FC) &
    (abs(d_quad$log2Tumor_FC) > thr_log2FC | abs(d_quad$log2Stroma_FC) > thr_log2FC), ]

p_quad <- ggplot2::ggplot(
  d_quad,
  ggplot2::aes(x=log2Tumor_FC_plot, y=log2Stroma_FC_plot)
) +
  ggplot2::annotate("rect", xmin=-SCATTER_FC_CAP, xmax=0, ymin=0, ymax=SCATTER_FC_CAP,
                    fill="#D1E5F0", alpha=0.35) +
  ggplot2::annotate("rect", xmin=0, xmax=SCATTER_FC_CAP, ymin=-SCATTER_FC_CAP, ymax=0,
                    fill="#FDDBC7", alpha=0.35) +
  ggplot2::geom_hline(yintercept=0, linetype="dashed", color="grey45", linewidth=0.4) +
  ggplot2::geom_vline(xintercept=0, linetype="dashed", color="grey45", linewidth=0.4) +
  ggplot2::geom_point(ggplot2::aes(color=Process, size=sig_size), alpha=0.78) +
  # Triangle on capped points -- appears at boundary edge
  ggplot2::geom_point(
    data=d_quad[d_quad$capped, ],
    ggplot2::aes(x=log2Tumor_FC_plot, y=log2Stroma_FC_plot,
                 shape="Capped: true |log2FC| > 2.6 in >= 1 axis"),
    color="black", size=2, na.rm=TRUE
  ) +
  ggplot2::scale_shape_manual(
    values=c("Capped: true |log2FC| > 2.6 in >= 1 axis"=17),
    name="Note"
  ) +
  ggrepel::geom_text_repel(
    data=d_label,
    ggplot2::aes(label=Gene, color=Process),
    size=1.8, show.legend=FALSE,
    max.overlaps=Inf,
    box.padding=0.3, point.padding=0.2,
    segment.size=0.3, segment.color="grey60",
    min.segment.length=0.2
  ) +
  ggplot2::scale_color_manual(values=proc_colors, name="Process") +
  ggplot2::scale_size_continuous(name="-log10(best padj)", range=c(1.0, 5.5)) +
  ggplot2::annotate("text", x=-SCATTER_FC_CAP*0.85, y=SCATTER_FC_CAP*0.90,
                    label="Stroma up\nTumor neutral/down", size=2, color="#1D6FA5", hjust=0) +
  ggplot2::annotate("text", x=SCATTER_FC_CAP*0.10,  y=-SCATTER_FC_CAP*0.90,
                    label="Tumor up\nStroma neutral/down", size=2, color="#C4501A", hjust=0) +
  ggplot2::coord_cartesian(xlim=c(-SCATTER_FC_CAP, SCATTER_FC_CAP),
                           ylim=c(-SCATTER_FC_CAP, SCATTER_FC_CAP)) +
  ggplot2::xlab("log2 Tumor FC") +
  ggplot2::ylab("log2 Stroma FC") +
  ggplot2::ggtitle("Compartment comparison: Tumor vs Stroma log2 FC") +
  ggplot2::theme_bw(base_size=8) +
  ggplot2::theme(legend.key.size=ggplot2::unit(3,"mm"),
                 plot.title=ggplot2::element_text(size=8))

ggplot2::ggsave(paste0(inpW, selThr, selThrFC, labelS, ".QuadrantScatter.svg"),
                width=9, height=7, dpi=300, p_quad)
print(p_quad)
