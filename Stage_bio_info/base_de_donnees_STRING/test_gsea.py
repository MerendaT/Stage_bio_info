# -*- coding: utf-8 -*-
"""
    Created on Tue Jul 20 2026
    @author: meren
"""

import requests
import json
import gseapy as gp
from pathlib import Path
import time
import pandas as pd # Bibliotheque indispensable pour manipuler le fichier Excel

# -----------------------------------------------------------------------------
# 1. CONFIGURATION DES CHEMINS DE SORTIE
# -----------------------------------------------------------------------------

# Definition du chemin d'acces au dossier qui va contenir tous les fichiers Markdown (.md)
out_dir = Path("~/Documents/remod_diffchip/Stage_bio_info/base_de_donnees_STRING/string_reports")
# La methode mkdir cree le dossier s'il n'existe pas encore. parents=True permet de creer les dossiers intermediaires si necessaire.
out_dir.mkdir(exist_ok=True, parents=True)

# Definition du chemin absolu menant a ton fichier d'entree au format Excel (.xlsx)
EXCEL_FILE = Path("~/Documents/remod_diffchip/Stage_bio_info/base_de_donnees_STRING/test_ms_uniport.xlsx")

# Specification de la colonne precise que Pandas doit lire a l'intérieur de la feuille Excel
UNIPROT_COLUMN = "PG,Genes"

# Initialisation d'un dictionnaire vide destine a stocker la liste des partenaires d'interactions 
# pour chaque proteine identifiee. Format attendu : { "Nom_Proteine": ["Partenaire1", "Partenaire2", ...] }
dictionnaire_enrichissement = {}

# -----------------------------------------------------------------------------
# 2. ENTRÉES UTILISATEUR
# -----------------------------------------------------------------------------

# Demande a l'utilisateur de saisir le numéro d'identification de la taxonomie (TaxID)
tax_input = input("TaxID de l'organisme, par défaut : 9606 (Humain) : ").strip()

# Si l'utilisateur valide directement en appuyant sur Entree, on applique le TaxID de l'humain (9606)
if tax_input == "":
    tax_id = 9606
else:
    # Utilisation d'un bloc try/except pour capter les erreurs si l'utilisateur saisit du texte au lieu d'un nombre
    try:
        tax_id = int(tax_input)
    except ValueError:
        print(" ID invalide. Utilisation du TaxID par défaut : 9606")
        tax_id = 9606

# -----------------------------------------------------------------------------
# 3. IDENTIFICATION DE L'ORGANISME VIA UNIPROT
# -----------------------------------------------------------------------------

print(f"\nRecherche du nom de l'organisme pour le TaxID {tax_id}")
try:
    # On interroge l'API officielle d'UniProt pour recuperer le nom scientifique associe au TaxID
    res_org = requests.get(f"https://rest.uniprot.org/taxonomy/{tax_id}", timeout=60)
    
    # Si le serveur répond positivement (code statut 200)
    if res_org.status_code == 200:
        # On extrait le nom scientifique depuis le format JSON, sinon on applique une valeur par défaut
        org_name = res_org.json().get("scientificName", f"ID {tax_id}")
    else:
        org_name = f"ID {tax_id}"
except Exception:
    # En cas d'erreur de reseau ou d'absence de réponse, on bascule sur l'ID brut pour eviter le crash
    org_name = f"ID {tax_id}"
print(f"Organisme retenu : {org_name}\n")
librairie_organism = gp.get_library_name(organism=f"{org_name}") #recupere toutes les librairie de gsea pour l'organisme

# -----------------------------------------------------------------------------
# 4. LECTURE DU FICHIER EXCEL VIA PANDAS
# -----------------------------------------------------------------------------

print(f"Lecture du fichier Excel : {EXCEL_FILE}")
try:
    # skiprows=1 permet d'ignorer la première ligne du fichier Excel
    df = pd.read_excel(EXCEL_FILE, skiprows=1)
    
    # Processus de traitement de la colonne cible :
    # 1. dropna() supprime toutes les cellules vides
    # 2. astype(str) convertit l'ensemble des donnees en chaines de texte
    # 3. unique() elimine les doublons de lignes dans le fichier
    # 4. tolist() transforme la colonne Pandas en une liste Python standard manipulable par une boucle
    liste_proteines = df[UNIPROT_COLUMN].dropna().astype(str).unique().tolist()
except Exception as e:
    print(f" Erreur lors de la lecture du fichier Excel : {e}")
    exit(1)

# Definition des points d'acces (endpoints) de l'API STRING-DB
# url_map permet d'obtenir un identifiant STRING valide a partir d'un nom de gene ou d'un ID UniProt
url_map = "https://string-db.org/api/json/get_string_ids"
# url_network permet de recuperer les proteines partenaires en interaction fonctionnelle
url_network = "https://string-db.org/api/json/network"

