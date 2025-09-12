% POC sur les données mnase-chip-seq et leurs intégrations 
% Emilie Drouineau

[//]: # /volatile/home/ed245113/pixi/pandoc/.pixi/envs/default/bin/pandoc topo_integration.md -o topo_integration.pdf -V geometry:margin=1in --toc -f markdown-implicit_figures -V colorlinks -V urlcolor=NavyBlue -N

# Le contexte du sujet d'étude

## Déscriptions des données biologiques

### Complexe BAF :

Fonctions biologiques : remodeleurs de la chromatine.

Je vais m'interesser à la fonction de protéine participant aux complexes Bafs en terme de protéction de l'ADN par le biais de mnases-seq ou de chip-seq qui ont été réalisés dans le contexte de déplétions de plusieurs facteurs et ensuite une étude plus générale sera produite pour comparer les profils de fixation. 

- Les expériences de **Mnase-seq** permettent d'avoir une idée sur le niveau de protection de l'ADN peut importe le facteur protégeant l'ADN car il n'y a pas d'étape d'immunoprécipitation. Ls fragments qu'on obtient sont des fragments d'ADN protégé de la coupure de la Mnase soit par des histones ou des facteurs de transcriptions...
- Les expriences de **Mnase-chip-seq** permettent de voir l'impact des dépletions sur le profil de fixation d'un facteur en particulier. Dans notre cas, on se focalise que les protéines composants le nucléosome (H3, H4, H2B et H2A).

![bafcplx.png](images/bafcplx.png){width=90%}

Image de Hayden A. Malone et al. 2024 présantant les 3 classes des complexes BAF (canonical BAF (cBFA), polydromo-associated BAF (pBAF) et non-canonical BAF (ncBAF)).

Nous voulons étudier des facteurs spécifiques à chacunnes des sous-classes des BAF mais aussi des protéines présentes dans plusieurs complexes : 

- cBAF :
    * ARID1A
    * DPF2
- pBAF :
    * PBRM1
    * BRD7
- ncBAF :
    * BRD9
- cBAF/pBAF:
    * SMARCB1
- cBAF/pBAF/ncBAF :
    * SMARCA4


### Gradients

Pour avoir une idée de la catégorie de facteur protégeant l'ADN de le contexte de la déplétion, l'ADN a été digéré puis migré sur un gradient de succrose, ce qui permet de séparer les fragments d'adn en fonction de leurs tailles ce qui corrélent en partie avec la taille des protéines qui protégent ces fragments d'adn.

![gradient.png](images/gradient.png){width=50%}

Les fractions 2-3-4 sont les fractions avec les plus petits fragments en terme de taille et on les facteurs de fixations les plus petits. Les facteurs migrants dans ces fractions ont un faible poids moléculaire et sont trop petits pour correspondre à des nucléosomes mais on peut supposer que cela correspond à des facteurs de transcriptions. Dans ces fractions on ne devrait pas retrouver de nucléosome, car c'est un complexe protéique trop gros qui ne peut pas migrer dans ces fractions (cf. image ci-dessus). 

Les fractions 5-6 correspondent à des fractions ou on a des protéines avec un poids moléculaire un peu plus grand que la fraction 2-3-4. On peut s'attendre à avoir des fragments d'ADN plus grand mais aussi des prarticules comme des subnucléosomes (des nucléosomes incomplets).

Dans un 1er temps, le but est de travailler sur les fractions Mnase-seq 5-6 et 2-3-4 dans le contexte de dépletion. 


### Les limites

- Comme je veux intégrer un grand nombre d'expérience, j'utilise le même protocole bioinformatique pour les données Mnase-seq et Chip-seq. Cela évite de cumuler les biais liés aux outils de bioinformatique. Pour le moment, je vais me focaliser sur des outils en lien avec de comparaison de chip-seq. Est ce que cela n'entraine pas aussi des biais ?

- J'ai peu de réplicats ce qui entraine des limites dans la possibilité de l'intégration des données et la robustesse des résultats.

## Protocole Bioinformatique lors d'une analyse de chip/mnase

### Le contexte 

Une fois les expériences de chip-seq terminés par les biologistes, les séquences sont envoyées sur une plateforme de séquençage. Les séquences ADN en sortie du séquenceur sont de "petites" tailles (entre 100 et 150 nt, selon la commande lors du séquençage, le plus on allonge, le plus ça coûte cher). La plateforme nous envoie ensuite des fichiers avec des séquences ADN mais aussi la qualité (la confiance) que l'on peut avoir concernant chaque base du fragment (cette valeur de confiance est fourni par le séquenceur lui-même). On a en moyenne 25 millions de fragments/séquences par échantillons.

Le but de l'analyse bioinformatique des données chip-seq est de passer des séquences d'ADN données par le séquenceur à des localisations d'enrichissements de fragments avec une position dans le génome mais aussi déterminer si une protéine d’intérêt a un effet sur la localisation de l’élément immunoprécipité. 

![pairedEndFragment.png](images/pairedEndFragment.png){width=90%}

Sur l'image ci-dessus on peut voir un fragment d'ADN avec sont orientation 5'-3'. Le *read* (ou lecture) 1 et le *read* 2 correspondent à la partie réellement séquencée et avec lesquels on va travailler. Dans notre cas on travaille avec des données *Paired-End*. Lors du séquençage, on va identifier les deux extrémités du fragment. Elles seront dans 2 fichiers différents mais auront un identifiant commun pour que les logiciels puissent les traiter en couple. Ces paires de séquences aide énormément à la précision de la localisation de la séquence sur le génome. Cela simplifie aussi le calcul des enrichissements car les logiciels ont toutes les informations pour la taille des fragments. 

Pour aller plus loin:

- [Paired-end vs Single-end](https://www.illumina.com/science/technology/next-generation-sequencing/plan-experiments/paired-end-vs-single-read.html) 
- [illumina-sequencing](https://microbenotes.com/illumina-sequencing/)

### Les grandes étapes de l'analyse

Il faut réaliser un ensemble d’étape pour aller jusqu’à la comparaison. A chaque étape on a un logiciel qui va fournir un ou plusieurs fichiers. Cette ensemble d'étape est connu sous le nom de pipeline (réalisé en Snakemake). On peut avoir des images, des statistiques, des fichiers de données (souvent mais pas toujours dans un format différent des fichiers de données d'entrée). Les nouveaux fichiers produits peuvent servir à un nouveau logiciel pour continuer l'analyse. Par ce biais on pourra déterminer la qualité des données et établir la confiance que l'on peut attribuer aux résultats.

Toutes les données du projet proviennent *d'Embryonic stem cell* de souris. Nous utilisons la version [mm9](https://www.gencodegenes.org/mouse/release_M1.html) du génome et de l'annotation de souris.

![simplePipeline.png](images/simplePipeline.png){width=100%}

Pipeline simplifié des grandes étapes d'une analyse Chip-seq

1) Nettoyage + contrôle qualité (aussi appelé QC)

Les données de départ sont des fichiers de séquences (fichier texte au format fastq). Avec ces fichiers on va pouvoir regarder les qualités des séquençages et les diverses contaminations. Pour ce faire j'utilise 3 logiciels différents. 
 
- **FastQC** : produit des images pour déterminer simplement la qualité du séquençage
- **FastqScreen** : produit des images pour déterminer d'éventuelles contaminations bactériens ou rRNA
- **Fastp** : un logiciel de nettoyage de donnée, pour supprimer les mauvaises qualités de séquences (en raccourcissant les séquences ou en les supprimant en parallèle dans les deux fichiers)

Une fois le nettoyage terminé, je refais un contrôle qualité.

2) Alignement + QC

