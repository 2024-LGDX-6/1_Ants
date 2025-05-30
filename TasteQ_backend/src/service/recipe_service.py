from database.connection import get_connection

def get_all_recipes():
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                SELECT recipe_id, recipe_name, cook_time_min, recipe_link, main_ingredient
                FROM recipe
            """
            cursor.execute(sql)
            return cursor.fetchall()
    finally:
        conn.close()

def get_recipe_by_id(recipe_id: int):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                SELECT recipe_id, recipe_name, cook_time_min, recipe_link, main_ingredient
                FROM recipe
                WHERE recipe_id = %s
            """
            cursor.execute(sql, (recipe_id,))
            return cursor.fetchone()
    finally:
        conn.close()

def get_recipes_by_name(names: list[str]):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            placeholders = ', '.join(['%s'] * len(names))
            sql = f"""
                SELECT recipe_id, recipe_name, cook_time_min, recipe_link, main_ingredient
                FROM recipe
                WHERE recipe_name IN ({placeholders})
            """
            cursor.execute(sql, names)
            return cursor.fetchall()
    finally:
        conn.close()


def get_recipes_by_main_ingredients(ingredients: list[str]):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            # SQL IN 절을 사용하여 여러 재료 중 하나라도 포함된 레시피 검색
            placeholders = ', '.join(['%s'] * len(ingredients))
            sql = f"""
                SELECT recipe_id, recipe_name, cook_time_min, recipe_link, main_ingredient
                FROM recipe
                WHERE main_ingredient IN ({placeholders})
            """
            cursor.execute(sql, ingredients)
            return cursor.fetchall()
    finally:
        conn.close()

def get_recipes_by_user_fridge(user_id: int):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            # 냉장고 재료 추출
            fridge_sql = """
                SELECT uf.fridge_Ingredients
                FROM user_fridge uf
                JOIN cooking_device cd ON uf.device_id = cd.device_id
                WHERE cd.user_id = %s
            """
            cursor.execute(fridge_sql, (user_id,))
            fridge_ingredients = [row['fridge_Ingredients'] for row in cursor.fetchall()]

            if not fridge_ingredients:
                return []

            # 재료 기반 레시피 검색
            placeholders = ', '.join(['%s'] * len(fridge_ingredients))
            recipe_sql = f"""
                SELECT recipe_id, recipe_name, cook_time_min, recipe_link, main_ingredient
                FROM recipe
                WHERE main_ingredient IN ({placeholders})
            """
            cursor.execute(recipe_sql, fridge_ingredients)
            return cursor.fetchall()
    finally:
        conn.close()