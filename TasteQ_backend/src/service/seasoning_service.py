from database.connection import get_connection

def get_all_seasonings():
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = "SELECT seasoning_id, seasoning_name FROM seasoning"
            cursor.execute(sql)
            return cursor.fetchall()
    finally:
        conn.close()


def get_seasoning_by_id(seasoning_id: int):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = "SELECT seasoning_id, seasoning_name FROM seasoning WHERE seasoning_id = %s"
            cursor.execute(sql, (seasoning_id,))
            return cursor.fetchone()
    finally:
        conn.close()