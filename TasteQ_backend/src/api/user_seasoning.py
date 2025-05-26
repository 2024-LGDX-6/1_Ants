from fastapi import APIRouter
from schema.request import UserSeasoningCreateRequest
from schema.response import UserSeasoningResponse
import service.user_seasoning_service as user_seasoning_service

router = APIRouter()

@router.post("/user-seasonings", response_model=int)
def create_user_seasoning(request: UserSeasoningCreateRequest):
    return user_seasoning_service.create_user_seasoning(
        request.user_id,
        request.seasoning_id,
        request.amount,
        request.unit,
        request.injection_order
    )

@router.get("/user-seasonings/{user_id}", response_model=list[UserSeasoningResponse])
def get_user_seasonings(user_id: int):
    return user_seasoning_service.get_user_seasonings_by_user_id(user_id)