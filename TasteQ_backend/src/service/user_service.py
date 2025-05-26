from database.connection import get_connection

def get_all_users():
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT * FROM user")
            return cursor.fetchall()
    finally:
        conn.close()

def get_user_by_id(user_id: int):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT * FROM user WHERE user_id = %s", (user_id,))
            return cursor.fetchone()
    finally:
        conn.close()