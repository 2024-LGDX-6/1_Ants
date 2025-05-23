# src/database/connection.py
# DB 연결/세션 관련
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from typing import Generator
import os
from dotenv import load_dotenv
from urllib.parse import quote_plus

load_dotenv()                           # .env 로드

# ---------- 환경변수 읽기 ----------
user = os.getenv("MYSQL_USER")
pw_raw = os.getenv("MYSQL_PW")
host = os.getenv("MYSQL_HOST", "127.0.0.1")
port = os.getenv("MYSQL_PORT", "3307")
db   = os.getenv("MYSQL_DB")

if None in (user, pw_raw, db):
    raise RuntimeError("MYSQL 환경변수가 누락되었습니다 (.env 확인)")
pw = quote_plus(pw_raw)                 

DATABASE_URL = f"mysql+pymysql://{user}:{pw}@{host}:{port}/{db}"

# ---------- SQLAlchemy 엔진 ----------
_engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,
    echo=False          # SQL 로그 보고 싶으면 True uvicorn실행시에 쭈루룩 나올거임임
)

SessionFactory = sessionmaker(bind=_engine, autocommit=False, autoflush=False)

def get_db() -> Generator[Session, None, None]:
    
    db = SessionFactory()
    try:
        yield db
    finally:
        db.close()
