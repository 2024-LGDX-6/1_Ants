from fastapi import APIRouter, HTTPException
from schema.request import CustomRecipeSeasoningDetailCreateRequest
from schema.response import CustomRecipeSeasoningDetailResponse
import service.custom_recipe_seasoning_detail_service as service

router = APIRouter()

@router.post("/custom-recipe-seasoning-details")
def create_custom_detail(data: CustomRecipeSeasoningDetailCreateRequest):
    service.create_custom_recipe_seasoning_detail(data)
    return {"message": "Custom recipe seasoning detail created successfully"}

@router.get("/custom-recipe-seasoning-details", response_model=list[CustomRecipeSeasoningDetailResponse])
def get_all_details():
    results = service.get_all_custom_recipe_seasoning_details()
    if not results:
        raise HTTPException(status_code=404, detail="No data found")
    return results

@router.get("/custom-recipes/{custom_recipe_id}/seasoning-details", response_model=list[CustomRecipeSeasoningDetailResponse])
def get_by_recipe_id(custom_recipe_id: int):
    results = service.get_custom_recipe_seasoning_details_by_recipe_id(custom_recipe_id)
    if not results:
        raise HTTPException(status_code=404, detail="No data for that custom recipe")
    return results
