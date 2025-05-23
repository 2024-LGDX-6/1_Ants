# src/schema/response.py
 # Pydantic 모델
from pydantic import BaseModel


class UserSchema(BaseModel):
    id: int
    username: str

    class Config:
        from_attributes = True

class TokenSchema(BaseModel):    
    access_token: str
