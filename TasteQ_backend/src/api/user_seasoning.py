from fastapi import APIRouter, HTTPException
from schema.response import UserSeasoningResponse
import service.user_seasoning_service as service

router = APIRouter()

@router.get("/user-seasonings", response_model=list[UserSeasoningResponse])
def get_all_user_seasonings():
    result = service.get_all_user_seasonings()
    if not result:
        raise HTTPException(status_code=404, detail="No user seasonings found")
    return result


@router.get("/users/{user_id}/seasonings", response_model=list[UserSeasoningResponse])
def get_user_seasonings(user_id: int):
    result = service.get_user_seasonings_by_user_id(user_id)
    if not result:
        raise HTTPException(status_code=404, detail="No seasonings found for this user")
    return result
