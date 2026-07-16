# Stage de Bio-Informaique

# __1. Sommaire__

|                             |
|:---------------------------:|
|[__Contexte__](#Contexte)    |
|[__Détails__](#détails)      |
|[__Conclusion__](#conclusion)|


## __2. Contexte__
### 2.1 Contexte Institutionnel : Institut de Biologie Intégrative de la Celule (I2BC)

Mon stage s'est déroulé au sein de l'Institut de Biologie Intégrative de la Celule (I2BC), une Unité Mixte de Recherche (UMR) d'envergure internationale placée sous la tutelle du CNRS, du CEA et de l'Université Paris-Saclay. Situé sur le campus de Gif-Sur-Yvette, cet institut regroupe de nombreuses équipes de recherche qui explorent les mécanismes fondamentaux du vivant,de la structure des macromolécules jusqu'au fonctionnement global des cellules et des organismes.

La recherche moderne génère une quantité massive de données surtout avec le séquençage à haut débit et l'imagerie. C'est pour quoi l'I2BC intègre pleinement la bio-informatique au coeur de ses activités, combinant l'informatique, les statistiques et la biologie pour analyser et interpréter ces données complexes.

J'ai eu l'opportunité d'intégrer l'équipe de la Bio-Informaticienne Emilie Drouineau, qui concentre ses recherches sur le phasing des nucléosomes et sur l'impact de la perte de fonction des protéines du complexe BAF sur la régulation de la chromatine.

### 2.2 La problématique scientifique et les besoins de l'équipe
Création d'un code python pour permettre l'interrogation de la base de données publique appelé STRING, pour récupérer les listes protéiques appartenant à des complexes d'intérêts afin de réaliser dans un deuxième temps de l'enrichissement de complexe protéique à partir de résultats de spectro masse avec le logiciel GSEAPY. 

Le code doit être reproductible ainsi la documentation ainsi que les versions utilisées seront implémentées dans les code et l'utilisation de git est de rigueur afin de voir l'avancer de mes travaux.

### 2.3 Comment ai-je fait pour réaliser ces tâches ?

Tout d'abord, un biologiste m'a demandé de vérifier et d'améliorer son code. Il consistait à prendre en lecture un fichier excel, comprenant des noms de protéines, afin de retrouver toutes leurs particularités au seins de la base de données UniProt grâce à une requête API. Vous pouvez retrouver les deux code au sein du dossier "base_de_donnees_UniProt"

La deuxième tâche m'a permit d'apprendre à effectuer en toute autonomie une requête API de STRING, afin de rechercher d'avantage de données protéiques. Cependant, cela n'a pas été facile, car il a fallu aller chercher directement depuis le web dans la base de données STRING, afin de savoir les identifiants exacts pour répondre au besoin demandé. Ensuite le code est simple d'utilisation il suffit de rentrer le nom d'un gène par exemple INS pour l'insuline puis, si l'on connait déjà le nom de la protéine il nous suffit de la marquer dans le filtre sinon de simplement laissez un vide et le code se chargera de tout. Vous n'aurez plus qu'à chercher dans le dossier final au format markdown ce qui vous intéresse. Ce code se trouve dans "base_de_donnees_STRING" et se nomme "code_requete_API_STRING.py".

Pour ma dernière tâche, 

## __3. L'apport de ce stage__
* __Python__
    * amélioration et documentation de code
        * _permet de consolider mes bases_
        * _permet d'aider à une meilleure compréhension du code pour ses utilisateurs futur_
    * uniformisation de fichier type base de données
        * _amélioration de la comparaison de fichier_
        * _priorisation de certains critères de selection_
    * automatisation de la determination de complexe protéiques avec extraction de base de données

## __4. Conclusion__