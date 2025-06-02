from database.connection import get_connection

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


def update_seasoning_amount_by_recipe(recipe_id: int, seasoning_id: int, scale: float):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            # update
            update_sql = """
                UPDATE recipe_seasoning_detail
                SET amount = amount * %s
                WHERE recipe_id = %s AND seasoning_id = %s
            """
            cursor.execute(update_sql, (scale, recipe_id, seasoning_id))
            if cursor.rowcount == 0:
                return None
            conn.commit()

            # 변경된 row 다시 조회
            select_sql = """
                SELECT 
                    rsd.detail_id,
                    rsd.recipe_id,
                    r.recipe_name,
                    rsd.seasoning_id,
                    s.seasoning_name,
                    rsd.amount,
                    rsd.unit,
                    rsd.injection_order
                FROM recipe_seasoning_detail rsd
                JOIN recipe r ON rsd.recipe_id = r.recipe_id
                JOIN seasoning s ON rsd.seasoning_id = s.seasoning_id
                WHERE rsd.recipe_id = %s AND rsd.seasoning_id = %s
            """
            cursor.execute(select_sql, (recipe_id, seasoning_id))
            return cursor.fetchone()
    finally:
        conn.close()

def apply_taste_feedback(recipe_id: int, feedback: str):
    feedback_rules = {
        "달았어요": {"seasoning_id": 2, "scale": 0.9},
        "짰어요": {"seasoning_id": 3, "scale": 0.9},
        "매웠어요": {"seasoning_id": 1, "scale": 0.9},
        "싱거웠어요": {"seasoning_id": 3, "scale": 1.1},
        "좋았어요": None
    }

    rule = feedback_rules.get(feedback)
    if rule is None:
        return None  # '좋았어요'인 경우 변경 없음

    return update_seasoning_amount_by_recipe(recipe_id, rule["seasoning_id"], rule["scale"])