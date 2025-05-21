library(DiffBind)
setwd("~/Stage")

# create dataframe with 5 columns and 22 rows
## create variables
sample_id <- c("TIR1_20_1", "TIR1_20_2", "TIR1_20_3", "TIR1_20_4", "TIR1_22_1",
               "TIR1_22_2", "Smarca4_20_1", "Smarca4_20_2", "Smarca4_20_3",
               "Smarca4_20_4", "ARID1A_22_1", "ARID1A_22_2", "BRD7_22_1",
               "BRD7_22_2", "BRD9_22_1", "BRD9_22_2", "DPF2_22_1", "DPF2_22_2",
               "PDRM1_22_1", "PDRM1_22_2", "SMARCB1_22_1", "SMARCB1_22_2")
annee <- c("2020", "2020", "2020", "2020", "2022", "2022", "2020", "2020",
           "2020", "2020", "2022", "2022", "2022", "2022", "2022", "2022",
           "2022", "2022", "2022", "2022", "2022", "2022")
condition <- c("control", "control", "control", "control", "control",
               "control", "Smarca4", "Smarca4", "Smarca4", "Smarca4",
               "ARID1A", "ARID1A", "BRD7", "BRD7", "BRD9", "BRD9",
               "DPF2", "DPF2", "PBRM1", "PBRM1", "SMARCB1", "SMARCB1")
replicate <- c("1", "2", "3", "4", "1", "2", "1", "2", "3", "4", "1", "2",
               "1", "2", "1", "2", "1", "2", "1", "2", "1", "2")

## create dataframe
table_dba_baf_complexes <- data.frame(sample_id, annee,
                                      condition, replicate)

print(table_dba_baf_complexes)

save.image("EnvironmentDiffBindDBA.RData")


