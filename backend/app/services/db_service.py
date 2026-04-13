import os
import psycopg2
from psycopg2.extras import RealDictCursor
from fastapi import HTTPException
import json

def get_db_connection():
    DB_HOST = os.getenv("DB_HOST", "localhost")
    DB_PORT = os.getenv("DB_PORT", "5432")
    DB_NAME = os.getenv("DB_NAME", "stockflow_db")
    DB_USER = os.getenv("DB_USER", "postgres")
    DB_PASSWORD = os.getenv("DB_PASSWORD", "postgres")

    try:
        conn = psycopg2.connect(
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
            host=DB_HOST,
            port=DB_PORT,
            cursor_factory=RealDictCursor
        )
        return conn
    except Exception as e:
        raise HTTPException(status_code=500, detail="Error interno: No se pudo conectar a la base de datos.")

def execute_query(query: str, params: tuple | None = None, fetchone=False, fetchall=False, commit=False):
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(query, params)
        
        result = None
        if fetchone:
            result = cur.fetchone()
        elif fetchall:
            result = cur.fetchall()
            
        if commit:
            conn.commit()
            
        cur.close()
        return result
    except Exception as e:
        if conn:
            conn.rollback()
        print(f"Error executing query: {e}")
        raise HTTPException(status_code=500, detail=f"Error en BD: {e}")
    finally:
        if conn:
            conn.close()
