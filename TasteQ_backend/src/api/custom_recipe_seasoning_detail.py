from fastapi import APIRouter, HTTPException
from schema.request import CustomRecipeSeasoningDetailCreateRequest, CustomRecipeTasteFeedbackRequest
from schema.response import CustomRecipeSeasoningDetailResponse, MessageResponse
import service.custom_recipe_seasoning_detail_service as service
from typing import Union

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

@router.patch(
    "/custom-recipes/feedback",
    response_model=Union[list[CustomRecipeSeasoningDetailResponse], MessageResponse]
)
def apply_custom_feedback(request: CustomRecipeTasteFeedbackRequest):
    result = service.apply_custom_recipe_taste_feedback(
        request.custom_recipe_id, request.feedback
    )
    if result == []:
        return {"message": "No adjustment needed (normal taste)"}
    if result is None:
        raise HTTPException(status_code=404, detail="No matching seasoning details to update")
    return result