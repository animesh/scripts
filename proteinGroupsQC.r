## CRAN
install.packages("PTXQC")
cat(paste0("\nPTXQC was installed to '", .libPaths()[1], "'.\n\n"))
library("PTXQC")
createReport("L:\\promec\\TIMSTOF\\LARS\\2023\\230526 ROLF\\combined\\txt")
#check for peptides -> sequence with git clone https://github.com/pierrepeterlongo/kmer2sequences.git
#f:\promec\Pythonv3p11\python.exe -m pip install AA_stat
#f:\promec\Pythonv3p11\Scripts\AA_stat.exe --pepxml 230607_hela_Slot1-54_1_4598.pepXML
#https://juliasilge.com/blog/roy-kent/
library(tidyverse)
library(richmondway)
data(richmondway)
glimpse(richmondway)
## Rows: 34
## Columns: 16
## $ Character         <chr> "Roy Kent", "Roy Kent", "Roy Kent", "Roy Kent", "Roy.
## $ Episode_order     <dbl> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 1.
## $ Season            <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2.
## $ Episode           <dbl> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 1, 2, 3, 4, 5, 6, 7, .
## $ Season_Episode    <chr> "S1_e1", "S1_e2", "S1_e3", "S1_e4", "S1_e5", "S1_e6".
## $ F_count_RK        <dbl> 2, 2, 7, 8, 4, 2, 5, 7, 14, 5, 11, 10, 2, 2, 23, 12,.
## $ F_count_total     <dbl> 13, 8, 13, 17, 13, 9, 15, 18, 22, 22, 16, 22, 8, 6, .
## $ cum_rk_season     <dbl> 2, 4, 11, 19, 23, 25, 30, 37, 51, 56, 11, 21, 23, 25.
## $ cum_total_season  <dbl> 13, 21, 34, 51, 64, 73, 88, 106, 128, 150, 16, 38, 4.
## $ cum_rk_overall    <dbl> 2, 4, 11, 19, 23, 25, 30, 37, 51, 56, 67, 77, 79, 81.
## $ cum_total_overall <dbl> 13, 21, 34, 51, 64, 73, 88, 106, 128, 150, 166, 188,.
## $ F_score           <dbl> 0.1538462, 0.2500000, 0.5384615, 0.4705882, 0.307692.
## $ F_perc            <dbl> 15.4, 25.0, 53.8, 47.1, 30.8, 22.2, 33.3, 38.9, 63.6.
## $ Dating_flag       <chr> "No", "No", "No", "No", "No", "No", "No", "Yes", "Ye.
## $ Coaching_flag     <chr> "No", "No", "No", "No", "No", "No", "No", "No", "No".
## $ Imdb_rating       <dbl> 7.8, 8.1, 8.5, 8.2, 8.9, 8.5, 9.0, 8.7, 8.6, 9.1, 7..
This is not what you call a large dataset but we can check out the distribution of how often Roy Kent says "f*ck" per episode. Can we compare when he is dating Keeley vs. not?

  richmondway |>
  ggplot(aes(F_count_RK, fill = Dating_flag)) +
  geom_histogram(position = "identity", bins = 7, alpha = 0.7) +
  scale_fill_brewer(palette = "Dark2")


Or what about when he coaching vs. not?

  richmondway |>
  ggplot(aes(F_count_RK, fill = Coaching_flag)) +
  geom_histogram(position = "identity", bins = 7, alpha = 0.7) +
  scale_fill_brewer(palette = "Dark2")


It looks like maybe there are differences here but it's a small dataset, so let's use statistical modeling to help us be more sure what we are seeing.

Bootstrap confidence intervals for Poisson regression
There isn't much code in what we're about to do, but let's outline two important pieces of what is going on:

  These are counts of Roy Kent's F-bombs per episode, so we want to use a model that is a good fit for count data, i.e. Poisson regression.
We could fit a Poisson regression model one time to this dataset, but it's such a tiny dataset that we might not have much confidence in the results. Instead, we want to use bootstrap resamples to fit our model a whole bunch of times to get confidence intervals, and then use these replicate results to estimate the impact of coaching and dating.
We can use the reg_intervals() function from rsample to do this all at once. If we use keep_reps = TRUE, we will get each individual model result in our results:

  library(rsample)

