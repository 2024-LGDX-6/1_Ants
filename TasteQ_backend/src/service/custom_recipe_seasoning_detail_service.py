from database.connection import get_connection

def create_custom_recipe_seasoning_detail(data):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                INSERT INTO custom_recipe_seasoning_detail (
                    custom_recipe_id, seasoning_id, amount, unit, injection_order
                ) VALUES (%s, %s, %s, %s, %s)
            """
            cursor.execute(sql, (
                data.custom_recipe_id,
                data.seasoning_id,
                data.amount,
                data.unit,
                data.injection_order
            ))
            conn.commit()
    finally:
        conn.close()


def get_all_custom_recipe_seasoning_details():
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                SELECT 
                    csd.detail_id,
                    csd.custom_recipe_id,
                    cr.custom_recipe_name,
                    csd.seasoning_id,
                    s.seasoning_name,
                    csd.amount,
                    csd.unit,
                    csd.injection_order
                FROM custom_recipe_seasoning_detail csd
                JOIN custom_recipe cr ON csd.custom_recipe_id = cr.custom_recipe_id
                JOIN seasoning s ON csd.seasoning_id = s.seasoning_id
                ORDER BY csd.custom_recipe_id, csd.injection_order
            """
            cursor.execute(sql)
            return cursor.fetchall()
    finally:
        conn.close()


def get_custom_recipe_seasoning_details_by_recipe_id(custom_recipe_id: int):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                SELECT 
                    csd.detail_id,
                    csd.custom_recipe_id,
                    cr.custom_recipe_name,
                    csd.seasoning_id,
                    s.seasoning_name,
                    csd.amount,
                    csd.unit,
                    csd.injection_order
                FROM custom_recipe_seasoning_detail csd
                JOIN custom_recipe cr ON csd.custom_recipe_id = cr.custom_recipe_id
                JOIN seasoning s ON csd.seasoning_id = s.seasoning_id
                WHERE csd.custom_recipe_id = %s
                ORDER BY csd.injection_order
            """
            cursor.execute(sql, (custom_recipe_id,))
            return cursor.fetchall()
    finally:
        conn.close()
