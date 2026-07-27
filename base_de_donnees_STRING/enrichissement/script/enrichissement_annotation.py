# -*- coding: utf-8 -*-
"""
Créé le mardi 20 juillet 2026
@auteur : merenda teo

Description :
Ce script permet de lire une liste de gènes/protéines depuis un fichier Excel,
d'interroger l'API de STRING-DB en parallèle (Multi-threading) pour récupérer 
leurs réseaux d'interactions protéiques, de sauvegarder ces rapports au format 
Markdown et JSON, puis d'exécuter une analyse d'enrichissement fonctionnel (GSEA) 
via la librairie GSEApy avec génération de graphiques (dotplot).
"""

from concurrent.futures import ThreadPoolExecutor, as_completed
import json
from pathlib import Path
import threading

# Importation des librairies tierces
import gseapy as gp
from gseapy import dotplot
import matplotlib.pyplot as plt
import pandas as pd
import requests

# -----------------------------------------------------------------------------
# 1. CONFIGURATION DES CHEMINS ET CONSTANTES
# -----------------------------------------------------------------------------

BASE_DIR = Path(
    "~/Documents/remod_diffchip/Stage_bio_info/base_de_donnees_STRING/enrichissement/resultat/"
).expanduser()
OUT_DIR = BASE_DIR / "string_reports"
SCHEMAS_DIR = BASE_DIR / "schemas_enrichissement_png"
EXCEL_FILE = Path(
    "~/Documents/remod_diffchip/Stage_bio_info/base_de_donnees_STRING/enrichissement/donnees/donnees_ms_uniprot.xlsx"
).expanduser()

COLONNE_UNIPROT = "PG,Genes"

# Nombre maximum de threads en parallèle (à ajuster selon la connexion, 5 à 10 est idéal pour STRING API)
MAX_WORKERS = 8

# Verrou de sécurité pour éviter les conflits d'écriture entre threads
LOCK = threading.Lock()

OUT_DIR.mkdir(exist_ok=True, parents=True)
SCHEMAS_DIR.mkdir(exist_ok=True, parents=True)


# -----------------------------------------------------------------------------
# FONCTIONS
# -----------------------------------------------------------------------------
def traiter_un_gene(
    ligne: str,
    tax_id: int,
    colonne_genes: str,
    out_dir: Path,
    org_name: str,
    url_map: str,
    url_network: str,
    dictionnaire_enrichissement: dict,
    genes_excel_cleans: list,
):
    """Traitement individuel d'une protéine exécuté par un Worker (Thread)."""
    brut = ligne.strip()

    if not brut or brut == "nan" or brut == colonne_genes:
        return

    # --- Nettoyage des identifiants ---
    if ";" in brut:
        brut = brut.split(";")[0].strip()
    if "," in brut:
        brut = brut.split(",")[0].strip()
    if "|" in brut:
        parts = brut.split("|")
        prot_name = parts[1].strip() if len(parts) >= 2 else brut
    else:
        prot_name = brut

    gene_clean = prot_name.upper()

    with LOCK:
        genes_excel_cleans.append(gene_clean)

    print(f"Connexion à STRING-DB pour : {prot_name}")
    results_blocks = []
    liste_preferred_valides = []

    # --- Étape C.1 : Mapping STRING ---
    param_map = {"identifiers": prot_name, "species": tax_id, "limit": 1}
    string_id_valide = None
    try:
        res_map = requests.get(url_map, params=param_map, timeout=60)
        if res_map.status_code == 200:
            donnees = res_map.json()
            if donnees and isinstance(donnees, list) and len(donnees) > 0:
                string_id_valide = donnees[0].get("stringId")
    except Exception as e:
        print(f" Erreur lors du mapping de {prot_name} : {e}")

    if not string_id_valide:
        print(f" Impossible de mapper {prot_name} dans STRING.")
        return

    # --- Étape C.2 : Réseau d'interactions ---
    api_params = {
        "identifiers": string_id_valide,
        "species": tax_id,
        "required_score": 400,
        "limit": 15,
    }
    raw_json = None
    try:
        response = requests.get(url_network, params=api_params, timeout=60)
        if response.status_code == 200:
            raw_json = response.json()
        else:
            print(
                f" Erreur API Network ({response.status_code}) pour {prot_name}"
            )
    except Exception as error:
        print(f" Erreur réseau pour {prot_name} : {error}")

    # --- Étape C.3 : Mise en forme ---
    if raw_json:
        print(
            f" -> {len(raw_json)} interaction(s) fonctionnelle(s) pour {prot_name}"
        )
        bloc = (
            f"### Réseau d'interactions pour le gène : {prot_name}\n"
            f"Identifiant STRING officiel : `{string_id_valide}`\n\n"
            f"| Protéine A (Cible) | Protéine B (Partenaire) | Score de confiance total |\n"
            f"| :--- | :--- | :--- |\n"
        )
        for item in raw_json:
            p_a = item.get("preferredName_A", prot_name)
            p_b = item.get("preferredName_B", "")
            score = item.get("score", 0)

            bloc += f"| {p_a} | **{p_b}** | {score} |\n"

            if p_b and p_b != prot_name:
                liste_preferred_valides.append(p_b)

        results_blocks.append(bloc)
    else:
        results_blocks.append(
            f"Aucune interaction valide trouvée dans STRING pour {prot_name} (TaxID: {tax_id})."
        )

    # Remplissage sécurisé du dictionnaire
    if liste_preferred_valides:
        partenaires = list(set([g.upper() for g in liste_preferred_valides]))
        with LOCK:
            dictionnaire_enrichissement[gene_clean] = partenaires

    # --- Étape C.4 : Écriture du rapport MD ---
    safe_name = "".join([c if c.isalnum() else "_" for c in prot_name])
    out_txt = out_dir / f"{safe_name}.md"
    try:
        with open(out_txt, "w", encoding="utf-8") as f_txt:
            f_txt.write("# RÉSULTATS DE LA RECHERCHE STRING-DB\n\n")
            f_txt.write(f"## Cible protéique : {prot_name}\n")
            f_txt.write(f"## Organisme : {org_name} (TaxID : {tax_id})\n\n")
            f_txt.write("---\n\n")
            for b in results_blocks:
                f_txt.write(b + "\n")
    except Exception as e:
        print(f" Impossible d'écrire le fichier MD pour {prot_name} : {e}")


