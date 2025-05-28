library(DiffBind)
setwd("~/Stage")

# create dataframe with 8 columns and 22 rows
## create variables
SampleID <- c("TIR1_20_1", "TIR1_20_2", "TIR1_20_3", "TIR1_20_4", "TIR1_22_1",
              "TIR1_22_2", "Smarca4_20_1", "Smarca4_20_2", "Smarca4_20_3",
              "Smarca4_20_4", "ARID1A_22_1", "ARID1A_22_2", "BRD7_22_1",
              "BRD7_22_2", "BRD9_22_1", "BRD9_22_2", "DPF2_22_1", "DPF2_22_2",
              "PDRM1_22_1", "PDRM1_22_2", "SMARCB1_22_1", "SMARCB1_22_2")

Annee <- c("2020", "2020", "2020", "2020", "2022", "2022", "2020", "2020",
           "2020", "2020", "2022", "2022", "2022", "2022", "2022", "2022",
           "2022", "2022", "2022", "2022", "2022", "2022")

Condition <- c("control", "control", "control", "control", "control",
               "control", "Smarca4", "Smarca4", "Smarca4", "Smarca4",
               "ARID1A", "ARID1A", "BRD7", "BRD7", "BRD9", "BRD9",
               "DPF2", "DPF2", "PBRM1", "PBRM1", "SMARCB1", "SMARCB1")

Replicate <- c("1", "2", "3", "4", "1", "2", "1", "2", "3", "4", "1", "2",
               "1", "2", "1", "2", "1", "2", "1", "2", "1", "2")

PeakCaller <- c("narrowPeak", "narrowPeak", "narrowPeak", "narrowPeak",
                "narrowPeak", "narrowPeak", "narrowPeak", "narrowPeak",
                "narrowPeak", "narrowPeak", "narrowPeak", "narrowPeak",
                "narrowPeak", "narrowPeak", "narrowPeak", "narrowPeak",
                "narrowPeak", "narrowPeak", "narrowPeak", "narrowPeak",
                "narrowPeak", "narrowPeak")

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
  file.path("~/Stage/data_stage/chr18_peak_input2-4/chr18_SMARCA4_rep4_g2-3-4_INPUT_2020.narrowPeak"),
  file.path("~/Stage/data_stage/chr18_peak_input2-4/chr18_ARID1A-2-3-4-INPUT_rep1_C002GEX_.narrowPeak"),
  file.path("~/Stage/data_stage/chr18_peak_input2-4/chr18_ARID1A-2-3-4-INPUT_rep2_C002GEY_.narrowPeak"),
  file.path("~/Stage/data_stage/chr18_peak_input2-4/chr18_BRD7-2-3-4-INPUT_rep1_C002GF3_.narrowPeak"),
  file.path("~/Stage/data_stage/chr18_peak_input2-4/chr18_BRD7-2-3-4-INPUT_rep2_C002GF4_.narrowPeak"),
  file.path("~/Stage/data_stage/chr18_peak_input2-4/chr18_BRD9-2-3-4-INPUT_rep1_C002GF5_.narrowPeak"),
  file.path("~/Stage/data_stage/chr18_peak_input2-4/chr18_BRD9-2-3-4-INPUT_rep2_C002GF6_.narrowPeak"),
  file.path("~/Stage/data_stage/chr18_peak_input2-4/chr18_DPF2-2-3-4-INPUT_rep1_C002GEZ_.narrowPeak"),
  file.path("~/Stage/data_stage/chr18_peak_input2-4/chr18_DPF2-2-3-4-INPUT_rep2_C002GF0_.narrowPeak"),
  file.path("~/Stage/data_stage/chr18_peak_input2-4/chr18_PBRM1-2-3-4-INPUT_rep1_C002GF1_.narrowPeak"),
  file.path("~/Stage/data_stage/chr18_peak_input2-4/chr18_PBRM1-2-3-4-INPUT_rep2_C002GF2_.narrowPeak"),
  file.path("~/Stage/data_stage/chr18_peak_input2-4/chr18_SMARCB1-2-3-4-INPUT_rep1_C002GF9_.narrowPeak"),
  file.path("~/Stage/data_stage/chr18_peak_input2-4/chr18_SMARCB1-2-3-4-INPUT_rep2_C002GFA_.narrowPeak")
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
    file.path("~/Stage/data_stage/reads/chr18_SMARCA4_rep4_g2-3-4_INPUT_2020.bam"),
    file.path("~/Stage/data_stage/reads/chr18_ARID1A-2-3-4-INPUT_rep1_C002GEX_.bam"),
    file.path("~/Stage/data_stage/reads/chr18_ARID1A-2-3-4-INPUT_rep2_C002GEY_.bam"),
    file.path("~/Stage/data_stage/reads/chr18_BRD7-2-3-4-INPUT_rep1_C002GF3_.bam"),
    file.path("~/Stage/data_stage/reads/chr18_BRD7-2-3-4-INPUT_rep2_C002GF4_.bam"),
    file.path("~/Stage/data_stage/reads/chr18_BRD9-2-3-4-INPUT_rep1_C002GF5_.bam"),
    file.path("~/Stage/data_stage/reads/chr18_BRD9-2-3-4-INPUT_rep2_C002GF6_.bam"),
    file.path("~/Stage/data_stage/reads/chr18_DPF2-2-3-4-INPUT_rep1_C002GEZ_.bam"),
    file.path("~/Stage/data_stage/reads/chr18_DPF2-2-3-4-INPUT_rep2_C002GF0_.bam"),
    file.path("~/Stage/data_stage/reads/chr18_PBRM1-2-3-4-INPUT_rep1_C002GF1_.bam"),
    file.path("~/Stage/data_stage/reads/chr18_PBRM1-2-3-4-INPUT_rep2_C002GF2_.bam"),
    file.path("~/Stage/data_stage/reads/chr18_SMARCB1-2-3-4-INPUT_rep1_C002GF9_.bam"),
    file.path("~/Stage/data_stage/reads/chr18_SMARCB1-2-3-4-INPUT_rep2_C002GFA_.bam")
)

