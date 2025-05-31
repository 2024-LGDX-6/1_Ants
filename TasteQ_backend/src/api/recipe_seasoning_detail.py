from fastapi import APIRouter, HTTPException, Body
from schema.response import RecipeSeasoningDetailResponse
from schema.request import SeasoningFeedbackRequest
import service.recipe_seasoning_detail_service as service

router = APIRouter()

@router.get("/recipe-seasoning-details", response_model=list[RecipeSeasoningDetailResponse])
def get_all_recipe_seasoning_details():
    details = service.get_all_recipe_seasoning_details()
    if not details:
        raise HTTPException(status_code=404, detail="No recipe seasoning details found")
    return details


@router.get("/recipes/{recipe_id}/seasoning-details", response_model=list[RecipeSeasoningDetailResponse])
def get_recipe_seasoning_details(recipe_id: int):
    details = service.get_recipe_seasoning_details_by_recipe_id(recipe_id)
    if not details:
        raise HTTPException(status_code=404, detail="No seasoning details found for this recipe")
    return details

@router.patch("/recipes/{recipe_id}/seasonings/{seasoning_id}", response_model=RecipeSeasoningDetailResponse)
def update_seasoning_amount(recipe_id: int, seasoning_id: int, request: SeasoningFeedbackRequest):
    scale_map = {
        "increase": 1.2,
        "decrease": 0.8
    }
    scale = scale_map[request.feedback_type]
    updated_detail = service.update_seasoning_amount_by_recipe(recipe_id, seasoning_id, scale)
    if not updated_detail:
        raise HTTPException(status_code=404, detail="Detail not found")
    return updated_detail