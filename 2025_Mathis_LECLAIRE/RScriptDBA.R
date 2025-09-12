library(DiffBind)
setwd("~/Stage")

# create dataframe with 8 columns and 22 rows
## create variables
SampleID <- c("TIR1_20_1", "TIR1_20_2", "TIR1_20_3", "TIR1_20_4", "TIR1_22_1",
              "TIR1_22_2", "Smarca4_20_1", "Smarca4_20_2", "Smarca4_20_3",
              "Smarca4_20_4", "ARID1A_22_1", "ARID1A_22_2", "BRD7_22_1",
              "BRD7_22_2", "BRD9_22_1", "BRD9_22_2", "DPF2_22_1", "DPF2_22_2",
              "PBRM1_22_1", "PBRM1_22_2", "SMARCB1_22_1", "SMARCB1_22_2")

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

png(file = "~/Stage/Plots/100_correlation_heatmap_occupancy.png", width=3.25, height=3.25, units="in", res=1200, pointsize=4)
plot(object_dba_baf_complexes)
dev.off()

png(file = "~/Stage/Plots/101_correlation_heatmap_occupancy.png", width = 3.25, height = 3.25, units = "in", res = 1200, pointsize=4)
plot(object_dba_baf_complexes)
dev.off()

## Blacklists
peakdata <- dba.show(object_dba_baf_complexes)$Intervals
peakdata

object_dba_baf_complexes_bl <- dba.blacklist(object_dba_baf_complexes,
                                             blacklist = DBA_BLACKLIST_MM9,greylist = FALSE)
object_dba_baf_complexes_bl

peakdata.BL <- dba.show(object_dba_baf_complexes_bl)$Intervals
peakdata - peakdata.BL


png(file = "~/Stage/Plots/02_venn_plot_analysis_ctl_1-4.png", width = 3.25, height = 3.25, units = "in", res = 1200, pointsize=4)
dba.plotVenn(object_dba_baf_complexes_bl, 1 : 4)
dev.off()

png(file = "~/Stage/Plots/03_venn_plot_analysis_ctl_5-6.png", width = 3.25, height = 3.25, units = "in", res = 1200, pointsize=4)
dba.plotVenn(object_dba_baf_complexes_bl, 5 : 6)
dev.off()

png(file = "~/Stage/Plots/04_venn_plot_analysis_smarca4.png", width = 3.25, height = 3.25, units = "in", res = 1200, pointsize=4)
dba.plotVenn(object_dba_baf_complexes_bl, 7 : 10)
dev.off()

png(file = "~/Stage/Plots/05_venn_plot_analysis_arid1a.png", width = 3.25, height = 3.25, units = "in", res = 1200, pointsize=4)
dba.plotVenn(object_dba_baf_complexes_bl,
             object_dba_baf_complexes_bl$masks$ARID1A)
dev.off()

png(file = "~/Stage/Plots/06_venn_plot_analysis_brd7.png", width = 3.25, height = 3.25, units = "in", res = 1200, pointsize=4)
dba.plotVenn(object_dba_baf_complexes_bl,
             object_dba_baf_complexes_bl$masks$BRD7)
dev.off()

png(file = "~/Stage/Plots/07_venn_plot_analysis_brd9.png", width = 3.25, height = 3.25, units = "in", res = 1200, pointsize=4)
dba.plotVenn(object_dba_baf_complexes_bl,
             object_dba_baf_complexes_bl$masks$BRD9)
dev.off()

png(file = "~/Stage/Plots/08_venn_plot_analysis_dpf2.png", width = 3.25, height = 3.25, units = "in", res = 1200, pointsize=4)
dba.plotVenn(object_dba_baf_complexes_bl,
             object_dba_baf_complexes_bl$masks$DPF2)
dev.off()

png(file = "~/Stage/Plots/09_venn_plot_analysis_pbrm1.png", width = 3.25, height = 3.25, units = "in", res = 1200, pointsize=4)
dba.plotVenn(object_dba_baf_complexes_bl,
             object_dba_baf_complexes_bl$masks$PBRM1)
dev.off()

png(file = "~/Stage/Plots/10_venn_plot_analysis_smarcb1.png", width = 3.25, height = 3.25, units = "in", res = 1200, pointsize=4)
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

png(file = "~/Stage/Plots/11_correlation_heatmap_affinity.png", width = 3.25, height = 3.25, units = "in", res = 1200, pointsize=4)
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
object_dba_baf_complexes_ctt <- dba.contrast(object_dba_baf_complexes_norm,minMembers = 2, categories = DBA_CONDITION)

object_dba_baf_complexes_ctt

## Performing the differential analysis
object_dba_baf_complexes_da <- dba.analyze(object_dba_baf_complexes_ctt)
dba.show(object_dba_baf_complexes_da, bContrasts = TRUE)

png(file = "~/Stage/Plots/12_correlation_heatmap_differentially_bound_sites.png", width = 3.25, height = 3.25, units = "in", res = 1200, pointsize=4)
plot(object_dba_baf_complexes_da)
dev.off()