def acquerir_base_string(
    excel_file: Path,
    colonne_genes: str,
    tax_id: int = 9606,
    out_dir: Path = OUT_DIR,
    max_workers: int = MAX_WORKERS,
) -> tuple[dict, list, str]:
    """Lit le fichier Excel et interroge STRING en multi-threading via ThreadPoolExecutor."""

    print(
        f"\nRecherche du nom de l'organisme pour le TaxID {tax_id} via UniProt..."
    )
    try:
        res_org = requests.get(
            f"https://rest.uniprot.org/taxonomy/{tax_id}", timeout=60
        )
        org_name = (
            res_org.json().get("scientificName", f"ID {tax_id}")
            if res_org.status_code == 200
            else f"ID {tax_id}"
        )
    except Exception:
        org_name = f"ID {tax_id}"

    print(f"Organisme retenu : {org_name}\n")

    print(f"Lecture du fichier Excel : {excel_file}")
    try:
        df = pd.read_excel(excel_file, skiprows=1)
        liste_raw = df[colonne_genes].dropna().astype(str).unique().tolist()
    except Exception as e:
        print(f"Erreur lors de la lecture du fichier Excel : {e}")
        return {}, [], org_name

    url_map = "https://string-db.org/api/json/get_string_ids"
    url_network = "https://string-db.org/api/json/network"

    dictionnaire_enrichissement = {}
    genes_excel_cleans = []

    print(
        f"\nDébut du traitement multi-threadé de {len(liste_raw)} éléments (Max Workers: {max_workers})...\n"
    )

    # Lancement du pool de threads
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = [
            executor.submit(
                traiter_un_gene,
                ligne,
                tax_id,
                colonne_genes,
                out_dir,
                org_name,
                url_map,
                url_network,
                dictionnaire_enrichissement,
                genes_excel_cleans,
            )
            for ligne in liste_raw
        ]

        # Attend la fin de toutes les exécutions
        for future in as_completed(futures):
            try:
                future.result()
            except Exception as e:
                print(f"Erreur dans le thread : {e}")

    with LOCK:
        genes_excel_cleans = list(set(genes_excel_cleans))

    dict_output_path = BASE_DIR / "dictionnaire_enrichissement.json"
    with open(dict_output_path, "w", encoding="utf-8") as f_dict:
        json.dump(
            dictionnaire_enrichissement, f_dict, indent=4, ensure_ascii=False
        )

    print(
        f"\nAcquisition terminée. Dictionnaire enregistré dans : {dict_output_path}"
    )
    return dictionnaire_enrichissement, genes_excel_cleans, org_name