set.seed(123)
poisson_intervals <-
  reg_intervals(
    F_count_RK ~ Dating_flag + Coaching_flag,
    data = richmondway,
    model_fn = "glm",
    family = "poisson",
    keep_reps = TRUE
  )

poisson_intervals
## # A tibble: 2 ? 7
##   term             .lower .estimate .upper .alpha .method          .replicates
##   <chr>             <dbl>     <dbl>  <dbl>  <dbl> <chr>     <list<tibble[,2]>>
## 1 Coaching_flagYes  0.236    0.654   1.04    0.05 student-t        [1,001 ? 2]
## 2 Dating_flagYes   -0.351    0.0428  0.448   0.05 student-t        [1,001 ? 2]
Notice the .replicates column where we have each of the 1000 results from our 1000 bootstrap resamples. We can unnest() this column and make a visualization:

  poisson_intervals |>
  mutate(term = str_remove(term, "_flagYes")) |>
  unnest(.replicates) |>
  ggplot(aes(estimate, fill = term)) +
  geom_vline(xintercept = 0, linewidth = 1.5, lty = 2, color = "gray50") +
  geom_histogram(alpha = 0.8, show.legend = FALSE) +
  facet_wrap(vars(term)) +
  scale_fill_brewer(palette = "Accent")


https://tschauer.github.io/blog/posts/2020-09-24-mass-spec-analysis-with-ttest-lm-or-limma/?s=03
CompBioMethodsHome About
A comparison of statistical methods for analyzing mass spectrometry data
Analysis of mass spectrometry data with t.test, lm or limma.

AUTHOR
AFFILIATION
Tamas Schauer

LMU - Biomedical Center

PUBLISHED
Sept. 24, 2020

CITATION
Schauer, 2020

TABLE OF CONTENTS
Data Description
Setup
Students t-test
Linear model with lm
Linear model with limma
Volcano Plots
Conclusions
Data Description
AP-MS data of DomA, DomB and control IP
3 biological with 3 technical replicates each
biological replicates are from different clones (c_1, c_2 etc.)
label-free quantification (LFQ) and imputation was performed previously
technical replicates were averaged
data were log-transformed
data source: Scacchetti et al. 2020, https://cdn.elifesciences.org/articles/56325/elife-56325-supp1-v1.xlsx
Setup
# load data
ms_data <- read.table("data_massspec/elife-56325-supp1-v1.txt", header = T, row.names = 1, stringsAsFactors = FALSE)

ms_data[1:5,1:4]

DomA_c_1_mean DomA_c_2_mean DomA_c_3_mean DomB_c_1_mean
A0A0B4JCZ0      30.07340      28.10453      30.76833      29.19630
A0A0B4JD97      26.56143      29.04703      27.66783      28.51773
A0A0B4JDG4      26.90077      27.31623      26.88430      27.35533
A0A0B4K5Z8      27.83300      26.35150      27.51597      25.59287
A0A0B4K651      26.55867      26.90197      26.92103      26.23967
library(org.Dm.eg.db)
# convert protein ids to gene names
gene_names <- mapIds(x = org.Dm.eg.db, keys = gsub("\\;.*","", rownames(ms_data)),
                     keytype = "UNIPROT", column = "SYMBOL", multiVals = "first")
# setup conditions
my_conditions <- factor(gsub("_.*","",colnames(ms_data)))
my_conditions

[1] DomA DomA DomA DomB DomB DomB CTRL CTRL CTRL
Levels: CTRL DomA DomB
# setup comparisons
my_comparisons <- list(c(levels(my_conditions)[2], levels(my_conditions)[1]),
                       c(levels(my_conditions)[3], levels(my_conditions)[1]),
                       c(levels(my_conditions)[2], levels(my_conditions)[3]))
my_comparisons

[[1]]
[1] "DomA" "CTRL"

[[2]]
[1] "DomB" "CTRL"

