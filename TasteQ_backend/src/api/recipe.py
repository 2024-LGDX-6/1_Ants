from fastapi import APIRouter, HTTPException
from schema.request import RecipeCreateRequest
from schema.response import RecipeResponse, RecipeSeasoningDetailResponse
import service.recipe_service as recipe_service

router = APIRouter()

@router.post("/recipes", response_model=RecipeResponse)
def create_recipe(recipe: RecipeCreateRequest):
    recipe_id = recipe_service.create_recipe(recipe.name, recipe.description)
    return RecipeResponse(recipe_id=recipe_id, name=recipe.name, description=recipe.description)


@router.get("/recipes/{recipe_id}", response_model=RecipeResponse)
def get_recipe_by_id(recipe_id: int):
    recipe_data = recipe_service.get_recipe_by_id(recipe_id)
    if not recipe_data:
        raise HTTPException(status_code=404, detail="Recipe not found")
    return RecipeResponse(**recipe_data)


@router.get("/recipes/{recipe_id}/seasoning-details", response_model=list[RecipeSeasoningDetailResponse])
def get_recipe_seasoning_details(recipe_id: int):
    data = recipe_service.get_recipe_seasoning_details(recipe_id)
    if not data:
        raise HTTPException(status_code=404, detail="No seasoning details found for this recipe")
    return [RecipeSeasoningDetailResponse(**row) for row in data]