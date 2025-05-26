from database.connection import get_connection

def create_user_seasoning(user_id: int, seasoning_id: int, amount: int, unit: str, injection_order: int) -> int:
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                INSERT INTO user_seasoning (user_id, seasoning_id, amount, unit, injection_order)
                VALUES (%s, %s, %s, %s, %s)
            """
            cursor.execute(sql, (user_id, seasoning_id, amount, unit, injection_order))
            conn.commit()
            return cursor.lastrowid
    finally:
        conn.close()


def get_user_seasonings_by_user_id(user_id: int):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                SELECT * FROM user_seasoning
                WHERE user_id = %s
                ORDER BY injection_order
            """
            cursor.execute(sql, (user_id,))
            return cursor.fetchall()
    finally:
        conn.close()