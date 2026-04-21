import os
import psycopg2
from dotenv import load_dotenv

load_dotenv('backend/.env')

conn = psycopg2.connect(
    host=os.getenv('DB_HOST'),
    port=int(os.getenv('DB_PORT')),
    dbname=os.getenv('DB_NAME'),
    user=os.getenv('DB_USER'),
    password=os.getenv('DB_PASSWORD'),
    sslmode=os.getenv('DB_SSLMODE', 'require'),
)
conn.autocommit = True
cur = conn.cursor()

with open('database_scripts/catalog_functions.sql', 'r', encoding='utf-8') as f:
    sql = f.read()

cur.execute(sql)
print('catalog_functions.sql aplicado correctamente a Aiven.')
conn.close()
