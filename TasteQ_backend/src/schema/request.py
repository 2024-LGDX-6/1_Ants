from pydantic import BaseModel,validator
from datetime import datetime
from typing import Optional, Union
from enum import Enum

class CookingLogCreateRequest(BaseModel):
    recipe_id: int
    cooking_mode: Union[str, int]  # 숫자 또는 문자열 입력 가능
    servings: int
    recipe_type: int

    @validator("cooking_mode", pre=True)
    def convert_cooking_mode(cls, v):
        mode_map = {
            0: "표준",
            1: "웰빙",
            2: "미식"
        }
        if isinstance(v, int):
            return mode_map.get(v, "unknown")
        return v

class DeviceConnectionLogCreateRequest(BaseModel):
    device_id: int
    connection_status: str  # 'on' or 'off'
    timestamp: datetime

class CustomRecipeCreateRequest(BaseModel):
    user_id: int
    custom_recipe_name: str
    cook_time_min: int
    custom_main_ingredient: str

class CustomRecipeSeasoningDetailCreateRequest(BaseModel):
    custom_recipe_id: int
    seasoning_id: int
    amount: float
    unit: str
    injection_order: int


class UserFridgeCreateRequest(BaseModel):
    device_id: int
    fridge_Ingredients: str


class UserFridgeDeleteRequest(BaseModel):
    device_id: int
    fridge_Ingredients: str


class RecipeImageRequest(BaseModel):
    recipe_id: int
    image_name: str
    image_path: str  # ✅ 추가: 실제 저장된 경로


class TasteFeedbackType(str, Enum):
    sweet = "달았어요"
    salty = "짰어요"
    spicy = "매웠어요"
    bland = "싱거웠어요"
    normal = "좋았어요"

class TasteFeedbackRequest(BaseModel):
    recipe_id: int
    feedback: TasteFeedbackType

class CustomRecipeTasteFeedbackRequest(BaseModel):
    custom_recipe_id: int
    feedback: TasteFeedbackType


class CustomRecipeImageCreateRequest(BaseModel):
    custom_recipe_id: int
    custom_image_name: str
    custom_image_path: str  # ✅ 새로 추가된 필드 (파일 경로 또는 URL)