print(f"\nDébut du traitement de {len(liste_proteines)} protéines uniques...\n")

# -----------------------------------------------------------------------------
# 5. BOUCLE PRINCIPALE (TRAITEMENT LIGNE PAR LIGNE)
# -----------------------------------------------------------------------------

# On parcourt chaque ligne brute extraite de notre liste
for row in liste_proteines:
    brut = row.strip()
    
    # Securite pour eliminer les valeurs vides, les erreurs "nan" ou l'en-tête de la colonne repete
    if not brut or brut == "nan" or brut == "PG,Genes":
        continue

    # NETTOYAGE CHIRURGICAL DE L'IDENTIFIANT
    # Les fichiers de spectrometrie de masse regroupent souvent plusieurs proteines sur une ligne
    # Si la cellule contient des points-virgules ou des virgules, on ne conserve que la première proteine listee
    if ";" in brut:
        brut = brut.split(";")[0].strip()
    if "," in brut:
        brut = brut.split(",")[0].strip()
        
    # Si l'identifiant est au format d'accession complet UniProt (ex: sp|P04637|P53_HUMAN),
    # on decoupe la chaine au niveau des barres verticales '|' pour extraire uniquement l'ID central 
    if "|" in brut:
        parts = brut.split("|")
        prot_name = parts[1].strip() if len(parts) >= 2 else brut
    else:
        # Si la chaine est deja propre, on l'assigne directement
        prot_name = brut

    print(f" Connexion à STRING-DB pour : {prot_name}")
    
    # Reinitialisation systematique des listes de resultats a CHAQUE début de cycle 
    # pour eviter que les donnees de la proteine precedente ne débordent sur la suivante
    results = []
    liste_preferred_valides = []
    
    # --- ÉTAPE 1 : MAPPING (TRADUCTION DU NOM EN IDENTIFIANT STRING) ---
    # L'API STRING-DB requiert un dictionnaire de parametres specifiques pour faire correspondre le nom
    param_map = {
        "identifiers": prot_name, # Notre identifiant nettoye
        "species": tax_id, # Restreint la recherche au TaxID sélectionne
        "limit": 1 # On ne demande que le premier resultat le plus pertinent
    }
    
    string_id_valide = None
    try:
        # Appel de l'API avec un delai de rigueur de 10 secondes maximum (timeout)
        res_map = requests.get(url_map, params=param_map, timeout=60)
        
        # Si le serveur de STRING repond positivement
        if res_map.status_code == 200:
            donnees = res_map.json()
            
            # L'API get_string_ids renvoie obligatoirement une LISTE de dictionnaires.
            # On verifie que la liste contient bien au moins un resultat avant d'avancer.
            if donnees and isinstance(donnees, list) and len(donnees) > 0:
                # On extrait la valeur associee a la cle "stringId" presente dans le premier dictionnaire [0]
                string_id_valide = donnees[0].get("stringId")
    except Exception as e:
        print(f" Erreur lors du mapping de {prot_name} dans STRING : {e}")
       
    # Si STRING-DB ne renvoie aucun identifiant officiel correspondant (string_id_valide est reste à None),
    # l'instruction 'continue' force le script a abandonner le reste de ce cycle et a passer a la proteine suivante.
    if not string_id_valide:
        print(f" Impossible de mapper : {prot_name} dans STRING")
        continue
    
    print(f" Match trouvé dans STRING : {string_id_valide}")
    
    # --- ÉTAPE 2 : RECUPERATION DU RESEAU D'INTERACTIONS ---
    # Definition des parametres pour interroger le reseau fonctionnel
    api_params = {
        "identifiers": string_id_valide, # On envoie l'ID STRING officiel que l'on vient de valider à l'étape 1
        "species": tax_id,
        "required_score": 400, # Seuil de confiance de l'interaction (400 correspond à un niveau moyen)
        "limit": 15 # On restreint l'affichage aux 15 partenaires principaux les plus fiables
    }

    raw_json = None
    try:
        response = requests.get(url_network, params=api_params, timeout=60)
        if response.status_code == 200:
            # On convertit le texte brut reçu du serveur en un objet JSON (liste Python)
            raw_json = response.json()
        else:
            print(f" Erreur API Network {response.status_code} pour {prot_name}")
    except Exception as error:
        print(f" Erreur réseau lors de l'appel Network : {error}")

    # --- ÉTAPE 3 : TRAITEMENT ET FILTRAGE DES CHAINES ---
    if raw_json:
        print(f" -> {len(raw_json)} interaction(s) fonctionnelle(s) trouvée(s) !")
        
        # Initialisation de la structure du tableau Markdown pour le futur rapport
        block = (
            f"### Réseau d'interactions pour le gène : {prot_name}\n"
            f"Identifiant STRING officiel : `{string_id_valide}`\n\n"
            "| Protéine A (Cible) | Protéine B (Partenaire) | Score de confiance total |\n"
            "| :--- | :--- | :--- |\n"
        )
        
        # On passe au crible chaque interaction renvoyee par le fichier JSON
        for item in raw_json:
            # Recuperation du nom preferentiel de la proteine source et de son partenaire detecte
            p_a = item.get("preferredName_A", prot_name)
            p_b = item.get("preferredName_B", "")
            score = item.get("score", 0)
            
            # Incrémentation du tableau Markdown avec les données récupérées
            block += f"| {p_a} | **{p_b}** | {score} |\n"
            
            # Si le partenaire (p_b) possède un nom valide et qu'il ne s'agit pas de la proteine elle-même,
            # on l'enregistre dans notre liste locale de partenaires
            if p_b and p_b != prot_name:
                liste_preferred_valides.append(p_b)
                
        # On ajoute le bloc textuel complet du tableau a notre liste de resultats
        results.append(block)
        
        # Pause obligatoire de 0.2 seconde entre chaque appel pour eviter d'etre banni par les serveurs de STRING-DB (protection anti-DDOS)
        time.sleep(0.2)

    # Si la variable 'results' est restee vide (aucune interaction retournee par STRING)
    if not ... or not results:
        results.append(f"Aucune interaction valide trouvée dans STRING pour {prot_name} (TaxID: {tax_id}).")

    # --- ÉTAPE 4 : REMPLISSAGE DU DICTIONNAIRE GLOBAL ---
    if liste_preferred_valides:
        # L'utilisation de list(set(...)) est une astuce bio-informatique permettant d'eliminer 
        # d'un seul coup tous les doublons de genes partenaires accumules pendant la boucle
        dictionnaire_enrichissement[prot_name] = list(set(liste_preferred_valides))

    # --- ÉTAPE 5 : ÉCRITURE DU FICHIER MARKDOWN INDIVIDUEL (DANS LA BOUCLE) ---
    # La variable safe_name supprime les caracteres speciaux de l'identifiant pour generer un nom de fichier sain
    safe_name = "".join([c if c.isalnum() else "_" for c in prot_name])
    out_txt = out_dir / f"{safe_name}.md"

    try:
        # Ouverture du fichier en mode ecriture ("w") avec encodage UTF-8 universel
        with open(out_txt, "w", encoding="utf-8") as f_txt:
            f_txt.write(f"# RÉSULTATS DE LA RECHERCHE STRING-DB\n\n")
            f_txt.write(f"## Protéine cible : {prot_name}\n")
            f_txt.write(f"## Organisme : {org_name} (TaxID: {tax_id})\n\n")
            f_txt.write("---\n\n")
            
            # On ecrit tous les blocs de tableaux d'interactions stockes dans 'results'
            for result_block in results:
                f_txt.write(result_block + "\n")
                
        print(f" Fichier généré avec succès : {out_txt.name}\n")
    except Exception as e:
        print(f" Impossible d'écrire le fichier pour {prot_name} : {e}\n")

