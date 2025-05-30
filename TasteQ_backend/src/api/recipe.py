from fastapi import APIRouter, HTTPException
from schema.response import RecipeResponse
import service.recipe_service as recipe_service
from fastapi import Query
from typing import List, Union

router = APIRouter()

@router.get("/recipes", response_model=list[RecipeResponse])
def get_recipes():
    recipes = recipe_service.get_all_recipes()
    if not recipes:
        raise HTTPException(status_code=404, detail="No recipes found")
    return recipes


@router.get("/recipes/search", response_model=List[RecipeResponse])
def search_recipes_by_main_ingredients(
    ingredients: Union[List[str], str] = Query(..., description="주재료 이름 (복수 가능)")
):
    # 단일 문자열이 들어오면 리스트로 변환
    if isinstance(ingredients, str):
        ingredients = [ingredients]

    recipes = recipe_service.get_recipes_by_main_ingredients(ingredients)
    if not recipes:
        raise HTTPException(
            status_code=404,
            detail=f"No recipes found with main ingredients: {', '.join(ingredients)}"
        )
    return recipes


@router.get("/recipes/by-user-fridge/{user_id}", response_model=List[RecipeResponse])
def search_recipes_by_user_fridge(user_id: int):
    recipes = recipe_service.get_recipes_by_user_fridge(user_id)
    if not recipes:
        raise HTTPException(status_code=404, detail="No matching recipes found for user’s fridge ingredients")
    return recipes


@router.get("/recipes/by-recipe-name/{recipe_name}", response_model=RecipeResponse)
def get_recipe(recipe_name: str):
    recipe = recipe_service.get_recipe_by_name(recipe_name)
    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")
    return recipe


@router.get("/recipes/{recipe_id}", response_model=RecipeResponse)
def get_recipe(recipe_id: int):
    recipe = recipe_service.get_recipe_by_id(recipe_id)
    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")
    return recipe
