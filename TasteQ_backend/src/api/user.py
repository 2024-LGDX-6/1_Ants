from fastapi import APIRouter, HTTPException
from schema.response import UserResponse
import service.user_service as user_service

router = APIRouter()

@router.get("/users", response_model=list[UserResponse])
def get_users():
    return user_service.get_all_users()

@router.get("/users/{user_id}", response_model=UserResponse)
def get_user_by_id(user_id: int):
    user = user_service.get_user_by_id(user_id)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return user