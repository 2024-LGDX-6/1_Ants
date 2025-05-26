# src/service/device_connection_log_service.py
from database.connection import get_connection

def create_device_connection_log(device_id: int, connection_status: str, timestamp):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                INSERT INTO device_connection_log (device_id, connection_status, timestamp)
                VALUES (%s, %s, %s)
            """
            cursor.execute(sql, (device_id, connection_status, timestamp))
            conn.commit()
            return cursor.lastrowid
    finally:
        conn.close()

def get_all_device_connection_logs():
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                SELECT dcl.device_connection_id, dcl.device_id, cd.device_name,
                       dcl.connection_status, dcl.timestamp
                FROM device_connection_log dcl
                JOIN cooking_device cd ON dcl.device_id = cd.device_id
                ORDER BY dcl.timestamp DESC
            """
            cursor.execute(sql)
            return cursor.fetchall()
    finally:
        conn.close()

def get_device_connection_logs_by_device(device_id: int):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                SELECT dcl.device_connection_id, dcl.device_id, cd.device_name,
                       dcl.connection_status, dcl.timestamp
                FROM device_connection_log dcl
                JOIN cooking_device cd ON dcl.device_id = cd.device_id
                WHERE dcl.device_id = %s
                ORDER BY dcl.timestamp DESC
            """
            cursor.execute(sql, (device_id,))
            return cursor.fetchall()
    finally:
        conn.close()
