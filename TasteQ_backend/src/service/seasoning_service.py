from database.connection import get_connection

def get_all_seasonings():
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT * FROM seasoning")
            return cursor.fetchall()
    finally:
        conn.close()

def get_seasoning_by_id(seasoning_id: int):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT * FROM seasoning WHERE seasoning_id = %s", (seasoning_id,))
            return cursor.fetchone()
    finally:
        conn.close()