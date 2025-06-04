import os
from fastapi import UploadFile
from database.connection import get_connection

# 이미지가 저장될 절대 경로 (예: C:/myproject/static/custom_recipe_images)
BASE_DIR = os.path.dirname(os.path.abspath(__file__))  # 현재 파일 기준 절대경로
UPLOAD_DIR = os.path.join(BASE_DIR, "../../static/custom_recipe_images")
os.makedirs(UPLOAD_DIR, exist_ok=True)

def save_custom_recipe_image(custom_recipe_id: int, custom_image_name: str, image_file: UploadFile) -> int:
    ext = os.path.splitext(image_file.filename)[-1]
    filename = f"{custom_recipe_id}{ext}"
    file_path = os.path.join(UPLOAD_DIR, filename)

    with open(file_path, "wb") as f:
        f.write(image_file.file.read())

    relative_path = f"/{file_path.replace(os.sep, '/')}"

    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                INSERT INTO custom_recipe_image (custom_recipe_id, custom_image_name, custom_image_path)
                VALUES (%s, %s, %s)
            """
            cursor.execute(sql, (custom_recipe_id, custom_image_name, relative_path))
            conn.commit()
            return cursor.lastrowid
    finally:
        conn.close()


def get_custom_recipe_image(custom_recipe_id: int):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                SELECT cri.custom_image_id, cri.custom_recipe_id, cr.custom_recipe_name,
                       cri.custom_image_name, cri.custom_image_path
                FROM custom_recipe_image cri
                JOIN custom_recipe cr ON cri.custom_recipe_id = cr.custom_recipe_id
                WHERE cri.custom_recipe_id = %s
                LIMIT 1
            """
            cursor.execute(sql, (custom_recipe_id,))
            return cursor.fetchone()
    finally:
        conn.close()


def get_all_custom_recipe_images():
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                SELECT cri.custom_image_id, cri.custom_recipe_id, cr.custom_recipe_name,
                       cri.custom_image_name, cri.custom_image_path
                FROM custom_recipe_image cri
                JOIN custom_recipe cr ON cri.custom_recipe_id = cr.custom_recipe_id
                ORDER BY cri.custom_recipe_id
            """
            cursor.execute(sql)
            return cursor.fetchall()
    finally:
        conn.close()
