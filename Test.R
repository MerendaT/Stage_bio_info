library(DiffBind)
setwd("~/Stage")

# create dataframe with 7 columns and 22 rows
## create variables
SampleID <- c("TIR1_20_1", "TIR1_20_2", "TIR1_20_3", "TIR1_20_4", "TIR1_22_1",
              "TIR1_22_2", "Smarca4_20_1", "Smarca4_20_2", "Smarca4_20_3",
              "Smarca4_20_4")
Annee <- c("2020", "2020", "2020", "2020", "2022", "2022", "2020", "2020",
           "2020", "2020")
Condition <- c("control", "control", "control", "control", "control",
               "control", "Smarca4", "Smarca4", "Smarca4", "Smarca4")
Replicate <- c("1", "2", "3", "4", "1", "2", "1", "2", "3", "4")

## Import narrowPeak files
Peaks <- c(
  file.path("~/Stage/data_stage/chr18_peak_input2-4/chr18_TIR1_rep1_g2-3-4_INPUT_2020.narrowPeak"),
  file.path("~/Stage/data_stage/chr18_peak_input2-4/chr18_TIR1_rep2_g2-3-4_INPUT_2020.narrowPeak"),
  file.path("~/Stage/data_stage/chr18_peak_input2-4/chr18_TIR1_rep3_g2-3-4_INPUT_2020.narrowPeak"),
  file.path("~/Stage/data_stage/chr18_peak_input2-4/chr18_TIR1_rep4_g2-3-4_INPUT_2020.narrowPeak"),
  file.path("~/Stage/data_stage/chr18_peak_input2-4/chr18_TIR1-2-3-4-INPUT_rep1_C002GF8_.narrowPeak"),
  file.path("~/Stage/data_stage/chr18_peak_input2-4/chr18_TIR1-2-3-4-INPUT_rep2_C002GF7_.narrowPeak"),
  file.path("~/Stage/data_stage/chr18_peak_input2-4/chr18_SMARCA4_rep1_g2-3-4_INPUT_2020.narrowPeak"),
  file.path("~/Stage/data_stage/chr18_peak_input2-4/chr18_SMARCA4_rep2_g2-3-4_INPUT_2020.narrowPeak"),
  file.path("~/Stage/data_stage/chr18_peak_input2-4/chr18_SMARCA4_rep3_g2-3-4_INPUT_2020.narrowPeak"),
  file.path("~/Stage/data_stage/chr18_peak_input2-4/chr18_SMARCA4_rep4_g2-3-4_INPUT_2020.narrowPeak")
)

## Import bam files
bamReads <- c(
    file.path("~/Stage/data_stage/reads/chr18_TIR1_rep1_g2-3-4_INPUT_2020.bam"),file.path("~/Stage/data_stage/reads/chr18_TIR1_rep2_g2-3-4_INPUT_2020.bam"),file.path("~/Stage/data_stage/reads/chr18_TIR1_rep3_g2-3-4_INPUT_2020.bam"),
    file.path("~/Stage/data_stage/reads/chr18_TIR1_rep4_g2-3-4_INPUT_2020.bam"),
    file.path("~/Stage/data_stage/reads/chr18_TIR1-2-3-4-INPUT_rep1_C002GF8_.bam"),
    file.path("~/Stage/data_stage/reads/chr18_TIR1-2-3-4-INPUT_rep2_C002GF7_.bam"),
    file.path("~/Stage/data_stage/reads/chr18_SMARCA4_rep1_g2-3-4_INPUT_2020.bam"),
    file.path("~/Stage/data_stage/reads/chr18_SMARCA4_rep2_g2-3-4_INPUT_2020.bam"),
    file.path("~/Stage/data_stage/reads/chr18_SMARCA4_rep3_g2-3-4_INPUT_2020.bam"),
    file.path("~/Stage/data_stage/reads/chr18_SMARCA4_rep4_g2-3-4_INPUT_2020.bam")
)

## Import BamControl files
bamControl <- c(
    file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam")
)

## Add bamControl in the table
table_dba_baf_complexes <- data.frame(SampleID, Annee, Condition, Replicate,
                                      Peaks, bamReads, bamControl)

table_dba_baf_complexes

