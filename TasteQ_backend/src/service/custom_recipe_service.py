# service/custom_recipe_service.py
from database.connection import get_connection

def create_custom_recipe(data):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                INSERT INTO custom_recipe (user_id, custom_recipe_name, cook_time_min)
                VALUES (%s, %s, %s)
            """
            cursor.execute(sql, (data.user_id, data.custom_recipe_name, data.cook_time_min))
            conn.commit()
            return cursor.lastrowid
    finally:
        conn.close()

def get_all_custom_recipes():
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                SELECT cr.custom_recipe_id, cr.user_id, u.name AS user_name,
                       cr.custom_recipe_name, cr.cook_time_min
                FROM custom_recipe cr
                JOIN user u ON cr.user_id = u.user_id
                ORDER BY cr.custom_recipe_id DESC
            """
            cursor.execute(sql)
            return cursor.fetchall()
    finally:
        conn.close()

def get_custom_recipe_by_id(recipe_id: int):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                SELECT cr.custom_recipe_id, cr.user_id, u.name AS user_name,
                       cr.custom_recipe_name, cr.cook_time_min
                FROM custom_recipe cr
                JOIN user u ON cr.user_id = u.user_id
                WHERE cr.custom_recipe_id = %s
            """
            cursor.execute(sql, (recipe_id,))
            return cursor.fetchone()
    finally:
        conn.close()
