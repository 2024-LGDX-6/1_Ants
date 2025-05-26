from fastapi import FastAPI
from api import user, seasoning, recipe,  user_seasoning

app = FastAPI()

# 각 API 라우터 등록
app.include_router(user.router, tags=["User"])
app.include_router(recipe.router, tags=["Recipe"]) 
app.include_router(seasoning.router, tags=["Seasoning"])
app.include_router(user_seasoning.router, tags=["User_seasoning"])
