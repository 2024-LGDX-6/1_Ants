from fastapi import APIRouter, HTTPException, Body
from schema.response import RecipeSeasoningDetailResponse
from schema.request import TasteFeedbackRequest
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

@router.patch("/recipe-feedback", response_model=RecipeSeasoningDetailResponse)
def apply_taste_feedback(request: TasteFeedbackRequest):
    result = service.apply_taste_feedback(request.recipe_id, request.feedback)
    if result is None:
        return {"message": "No adjustment needed (normal taste)"}
    return result