import os
from fastapi import UploadFile
from database.connection import get_connection

# 상대 경로 기반 디렉토리
UPLOAD_DIR = "static/recipe_images"
os.makedirs(UPLOAD_DIR, exist_ok=True)

def save_recipe_image(recipe_id: int, image_name: str, image_file: UploadFile) -> int:
    ext = os.path.splitext(image_file.filename)[-1]
    filename = f"{recipe_id}{ext}"
    
    # ✅ 상대경로로 저장 (실제 파일은 프로젝트 기준 상대 위치에 저장됨)
    file_path = os.path.join(UPLOAD_DIR, filename)

    # 실제 파일 쓰기
    with open(file_path, "wb") as f:
        f.write(image_file.file.read())

    # ✅ DB에는 /static/... 형식으로 저장
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
