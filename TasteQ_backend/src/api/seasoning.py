from fastapi import APIRouter
from database.connection import get_connection

router = APIRouter()

@router.get("/seasonings/test")
def test_seasonings():
    return {"message": "Seasoning API is working"}

@router.get("/seasonings")
def get_seasonings():
    conn = get_connection()
    with conn.cursor() as cursor:
        cursor.execute("SELECT * FROM seasoning")
        result = cursor.fetchall()
    conn.close()
    return result