write.csv(table_dba_baf_complexes, file = "~/Stage/dba_baf_complexes_table.csv")

object_dba_baf_complexes <- dba(sampleSheet = table_dba_baf_complexes, scoreCol = 5)

object_dba_baf_complexes

pdf(file = "~/Stage/Plots/1_correlation_heatmap_occupancy.pdf")
plot(object_dba_baf_complexes)
dev.off()

#3.2 Blacklists and greylists
#3.3 Counting reads
object_dba_baf_complexes_cr <- dba.count(object_dba_baf_complexes)

object_dba_baf_complexes_cr

info <- dba.show(object_dba_baf_complexes_cr)
libsizes <- cbind(LibReads = info$Reads, FRiP = info$FRiP, PeakReads = round(                 info$Reads * info$FRiP))

rownames(libsizes) <- info$ID
libsizes

pdf(file = "~/Stage/Plots/2_correlation_heatmap_affinity.pdf")
plot(object_dba_baf_complexes_cr)
dev.off()

#3.4 Normalizing the data
object_dba_baf_complexes_norm <- dba.normalize(object_dba_baf_complexes_cr)

norm <- dba.normalize(object_dba_baf_complexes_norm, bRetrieve = TRUE)
norm

normlibs <- cbind(FullLibSize = norm$lib.sizes, NormFacs = norm$norm.factors,
                  NormLibSize = round(norm$lib.sizes / norm$norm.factors))
rownames(normlibs) <- info$ID
normlibs

#3.5 Establishing a model design and contrast

object_dba_baf_complexes_ctt <- dba.contrast(object_dba_baf_complexes_norm, reorderMeta = list(Condition = "Smarca4"))

object_dba_baf_complexes_ctt

#3.6 Performing the differential analysis
object_dba_baf_complexes_da <- dba.analyze(object_dba_baf_complexes_ctt)
dba.show(object_dba_baf_complexes_da, bContrasts = TRUE)

pdf(file = "~/Stage/Plots/3_correlation_heatmap_differentially_bound_sites.pdf")
plot(object_dba_baf_complexes_da)
dev.off()

#3.7 Retrieving the differentially bound sites

object_dba_baf_complexes.DB <- dba.report(object_dba_baf_complexes_da)

object_dba_baf_complexes.DB

sum(object_dba_baf_complexes.DB$Fold > 0)

sum(object_dba_baf_complexes.DB$Fold < 0)

#4 Plotting in DiffBind

#4.1 Venn diagrams
pdf(file = "~/Stage/Plots/4_venn_diagram_gain_loss_dbs.pdf")
dba.plotVenn(object_dba_baf_complexes_da, contrast = 1, bDB = TRUE, bGain =
               TRUE, bLoss = TRUE, bAll = FALSE)
dev.off()

#4.2 PCA plots

#4.3 MA plots
pdf(file = "~/Stage/Plots/7_ma_plot_control_smarca4_contrast.pdf")
dba.plotMA(object_dba_baf_complexes_da)
dev.off()

#4.4 Volcano plots
pdf(file = "~/Stage/Plots/8_volcano_plot_control_smarca4_contrast.pdf")
dba.plotVolcano(object_dba_baf_complexes_da)
dev.off()

#4.5 Boxplots

sum(object_dba_baf_complexes.DB$Fold > 0)

sum(object_dba_baf_complexes.DB$Fold > 0)

pdf(file = "~/Stage/Plots/9_box_plots_read_distributions_dbs.pdf")
dba.plotBox(object_dba_baf_complexes_da)
dev.off()

pvals <- dba.plotBox(object_dba_baf_complexes_da)

pvals

#4.6 Heatmaps
corvals <- dba.plotHeatmap(object_dba_baf_complexes_da)

hmap <- colorRampPalette(c("red", "black", "green"))(n = 13)
pdf(file = "~/Stage/Plots/10_heatmap_ba_dbs.pdf")
dba.plotHeatmap(object_dba_baf_complexes_da, contrast = 1,
                              correlations = FALSE, scale = "row", colScheme = hmap)
dev.off()
readscores <- dba.plotHeatmap(object_dba_baf_complexes_da, contrast = 1,
                              correlations = FALSE, scale = "row", colScheme = hmap)