## Import BamControl files
bamControl <- c(
    file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam")
)

## Add bam_read_ctl in the table
table_dba_baf_complexes <- data.frame(SampleID, Annee, Condition, Replicate,
                                      bamReads, bamControl, Peaks, PeakCaller)

table_dba_baf_complexes

write.csv(table_dba_baf_complexes, file = "~/Stage/dba_baf_complexes_table.csv")

# Differentially bound sites analysis
## Reading in the peaksets
object_dba_baf_complexes <- dba(sampleSheet = "~/Stage/dba_baf_complexes_table.csv", scoreCol = 7)

object_dba_baf_complexes

pdf(file = "~/Stage/Plots/1_correlation_heatmap_occupancy.pdf")
plot(object_dba_baf_complexes)
dev.off()

## Blacklists and grelists
peakdata <- dba.show(object_dba_baf_complexes)$Intervals
peakdata

object_dba_baf_complexes_bl <- dba.blacklist(object_dba_baf_complexes,
                                             blacklist = DBA_BLACKLIST_MM9,greylist = FALSE)
object_dba_baf_complexes_bl

peakdata.BL <- dba.show(object_dba_baf_complexes_bl)$Intervals
peakdata - peakdata.BL


pdf(file = "~/Stage/Plots/venn_plot_analysis_ctl_1-4.pdf")
dba.plotVenn(object_dba_baf_complexes_bl, 1 : 4)
dev.off()


pdf(file = "~/Stage/Plots/venn_plot_analysis_ctl_5-6.pdf")
dba.plotVenn(object_dba_baf_complexes_bl, 5 : 6)
dev.off()


