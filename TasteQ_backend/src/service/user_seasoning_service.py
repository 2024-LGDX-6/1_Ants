from database.connection import get_connection

def get_all_user_seasonings():
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                SELECT 
                    us.batch_id,
                    us.user_id,
                    u.name AS user_name,
                    us.seasoning_id,
                    s.seasoning_name
                FROM user_seasoning us
                JOIN user u ON us.user_id = u.user_id
                JOIN seasoning s ON us.seasoning_id = s.seasoning_id
                ORDER BY us.user_id
            """
            cursor.execute(sql)
            return cursor.fetchall()
    finally:
        conn.close()


def get_user_seasonings_by_user_id(user_id: int):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                SELECT 
                    us.batch_id,
                    us.user_id,
                    u.name AS user_name,
                    us.seasoning_id,
                    s.seasoning_name
                FROM user_seasoning us
                JOIN user u ON us.user_id = u.user_id
                JOIN seasoning s ON us.seasoning_id = s.seasoning_id
                WHERE us.user_id = %s
            """
            cursor.execute(sql, (user_id,))
            return cursor.fetchall()
    finally:
        conn.close()
