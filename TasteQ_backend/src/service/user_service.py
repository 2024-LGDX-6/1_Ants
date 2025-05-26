from database.connection import get_connection

def get_all_users():
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = "SELECT user_id, name, age FROM user"
            cursor.execute(sql)
            return cursor.fetchall()
    finally:
        conn.close()

def get_user_by_id(user_id: int):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = "SELECT user_id, name, age FROM user WHERE user_id = %s"
            cursor.execute(sql, (user_id,))
            return cursor.fetchone()
    finally:
        conn.close()