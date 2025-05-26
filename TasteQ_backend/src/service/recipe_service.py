from database.connection import get_connection

def create_recipe(name: str, description: str) -> int:
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = "INSERT INTO recipe (name, description) VALUES (%s, %s)"
            cursor.execute(sql, (name, description))
            conn.commit()
            return cursor.lastrowid
    finally:
        conn.close()


def get_recipe_by_id(recipe_id: int):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = "SELECT * FROM recipe WHERE recipe_id = %s"
            cursor.execute(sql, (recipe_id,))
            return cursor.fetchone()
    finally:
        conn.close()


def get_recipe_seasoning_details(recipe_id: int):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                SELECT 
                    rsd.detail_id,
                    s.seasoning_id,
                    s.seasoning_name,
                    rsd.amount,
                    rsd.unit,
                    rsd.injection_order
                FROM recipe_seasoning_detail rsd
                JOIN seasoning s ON rsd.seasoning_id = s.seasoning_id
                WHERE rsd.recipe_id = %s
                ORDER BY rsd.injection_order ASC
            """
            cursor.execute(sql, (recipe_id,))
            return cursor.fetchall()
    finally:
        conn.close()
