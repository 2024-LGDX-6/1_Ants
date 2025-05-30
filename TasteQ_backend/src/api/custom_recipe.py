
# api/custom_recipe.py
from fastapi import APIRouter, HTTPException
from schema.request import CustomRecipeCreateRequest
from schema.response import CustomRecipeResponse
import service.custom_recipe_service as service

from fastapi import Query
from typing import List, Union


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

@router.get("/custom-recipes/search", response_model=List[CustomRecipeResponse])
def search_custom_recipes_by_main_ingredients(
    ingredients: List[str] = Query(..., description="주재료 이름들")
):
    recipes = service.get_custom_recipes_by_main_ingredients(ingredients)
    if not recipes:
        raise HTTPException(status_code=404, detail="No custom recipes found for given ingredients")
    return recipes

@router.get("/custom-recipes/by-user-fridge/{user_id}", response_model=List[CustomRecipeResponse])
def search_custom_recipes_by_user_fridge(user_id: int):
    recipes = service.get_custom_recipes_by_user_fridge(user_id)
    if not recipes:
        raise HTTPException(status_code=404, detail="No custom recipes found based on user's fridge")
    return recipes


# 레시피 이름으로 복수 검색
@router.get("/custom-recipes/by-names", response_model=List[CustomRecipeResponse])
def get_custom_recipes_by_names(
    names: Union[List[str], str] = Query(..., description="레시피 이름 (복수 가능)")
):
    if isinstance(names, str):
        names = [names]

    recipes = service.get_custom_recipes_by_name(names)
    if not recipes:
        raise HTTPException(
            status_code=404,
            detail=f"No custom recipes found with names: {', '.join(names)}"
        )
    return recipes



@router.get("/custom-recipes/{recipe_id}", response_model=CustomRecipeResponse)
def get_custom_recipe(recipe_id: int):
    recipe = service.get_custom_recipe_by_id(recipe_id)
    if not recipe:
        raise HTTPException(status_code=404, detail="Custom recipe not found")
    return recipe

