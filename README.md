# Documentation des Scripts et Utilisation (CLI)

Ce dépôt réunit des outils bio-informatiques développés pour automatiser le requêtage de bases de données biologiques (**UniProt**, **STRING-DB**) et réaliser des analyses d'enrichissement fonctionnel (**GSEApy**) à partir de données de spectrométrie de masse.

---

## 1. Code_documente_mixte.py

* **Description :** Analyse une liste de gènes issue d'un fichier **Excel (.xlsx)** ou **Texte (.txt)**, interroge l'API REST **UniProtKB** et extrait la localisation sous-cellulaire (consensus et sous-types ER), les termes Gene Ontology (GO) associés, la fonction descriptive, ainsi que l'accession et l'identifiant UniProt. Le résultat est exporté sous forme de tableau Excel récapitulatif.
* **Localisation :** [code_documente_mixte.py](https://github.com/MerendaT/Stage_bio_info/blob/interaction_LC/base_de_donnees_UniProt/script/code_documente_mixte.py)
### Exécution en ligne de commande :

# Pour traiter un fichier Excel (.xlsx)
python uniprot_localisation.py --format 1
# ou
python uniprot_localisation.py -f xlsx

# Pour traiter un fichier texte (.txt)
python uniprot_localisation.py --format 2
# ou
python uniprot_localisation.py -f txt

# Mode interactif (si aucun argument n'est fourni)
python uniprot_localisation.py

---

## 2. Code_requete_API_STRING.py

* **Description :** Interroge l'API de **STRING-DB** pour une protéine unique. Le script extrait les termes d'annotations fonctionnelles ainsi que les réseaux d'interactions, applique un filtre optionnel par catégorie/terme, sauvegarde le fichier JSON brut et génère un rapport lisible au format Markdown (.md).
* **Localisation :** [code_requete_API_STRING.py](https://github.com/MerendaT/Stage_bio_info/blob/interaction_LC/base_de_donnees_STRING/requete_API_STRING/code_requete_API_STRING.py)

### Exécution en ligne de commande :

# Recherche simple (Organisme humain par défaut - TaxID 9606)
python string_annotation_prot.py --protein SMARCA4

# Recherche sur un autre organisme (ex: Souris - TaxID 10090)
python string_annotation_prot.py -p TP53 -t 10090

# Recherche avec filtrage sur une catégorie
python string_annotation_prot.py -p SMARCA4 -f COMPONENT

# Mode interactif via invites d'entrée
python string_annotation_prot.py

---

## 3. Enrichissement_annotation.py

* **Description :** Pipeline haut débit multi-threadé (`ThreadPoolExecutor`). Il extrait une liste de gènes depuis un fichier Excel de spectrométrie de masse, interroge l'API STRING pour reconstruire les réseaux d'interactions, sauvegarde le dictionnaire d'interactions au format JSON, puis exécute une analyse d'enrichissement de jeux de gènes via **GSEApy** avec génération automatique de graphiques (dotplots).
* **Localisation :** [Enrichissement_annotation.py](https://github.com/MerendaT/Stage_bio_info/blob/interaction_LC/base_de_donnees_STRING/enrichissement/script/enrichissement_annotation.py)

### Exécution en ligne de commande :

#### Mode 1 : Extraction des réseaux d'interactions STRING uniquement
# Pour l'humain (TaxID 9606 par défaut)
python pipeline_string_gsea.py --mode 1

# Pour un autre organisme (ex: Souris - TaxID 10090)
python pipeline_string_gsea.py -m 1 -t 10090

#### Mode 2 : Pipeline complet (STRING + Enrichissement GSEA)
# Enrichissement GSEA avec les réseaux d'interactions STRING (p-value < 0.05)
python pipeline_string_gsea.py --mode 2 --db STRING --p-value 0.05

# Enrichissement GSEA sur les bibliothèques officielles de GSEApy (p-value < 0.01)
python pipeline_string_gsea.py -m 2 -d GSEA -p 0.01

#### Menu d'aide
python pipeline_string_gsea.py --help