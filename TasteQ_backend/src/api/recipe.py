from fastapi import APIRouter
from database.connection import get_connection

router = APIRouter()

@router.get("/recipes/test")
def test_recipes():
    return {"message": "Recipe API is working"}

@router.get("/recipes")
def get_recipes():
    conn = get_connection()
    with conn.cursor() as cursor:
        cursor.execute("SELECT * FROM recipe")
        result = cursor.fetchall()
    conn.close()
    return result

@router.get("/recipes/{recipe_id}/seasonings")
def get_recipe_seasonings(recipe_id: int):
    conn = None
    try:
        conn = get_connection()
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT s.seasoning_name, d.amount
                FROM recipe_seasoning_detail d
                JOIN seasoning s ON d.seasoning_id = s.seasoning_id
                WHERE d.recipe_id = %s
            """, (recipe_id,))
            result = cursor.fetchall()
        return result
    except Exception as e:
        # 예외 메시지를 응답으로 보여줌
        return {"error": str(e)}
    finally:
        if conn is not None:
            conn.close()

