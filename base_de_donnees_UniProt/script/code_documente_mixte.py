# -*- coding: utf-8 -*-
"""
Created on Thu June 29 07:51:50 2026

@author: meren
"""
import argparse
import json
from pathlib import Path
import re
import time
import pandas as pd
import requests

# Ce code vous permet de choisir le format du fichier d'entree (soit xlsx, soit txt). Pour modifier le chemin du fichier xlsx cela ce passe ligne 23, pour le fichier txt cela ce passe ligne 224.
# lors de l'execution du code, si vous avez un fichier xlsx choisissez 1, si vous avez un fichier txt choisissez 2.


def fichier_xlsx():
    # =====================================================
    # 1. Fichiers
    # creer 3 chemins distincts afin de recuperer des fichiers utiles au code
    # =====================================================
    input_file = Path(
        "~/Documents/remod_diffchip/Stage_bio_info/base_de_donnees_UniProt/donnees/fichier_test_raccourci_Gene_ID.xlsx"
    ).expanduser()
    output_file = Path(
        "~/Documents/remod_diffchip/Stage_bio_info/base_de_donnees_UniProt/resultats/uniprot_localisation_from_GeneID.xlsx"
    ).expanduser()
    json_dir = Path(
        "~/Documents/remod_diffchip/Stage_bio_info/base_de_donnees_UniProt/resultats/uniprot_json_localisation"
    ).expanduser()

    json_dir.mkdir(
        exist_ok=True, parents=True
    )  # cree le dossier json_dir s'il n'existe pas deja

    if json_dir.exists():
        print(f" Dossier JSON existe : {json_dir}")

    organisme = 9606  # a changer si l'on souhaite interroger un autre organisme (organismes les plus utilises : mammal [homo-Sapiens = 9606, mus musculus = 10090], fish : [zebrafish = 7955], amphibian[xenopus laevis = 8355], yeast[saccharomyces = 4930], bacterium[escherichia coli = 562])

    # Recuperation du nom de l'organisme via UniProt
    print(f"recherche du nom de l'organisme : {organisme}")
    try:
        org_res = requests.get(
            f"https://rest.uniprot.org/taxonomy/{organisme}"
        )
        data_org = org_res.json()
        nom_organisme = data_org.get("scientificName", f"ID {organisme}")
    except Exception:
        nom_organisme = f"ID {organisme}"  # solution de secours si le reseau est problematique
    print(f"Nom de l'organisme : {nom_organisme}")

    # =====================================================
    # 2. Lecture du fichier (DataFrame)
    #    On utilise la colonne 'Gene ID' comme identifiant de gène
    # =====================================================
    df = pd.read_excel(
        input_file
    )  # permet de lire le fichier excel et le convertit sous forme de dataframe

    if (
        "Gene ID" not in df.columns
    ):  # si la colonne "Gene ID" n'est pas dans les colonnes du DataFrame alors renvoie une erreur
        raise ValueError(
            f"La colonne 'Gene ID' n'existe pas dans le fichier. Colonnes disponibles : {list(df.columns)}"
        )

    gene_ids = (
        df["Gene ID"].dropna().astype(str).unique().tolist()
    )  # genere une liste en format str de toutes les lignes differentes de la colonne demandee et la supprime des que l'information du Gene ID est manquante
    print(f"Nombre de Gene ID uniques à interroger : {len(gene_ids)}")

    # =====================================================
    # 3. Requête UniProt pour récupérer la localisation
    #    On suppose que GeneID correspond au symbole de gène humain
    #    (sinon il faudra adapter le champ de requête : par ex. id: si c'est un UniProt ID)
    # =====================================================
    def query_uniprot_localisation(gene_ids, save_json=True):
        base_url = "https://rest.uniprot.org/uniprotkb/search"
        fields = [
            "accession",  # c'est l'identifiant unique de l'entree UniProt en format str
            "id",  # c'est l'identifiant unique en format str
            "gene_primary",  # recupere le nom du gene principal de l'entree UniProt en format str
            "cc_subcellular_location",  # recupere la localisation sous-cellulaire de l'entree UniProt en format str
            "go_c",  # recupere les annotations GO de l'entree UniProt en format str
            "cc_function",  # recupere la fonction de l'entree UniProt en format str
        ]  # liste des champs que l'on souhaite recuperer depuis UniProt

        results = (
            []
        )  # liste vide qui va contenir les resultats de la requete

        for gene in gene_ids:
            # si GeneID = symbole de gene humain (ex: SLC2A1), on utilise gene:
            queries = [
                f"gene:{gene} AND organism_id:{organisme} AND reviewed:true",
                f"gene:{gene} AND organism_id:{organisme}",
                f"{gene} AND organism_id:{organisme}",
            ]  # liste des requetes a tester en format str pour chaque gene_id, en filtrant par organisme humain et en priorisant les entrees revues

            entry = None
            data_to_save = None

            for q in queries:  # prend le gene donne par queries
                params = {
                    "query": q,  # nom du gene
                    "fields": ",".join(
                        fields
                    ),  # appelle fields pour la liste des donnees Uniprot
                    "format": "json",
                    "size": 1,
                }  # cree un dictionnaire params qui contient la requete q, les champs a recuperer, le format de sortie et la taille de la reponse

                try:
                    r = requests.get(base_url, params=params, timeout=15)
                except requests.exceptions.RequestException as e:
                    print(f"Erreur réseau pour {gene} : {e}")
                    break  # si il y a une erreur reseau alors affiche l'erreur et sort de la boucle

                if r.status_code == 200:
                    data = (
                        r.json()
                    )  # cree un dictionnaire data qui prend en compte ce que renvoie l'appel HTTP de r en format "json"
                    hits = data.get(
                        "results", []
                    )  # hits va contenir ce que va trouver get dans le dictionnaire data a "results" sinon renvoie une liste vide
                    if hits:
                        entry = hits[
                            0
                        ]  # entry prend la premiere valeur de hits en format dictionnaire
                        data_to_save = (
                            data  # data_to_save prend le dictionnaire data en format dictionnaire
                        )
                        break  # si entry est trouve alors sort de la boucle

                else:
                    print(
                        f"Erreur UniProt {r.status_code} pour {gene}"
                    )  # sinon affiche une erreur pour le gene demande en indiquant lequel

                time.sleep(0.3)

            if (
                save_json and data_to_save
            ):  # si save_json est vrai et que data_to_save n'est pas vide alors sauvegarde le dictionnaire data_to_save dans un fichier json
                with open(
                    json_dir / f"{gene}.json", "w", encoding="utf-8"
                ) as f:
                    json.dump(data_to_save, f, indent=2, ensure_ascii=False)

            # ------------- Extraction des informations -----------------
            uniprot_id = ""
            accession = ""
            confirmed_loc_list = (
                []
            )  # localisation "consensus" UniProt type str
            er_subtype_list = (
                []
            )  # sous-types ER (optionnel, filtre) type str
            go_locterms = (
                []
            )  # GO cellular component (putative) type str
            function_texts = []  # fonction type str

            if (
                entry is not None
            ):  # on verifie que results est bien dans le dictionnaire data
                accession = entry.get(
                    "primaryAccession", ""
                )  # cherche la requete dans entry et la met dans accession sinon met une entree vide en format str
                uniprot_id = entry.get(
                    "uniProtkbId", ""
                )  # cherche la requete dans entry et la met dans uniprot_id sinon met une entree vide en format str

                # Commentaires UniProt (fonction, localisation)
                for comment in entry.get(
                    "comments", []
                ):  # prend chaque comment ou entry a la valeur demandee
                    ctype = comment.get(
                        "commentType"
                    )  # donne la valeur de commentType sinon met une entree vide dans un format str

                    if ctype == "SUBCELLULAR LOCATION":
                        for loc in comment.get(
                            "subcellularLocations", []
                        ):  # prend les localisations pour chaque comment qui a un subcellularLocations sinon prend une liste vide
                            loc_txt = loc.get("location", {}).get(
                                "value", ""
                            )  # donne la valeur de location sinon met une entree vide
                            if (
                                loc_txt
                            ):  # si loc_txt n'est pas vide alors ajoute loc_txt a la liste confirmed_loc_list
                                confirmed_loc_list.append(loc_txt)
                                # exemple de detection plus fine pour ER
                                if (
                                    "endoplasmic reticulum"
                                    in loc_txt.lower()
                                ):  # si endoplasmic reticulum est dans loc_txt alors ajoute loc_txt a la liste er_subtype_list
                                    er_subtype_list.append(loc_txt)

                    if (
                        ctype == "FUNCTION"
                    ):  # si ctype est egal a FUNCTION alors prend les textes pour chaque comment qui a un texts sinon prend une liste vide
                        for txt in comment.get(
                            "texts", []
                        ):  # prend les textes pour chaque comment qui a un texts sinon prend une liste vide
                            val = txt.get(
                                "value", ""
                            )  # donne la valeur de txt sinon met une entree vide
                            if (
                                val
                            ):  # si val n'est pas vide alors ajoute val a la liste function_texts
                                function_texts.append(val)  # format str

                # GO cellular component pour localisation putative
                for xref in entry.get(
                    "uniProtKBCrossReferences", []
                ):  # prend les xref pour chaque fois que la demande a ete confirmee dans entry
                    if xref.get("database") == "GO":
                        # GO term de type C (cellular component)
                        # inclu dans prop_type, chaque
                        prop_type = {
                            p.get("value", "")
                            for p in xref.get("properties", [])
                            if p.get("key") == "aspect"
                        }  # donne la valeur de chaque propriete qui a pour cle "aspect" sinon met une entree vide
                        if (
                            "C" in prop_type
                        ):  # si "C" est dans prop_type alors ajoute a la liste go_locterms le GO ID et le nom du terme
                            go_id = xref.get(
                                "id", ""
                            )  # go_id renvoie du format str
                            term_name = ""
                            for p in xref.get(
                                "properties", []
                            ):  # prend chaque propriete de xref
                                if (
                                    p.get("key") == "term"
                                ):  # si la cle de p est "term" alors met la valeur de p dans term_name sinon met une entree vide
                                    term_name = p.get("value", "")
                            if (
                                term_name
                            ):  # si term_name n'est pas vide alors ajoute a la liste go_locterms le GO ID et le nom du terme
                                go_locterms.append(f"{go_id} ({term_name})")
            else:
                print(f"I can't do anything because entry is {entry}")

            # Assemblage des champs texte
            confirmed_loc = (
                "; ".join(sorted(set(confirmed_loc_list)))
                if confirmed_loc_list
                else ""
            )  # si confirmed_loc_list n'est pas vide alors join les valeurs de la liste triee et sans doublons avec un "; " sinon met une entree vide
            er_subtype = (
                "; ".join(sorted(set(er_subtype_list)))
                if er_subtype_list
                else ""
            )  # si er_subtype_list n'est pas vide alors join les valeurs de la liste triee et sans doublons avec un "; " sinon met une entree vide
            putative_loc = (
                "; ".join(sorted(set(go_locterms))) if go_locterms else ""
            )  # si go_locterms n'est pas vide alors join les valeurs de la liste triee et sans doublons avec un "; " sinon met une entree vide
            function_str = (
                " ".join(function_texts) if function_texts else ""
            )  # si function_texts n'est pas vide alors join les valeurs de la liste avec un " " sinon met une entree vide

            results.append({
                "Gene ID": gene,
                "Uniprot ID": uniprot_id,
                "Confirmed localization (UniProt consensus)": confirmed_loc,
                "ER location subtype": er_subtype,
                "Putative localization GO annotation": putative_loc,
                "Function": function_str,
                "UniProt accession": accession,
            })  # ajoute a la liste results un dictionnaire de str avec les valeurs demandees pour chaque gene

            time.sleep(0.3)

        return pd.DataFrame(
            results
        )  # renvoie un DataFrame avec les resultats de la liste results

    # =====================================================
    # 4. Pipeline principal
    # =====================================================
    df_loc = query_uniprot_localisation(
        gene_ids, save_json=True
    )  # appelle la fonction query_uniprot_localisation avec la liste des gene_ids et save_json a True pour sauvegarder les fichiers json

    # On peut soit :
    #    - Sauvegarder uniquement le tableau localisation
    #    - Ou le fusionner avec le fichier d'origine
    # Ici, on ne garde que les colonnes demandees dans la question

    cols_finales = [
        "Gene ID",
        "Uniprot ID",
        "Confirmed localization (UniProt consensus)",
        "ER location subtype",
        "Putative localization GO annotation",
        "Function",
    ]  # liste des colonnes que l'on souhaite garder dans le DataFrame final

    df_output = df_loc[
        cols_finales
    ]  # renvoie un DataFrame avec les colonnes demandees dans cols_finales

    # =====================================================
    # 5. Export Excel
    # =====================================================
    df_output.to_excel(
        output_file, index=False, engine="openpyxl"
    )  # exporte le DataFrame df_output dans un fichier excel avec le nom de fichier output_file, sans les index et en utilisant le moteur openpyxl

    if json_dir.exists():
        print(f" Dossier JSON existe : {json_dir}")

    print(f"✅ Fichier exporté : {output_file}")
    print(f"📁 JSON UniProt sauvegardés dans : {json_dir}")
    print(
        f"voici les résultats demandé pour l'organisme {nom_organisme}: ID {organisme}"
    )


