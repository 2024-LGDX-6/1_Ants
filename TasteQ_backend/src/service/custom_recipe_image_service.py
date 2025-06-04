import os
from fastapi import UploadFile
from database.connection import get_connection

# ✅ 상대 경로 기반 저장 디렉토리 설정 (프로젝트 루트 기준)
STATIC_SUBDIR = "static/custom_recipe_images"
UPLOAD_DIR = os.path.join(os.getcwd(), STATIC_SUBDIR)
os.makedirs(UPLOAD_DIR, exist_ok=True)

def save_custom_recipe_image(custom_recipe_id: int, custom_image_name: str, image_file: UploadFile) -> int:
    ext = os.path.splitext(image_file.filename)[-1]
    filename = f"{custom_recipe_id}{ext}"
    file_path = os.path.join(UPLOAD_DIR, filename)

    with open(file_path, "wb") as f:
        f.write(image_file.file.read())

    # ✅ DB에는 상대 경로 저장 (예: /static/custom_recipe_images/2.jpg)
    relative_path = f"/{STATIC_SUBDIR}/{filename}".replace("\\", "/")

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