pdf(file = "~/Stage/Plots/venn_plot_analysis_smarca4.pdf")
dba.plotVenn(object_dba_baf_complexes_bl, 7 : 10)
dev.off()

pdf(file = "~/Stage/Plots/venn_plot_analysis_arid1a.pdf")
dba.plotVenn(object_dba_baf_complexes_bl,
             object_dba_baf_complexes_bl$masks$ARID1A)
dev.off()

pdf(file = "~/Stage/Plots/venn_plot_analysis_brd7.pdf")
dba.plotVenn(object_dba_baf_complexes_bl,
             object_dba_baf_complexes_bl$masks$BRD7)
dev.off()

pdf(file = "~/Stage/Plots/venn_plot_analysis_brd9.pdf")
dba.plotVenn(object_dba_baf_complexes_bl,
             object_dba_baf_complexes_bl$masks$BRD9)
dev.off()

pdf(file = "~/Stage/Plots/venn_plot_analysis_dpf2.pdf")
dba.plotVenn(object_dba_baf_complexes_bl,
             object_dba_baf_complexes_bl$masks$DPF2)
dev.off()

pdf(file = "~/Stage/Plots/venn_plot_analysis_pbrm1.pdf")
dba.plotVenn(object_dba_baf_complexes_bl,
             object_dba_baf_complexes_bl$masks$PBRM1)
dev.off()

pdf(file = "~/Stage/Plots/venn_plot_analysis_smarcb1.pdf")
dba.plotVenn(object_dba_baf_complexes_bl,
             object_dba_baf_complexes_bl$masks$SMARCB1)
dev.off()


## Counting reads
object_dba_baf_complexes_cr <- dba.count(object_dba_baf_complexes_bl)

object_dba_baf_complexes_cr

info <- dba.show(object_dba_baf_complexes_cr)
libsizes <- cbind(LibReads = info$Reads, FRiP = info$FRiP, PeakReads = round(                 info$Reads * info$FRiP))

rownames(libsizes) <- info$ID
libsizes

pdf(file = "~/Stage/Plots/2_correlation_heatmap_affinity.pdf")
plot(object_dba_baf_complexes_cr)
dev.off()

## Normalizing the data
object_dba_baf_complexes_norm <- dba.normalize(object_dba_baf_complexes_cr, normalize = DBA_NORM_NATIVE, background = TRUE)

norm <- dba.normalize(object_dba_baf_complexes_norm, normalize = DBA_NORM_NATIVE, background = TRUE, bRetrieve = TRUE)

normlibs <- cbind(FullLibSize = norm$lib.sizes, NormFacs = norm$norm.factors,
                  NormLibSize = round(norm$lib.sizes / norm$norm.factors))
rownames(normlibs) <- info$ID
normlibs

## Establishing a model design and contrast

object_dba_baf_complexes_ctt <- dba.contrast(object_dba_baf_complexes_norm, minMembers = 2, categories = DBA_CONDITION)

object_dba_baf_complexes_ctt

# Performing the differential analysis
object_dba_baf_complexes_da <- dba.analyze(object_dba_baf_complexes_ctt)
dba.show(object_dba_baf_complexes_da, bContrasts = TRUE)

pdf(file = "~/Stage/Plots/3_correlation_heatmap_differentially_bound_sites.pdf")
plot(object_dba_baf_complexes_da)
dev.off()

## Retrieving the differentially bound sites

object_dba_baf_complexes.DB <- dba.report(object_dba_baf_complexes_da)

object_dba_baf_complexes.DB

sum(object_dba_baf_complexes.DB$Fold > 0)

sum(object_dba_baf_complexes.DB$Fold < 0)

# Plots
# PCA plots
pdf(file = "~/Stage/Plots/4_PCA_plot_differentially_bound_sites.pdf")
dba.plotPCA(object_dba_baf_complexes_da, DBA_CONDITION)
dev.off()

save.image("~/Stage/EnvironmentDiffBindDBA.RData")

# Upset plots

