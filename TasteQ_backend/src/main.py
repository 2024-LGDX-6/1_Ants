# main.py
from fastapi import FastAPI
from api.auth import router as auth_router
from database.orm import Base
from database.connection import _engine  # 내부 객체 직접 사용
from api.user_info import router as user_router

app = FastAPI()
app.include_router(auth_router)
app.include_router(user_router)

@app.on_event("startup")
def on_startup():
    # 테이블이 없으면 자동 생성
    print("▶ create_all called")
    Base.metadata.create_all(bind=_engine)


@app.get("/")
def hello_404():
    return {"status": "ok"}

