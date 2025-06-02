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


def apply_custom_recipe_taste_feedback(custom_recipe_id: int, feedback: str):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            # 조건 매핑
            feedback_map = {
                "달았어요": (2, 0.9),   # 단맛 줄임 (seasoning_id=2)
                "짰어요":   (3, 0.9),   # 짠맛 줄임 (seasoning_id=3)
                "매웠어요": (1, 0.9),   # 매운맛 줄임 (seasoning_id=1)
                "싱거웠어요": (3, 1.1),  # 짠맛 늘림 (seasoning_id=3)
                "좋았어요":     (None, 1.0) # 변경 없음
            }

            if feedback not in feedback_map:
                return None

            seasoning_id, scale = feedback_map[feedback]
            if seasoning_id is None or scale == 1.0:
                return []  # 변경 없음

            # update
            cursor.execute("""
                UPDATE custom_recipe_seasoning_detail
                SET amount = amount * %s
                WHERE custom_recipe_id = %s AND seasoning_id = %s
            """, (scale, custom_recipe_id, seasoning_id))
            if cursor.rowcount == 0:
                return None
            conn.commit()

            # 변경된 데이터 반환
            cursor.execute("""
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
                WHERE csd.custom_recipe_id = %s AND csd.seasoning_id = %s
            """, (custom_recipe_id, seasoning_id))
            return cursor.fetchall()
    finally:
        conn.close()