[[3]]
[1] "DomA" "DomB"
Students t-test
fit a t-test for each pair-wise comparison for each protein
the model includes only 6 data points in each test
3 tests (comparisons) are performed separately (multiple testing)
for(j in seq_along(my_comparisons)){

  res_ttest <- data.frame(matrix(NA, nrow = nrow(ms_data), ncol = 2),
                          row.names = rownames(ms_data))

  for(i in 1:nrow(ms_data)){

    fit <-  t.test(x = ms_data[i, my_conditions == my_comparisons[[j]][1]],
                   y = ms_data[i, my_conditions == my_comparisons[[j]][2]],
                   var.equal = TRUE)

    res_ttest[i,1] <- fit$estimate[1] - fit$estimate[2]
    res_ttest[i,2] <- fit$p.value

    rm(list = "fit")
  }

  my_comparison_name <- paste(my_comparisons[[j]], collapse = "vs")

  colnames(res_ttest) <- c(paste0("coef_",my_comparison_name),
                           paste0("pval_",my_comparison_name))

  res_ttest$gene_name <- gene_names

  assign(paste0("res_ttest_", my_comparison_name), res_ttest)

  rm(list = "res_ttest")
}
head(res_ttest_DomAvsCTRL)

coef_DomAvsCTRL pval_DomAvsCTRL       gene_name
A0A0B4JCZ0      -0.1522889      0.86138949         CG42668
A0A0B4JD97      -1.1075667      0.20122473            tacc
A0A0B4JDG4       0.4864667      0.21138652 pre-mod(mdg4)-V
A0A0B4K5Z8       0.1355333      0.89152875           Sec23
A0A0B4K651       1.0487889      0.14619876           Best1
A0A0B4K6E6       1.1618556      0.06399887         CG17734
Linear model with lm
fit a linear model for each protein
the model includes all 9 data points in each model
3 contrasts (comparisons) are performed on the same model
for(j in seq_along(my_comparisons)){

  res_lm <- data.frame(matrix(NA, nrow = nrow(ms_data), ncol = 2),
                       row.names = rownames(ms_data))

  for(i in 1:nrow(ms_data)){

    y <- as.numeric(ms_data[i,])
    my_conditions <- relevel(relevel(my_conditions, ref = my_comparisons[[j]][1]), ref = my_comparisons[[j]][2])

    fit <- lm(y ~ my_conditions)

    res_lm[i,1] <- coef(summary(fit))[2,1]
    res_lm[i,2] <- coef(summary(fit))[2,4]
  }

  my_comparison_name <- paste(my_comparisons[[j]], collapse = "vs")

  colnames(res_lm) <- c(paste0("coef_",my_comparison_name),
                        paste0("pval_",my_comparison_name))

  res_lm$gene_name <- gene_names

  assign(paste0("res_lm_", my_comparison_name), res_lm)

  rm(list = "res_lm")
}
head(res_lm_DomAvsCTRL)

coef_DomAvsCTRL pval_DomAvsCTRL       gene_name
A0A0B4JCZ0      -0.1522889       0.8385450         CG42668
A0A0B4JD97      -1.1075667       0.1268511            tacc
A0A0B4JDG4       0.4864667       0.1528289 pre-mod(mdg4)-V
A0A0B4K5Z8       0.1355333       0.8953270           Sec23
A0A0B4K651       1.0487889       0.2617120           Best1
A0A0B4K6E6       1.1618556       0.0280833         CG17734
Linear model with limma
fit a linear model including all data points
information is "borrowed" across proteins
3 contrasts (comparisons) are performed on the same model
library(limma)