def fichier_txt():
    # =====================================================
    # 1. Fichiers
    # =====================================================
    # Definition des chemins de fichiers et dossiers
    input_file = Path(
        "~/Documents/remod_diffchip/Stage_bio_info/base_de_donnees_UniProt/donnees/list_gene_name.txt"
    ).expanduser()
    output_file = Path(
        "~/Documents/remod_diffchip/Stage_bio_info/base_de_donnees_UniProt/resultats/uniprot_localisation_from_GeneID.xlsx"
    ).expanduser()
    json_dir = Path(
        "~/Documents/remod_diffchip/Stage_bio_info/base_de_donnees_UniProt/resultats/uniprot_json_localisation"
    ).expanduser()

    json_dir.mkdir(
        exist_ok=True, parents=True
    )  # cree le dossier json_dir s'il n'existe pas deja

    if json_dir.exists():
        print(f"Dossier JSON existe : {json_dir}")

    organisme = 9606  # NCBI Taxonomy ID (9606 = Homo sapiens)

    # Recuperation du nom de l'organisme via UniProt
    print(f"Recherche du nom de l'organisme : {organisme}")
    try:
        org_res = requests.get(
            f"https://rest.uniprot.org/taxonomy/{organisme}", timeout=10
        )
        data_org = org_res.json()
        nom_organisme = data_org.get("scientificName", f"ID {organisme}")
    except Exception:
        nom_organisme = f"ID {organisme}"  # Solution de secours si le reseau est problematique

    print(f"Nom de l'organisme : {nom_organisme}")

    # =====================================================
    # 2. Lecture du fichier Texte (.txt)
    # =====================================================
    if not input_file.exists():
        raise FileNotFoundError(
            f"Le fichier spécifié est introuvable : {input_file}"
        )

    with open(input_file, "r", encoding="utf-8") as f:
        content = f.read()

    # re.split permet de separer par retour a la ligne, virgule, point-virgule ou espace
    raw_genes = re.split(r"[\s,;]+", content)

    # Nettoyage de la liste (suppression des elements vides et des doublons)
    gene_ids = sorted(list(set([g.strip() for g in raw_genes if g.strip()])))

    print(
        f"Nombre de noms de gènes/protéines uniques à interroger : {len(gene_ids)}"
    )

    # =====================================================
    # 3. Requête UniProt pour récupérer la localisation
    # =====================================================
    def query_uniprot_localisation(gene_ids, save_json=True):
        base_url = "https://rest.uniprot.org/uniprotkb/search"
        fields = [
            "accession",  # Identifiant unique de l'entree UniProt
            "id",  # Identifiant ID UniProt
            "gene_primary",  # Nom du gene principal
            "cc_subcellular_location",  # Localisation sous-cellulaire
            "go_c",  # Annotations GO (Composant cellulaire)
            "cc_function",  # Fonction de la proteine
        ]

        results = []

        for gene in gene_ids:
            queries = [
                f"gene:{gene} AND organism_id:{organisme} AND reviewed:true",
                f"gene:{gene} AND organism_id:{organisme}",
                f"{gene} AND organism_id:{organisme}",
            ]

            entry = None
            data_to_save = None

            for q in queries:
                params = {
                    "query": q,
                    "fields": ",".join(fields),
                    "format": "json",
                    "size": 1,
                }

                try:
                    r = requests.get(base_url, params=params, timeout=15)
                except requests.exceptions.RequestException as e:
                    print(f"Erreur réseau pour {gene} : {e}")
                    break

                if r.status_code == 200:
                    data = r.json()
                    hits = data.get("results", [])
                    if hits:
                        entry = hits[0]
                        data_to_save = data
                        break
                else:
                    print(f"Erreur UniProt {r.status_code} pour {gene}")

                time.sleep(0.3)

            if save_json and data_to_save:
                with open(
                    json_dir / f"{gene}.json", "w", encoding="utf-8"
                ) as f:
                    json.dump(data_to_save, f, indent=2, ensure_ascii=False)

            # ------------- Extraction des informations -----------------
            uniprot_id = ""
            accession = ""
            confirmed_loc_list = []
            er_subtype_list = []
            go_locterms = []
            function_texts = []

            if entry is not None:
                accession = entry.get("primaryAccession", "")
                uniprot_id = entry.get("uniProtkbId", "")

                # Commentaires UniProt (fonction, localisation)
                for comment in entry.get("comments", []):
                    ctype = comment.get("commentType")

                    if ctype == "SUBCELLULAR LOCATION":
                        for loc in comment.get("subcellularLocations", []):
                            loc_txt = loc.get("location", {}).get("value", "")
                            if loc_txt:
                                confirmed_loc_list.append(loc_txt)
                                if "endoplasmic reticulum" in loc_txt.lower():
                                    er_subtype_list.append(loc_txt)

                    if ctype == "FUNCTION":
                        for txt in comment.get("texts", []):
                            val = txt.get("value", "")
                            if val:
                                function_texts.append(val)

                # GO cellular component
                for xref in entry.get("uniProtKBCrossReferences", []):
                    if xref.get("database") == "GO":
                        prop_type = {
                            p.get("value", "")
                            for p in xref.get("properties", [])
                            if p.get("key") == "aspect"
                        }
                        if "C" in prop_type:
                            go_id = xref.get("id", "")
                            term_name = ""
                            for p in xref.get("properties", []):
                                if p.get("key") == "term":
                                    term_name = p.get("value", "")
                            if term_name:
                                go_locterms.append(f"{go_id} ({term_name})")
            else:
                print(f"Aucune entrée trouvée pour : {gene}")

            # Assemblage des champs texte
            confirmed_loc = (
                "; ".join(sorted(set(confirmed_loc_list)))
                if confirmed_loc_list
                else ""
            )
            er_subtype = (
                "; ".join(sorted(set(er_subtype_list)))
                if er_subtype_list
                else ""
            )
            putative_loc = (
                "; ".join(sorted(set(go_locterms))) if go_locterms else ""
            )
            function_str = (
                " ".join(function_texts) if function_texts else ""
            )

            results.append({
                "Gene ID": gene,
                "Uniprot ID": uniprot_id,
                "Confirmed localization (UniProt consensus)": confirmed_loc,
                "ER location subtype": er_subtype,
                "Putative localization GO annotation": putative_loc,
                "Function": function_str,
                "UniProt accession": accession,
            })

            time.sleep(0.3)

        return pd.DataFrame(results)

    # =====================================================
    # 4. Pipeline principal
    # =====================================================
    df_loc = query_uniprot_localisation(gene_ids, save_json=True)

    cols_finales = [
        "Gene ID",
        "Uniprot ID",
        "Confirmed localization (UniProt consensus)",
        "ER location subtype",
        "Putative localization GO annotation",
        "Function",
    ]

    df_output = df_loc[cols_finales]

    # =====================================================
    # 5. Export Excel
    # =====================================================
    df_output.to_excel(output_file, index=False, engine="openpyxl")

    print(f"\n✅ Fichier exporté : {output_file}")
    print(f"📁 JSON UniProt sauvegardés dans : {json_dir}")
    print(
        f"Résultats générés pour l'organisme {nom_organisme} (Taxonomy ID: {organisme})"
    )


def versions():
    print("voici le détail de toutes les versions, utilisées : \n")
    print("Pandas : 3.0.3")
    print("request : 2.34.2")
    print("pathlib : 1.0.1")
    print("openpyxl : 3.1.5")
    print("numpy : 2.5.1")
    print("gseapy : 0.12.0")
    print("python : 3.14.6")
    print("python-dateutil : 2.9.0.post0")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Requête UniProt pour la localisation sous-cellulaire depuis un fichier Excel ou TXT."
    )
    parser.add_argument(
        "-f",
        "--format",
        choices=["1", "2", "xlsx", "txt"],
        help="Format de fichier en entrée : 1 ou xlsx pour Excel, 2 ou txt pour Fichier Texte.",
    )

    args = parser.parse_args()

    # Si le format est passé via argparse, on l'utilise, sinon on bascule vers l'input()
    if args.format:
        choix = args.format.lower()
    else:
        choix = input("quel est le type de fichier en entré ? (1 ou 2) :")

    if choix in ["1", "xlsx"]:
        fichier_xlsx()
        versions()
    elif choix in ["2", "txt"]:
        fichier_txt()
        versions()
    else:
        print(
            "Impossible de lancer le script veuillez choisir un format de fichier"
        )