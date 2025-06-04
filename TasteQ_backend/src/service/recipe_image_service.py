# service/recipe_image_service.py
import os
from fastapi import UploadFile
from database.connection import get_connection

BASE_DIR = os.path.dirname(os.path.abspath(__file__))  # 현재 파일 기준 절대경로
UPLOAD_DIR = os.path.join(BASE_DIR, "../../static/recipe_images")
os.makedirs(UPLOAD_DIR, exist_ok=True)

def save_recipe_image(recipe_id: int, image_name: str, image_file: UploadFile) -> int:

    ext = os.path.splitext(image_file.filename)[-1]
    filename = f"{recipe_id}{ext}"
    file_path = os.path.join(UPLOAD_DIR, filename)

    with open(file_path, "wb") as f:
        f.write(image_file.file.read())

    relative_path = f"/{file_path.replace(os.sep, '/')}"

    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                INSERT INTO recipe_image (recipe_id, image_name, image_path)
                VALUES (%s, %s, %s)
            """
            cursor.execute(sql, (recipe_id, image_name, relative_path))
            conn.commit()
            return cursor.lastrowid
    finally:
        conn.close()

def get_recipe_image(recipe_id: int):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                SELECT image_name, image_path
                FROM recipe_image
                WHERE recipe_id = %s
                LIMIT 1
            """
            cursor.execute(sql, (recipe_id,))
            return cursor.fetchone()
    finally:
        conn.close()

def get_all_recipe_images():
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                SELECT image_id, recipe_id, image_name, image_path
                FROM recipe_image
                ORDER BY recipe_id
            """
            cursor.execute(sql)
            return cursor.fetchall()
    finally:
        conn.close()