## Retrieving the differentially bound sites
object_dba_baf_complexes.DB <- dba.report(object_dba_baf_complexes_da)
object_dba_baf_complexes.DB

sum(object_dba_baf_complexes.DB$Fold > 0)
sum(object_dba_baf_complexes.DB$Fold < 0)

# Plots
## PCA plots
png(file = "~/Stage/Plots/14_PCA_plot_differentially_bound_sites_replicate.png", width = 6.5, height = 6.5, units = "in", res = 1200, pointsize=1)
dba.plotPCA(object_dba_baf_complexes_da, DBA_CONDITION, label = DBA_REPLICATE)
dev.off()

png(file = "~/Stage/Plots/15_PCA_plot_differentially_bound_sites_tissue.png", width = 6.5, height = 6.5, units = "in", res = 1200, pointsize=1)
dba.plotPCA(object_dba_baf_complexes_da, DBA_CONDITION, label = DBA_TISSUE)
dev.off()

png(file = "~/Stage/Plots/16_PCA_plot_differentially_bound_sites_condition.png", width = 6.5, height = 6.5, units = "in", res = 1200, pointsize=1)
dba.plotPCA(object_dba_baf_complexes_da, DBA_CONDITION, label = DBA_CONDITION)
dev.off()

png(file = "~/Stage/Plots/17_PCA_plot_differentially_bound_sites_id.png", width = 6.5, height = 6.5, units = "in", res = 1200, pointsize=1)
dba.plotPCA(object_dba_baf_complexes_da, DBA_CONDITION, label = DBA_ID)
dev.off()


## Venn Plots
png(file = "~/Stage/Plots/19_venn_plot_analysis_tir1_20_1-2_smarca4_7-8.png", width = 3.25, height = 3.25, units = "in", res = 1200, pointsize=4)
dba.plotVenn(object_dba_baf_complexes_da, c(1, 2, 7, 8))
dev.off()
png(file = "~/Stage/Plots/20_venn_plot_analysis_tir1_20_1-2_smarca4_9-10.png", width = 3.25, height = 3.25, units = "in", res = 1200, pointsize=4)
dba.plotVenn(object_dba_baf_complexes_da, c(1, 2, 9, 10))
dev.off()
png(file = "~/Stage/Plots/21_venn_plot_analysis_tir1_20_5-6_smarca4_7-8.png", width = 3.25, height = 3.25, units = "in", res = 1200, pointsize=4)
dba.plotVenn(object_dba_baf_complexes_da, c(5, 6, 7, 8))
dev.off()
png(file = "~/Stage/Plots/22_venn_plot_analysis_tir1_20_5-6_smarca4_9-10.png", width = 3.25, height = 3.25, units = "in", res = 1200, pointsize=4)
dba.plotVenn(object_dba_baf_complexes_da, c(5, 6, 9, 10))
dev.off()
png(file = "~/Stage/Plots/23_venn_plot_analysis_tir1_22_3-4_smarca4_7-8.png", width = 3.25, height = 3.25, units = "in", res = 1200, pointsize=4)
dba.plotVenn(object_dba_baf_complexes_da, c(3, 4, 7, 8))
dev.off()
png(file = "~/Stage/Plots/24_venn_plot_analysis_tir1_22_3-4_smarca4_9-10.png", width = 3.25, height = 3.25, units = "in", res = 1200, pointsize=4)
dba.plotVenn(object_dba_baf_complexes_da, c(3, 4, 9, 10))
dev.off()

png(file = "~/Stage/Plots/25_venn_plot_analysis_tir1_1-2_arid1a.png", width = 3.25, height = 3.25, units = "in", res = 1200, pointsize=4)
dba.plotVenn(object_dba_baf_complexes_da, c(1, 2, 11, 12))
dev.off()
png(file = "~/Stage/Plots/26_venn_plot_analysis_tir1_5-6_arid1a.png", width = 3.25, height = 3.25, units = "in", res = 1200, pointsize=4)
dba.plotVenn(object_dba_baf_complexes_da, c(5, 6, 11, 12))
dev.off()

png(file = "~/Stage/Plots/27_venn_plot_analysis_tir1_1-2_brd7.png", width = 3.25, height = 3.25, units = "in", res = 1200, pointsize=4)
dba.plotVenn(object_dba_baf_complexes_da, c(1, 2, 13, 14))
dev.off()
png(file = "~/Stage/Plots/28_venn_plot_analysis_tir1_5-6_brd7.png", width = 3.25, height = 3.25, units = "in", res = 1200, pointsize=4)
dba.plotVenn(object_dba_baf_complexes_da, c(5, 6, 13, 14))
dev.off()

png(file = "~/Stage/Plots/29_venn_plot_analysis_tir1_1-2_brd9.png", width = 3.25, height = 3.25, units = "in", res = 1200, pointsize=4)
dba.plotVenn(object_dba_baf_complexes_da, c(1, 2, 15, 16))
dev.off()
png(file = "~/Stage/Plots/30_venn_plot_analysis_tir1_5-6_brd9.png", width = 3.25, height = 3.25, units = "in", res = 1200, pointsize=4)
dba.plotVenn(object_dba_baf_complexes_da, c(5, 6, 15, 16))
dev.off()

