from fastapi import APIRouter, HTTPException
from schema.response import RecipeResponse
import service.recipe_service as recipe_service
from schema.response import RecipeSeasoningDetailResponse

router = APIRouter()

@router.get("/recipes", response_model=list[RecipeResponse])
def get_recipes():
    recipes = recipe_service.get_all_recipes()
    if not recipes:
        raise HTTPException(status_code=404, detail="No recipes found")
    return recipes


@router.get("/recipes/{recipe_id}", response_model=RecipeResponse)
def get_recipe(recipe_id: int):
    recipe = recipe_service.get_recipe_by_id(recipe_id)
    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")
    return recipe

