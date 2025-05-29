from database.connection import get_connection

def create_user_fridge(device_id: int, fridge_Ingredients: str) -> int:
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = "INSERT INTO user_fridge (device_id, fridge_Ingredients) VALUES (%s, %s)"
            cursor.execute(sql, (device_id, fridge_Ingredients))
            conn.commit()
            return cursor.lastrowid
    finally:
        conn.close()


def get_user_fridge_by_user_id(user_id: int):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                SELECT 
                    uf.fridge_Ingredients_id,
                    uf.device_id,
                    cd.device_name,
                    u.user_id,
                    u.name AS user_name,
                    uf.fridge_Ingredients
                FROM user_fridge uf
                JOIN cooking_device cd ON uf.device_id = cd.device_id
                JOIN user u ON cd.user_id = u.user_id
                WHERE u.user_id = %s
            """
            cursor.execute(sql, (user_id,))
            return cursor.fetchall()
    finally:
        conn.close()


def delete_fridge_ingredient(device_id: int, ingredient: str) -> int:
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                DELETE FROM user_fridge
                WHERE device_id = %s AND fridge_Ingredients = %s
            """
            result = cursor.execute(sql, (device_id, ingredient))
            conn.commit()
            return result  # 삭제된 행 수
    finally:
        conn.close()