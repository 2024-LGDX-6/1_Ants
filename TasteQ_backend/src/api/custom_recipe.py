
# api/custom_recipe.py
from fastapi import APIRouter, HTTPException
from schema.request import CustomRecipeCreateRequest
from schema.response import CustomRecipeResponse
import service.custom_recipe_service as service

router = APIRouter()

@router.post("/custom-recipes", response_model=dict)
def create_custom_recipe(request: CustomRecipeCreateRequest):
    recipe_id = service.create_custom_recipe(request)
    return {"custom_recipe_id": recipe_id}

@router.get("/custom-recipes", response_model=list[CustomRecipeResponse])
def get_all_custom_recipes():
    recipes = service.get_all_custom_recipes()
    if not recipes:
        raise HTTPException(status_code=404, detail="No custom recipes found")
    return recipes

@router.get("/custom-recipes/{recipe_id}", response_model=CustomRecipeResponse)
def get_custom_recipe(recipe_id: int):
    recipe = service.get_custom_recipe_by_id(recipe_id)
    if not recipe:
        raise HTTPException(status_code=404, detail="Custom recipe not found")
    return recipe
