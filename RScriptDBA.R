library(DiffBind)
setwd("~/Stage")

# create dataframe with 7 columns and 22 rows
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
  file.path("~/Stage/data_stage/chr18_peak_input2-4/ chr18_BRD9-2-3-4-INPUT_rep1_C002GF5_.narrowPeak"),
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

object_dba_baf_complexes <- dba(sampleSheet = "~/Stage/dba_baf_complexes_table.csv", scoreCol = 7)

object_dba_baf_complexes