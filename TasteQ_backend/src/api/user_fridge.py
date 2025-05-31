from fastapi import APIRouter, HTTPException
from schema.request import UserFridgeCreateRequest
from schema.response import UserFridgeResponse
import service.user_fridge_service as user_fridge_service
from schema.request import UserFridgeDeleteRequest


router = APIRouter()

@router.post("/user-fridge", response_model=int)
def create_user_fridge(request: UserFridgeCreateRequest):
    return user_fridge_service.create_user_fridge(request.device_id, request.fridge_Ingredients)


@router.get("/user-fridge/{user_id}", response_model=list[UserFridgeResponse])
def get_user_fridge(user_id: int):
    result = user_fridge_service.get_user_fridge_by_user_id(user_id)
    if not result:
        raise HTTPException(status_code=404, detail="No fridge ingredients found")
    return result


@router.delete("/user-fridge", response_model=int)
def delete_fridge_ingredient(device_id: int, ingredient: str):
    deleted_count = user_fridge_service.delete_fridge_ingredient(
        device_id, ingredient
    )
    if deleted_count == 0:
        raise HTTPException(status_code=404, detail="Ingredient not found in fridge")
    return deleted_count