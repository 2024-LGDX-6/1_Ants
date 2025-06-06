# src/schema/response.py
 # Pydantic 모델
from pydantic import BaseModel, field_serializer
from typing import Optional
from datetime import datetime
from typing import List

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
    recipe_link: Optional[str] = None
    main_ingredient: Optional[str] = None  # ✅ 수정 필요

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
    amount: float
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
    cooking_mode: str  # 문자열로 DB에서 받아오지만, 응답 시 숫자로 변환
    start_time: datetime
    servings: int
    recipe_type: int

    @field_serializer("cooking_mode")
    def serialize_cooking_mode(self, value: str, _info) -> int:
        mode_map = {"표준": 0, "웰빙": 1, "미식": 2}
        return mode_map.get(value, -1)  # -1은 예외 처리용

    class Config:
        from_attributes = True


class CookingDeviceResponse(BaseModel):
    device_id: int
    device_name: str | None
    connection_status: str
    user_id: int

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
    custom_main_ingredient: str

    class Config:
        from_attributes = True

class CustomRecipeSeasoningDetailResponse(BaseModel):
    detail_id: int
    custom_recipe_id: int
    custom_recipe_name: str  # JOIN 결과
    seasoning_id: int
    seasoning_name: str      # JOIN 결과
    amount: float
    unit: str
    injection_order: int

    class Config:
        from_attributes = True


class UserFridgeResponse(BaseModel):
    fridge_Ingredients_id: int
    device_id: int
    device_name: str
    user_id: int
    user_name: str
    fridge_Ingredients: str

    class Config:
        from_attributes = True


class RecipeImageResponse(BaseModel):
    image_id: int
    recipe_id: int
    image_name: str
    image_path: str  # ✅ 파일 경로 추가

    class Config:
        from_attributes = True

class CustomRecipeImageResponse(BaseModel):
    custom_image_id: int
    custom_recipe_id: int
    custom_recipe_name: str  # JOIN된 결과
    custom_image_name: str
    custom_image_path: str

    class Config:
        from_attributes = True




class MessageResponse(BaseModel):
    message: str

class NounsResponse(BaseModel):
    nouns: List[str]