Viens ensuite le moment ou on veut attribuer un fragment à une position sur le génome. Dans notre cas on travaille avec la version mm9 de la souris. Pour ce faire j'utilise Bowtie2 qui est un outils performant pour trouver la position des lectures/séquences sur le génome quand on travaille sur des données génomiques (sans gap). Pour les QC à cette étape, Bowtie2 fournit des valeurs intéressantes comme les pourcentages de bon alignement sur le génome. J'utilise aussi l’outil Samtools pour produire des statistiques un peu similaires. 

- **Bowtie2** : alignement
- **Samtools** : QC

3) Nettoyage + QC

Tous les alignements ne seront pas de bonnes qualités. Ça peut venir de la taille du *read* trop petite qui peut être concordante avec trop d'endroit du génome, d'une séquence qui ne matche pas avec la référence, des séquences répétées. De plus avec les techniques de chip-seq ou mnase-seq, lorsque deux fragments ont strictement la même séquence. Ces fragments identiques peuvent venir de deux cellules différentes (ok) ou peuvent être issus d'un artefact de PCR (pas ok mais plus fréquent). On choisit de supprimer les éventuels biais de PCR (au détriment des *reads* issus de cellules différentes) en supprimant tous les duplicats. Le chips n'est pas une méthode quantitative. Il y a des méthodes qui existent pour contourner ce problème. Il faut utiliser d'autres solutions comme le *Spike-in*. Ce n'est pas le cas pour les données du laboratoire. 

