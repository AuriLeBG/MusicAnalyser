import time
import psycopg2
import clickhouse_driver
import os
import pandas as pd

print("--- Démarrage du Data Loader ---")

DB_USER = os.getenv('DB_USER', 'user')
DB_PASSWORD = os.getenv('DB_PASSWORD', 'password')
DB_NAME = os.getenv('DB_NAME', 'music_db')
DB_HOST_PG = os.getenv('DB_HOST_PG', 'postgres')
DB_HOST_CH = os.getenv('DB_HOST_CH', 'clickhouse')
CSV_FILE_PATH = '/data/sample.csv'

print("En attente des bases de données...")
time.sleep(10)

try:
    print(f"Tentative de connexion à Postgres - {DB_HOST_PG} ...")
    # On teste la connexion
    pg_conn = psycopg2.connect(
        host=DB_HOST_PG, user=DB_USER, password=DB_PASSWORD, dbname=DB_NAME
    )
    print(f"object postgres : {pg_conn}")
    print("Connexion Postgres réussie !")

    pg_conn.close()
    print("Tentative de connexion à ClickHouse...")
    client = clickhouse_driver.Client(
        host=DB_HOST_CH, 
        user=DB_USER,
        password=DB_PASSWORD
    )
    client.execute('SHOW DATABASES')
    print(f"object clickhouse : {client}")
    print("Connexion ClickHouse réussie !")

    # Création de la base de données si elle n'existe pas
    client.execute(f'CREATE DATABASE IF NOT EXISTS {DB_NAME}')
    
    # On bascule sur la bonne base
    client = clickhouse_driver.Client(host=DB_HOST_CH, user=DB_USER, password=DB_PASSWORD, database=DB_NAME)

    # Définition de la table selon votre CSV sample2.csv
    # Note : J'utilise String pour 'features' car c'est un format complexe dans le CSV
    create_table_query = """
    CREATE TABLE IF NOT EXISTS songs (
        title String,
        tag String,
        artist String,
        year UInt32,
        views UInt64,
        features String,
        lyrics String,
        id String,
        language_cld3 String,
        language_ft String,
        language String
    ) ENGINE = MergeTree()
    ORDER BY (artist, year, title) 
    """
    client.execute(create_table_query)
    print("Table 'songs' assurée.")

    # ---------------------------------------------------------
    # 3. Import des données
    # ---------------------------------------------------------
    
    # On vérifie si la table est vide
    count_result = client.execute("SELECT count() FROM songs")
    row_count = count_result[0][0]

    if row_count == 0:
        print(f"La table est vide. Chargement de {CSV_FILE_PATH}...")
        
        if os.path.exists(CSV_FILE_PATH):
            # Lecture avec Pandas
            df = pd.read_csv(CSV_FILE_PATH)
            
            # Nettoyage basique (Clickhouse n'aime pas les NaN dans les colonnes non-Nullable)
            df = df.fillna("") 
            
            # Conversion explicite pour éviter les erreurs de typage
            # On force year et views en numérique, et on remplace les erreurs par 0
            df['year'] = pd.to_numeric(df['year'], errors='coerce').fillna(0).astype(int)
            df['views'] = pd.to_numeric(df['views'], errors='coerce').fillna(0).astype(int)
            
            # Insertion Pandas
            df = pd.read_csv(CSV_FILE_PATH)
            df['id'] = df['id'].astype(str)
            df = df.fillna("") 
            df['year'] = pd.to_numeric(df['year'], errors='coerce').fillna(0).astype(int)
            df['views'] = pd.to_numeric(df['views'], errors='coerce').fillna(0).astype(int)
            
            # Insertion (votre code existant)
            print(f"Insertion de {len(df)} lignes...")
            client.execute('INSERT INTO songs VALUES', df.values.tolist())
            print("Import terminé avec succès !")
        else:
            print(f"ATTENTION: Le fichier {CSV_FILE_PATH} est introuvable.")
    else:
        print(f"La table contient déjà {row_count} lignes. Import ignoré.")

    # ---------------------------------------------------------
    # 4. Import des artistes dans PostgreSQL
    # ---------------------------------------------------------
    print("Import des artistes dans PostgreSQL...")

    df_artists = pd.read_csv(CSV_FILE_PATH, usecols=['artist'])
    df_artists = df_artists.dropna()
    df_artists = df_artists[df_artists['artist'].str.strip() != '']
    df_artists = df_artists.drop_duplicates(subset=['artist'])
    artists = df_artists['artist'].str.strip().tolist()

    pg_conn = psycopg2.connect(
        host=DB_HOST_PG, user=DB_USER, password=DB_PASSWORD, dbname=DB_NAME
    )
    pg_cursor = pg_conn.cursor()

    inserted = 0
    skipped = 0
    for name in artists:
        pg_cursor.execute(
            "INSERT INTO artists (name) VALUES (%s) ON CONFLICT (name) DO NOTHING",
            (name,)
        )
        if pg_cursor.rowcount == 1:
            inserted += 1
        else:
            skipped += 1

    pg_conn.commit()
    pg_cursor.close()
    pg_conn.close()

    print(f"Artistes insérés : {inserted}, ignorés (déjà présents) : {skipped}")

except Exception as e:
    print(f"Erreur : {e}")