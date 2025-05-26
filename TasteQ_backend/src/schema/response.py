# src/schema/response.py
 # Pydantic 모델
from pydantic import BaseModel


# 사용자 조회 응답용
class UserResponse(BaseModel):
    user_id: int
    name: str
    age: int

class RecipeResponse(BaseModel):
    recipe_id: int
    recipe_name: str
    cook_time_min: int

class SeasoningResponse(BaseModel):
    seasoning_id: int
    seasoning_name: str

class RecipeSeasoningDetailResponse(BaseModel):
    detail_id: int
    seasoning_id: int
    seasoning_name: str
    amount: int
    unit : str
    injection_order: int

class UserSeasoningResponse(BaseModel):
    batch_id: int
    user_id: int
    seasoning_id: int
    amount: int
    unit : str
    injection_order: int

class CookingDeviceResponse(BaseModel):
    device_id: int
    device_name: str
    connection_status: str
    user_id: int