def executer_enrichissement_gsea_DB(
    lib,
    gene_sets,
    p_value_cutoff: float = 0.05,
    schemas_dir: Path = SCHEMAS_DIR,
) -> dict:
    """Exécute l'analyse GSEA (via un dictionnaire STRING ou un nom de base GSEApy)."""
    gsea_results = {}

    if not lib or not gene_sets:
        print(
            "Erreur : La liste de gènes ou la base d'enrichissement est vide."
        )
        return gsea_results

    print(
        f"\nUtilisation de la bibliothèque GSEA : {lib}"
    )

    try:
        res_gsea = gp.enrich(
            gene_list=lib, gene_sets=gene_sets, outdir=None
        )

        if (
            hasattr(res_gsea, "results")
            and isinstance(res_gsea.results, pd.DataFrame)
            and not res_gsea.results.empty
        ):

            df_res = res_gsea.results
            df_filtered = df_res[df_res["P-value"] <= p_value_cutoff]

            if not df_filtered.empty:
                gsea_results["enrichment_results"] = df_filtered.to_dict(
                    orient="index"
                )

                chemin_png = schemas_dir / "dotplot_enrichissement.png"
                dotplot(
                    df_filtered,
                    column="P-value",
                    top_term=10,
                    figsize=(6, 8),
                    title="Enrichissement GSEA",
                    ofname=str(chemin_png),
                    show_ring=True,
                )
                plt.close("all")
                print(f" -> Dotplot sauvegardé avec succès : {chemin_png}")
            else:
                print(
                    f" -> Aucun terme significatif sous le seuil p-value de {p_value_cutoff}."
                )
        else:
            print(" -> Aucun résultat d'enrichissement renvoyé par GSEApy.")

    except Exception as e:
        print(f" -> Erreur lors de l'analyse GSEA : {e}")

    res_output_path = BASE_DIR / "resultats_enrichissement_gsea.json"
    with open(res_output_path, "w", encoding="utf-8") as f_res:
        json.dump(gsea_results, f_res, indent=4, ensure_ascii=False)

    print(f"Résultats de l'enrichissement enregistrés dans : {res_output_path}")
    return gsea_results


def versions():
    """Affiche les versions des librairies utilisées dans l'environnement de travail."""
    print("voici le détail de toutes les versions utilisées : \n")
    print("Pandas : 3.0.3")
    print("requests : 2.34.2")
    print("pathlib : 1.0.1")
    print("openpyxl : 3.1.5")
    print("numpy : 2.5.1")
    print("gseapy : 0.12.0")
    print("python : 3.14.6")
    print("python-dateutil : 2.9.0.post0")


# -----------------------------------------------------------------------------
# PROGRAMME PRINCIPAL
# -----------------------------------------------------------------------------
if __name__ == "__main__":
    print("=========================================================")
    print(" PIPELINE INTERACTIF : STRING-DB & ENRICHISSEMENT GSEA ")
    print("=========================================================\n")

    print("Que souhaitez-vous faire ?")
    print(" 1. Acquérir uniquement la base d'interactions STRING")
    print(" 2. Récupérer la base STRING ET faire l'enrichissement GSEA global")

    choix = input("\nVotre choix (1 ou 2) : ").strip()

    if choix in ["1", "2"]:
        tax_input = input(
            "\nTaxID de l'organisme [défaut : 9606 (Humain)] : "
        ).strip()
        try:
            tax_id = int(tax_input) if tax_input else 9606
        except ValueError:
            print("ID invalide. Utilisation du TaxID 9606.")
            tax_id = 9606

        p_val_thresh = 0.05
        if choix == "2":
            p_input = input("Seuil max p-value [défaut : 0.05] : ").strip()
            try:
                p_val_thresh = float(p_input) if p_input else 0.05
            except ValueError:
                print("p-value invalide. Utilisation de 0.05 par défaut.")
                p_val_thresh = 0.05

        string_dict, genes_excel, org_name = acquerir_base_string(
            excel_file=EXCEL_FILE,
            colonne_genes=COLONNE_UNIPROT,
            tax_id=tax_id,
            out_dir=OUT_DIR,
            max_workers=MAX_WORKERS,
        )

        if choix == "2":
            DB = input(
                "Quelle base souhaitez-vous utiliser ? (GSEA ou STRING) [défaut: STRING] : "
            )
            DB = DB.upper()

            if DB == "STRING":
                if string_dict and genes_excel:
                    executer_enrichissement_gsea_DB(
                        gene_list=genes_excel,
                        gene_sets=string_dict,
                        p_value_cutoff=p_val_thresh,
                        schemas_dir=SCHEMAS_DIR,
                    )
                else:
                    print(
                        "\nImpossible de lancer GSEA : dictionnaire ou liste vide."
                    )

            elif DB == "GSEA":
                # prend toutes les librairies
                
                # Reglage du nombre de threads pour requeter les banques GSEA Enrichr
                MAX_GSEA_WORKERS = 8 
                nb_lib_traitees = 0
                lib_choisie = gp.get_library_name(organism=org_name)
                with ThreadPoolExecutor(max_workers=MAX_GSEA_WORKERS) as executor:
                    # Lancement parallele de l analyse pour chaque librairie
                    future_to_lib = {
                        executor.submit(executer_enrichissement_gsea_DB, lib, gene_sets, p_value_cutoff, schemas_dir): lib
                        for lib in lib_choisie
                    }

        print("\n---------------------------------------------------------")
        print(" TRAITEMENT TERMINÉ avec succès ")
        print("---------------------------------------------------------")
        versions()

    else:
        print("Choix non valide. Fin du programme.")