from fastapi import APIRouter, HTTPException
from schema.response import RecipeSeasoningDetailResponse
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