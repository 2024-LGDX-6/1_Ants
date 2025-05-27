from fastapi import FastAPI
from api import user, seasoning, recipe,  user_seasoning, cooking_log ,cooking_device , custom_recipe ,device_connection_log, custom_recipe_seasoning_detail, recipe_seasoning_detail,speech


app = FastAPI()

# 각 API 라우터 등록
app.include_router(user.router, tags=["User"])
app.include_router(recipe.router, tags=["Recipe"]) 
app.include_router(seasoning.router, tags=["Seasoning"])
app.include_router(user_seasoning.router, tags=["User_seasoning"])
app.include_router(cooking_log.router, tags = ["Cooking_log"])
app.include_router(cooking_device.router, tags = ["Cooking_device"])
app.include_router(custom_recipe.router, tags = ["Costom_recipe"]) 
app.include_router(device_connection_log.router, tags = ["Device_connection_log"])
app.include_router(custom_recipe_seasoning_detail.router, tags = ["Custom_recipe_seasoning_detail"])
app.include_router(recipe_seasoning_detail.router, tags = ["Recipe_seasoning_detail"])
app.include_router(speech.router,tags = ["speech"])