import time
import psycopg2
import clickhouse_driver
import os

print("--- Démarrage du Data Loader ---")

DB_USER = os.getenv('DB_USER', 'user')
DB_PASSWORD = os.getenv('DB_PASSWORD', 'password')
DB_NAME = os.getenv('DB_NAME', 'music_db')
DB_HOST_PG = os.getenv('DB_HOST_PG', 'postgres')
DB_HOST_CH = os.getenv('DB_HOST_CH', 'clickhouse')

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

    print("--- TODO: Coder l'import du CSV ici ---")

except Exception as e:
    print(f"❌ Erreur : {e}")