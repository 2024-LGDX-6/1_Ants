from fastapi import FastAPI
from api import user, seasoning, recipe

app = FastAPI()

# 각 API 라우터 등록
app.include_router(user.router)
app.include_router(seasoning.router)
app.include_router(recipe.router)
