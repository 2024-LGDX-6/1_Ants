# --- service/cooking_log_service.py ---
from database.connection import get_connection

def create_cooking_log(data):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                INSERT INTO cooking_log (recipe_id, cooking_mode, start_time, servings, recipe_type)
                VALUES (%s, %s, %s, %s, %s)
            """
            cursor.execute(sql, (
                data.recipe_id,
                data.cooking_mode,
                data.start_time,
                data.servings,
                data.recipe_type
            ))
            conn.commit()
            return cursor.lastrowid
    finally:
        conn.close()

def get_all_cooking_logs():
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                SELECT 
                    cl.log_id,
                    cl.recipe_id,
                    r.recipe_name,
                    cl.cooking_mode,
                    cl.start_time,
                    cl.servings,
                    cl.recipe_type
                FROM cooking_log cl
                JOIN recipe r ON cl.recipe_id = r.recipe_id
                ORDER BY cl.start_time DESC
            """
            cursor.execute(sql)
            return cursor.fetchall()
    finally:
        conn.close()

def get_cooking_log_by_id(log_id: int):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                SELECT 
                    cl.log_id,
                    cl.recipe_id,
                    r.recipe_name,
                    cl.cooking_mode,
                    cl.start_time,
                    cl.servings,
                    cl.recipe_type
                FROM cooking_log cl
                JOIN recipe r ON cl.recipe_id = r.recipe_id
                WHERE cl.log_id = %s
            """
            cursor.execute(sql, (log_id,))
            return cursor.fetchone()
    finally:
        conn.close()

