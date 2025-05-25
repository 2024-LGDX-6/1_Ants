from fastapi import APIRouter
from database.connection import get_connection

router = APIRouter()

@router.get("/users/test")
def test_users():
    return {"message": "User API is working"}

@router.get("/users")
def get_users():
    conn = get_connection()
    with conn.cursor() as cursor:
        cursor.execute("SELECT * FROM user")
        result = cursor.fetchall()
    conn.close()
    return result
