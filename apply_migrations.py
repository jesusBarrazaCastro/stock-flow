import os
import sys
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

# Acepta el archivo como argumento, por defecto aplica movement_functions.sql
sql_file = sys.argv[1] if len(sys.argv) > 1 else 'database_scripts/movement_functions.sql'

with open(sql_file, 'r', encoding='utf-8') as f:
    sql = f.read()

cur.execute(sql)
print(f'{sql_file} aplicado correctamente a Aiven.')
conn.close()
