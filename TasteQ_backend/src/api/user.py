from fastapi import APIRouter, HTTPException
from schema.response import UserResponse
import service.user_service as user_service

router = APIRouter()

@router.get("/users", response_model=list[UserResponse])
def get_users():
    users = user_service.get_all_users()
    if not users:
        raise HTTPException(status_code=404, detail="No users found")
    return users

@router.get("/users/{user_id}", response_model=UserResponse)
def get_user_by_id(user_id: int):
    user = user_service.get_user_by_id(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user