## Import narrowPeak files
peak <- c(
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

## Add peak in the table
table_dba_baf_complexes <- data.frame(sample_id, annee,
                                      condition, replicate, peak)

print(table_dba_baf_complexes)


# ## Import bam files
# tir1_20_1_bam <- BamFile("/home/mathis.leclaire/Stage/data_stage/reads/chr18_TIR1_rep1_g2-3-4_INPUT_2020.bam")
# tir1_20_2_bam <- BamFile("/home/mathis.leclaire/Stage/data_stage/reads/chr18_TIR1_rep2_g2-3-4_INPUT_2020.bam")
# tir1_20_3_bam <- BamFile("/home/mathis.leclaire/Stage/data_stage/reads/chr18_TIR1_rep3_g2-3-4_INPUT_2020.bam")
# tir1_20_4_bam <- BamFile("/home/mathis.leclaire/Stage/data_stage/reads/chr18_TIR1_rep4_g2-3-4_INPUT_2020.bam")
# tir1_22_1_bam <- BamFile("/home/mathis.leclaire/Stage/data_stage/reads/chr18_TIR1-2-3-4-INPUT_rep1_C002GF8_.bam")
# tir1_22_2_bzm <- BamFile("/home/mathis.leclaire/Stage/data_stage/reads/chr18_TIR1-2-3-4-INPUT_rep2_C002GF7_.bam")
# smarca4_20_1_bam <- BamFile("/home/mathis.leclaire/Stage/data_stage/reads/chr18_SMARCA4_rep1_g2-3-4_INPUT_2020.bam")
# smarca4_20_2_bam <- BamFile("/home/mathis.leclaire/Stage/data_stage/reads/chr18_SMARCA4_rep2_g2-3-4_INPUT_2020.bam")
# smarca4_20_3_bam <- BamFile("/home/mathis.leclaire/Stage/data_stage/reads/chr18_SMARCA4_rep3_g2-3-4_INPUT_2020.bam")
# smarca4_20_4_bam <- BamFile("/home/mathis.leclaire/Stage/data_stage/reads/chr18_SMARCA4_rep4_g2-3-4_INPUT_2020.bam")
# arid1a_22_1_bam <- BamFile("/home/mathis.leclaire/Stage/data_stage/reads/chr18_ARID1A-2-3-4-INPUT_rep1_C002GEX_.bam")
# arid1a_22_2_bam <- BamFile("/home/mathis.leclaire/Stage/data_stage/reads/chr18_ARID1A-2-3-4-INPUT_rep2_C002GEY_.bam")
# brd7_22_1_bam <- BamFile("/home/mathis.leclaire/Stage/data_stage/reads/chr18_BRD7-2-3-4-INPUT_rep1_C002GF3_.bam")
# brd7_22_2_bam <- BamFile("/home/mathis.leclaire/Stage/data_stage/reads/chr18_BRD7-2-3-4-INPUT_rep2_C002GF4_.bam")
# brd9_22_1_bam <- BamFile("/home/mathis.leclaire/Stage/data_stage/reads/chr18_BRD9-2-3-4-INPUT_rep1_C002GF5_.bam")
# brd9_22_2_bam <- BamFile("/home/mathis.leclaire/Stage/data_stage/reads/chr18_BRD9-2-3-4-INPUT_rep2_C002GF6_.bam")
# dpf2_22_1_bam <- BamFile("/home/mathis.leclaire/Stage/data_stage/reads/chr18_DPF2-2-3-4-INPUT_rep1_C002GEZ_.bam")
# dpf2_22_2_bam <- BamFile("/home/mathis.leclaire/Stage/data_stage/reads/chr18_DPF2-2-3-4-INPUT_rep2_C002GF0_.bam")
# pbrm1_22_1_bam <- BamFile("/home/mathis.leclaire/Stage/data_stage/reads/chr18_PBRM1-2-3-4-INPUT_rep1_C002GF1_.bam")
# pbrm1_22_2_bam <- BamFile("/home/mathis.leclaire/Stage/data_stage/reads/chr18_PBRM1-2-3-4-INPUT_rep2_C002GF2_.bam")
# smarcb1_22_1_bam <- BamFile("/home/mathis.leclaire/Stage/data_stage/reads/chr18_SMARCB1-2-3-4-INPUT_rep1_C002GF9_.bam")
# smarcb1_22_2_bam <- BamFile("/home/mathis.leclaire/Stage/data_stage/reads/chr18_SMARCB1-2-3-4-INPUT_rep2_C002GFA_.bam")

# ## Put bam files in a variable
# bamread <- c(tir1_20_1_bam, tir1_20_2_bam, tir1_2O_3_bam, tir1_20_4_bam,
#               tir1_22_1_bam, tir1_22_2_bam, smarca4_20_1_bam, smarca4_20_2_bam,
#               smarca4_20_3_bam, smarca4_20_4_bam, arid1a_22_1_bam,
#               arid1a_22_2_bam, brd7_22_1_bam, brd7_22_2_bam, brd9_22_1_bam,
#               brd9_22_2_bam, dpf2_22_1_bam, dpf2_22_2_bam, pbrm1_22_1_bam,
#               pbrm1_22_2_bam, smarcb1_22_1_bam, smarcb1_22_2_bam)

# ## Add bamRead in the table
# table_dba_baf_complexes <- data.frame(sample_id, annee,
#                                       condition, replicate, bam_read, peak)

# print(table_dba_baf_complexes)



## Import bam files
bam_read <- c(
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

## Add bamRead in the table
table_dba_baf_complexes <- data.frame(sample_id, annee,
                                      condition, replicate, bam_read, peak)

print(table_dba_baf_complexes)

## Import BamControl files
bam_read_ctl <- c(
    file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam"),file.path("~/Stage/data_stage/reads/chr18_merge6_TIR1-2-3-4-INPUT.bam")
)

## Add bam_read_ctl in the table
table_dba_baf_complexes <- data.frame(sample_id, annee, condition, replicate,
                                      bam_read, bam_read_ctl, peak)

print(table_dba_baf_complexes)