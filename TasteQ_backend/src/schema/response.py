# src/schema/response.py
 # Pydantic 모델
from pydantic import BaseModel
from typing import Optional

# 사용자 조회 응답용
class UserResponse(BaseModel):
    user_id: int
    name: str
    age: int

    class Config:
        orm_mode = True

class RecipeResponse(BaseModel):
    recipe_id: int
    recipe_name: str
    cook_time_min: int
    recipe_link: Optional[str] = None  # 링크는 NULL 허용

    class Config:
        orm_mode = True

class SeasoningResponse(BaseModel):
    seasoning_id: int
    seasoning_name: str

    class Config:
        orm_mode = True

class RecipeSeasoningDetailResponse(BaseModel):
    detail_id: int
    recipe_id: int
    recipe_name: str
    seasoning_id: int
    seasoning_name: str
    amount: int
    unit: str
    injection_order: int

    class Config:
        from_attributes = True  # Pydantic v2 기준 (orm_mode=True 대체)


class UserSeasoningResponse(BaseModel):
    batch_id: int
    user_id: int
    user_name: str            # from user.name
    seasoning_id: int
    seasoning_name: str       # from seasoning.seasoning_name

    class Config:
        orm_mode = True

class CookingDeviceResponse(BaseModel):
    device_id: int
    device_name: str
    connection_status: str
    user_id: int