png(file = "~/Stage/Plots/31_venn_plot_analysis_tir1_1-2_dpf2.png", width = 3.25, height = 3.25, units = "in", res = 1200, pointsize=4)
dba.plotVenn(object_dba_baf_complexes_da, c(1, 2, 17, 18))
dev.off()
png(file = "~/Stage/Plots/32_venn_plot_analysis_tir1_5-6_dpf2.png", width = 3.25, height = 3.25, units = "in", res = 1200, pointsize=4)
dba.plotVenn(object_dba_baf_complexes_da, c(5, 6, 17, 18))
dev.off()

png(file = "~/Stage/Plots/33_venn_plot_analysis_tir1_1-2_pbrm1.png", width = 3.25, height = 3.25, units = "in", res = 1200, pointsize=4)
dba.plotVenn(object_dba_baf_complexes_da, c(1, 2, 19, 20))
dev.off()
png(file = "~/Stage/Plots/34_venn_plot_analysis_tir1_5-6_pbrm1.png", width = 3.25, height = 3.25, units = "in", res = 1200, pointsize=4)
dba.plotVenn(object_dba_baf_complexes_da, c(5, 6, 19, 20))
dev.off()

png(file = "~/Stage/Plots/35_venn_plot_analysis_tir1_1-2_smarcb1.png", width = 3.25, height = 3.25, units = "in", res = 1200, pointsize=4)
dba.plotVenn(object_dba_baf_complexes_da, c(1, 2, 21, 22))
dev.off()
png(file = "~/Stage/Plots/36_venn_plot_analysis_tir1_5-6_smarcb1.png", width = 3.25, height = 3.25, units = "in", res = 1200, pointsize=4)
dba.plotVenn(object_dba_baf_complexes_da, c(5, 6, 21, 22))
dev.off()

## Profile Plots
object_dba_baf_complexes.DB1 <- dba.report(object_dba_baf_complexes_da, contrast = 1)
profiles <- dba.plotProfile(object_dba_baf_complexes_da, sample = list(control = object_dba_baf_complexes_da$masks$control, mutant = object_dba_baf_complexes_da$masks$Smarca4), sites = 1, merge = NULL)
png(file = "~/Stage/Plots/37_profile_plot_control_smarca4.png", width=900, height=900)
dba.plotProfile(profiles)
dev.off()

# object_dba_baf_complexes.DB2 <- dba.report(object_dba_baf_complexes_da, contrast = 2)
profiles <- dba.plotProfile(object_dba_baf_complexes_da, sample = list(control = object_dba_baf_complexes_da$masks$control, mutant = object_dba_baf_complexes_da$masks$ARID1A), sites = 2, merge = NULL)
png(file = "~/Stage/Plots/38_profile_plot_control_arid1a.png", width=900, height=900)
dba.plotProfile(profiles)
dev.off()

# Plot 39 does not show a differential in peak calling, this graph shows similar peaks between the CTL and the BRD9 condition in regions showing a differential in enrichment calculation between the CTL condition and the SMARCA4 condition (contrast 1)
# object_dba_baf_complexes.DB4 <- dba.report(object_dba_baf_complexes_da, contrast = 4)
profiles <- dba.plotProfile(object_dba_baf_complexes_da, sample = list(control = object_dba_baf_complexes_da$masks$control, mutant = object_dba_baf_complexes_da$masks$BRD9), sites = 1, merge = NULL)
png(file = "~/Stage/Plots/39_profile_plot_control_brd9.png", width=900, height=900)
dba.plotProfile(profiles)
dev.off()

# object_dba_baf_complexes.DB7 <- dba.report(object_dba_baf_complexes_da, contrast = 7)
profiles <- dba.plotProfile(object_dba_baf_complexes_da, sample = list(control = object_dba_baf_complexes_da$masks$control, mutant = object_dba_baf_complexes_da$masks$SMARCB1), sites = 7, merge = NULL)
png(file = "~/Stage/Plots/40_profile_plot_control_smarcb1.png", width=900, height=900)
dba.plotProfile(profiles)
dev.off()

## file creation to save the coordinate of the differential peaks in a tsv format
out <- as.data.frame(object_dba_baf_complexes.DB1)
write.table(out, file="results/control_vs_smarca4_deseq2.txt", sep = "\t", quote = F, row.names = F)

out <- as.data.frame(object_dba_baf_complexes.DB2)
write.table(out, file="results/control_vs_arid1a_deseq2.txt", sep = "\t", quote = F, row.names = F)

out <- as.data.frame(object_dba_baf_complexes.DB4)
write.table(out, file="results/control_vs_brd9_deseq2.txt", sep = "\t", quote = F, row.names = F)

out <- as.data.frame(object_dba_baf_complexes.DB7)
write.table(out, file="results/control_vs_smarcb1_deseq2.txt", sep = "\t", quote = F, row.names = F)

save.image("~/Stage/EnvironmentDiffBindDBA.RData")