# src/schema/response.py
 # Pydantic 모델
from pydantic import BaseModel
from typing import Optional
from datetime import datetime


# 사용자 조회 응답용
class UserResponse(BaseModel):
    user_id: int
    name: str
    age: int

    class Config:
        from_attributes = True

class RecipeResponse(BaseModel):
    recipe_id: int
    recipe_name: str
    cook_time_min: int
    recipe_link: Optional[str] = None  # 링크는 NULL 허용

    class Config:
        from_attributes = True

class SeasoningResponse(BaseModel):
    seasoning_id: int
    seasoning_name: str

    class Config:
        from_attributes = True

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
        from_attributes = True

class CookingDeviceResponse(BaseModel):
    device_id: int
    device_name: str
    connection_status: str
    user_id: int

class CookingLogResponse(BaseModel):
    log_id: int
    recipe_id: int
    recipe_name: str
    cooking_mode: str
    start_time: datetime
    servings: int
    recipe_type: int

    class Config:
        from_attributes = True


class CookingDeviceResponse(BaseModel):
    device_id: int
    device_name: str | None
    connection_status: str
    user_id: int

    class Config:
        from_attributes = True

class CustomRecipeResponse(BaseModel):
    custom_recipe_id: int
    user_id: int
    custom_recipe_name: str
    cook_time_min: Optional[int] = None

    class Config:
        from_attributes = True

class DeviceConnectionLogResponse(BaseModel):
    device_connection_id: int
    device_id: int
    device_name: str
    connection_status: str
    timestamp: datetime

    class Config:
        from_attributes = True


class CustomRecipeResponse(BaseModel):
    custom_recipe_id: int
    user_id: int
    user_name: str
    custom_recipe_name: str
    cook_time_min: int

    class Config:
        from_attributes = True

class CustomRecipeSeasoningDetailResponse(BaseModel):
    detail_id: int
    custom_recipe_id: int
    custom_recipe_name: str  # JOIN 결과
    seasoning_id: int
    seasoning_name: str      # JOIN 결과
    amount: int
    unit: str
    injection_order: int

    class Config:
        from_attributes = True