for(j in seq_along(my_comparisons)){

  res_limma <- data.frame(matrix(NA, nrow = nrow(ms_data), ncol = 2),
                          row.names = rownames(ms_data))

  design <- model.matrix( ~ 0 + my_conditions)
  colnames(design) <- levels(my_conditions)

  my_comparison <- paste(my_comparisons[[j]], collapse = "-")
  my_contrast <- makeContrasts(my_comparison, levels = design)

  ###

  fit <- eBayes(contrasts.fit(lmFit(ms_data, design), my_contrast))

  res_limma[,1] <- as.numeric(fit$coefficients)
  res_limma[,2] <- as.numeric(fit$p.value)

  rm(list = "fit")

  ###

  my_comparison_name <- paste(my_comparisons[[j]], collapse = "vs")

  colnames(res_limma) <- c(paste0("coef_",my_comparison_name),
                           paste0("pval_",my_comparison_name))

  res_limma$gene_name <- gene_names

  assign(paste0("res_limma_", my_comparison_name), res_limma)

  rm(list = "res_limma")
}
head(res_limma_DomAvsCTRL)

coef_DomAvsCTRL pval_DomAvsCTRL       gene_name
A0A0B4JCZ0      -0.1522889      0.81184589         CG42668
A0A0B4JD97      -1.1075667      0.07543584            tacc
A0A0B4JDG4       0.4864667      0.14075893 pre-mod(mdg4)-V
A0A0B4K5Z8       0.1355333      0.87566598           Sec23
A0A0B4K651       1.0487889      0.18399592           Best1
A0A0B4K6E6       1.1618556      0.01369977         CG17734
Volcano Plots
loop through methods and comparisons
plot difference against -log10 p-value
color proteins with fdr < 0.05
label some interesting proteins
par(mfrow=c(3,3), mar = c(4,4,0,0), oma = c(1,3,1,1), mgp = c(2,1,0) ,cex=1.25)

fav_genes <- c("dom", "Tip60", "Arp6", "ocm")
my_methods <- c("ttest","lm","limma")

for(i in seq_along(my_methods)){

  my_method <- my_methods[i]

  for(j in seq_along(my_comparisons)){

    my_comparison_name <- paste(my_comparisons[[j]], collapse = "vs")

    res_plot <- get(paste0("res_",my_method,"_", my_comparison_name))

    plot(res_plot[,1], -log10(res_plot[,2]),
         xlim = c(-10,10), ylim = c(0,12),
         ylab = "-log10 p-value",
         xlab = gsub("vs", " vs ", my_comparison_name),
         pch = 19, col = "grey", cex = 0.25)

    my_sign <- p.adjust(res_plot[,2], method = "BH") < 0.05

    points(res_plot[,1][my_sign],
           -log10(res_plot[,2][my_sign]),
           pch = 19, col = "darkred", cex = 0.75)

    my_labeled <- res_plot$gene_name %in% fav_genes

    points(res_plot[,1][my_labeled],
           -log10(res_plot[,2][my_labeled]),
           pch = 19, col = "black", cex = 0.25)

    text(res_plot[,1][my_labeled],
         -log10(res_plot[,2][my_labeled]),
         res_plot$gene_name[my_labeled],
         col = "black", adj = c(0.5,-0.25), cex = 0.8)

    legend("topleft", legend = c("all","fdr < 0.05", "labeled"),
           pch = 19, col = c("grey", "darkred", "black"), pt.cex = c(0.5,1,0.5))

    if(j == 1){
      mtext(my_method, side = 2, line = 3.5, cex =1.5, font = 2)
    }
  }
}


Conclusions
p-values are less significant using t.test compared to lm or limma
it gives more power to fit a model with all data points (e.g. Tip60 in DomA vs DomB)
some proteins with a small difference are significant using t.test or lm (e.g. ocm, false positive?)
limma gives a "better separated" volcano plot.
Corrections
If you see mistakes or want to suggest changes, please create an issue on the source repository.

Citation
For attribution, please cite this work as

Schauer (2020, Sept. 24). CompBioMethods: A comparison of statistical methods for analyzing mass spectrometry data. Retrieved from https://tschauer.github.io/blog/posts/2020-09-24-mass-spec-analysis-with-ttest-lm-or-limma/
  BibTeX citation

@misc{schauer2020a,
  author = {Schauer, Tamas},
  title = {CompBioMethods: A comparison of statistical methods for analyzing mass spectrometry data},
  url = {https://tschauer.github.io/blog/posts/2020-09-24-mass-spec-analysis-with-ttest-lm-or-limma/},
  year = {2020}
}
