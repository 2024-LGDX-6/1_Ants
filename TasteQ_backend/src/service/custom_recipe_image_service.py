# service/custom_recipe_image_service.py
from database.connection import get_connection
from fastapi import UploadFile

def save_custom_recipe_image(custom_recipe_id: int, custom_image_name: str, image_file: UploadFile) -> int:
    image_data = image_file.file.read()
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                INSERT INTO custom_recipe_image (custom_recipe_id, custom_image_name, custom_image_data)
                VALUES (%s, %s, %s)
            """
            cursor.execute(sql, (custom_recipe_id, custom_image_name, image_data))
            conn.commit()
            return cursor.lastrowid
    finally:
        conn.close()

def get_custom_recipe_image(custom_recipe_id: int):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                SELECT cri.custom_image_name, cri.custom_image_data
                FROM custom_recipe_image cri
                JOIN custom_recipe cr ON cri.custom_recipe_id = cr.custom_recipe_id
                WHERE cri.custom_recipe_id = %s
                LIMIT 1
            """
            cursor.execute(sql, (custom_recipe_id,))
            result = cursor.fetchone()
            return result
    finally:
        conn.close()

def get_all_custom_recipe_images():
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                SELECT
                    cri.custom_image_id,
                    cri.custom_recipe_id,
                    cr.custom_recipe_name,
                    cri.custom_image_name
                FROM custom_recipe_image cri
                JOIN custom_recipe cr ON cri.custom_recipe_id = cr.custom_recipe_id
                ORDER BY cri.custom_recipe_id
            """
            cursor.execute(sql)
            return cursor.fetchall()
    finally:
        conn.close()