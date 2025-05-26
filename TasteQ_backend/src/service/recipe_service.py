from database.connection import get_connection

def get_all_recipes():
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = "SELECT recipe_id, recipe_name, cook_time_min, recipe_link FROM recipe"
            cursor.execute(sql)
            return cursor.fetchall()
    finally:
        conn.close()


def get_recipe_by_id(recipe_id: int):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = "SELECT recipe_id, recipe_name, cook_time_min, recipe_link FROM recipe WHERE recipe_id = %s"
            cursor.execute(sql, (recipe_id,))
            return cursor.fetchone()
    finally:
        conn.close()
