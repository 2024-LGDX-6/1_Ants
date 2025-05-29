from pydantic import BaseModel
from datetime import datetime
from typing import Optional


class CookingLogCreateRequest(BaseModel):
    recipe_id: int
    cooking_mode: str
    start_time: datetime
    servings: int
    recipe_type: int

class CustomRecipeCreateRequest(BaseModel):
    user_id: int
    custom_recipe_name: str
    cook_time_min: Optional[int] = None

class DeviceConnectionLogCreateRequest(BaseModel):
    device_id: int
    connection_status: str  # 'on' or 'off'
    timestamp: datetime

class CustomRecipeCreateRequest(BaseModel):
    user_id: int
    custom_recipe_name: str
    cook_time_min: int

class CustomRecipeSeasoningDetailCreateRequest(BaseModel):
    custom_recipe_id: int
    seasoning_id: int
    amount: int
    unit: str
    injection_order: int


class UserFridgeCreateRequest(BaseModel):
    device_id: int
    fridge_Ingredients: str


class UserFridgeDeleteRequest(BaseModel):
    device_id: int
    fridge_Ingredients: str