- **Picard** : détecter les duplicats de PCR
- **Samtools** : Nettoyer les duplicats de PCR, supprimer les fragments de trop petite taille ou de trop grande taille, supprimer les mauvais alignements.
- **Deeptools** : calcul de la couverture génomique, de la taille des fragments dans la librairie

4) Enrichissement + QC

Une fois le nettoyage des fragments alignés, on peut réaliser le calcul d'enrichissement de fragment par rapport au bruit de fond (d’où l'importance des Inputs). C'est à cette étape qu'on va détecter les zones du génome qui sont protégées (protection pour les histones ou tout autre protéine qui se fixe sur l'ADN et qui en empêche son accessibilité par la MNase).

- **MACS2** : outils de *peakcalling* (calcul d'enrichissement)
- **IGV** : visualisation des données sur le génome


### Documentations des outils :

- [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
- [FastqScreen](https://www.bioinformatics.babraham.ac.uk/projects/fastq_screen/_build/html/index.html)
- [Fastp](https://github.com/OpenGene/fastp)
- [Bowtie2](https://bowtie-bio.sourceforge.net/bowtie2/index.shtml)
- [Samtools](https://www.htslib.org/doc/samtools.html)
- [Picard](https://broadinstitute.github.io/picard/)
- [Deeptools](https://test-argparse-readoc.readthedocs.io/en/latest/)
- [MACS2](https://macs3-project.github.io/MACS/)
- [IGV](https://igv.org/)


# Qualité générale des données et reproductibilité

Nous allons travailler par la suite avec 22 échantillons pour la fraction 2-3-4 et 22 échantillons pour la fraction 5-6. Nous avons des données controles (TIR1) séquencées à deux périodes de temps différentes, cela permet de qualifier la variabilité d'une même manipulation biologique au cours du temps mais aussi de visualiser le niveau de reproductibilité. Les échantillons avec le nom d'un facteur (Smarca4, ARID1A, BRD7, BRD9, DPF2, PBRM1, SMARCB1) sont issus des manipulations ou le facteur a été inhibé pendant 20H à l'auxine. Nous aurons donc l'effet de la perte de fonction du facteur sur l'organisation de la chromatine. 

| années  | samples                |  #réplicat  |
| ------- | :--------------------- | ----------: |
| 2020    | input_TIR1_2-3-4       |           4 |
| 2022    | input_TIR1_2-3-4       |           2 |
| 2020    | input_Smarca4_2-3-4    |           4 |
| 2022    | input_ARID1A_2-3-4     |           2 |
| 2022    | input_BRD7_2-3-4       |           2 |
| 2022    | input_BRD9_2-3-4       |           2 |
| 2022    | input_DPF2_2-3-4       |           2 |
| 2022    | input_PBRM1_2-3-4      |           2 |
| 2022    | input_SMARCB1_2-3-4    |           2 |

| années  | samples                |  #réplicat  |
| ------- | :--------------------- | ----------: |
| 2020    | input_TIR1_5-6         |           4 |
| 2022    | input_TIR1_5-6         |           2 |
| 2020    | input_Smarca4_5-6      |           4 |
| 2022    | input_ARID1A_5-6       |           2 |
| 2022    | input_BRD7_5-6         |           2 |
| 2022    | input_BRD9_5-6         |           2 |
| 2022    | input_DPF2_5-6         |           2 |
| 2022    | input_PBRM1_5-6        |           2 |
| 2022    | input_SMARCB1_5-6      |           2 |



## Répartition de la taille des fragments entre les librairies

### taille de fragments

```bash
# Deeptools 3-5-0
bamPEFragmentSize --bamfiles /store/EQUIPES/REMOD/201127_evry/bam/T{1,2,3,4}_g2-3-4_.bam /store/EQUIPES/REMOD/220126_chipEvry/cleanedBam/TIR1-2-3-4-INPUT_rep*bam --histogram Tir1_input2-3-4_20-22.png --plotFileFormat png --maxFragmentLength 500 --samplesLabel T1_2-3-4_20 T2_2-3-4_20 T3_2-3-4_20 T4_2-3-4_20 T1_2-3-4_22 T2_2-3-4_22
```

![Tir1_input2-3-4_20-22.png](compSize_deeptools/Tir1_input2-3-4_20-22.png){width=90%}


Pour les fractions 2-3-4 les librairies ont des profiles de tailles similaires entres les réplicats. 

comparaison fractions 2-3-4 et 5-6 pour le réplicat1 de l'expérience de 2020.

![TIR1_1_input2-3-4-5-6_20.png](compSize_deeptools/TIR1_1_input2-3-4-5-6_20.png){width=90%}

On voit une répartition de la taille des fragments qui est cohérente avec le gradient, on a un décalage de la taille moyenne des fragments qui est plus grande dans la fraction 5-6 que la fraction 2-3-4. Les élèments protecteurs de l'ADN contre la dégradation sont certainements de plus grandes tailles. 

### corrélation avec deeptools de la répartition des fragments sur le genome

Couverture génomique : comme les fragments ont été digérés par de la Mnase et le séquencage s'est fait en paired-end, la couverture génomique est calculé en fonction du fragment et non des reads. Elle va être calculée base par base pour augmenter la précision. 

```bash
# Deeptools 3-5-0
bamCoverage --bam {input.bam} --outFileName {output} \
                --outFileFormat bigwig \
                --binSize 1 \
                --blackListFileName {params.black} \
                --numberOfProcessors {threads} \
                --effectiveGenomeSize 2701495761 \
                --normalizeUsing RPKM \
                --ignoreForNormalization chrX chrY chrM \
                --skipNonCoveredRegions \
                --MNase \
                --minFragmentLength 10 \
                --extendReads \
                --centerReads \
                --maxFragmentLength {params.maxlen} \
                {params.extra} &> {log}
```

Correlation de la couveture génomique sur tous les samples : 

Correlation de la couveture génomique sur des fusions : 




# Differentiel de chip

## Bibliographie


- DOI: 10.1101/gr.136184.111 ChIP-seq guidelines and practices of the ENCODE and modENCODE consortia. Cet article n'est pas récent mais il est intéressant quand on n'a jamais réalisé de chip que ca soit en biologie ou en bioinformatique.
- DOI: 10.1186/s13059-022-02686-y  Comprehensive assessment of differential ChIP-seq tools guides optimal algorithm selection

**TODO**

Expliquer le choix des algo choisit : diffbind / csaw


## Tests et intégrations

### Differentiel de peaks calling

#### Diffbind

#### Csaw

```bash
# conda activate diffbind
# R 4.4.3 
## library needed
library("csaw")
library(edgeR)
## data files
bam.files <- c("stage/data_stage/reads/chr18_TIR1-2-3-4-INPUT_rep1_C002GF8_.bam","stage/data_stage/reads/chr18_TIR1-2-3-4-INPUT_rep2_C002GF7_.bam","stage/data_stage/reads/chr18_ARID1A-2-3-4-INPUT_rep1_C002GEX_.bam","stage/data_stage/reads/chr18_ARID1A-2-3-4-INPUT_rep2_C002GEY_.bam")
data <- windowCounts(bam.files, width=10) 
#### TEST
param <- readParam(minq=20)
binned <- windowCounts(bam.files, bin=TRUE, width=10000, param=param)
keep <- filterWindowsGlobal(data, binned)$filter > log2(5)
data <- data[keep,]
data <- normFactors(binned, se.out=data)
## Design
sampleID <- c("TIR1_22_1", "TIR1_22_2", "ARID1A_22_1", "ARID1A_22_2")
condition <- c("control", "control", "t-ARID1A", "t-ARID1A")
replicate <- c("1", "2", "1", "2")
bamReads <- c(file.path("~/Stage/data_stage/reads/chr18_TIR1-2-3-4-INPUT_rep1_C002GF8_.bam"), file.path("~/Stage/data_stage/reads/chr18_TIR1-2-3-4-INPUT_rep2_C002GF7_.bam"), file.path("~/Stage/data_stage/reads/chr18_ARID1A-2-3-4-INPUT_rep1_C002GEX_.bam"), file.path("~/Stage/data_stage/reads/chr18_ARID1A-2-3-4-INPUT_rep2_C002GEY_.bam"))
infoCSV <- data.frame(sampleID, condition, replicate, bamReads)
design <- model.matrix(~condition)
## Diff EdgeR
y <- asDGEList(data)
y <- estimateDisp(y, design)
fit <- glmQLFit(y, design, robust=TRUE)
results <- glmQLFTest(fit)
```




# TODO

- calculer frip

articles : diffBind + medips

rapport sans compter les images.
- 3 pages pour le contexte bio
- Intro générale 1 page quesion bio (shéma)
- 3 pages pour l'expérimentation.



