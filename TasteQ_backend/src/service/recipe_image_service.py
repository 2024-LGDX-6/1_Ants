from database.connection import get_connection
from fastapi import UploadFile

def save_recipe_image(recipe_id: int, image_name: str, image_file: UploadFile):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            binary_data = image_file.file.read()
            sql = """
                INSERT INTO recipe_image (recipe_id, image_name, image_data)
                VALUES (%s, %s, %s)
            """
            cursor.execute(sql, (recipe_id, image_name, binary_data))
            conn.commit()
            return cursor.lastrowid
    finally:
        conn.close()

def get_recipe_image(recipe_id: int):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                SELECT
                    ri.image_id,
                    ri.recipe_id,
                    ri.image_name,
                    ri.image_data
                FROM recipe_image ri
                JOIN recipe r ON ri.recipe_id = r.recipe_id
                WHERE ri.recipe_id = %s
                LIMIT 1
            """
            cursor.execute(sql, (recipe_id,))
            result = cursor.fetchone()
            return result
    finally:
        conn.close()