# -----------------------------------------------------------------------------
# 6. SAUVEGARDE DU DICTIONNAIRE GLOBAL (EN DEHORS DE LA BOUCLE)
# -----------------------------------------------------------------------------

# Une fois que la boucle 'for' a traite la totalite des proteines du fichier Excel on definit le chemin de sortie pour enregistrer notre base de donnees structuree au format JSON
dict_output_path = out_dir.parent / "dictionnaire_enrichissement.json"

enrichissement_gsea = gp.enrich(
    gene_list = dictionnaire_enrichissement,
    gene_sets = (f"{librairie_organism}"),
    background = None, 
    outdir = None, 
    verbose = None)

       
try:
    with open(dict_output_path, "w", encoding="utf-8") as f_dict:
        # json.dump convertit le dictionnaire Python en texte JSON structure
        # indent=4 permet de rendre le fichier JSON lisible par un humain (sauts de lignes et espaces)
        # ensure_ascii=False permet de conserver les caracteres accentues intacts
        json.dump(dictionnaire_enrichissement, f_dict, indent=4, ensure_ascii=False)
        
    print("-----------------------------------------------------------------")
    print(" TRAITEMENT GLOBAL TERMINÉ AVEC SUCCÈS")
    print(f" Les rapports individuels (.md) sont ici : {out_dir}")
    print(f" Le dictionnaire d'interactions complet (.json) est ici : {dict_output_path}")
    print("-----------------------------------------------------------------")
except Exception as e:
    print(f" Erreur lors de la sauvegarde du dictionnaire JSON final : {e}")