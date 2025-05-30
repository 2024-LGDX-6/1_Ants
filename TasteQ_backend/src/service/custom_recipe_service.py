# service/custom_recipe_service.py
from database.connection import get_connection

def create_custom_recipe(data):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                INSERT INTO custom_recipe (user_id, custom_recipe_name, cook_time_min, custom_main_ingredient)
                VALUES (%s, %s, %s, %s)
            """
            cursor.execute(sql, (data.user_id, data.custom_recipe_name, data.cook_time_min, data.custom_main_ingredient))
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
                       cr.custom_recipe_name, cr.cook_time_min, cr.custom_main_ingredient
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
                       cr.custom_recipe_name, cr.cook_time_min, cr.custom_main_ingredient
                FROM custom_recipe cr
                JOIN user u ON cr.user_id = u.user_id
                WHERE cr.custom_recipe_id = %s
            """
            cursor.execute(sql, (recipe_id,))
            return cursor.fetchone()
    finally:
        conn.close()

def get_custom_recipe_by_name(recipe_name: str):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                SELECT cr.custom_recipe_id, cr.user_id, u.name AS user_name,
                       cr.custom_recipe_name, cr.cook_time_min, cr.custom_main_ingredient
                FROM custom_recipe cr
                JOIN user u ON cr.user_id = u.user_id
                WHERE cr.custom_recipe_name = %s
            """
            cursor.execute(sql, (recipe_name,))
            return cursor.fetchone()
    finally:
        conn.close()


def get_custom_recipes_by_main_ingredients(ingredients: list[str]):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            placeholders = ', '.join(['%s'] * len(ingredients))
            sql = f"""
                SELECT cr.custom_recipe_id, cr.user_id, u.name AS user_name,
                       cr.custom_recipe_name, cr.cook_time_min, cr.custom_main_ingredient
                FROM custom_recipe cr
                JOIN user u ON cr.user_id = u.user_id
                WHERE cr.custom_main_ingredient IN ({placeholders})
            """
            cursor.execute(sql, ingredients)
            return cursor.fetchall()
    finally:
        conn.close()

def get_custom_recipes_by_user_fridge(user_id: int):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            fridge_sql = """
                SELECT uf.fridge_Ingredients
                FROM user_fridge uf
                JOIN cooking_device cd ON uf.device_id = cd.device_id
                WHERE cd.user_id = %s
            """
            cursor.execute(fridge_sql, (user_id,))
            ingredients = [row["fridge_Ingredients"] for row in cursor.fetchall()]

            if not ingredients:
                return []

            placeholders = ', '.join(['%s'] * len(ingredients))
            recipe_sql = f"""
                SELECT cr.custom_recipe_id, cr.user_id, u.name AS user_name,
                       cr.custom_recipe_name, cr.cook_time_min, cr.custom_main_ingredient
                FROM custom_recipe cr
                JOIN user u ON cr.user_id = u.user_id
                WHERE cr.custom_main_ingredient IN ({placeholders})
            """
            cursor.execute(recipe_sql, ingredients)
            return cursor.fetchall()
    finally:
        conn.close()
