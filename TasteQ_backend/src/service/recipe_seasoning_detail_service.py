def get_all_recipe_seasoning_details():
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                SELECT 
                    rsd.detail_id,
                    rsd.recipe_id,
                    r.recipe_name,         -- ✅ 추가
                    rsd.seasoning_id,
                    s.seasoning_name,
                    rsd.amount,
                    rsd.unit,
                    rsd.injection_order
                FROM recipe_seasoning_detail rsd
                JOIN recipe r ON rsd.recipe_id = r.recipe_id    -- ✅ 추가
                JOIN seasoning s ON rsd.seasoning_id = s.seasoning_id
                ORDER BY rsd.recipe_id, rsd.injection_order
            """
            cursor.execute(sql)
            return cursor.fetchall()
    finally:
        conn.close()


def get_recipe_seasoning_details_by_recipe_id(recipe_id: int):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                SELECT 
                    rsd.detail_id,
                    rsd.recipe_id,
                    r.recipe_name,         -- ✅ 추가
                    rsd.seasoning_id,
                    s.seasoning_name,
                    rsd.amount,
                    rsd.unit,
                    rsd.injection_order
                FROM recipe_seasoning_detail rsd
                JOIN recipe r ON rsd.recipe_id = r.recipe_id    -- ✅ 추가
                JOIN seasoning s ON rsd.seasoning_id = s.seasoning_id
                WHERE rsd.recipe_id = %s
                ORDER BY rsd.injection_order
            """
            cursor.execute(sql, (recipe_id,))
            return cursor.fetchall()
    finally:
        conn.close()
