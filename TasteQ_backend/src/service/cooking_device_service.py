# service/cooking_device_service.py
from database.connection import get_connection

def get_all_cooking_devices():
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                SELECT 
                    cd.device_id, 
                    cd.device_name, 
                    cd.connection_status, 
                    cd.user_id,
                    u.name AS user_name
                FROM cooking_device cd
                JOIN user u ON cd.user_id = u.user_id
                ORDER BY cd.device_id
            """
            cursor.execute(sql)
            return cursor.fetchall()
    finally:
        conn.close()


def get_cooking_device_by_id(device_id: int):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                SELECT 
                    cd.device_id, 
                    cd.device_name, 
                    cd.connection_status, 
                    cd.user_id,
                    u.name AS user_name
                FROM cooking_device cd
                JOIN user u ON cd.user_id = u.user_id
                WHERE cd.device_id = %s
            """
            cursor.execute(sql, (device_id,))
            return cursor.fetchone()
    finally:
        conn.close()

