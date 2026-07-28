# Rapport de Stage : Automatisation de Requêtes d'Enrichissement de Complexes Protéiques en Bio-informatique

---

## 1. Sommaire

| Sections | Description |
| :--- | :--- |
| [**2. Contexte**](#2-contexte) | Présentation du cadre institutionnel, de la problématique et de la démarche. |
| [**3. L'apport de ce stage**](#3-lapport-de-ce-stage) | Compétences techniques développées et valorisation des livrables. |
| [**4. Comparaison des Technologies d'Environnement**](#4-comparaison-des-technologies-denvironnement) | Analyse comparative de Pixi, Docker et des Machines Virtuelles. |
| [**5. Tableau des Versions et Canaux**](#5-tableau-des-versions-et-canaux) | Traçabilité et reproductibilité des outils et dépendances du projet. |
| [**6. Conclusion**](#6-conclusion) | Bilan de l'expérience, apports personnels et perspectives. |

---

## 2. Contexte

### 2.1 Contexte Institutionnel : Institut de Biologie Intégrative de la Cellule (I2BC)

Mon stage s'est déroulé au sein de l'[Institut de Biologie Intégrative de la Cellule (I2BC)](https://www.i2bc.paris-saclay.fr/), une Unité Mixte de Recherche (UMR 9198) d'envergure internationale. Placé sous la triple tutelle du **CNRS**, du **CEA** et de l'**Université Paris-Saclay**, cet institut est implanté sur le campus de Gif-sur-Yvette. L'I2BC rassemble de nombreuses équipes de recherche d'excellence dont l'objectif commun est d'explorer les mécanismes fondamentaux du vivant, allant de la structure atomique des macromolécules jusqu'au fonctionnement global et intégré des cellules et des organismes.

À l'ère de la biologie quantitative, la recherche génère une quantité massive de données, portée notamment par l'essor des technologies de séquençage à haut débit (NGS) et de l'imagerie cellulaire avancée. Face à ce déluge de données, la **bio-informatique** est devenue un pilier incontournable à l'I2BC. Elle combine l'informatique, les statistiques et la biologie pour stocker, traiter, analyser et interpréter ces données complexes.

J'ai eu l'opportunité d'intégrer l'équipe de recherche dirigée par **Matthieu Gérard**, en travaillant sous la supervision directe d'**Émilie Drouineau**, responsable bio-informatique de l'équipe. Les axes de recherche du groupe se concentrent sur le **phasing des nucléosomes** et sur l'impact de la perte de fonction des protéines du **complexe BAF** (un remodeleur de la chromatine essentiel) sur la régulation de la chromatine et l'expression génique.

### 2.2 La problématique scientifique et les besoins de l'équipe

Dans le cadre des analyses en spectrométrie de masse (MS) réalisées par l'équipe, l'identification des protéines ne suffit pas à comprendre les mécanismes biologiques sous-jacents. Il est nécessaire de contextualiser ces résultats en identifiant si ces protéines interagissent ou appartiennent à des complexes macromoléculaires connus.

L'objectif principal de mon stage a été la **création d'un pipeline Python reproductible** permettant d'interroger automatiquement la base de données publique **STRING** (Search Tool for the Retrieval of Interacting Genes/Proteins). Ce script doit extraire les listes protéiques appartenant à des complexes d'intérêt afin de réaliser, dans un second temps, une analyse d'enrichissement de complexes protéiques à partir des résultats de spectrométrie de masse en s'appuyant sur la bibliothèque logicielle **GSEAPY** (Gene Set Enrichment Analysis in Python).

Une contrainte majeure de ce projet résidait dans la **reproductibilité de la recherche**. Pour garantir qu'un chercheur puisse réexécuter le pipeline à l'identique dans le futur, j'ai dû porter une attention stricte à :
* La documentation fine du code (docstrings, commentaires rigoureux).
* Le suivi strict du versionnage des dépendances logicielles via les fichiers de verrouillage.
* L'utilisation systématique de **Git** pour le suivi de versions du code source, favorisant ainsi le travail collaboratif et la transparence des développements.

### 2.3 Démarche de réalisation et méthodologie

#### Étape 1 : Optimisation et refactorisation du script UniProt
Ma première mission a consisté à auditer, documenter et améliorer un script existant développé initialement par un biologiste de l'équipe. Ce programme prenait en entrée un fichier Excel contenant une liste de noms de protéines pour en récupérer les caractéristiques (annotations, fonctions, structures) au sein de la base de données **UniProt** via des requêtes API. 

Mon rôle a été de structurer ce code en modules, d'optimiser la gestion des exceptions lors des appels réseaux et de fiabiliser l'écriture des fichiers de sortie. Les codes d'origine et optimisés sont disponibles dans le répertoire [`base_de_donnees_UniProt`](https://github.com/MerendaT/Stage_bio_info/tree/main/base_de_donnees_UniProt).

#### Étape 2 : Autonomie et requêtage de l'API STRING
La seconde tâche a consisté à concevoir de manière autonome un script d'interrogation de l'API de la base de données STRING. Cette étape a nécessité une phase d'exploration et d'évaluation comparative technique des différentes bases de données d'interactions existantes. L'analyse et les justifications qui ont mené au choix final de STRING sont documentées dans le fichier [`comparaison_base_de_donnees.md`](https://github.com/MerendaT/Stage_bio_info/comparaison_base_de_donnees.md).


#### Étape 3 : Automatisation de l'enrichissement protéique et traitement des données MS
La dernière phase de mon projet consistait à interconnecter les outils développés. Le script d'appel API a été adapté pour traiter un fichier de résultats de spectrométrie de masse au format `.xlsx`. 

Il convient de préciser qu'un tel fichier Excel n'est pas une donnée brute : les spectromètres de masse génèrent initialement des signaux (spectres complexes). Ces signaux bruts passent par un processus rigoureux de comparaison avec des bases de données de spectres théoriques pour identifier et scorer les peptides. Ensuite, des outils bio-informatiques dédiés réalisent une analyse différentielle entre les conditions contrôles et les conditions d'intérêt (incluant des étapes cruciales de filtrage, de normalisation et de calculs statistiques) afin d'aboutir au tableau final `.xlsx` des protéines différentiellement exprimées.

Le programme extrait automatiquement les identifiants pertinents de ce fichier, interroge STRING pour obtenir le réseau d'interactions, puis applique un filtre strict sur le score de confiance des données renvoyées par l'API. À partir de l'identifiant d'interaction récupéré, le script effectue une seconde requête spécifique aux enrichissements protéiques afin d'isoler toutes les protéines partenaires liées fonctionnellement à la protéine initiale. 

**C'est à ce stade que le script s'appuie sur la bibliothèque GSEAPY pour exécuter l'analyse d'enrichissement (GSEA - Gene Set Enrichment Analysis), permettant de valider statistiquement la surreprésentation des complexes protéiques identifiés.**

Le livrable final est un dictionnaire Python structuré sous la forme :
`{ protéine_principale: ["protéine_partenaire_1", "protéine_partenaire_2", ...] }`

Ce dictionnaire sert ensuite de matrice d'entrée directe pour les analyses fonctionnelles globales. Le code est consultable dans le script [`enrichissement_annotation.py`](https://github.com/loquo44/Stage_bio_info/tree/main/base_de_donnees_STRING/enrichissement/script/enrichissement_annotation.py).
#### Visualisation globale du pipeline et des interactions
![Image](schema_recap_code.odp)
---

## 3. L'apport de ce stage

Ce stage m'a permis de faire le pont entre la théorie informatique et les applications biologiques concrètes, développant ainsi une double compétence en développement logiciel et en analyse de données biologiques.

### 3.1 Compétences en Python (Cœur du développement)
* **Amélioration, refactorisation et documentation de code :** Ce travail m'a permis de consolider mes bases en programmation orientée objet et fonctionnelle. Documenter le code selon les standards (PEP 8) garantit une maintenance et une réutilisation simplifiées par les futurs membres du laboratoire.
* **Uniformisation de fichiers de bases de données :** J'ai appris à standardiser des structures de données hétérogènes, facilitant les opérations de comparaison et de fusion de fichiers, tout en implémentant des critères de sélection stricts pour prioriser les données biologiques de haute confiance.
* **Automatisation des processus et manipulation de formats standardisés :** L'extraction automatisée et le parsing de données web au format TSV et [JSON](https://json-schema.org/) (en s'appuyant sur les spécifications et schémas officiels de ce format d'échange) ont permis de transformer une tâche manuelle chronophage en un pipeline de calcul reproductible et instantané.

### 3.2 Compétences en Bash et gestion d'environnement
* **Maîtrise de la ligne de commande Linux :** L'utilisation quotidienne du terminal m'a permis de manipuler efficacement les arborescences de fichiers complexes via des chemins absolus et relatifs.
* **Interopérabilité des systèmes (OS) :** Développer et exécuter des scripts dans un environnement Linux m'a sensibilisé aux problématiques de portabilité du code entre les systèmes d'exploitation (Windows, macOS, Linux).
* **Gestion moderne des environnements avec Pixi :** J'ai configuré et déployé l'environnement de travail du projet à l'aide de Pixi, garantissant l'isolation complète des dépendances du projet sans impacter le système d'exploitation global.

---

## 4. Comparaison des Technologies d'Environnement

Dans le cadre de la reproductibilité de ce projet bio-informatique, le choix de l'outil de gestion d'environnement était crucial. Voici l'analyse comparative des technologies d'isolation pour justifier l'utilisation de **Pixi** face à **Docker** et aux **Machines Virtuelles**.

### 4.1 Pixi (Gestionnaire de paquets et d'environnements)
**Pixi** est un outil de gestion d'environnement moderne basé sur l'écosystème Conda/mamba et développé en Rust. Il permet d'installer des paquets et de figer des versions logicielles de manière isolée pour un projet donné.

* **Avantages :**
    * **Performance et rapidité :** Grâce à l'utilisation de liens physiques (*hard-links*), Pixi installe les dépendances presque instantanément sans dupliquer inutilement l'espace disque.
    * **Absence de privilèges administrateur :** Contrairement à Docker, Pixi s'exécute entièrement dans l'espace utilisateur. Il ne nécessite pas les droits `sudo`, ce qui est un atout majeur sur les serveurs de calcul partagés des instituts de recherche comme l'I2BC.
    * **Légèreté :** Il n'embarque pas de système d'exploitation virtuel. Il installe uniquement les binaires nécessaires (Python, bibliothèques C/C++, paquets spécifiques).
* **Inconvénients :**
    * **Isolation partielle :** Pixi isole l'environnement applicatif (les paquets), mais le code s'exécute directement sur le noyau de la machine hôte. Si un script dépend d'une fonctionnalité exclusive du noyau Linux, il ne fonctionnera pas de manière native sur Windows.

### 4.2 Docker (Conteneurisation)
**Docker** encapsule une application et l'ensemble de ses dépendances au sein d'un conteneur léger et isolé, partageant le noyau du système d'exploitation hôte.

* **Avantages :**
    * **Reproductibilité absolue :** Le conteneur embarque son propre mini-OS (souvent une base Alpine ou Ubuntu). Le comportement du code est rigoureusement identique sur la machine du développeur, sur le serveur de l'I2BC ou sur un cloud public.
    * **Standard industriel :** Docker et les conteneurs sont parfaitement adaptés au déploiement de pipelines complexes et lourds à grande échelle (souvent orchestrés via des gestionnaires de flux de travail comme Snakemake ou Nextflow).
* **Inconvénients :**
    * **Complexité et lourdeur :** La création d'images via un `Dockerfile` nécessite un temps d'apprentissage et de build non négligeable.
    * **Exigence de sécurité :** L'exécution du démon Docker requiert généralement des droits d'administration, ce qui pose de strictes contraintes de sécurité sur les infrastructures partagées en recherche.

### 4.3 Machines Virtuelles (Virtualisation complète)
Une **Machine Virtuelle (VM)** simule l'intégralité d'un matériel informatique (CPU, RAM, Disque) au-dessus d'un hyperviseur pour y exécuter un système d'exploitation invité complet.

* **Avantages :**
    * **Isolation étanche :** La VM est totalement coupée du système hôte, ce qui offre une sécurité maximale et permet de faire tourner des OS complètement différents.
* **Inconvénients :**
    * **Surconsommation de ressources :** Une VM nécessite l'allocation rigide d'une partie de la RAM et du CPU de la machine physique, ce qui ralentit considérablement l'ordinateur hôte.
    * **Lenteur opérationnelle :** Les temps de démarrage (boot de l'OS invité) et la taille des fichiers d'images (plusieurs Go) rendent cette technologie inadaptée pour de la simple gestion d'environnements de scripts légers au quotidien.

### Synthèse des technologies

| Critère | Pixi | Docker | Machine Virtuelle |
| :--- | :--- | :--- | :--- |
| **Niveau d'isolation** | Applicatif (Dépendances) | Conteneur (Processus/OS léger) | Matériel (OS Complet) |
| **Poids sur le disque** | Très léger (Mo à Go) | Moyen (Centaines de Mo à Go) | Très lourd (Plusieurs Go) |
| **Droits Administrateur**| Non requis (Utilisateur) | Requis (Démon root) | Requis pour l'installation |
| **Cas d'usage idéal** | Développement local rapide | Déploiement & Production | Isolation stricte d'OS |

> **Choix pour le stage :** L'utilisation de **Pixi** a été privilégiée pour ce projet car elle offrait le meilleur compromis entre la vitesse d'exécution en phase de développement local et la simplicité de déploiement pour les biologistes de l'équipe, sans se heurter aux restrictions de droits d'administration des machines du laboratoire.

---

## 5. Tableau des Versions Exactes et Canaux

Afin de garantir la réutilisabilité et la reproductibilité parfaite des scripts développés, l'environnement de développement a été figé de manière stricte. Les versions répertoriées ci-dessous correspondent aux versions exactes installées et extraites du fichier de verrouillage de Pixi (`pixi.lock`), garantissant ainsi qu'aucune mise à jour silencieuse ne vienne altérer le comportement du code.

Les canaux de paquets scientifiques de référence utilisés sont **Conda-Forge** et **Bioconda**.

| Outil / Bibliothèque | Version exacte (lock) | Canal de distribution | Rôle et justification dans le projet |
| :--- | :--- | :--- | :--- |
| **Python** | `3.12.3` | Conda-Forge | Langage de programmation principal du projet. |
| **Pandas** | `3.0.3` | Conda-Forge | Manipulation de structures de données tabulaires complexes (DataFrames). |
| **Numpy** | `2.5.1` | Conda-Forge | Calcul numérique optimisé et gestion des matrices. |
| **Requests** | `2.34.2` | Conda-Forge | Interrogation des API REST d'UniProt et de STRING (envoi et réception de requêtes HTTP). |
| **Openpyxl** | `3.1.5` | Conda-Forge | Lecture et écriture native des fichiers Excel (`.xlsx`) issus de l'analyse différentielle de MS. |
| **GSEAPY** | `1.3.0` | Bioconda / Conda-Forge | Bibliothèque d'analyse d'enrichissement de jeux de gènes (GSEA) adaptée à Python. |
| **Pathlib** | `1.0.1` | Conda-Forge | Gestion robuste et de niveau système des chemins de fichiers. |
| **Python-dateutil** | `2.9.0.post0` | Conda-Forge | Manipulation et parsing facilité des formats de dates. |

---

## 6. Conclusion

Ce stage effectué au sein de l'I2BC a été une expérience particulièrement formatrice et valorisante. Travailler sur des problématiques concrètes liées à la régulation de la chromatine et au complexe BAF m'a permis d'appréhender les exigences rigoureuses de la recherche publique en biologie moléculaire et cellulaire, tout en cernant la valeur ajoutée qu'apporte la bio-informatique au quotidien des chercheurs.

Sur le plan technique, j'ai pu consolider et élargir mes compétences en développement logiciel avec Python, en confrontant la théorie académique à la réalité du terrain : la gestion de données biologiques complexes, le traitement automatisé via des requêtes API (UniProt et STRING), et la création de formats de sortie clairs et directement exploitables par l'équipe. De plus, l'adoption d'outils modernes pour la gestion d'environnement comme **Pixi** et de gestion de version comme **Git** m'a sensibilisé de manière concrète aux bonnes pratiques DevOps et à la nécessité impérative de la reproductibilité scientifique.

Au-delà des aspects purement techniques, cette immersion au cœur d'une équipe de recherche m'a permis de gagner en autonomie, de développer ma rigueur méthodologique et d'améliorer mes compétences en communication scientifique en adaptant mes outils aux besoins d'utilisateurs non-informaticiens. Ce stage confirme pleinement mon intérêt pour ce domaine et renforce mon souhait de poursuivre ma spécialisation en bio-informatique, à l'interface de la science des données et de la découverte biologique.