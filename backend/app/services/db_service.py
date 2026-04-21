import os
import psycopg2
from psycopg2.extras import RealDictCursor
from fastapi import HTTPException
from dotenv import load_dotenv

load_dotenv()


def get_db_connection():
    DB_HOST     = os.getenv("DB_HOST")
    DB_PORT     = os.getenv("DB_PORT")
    DB_NAME     = os.getenv("DB_NAME")
    DB_USER     = os.getenv("DB_USER")
    DB_PASSWORD = os.getenv("DB_PASSWORD")
    DB_SSLMODE  = os.getenv("DB_SSLMODE", "require")

    try:
        conn = psycopg2.connect(
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
            host=DB_HOST,
            port=DB_PORT,
            sslmode=DB_SSLMODE,
            cursor_factory=RealDictCursor,
        )
        return conn
    except psycopg2.OperationalError as e:
        raise ConnectionError(str(e))


def execute_query(
    query: str,
    params: tuple | None = None,
    fetchone: bool = False,
    fetchall: bool = False,
):
    """
    Ejecuta una query dentro de una transacción explícita.
    - COMMIT si todo sale bien.
    - ROLLBACK automático si ocurre cualquier error.
    """
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

        conn.commit()
        cur.close()
        return result

    except ConnectionError as e:
        raise HTTPException(
            status_code=503,
            detail=f"No se pudo conectar a la base de datos: {e}",
        )
    except HTTPException:
        raise
    except Exception as e:
        if conn:
            conn.rollback()
        print(f"Error en BD (rollback): {e}")
        raise HTTPException(status_code=500, detail=f"Error en BD: {e}")
    finally:
        if conn:
            conn.close()
