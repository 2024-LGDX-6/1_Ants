from pydantic import BaseModel

class UserCreateRequest(BaseModel):
    name: str
    age: int

class RecipeCreateRequest(BaseModel):
    name: str
    description: str

class SeasoningCreateRequest(BaseModel):
    seasoning_id: int
    seasoning_name: str

class UserSeasoningCreateRequest(BaseModel):
    user_id: int
    seasoning_id: int
    amount: int
    unit : str
    injection_order: int