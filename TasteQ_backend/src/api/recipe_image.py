# api/recipe_image_router.py
from fastapi import File, APIRouter, UploadFile, Form, HTTPException
from service.recipe_image_service import (
    save_recipe_image,
    get_recipe_image,
    get_all_recipe_images as fetch_all_recipe_images
)
from schema.response import RecipeImageResponse
from fastapi.responses import JSONResponse
import os

router = APIRouter(prefix="/recipe-image", tags=["Recipe_image"])


@router.post("/upload")
async def upload_recipe_image(
    recipe_id: int = Form(...),
    image_name: str = Form(...),
    image_file: UploadFile = File(...)
):
    image_id = save_recipe_image(recipe_id, image_name, image_file)
    return {"image_id": image_id, "message": "Image uploaded successfully"}


@router.get("/all", response_model=list[RecipeImageResponse])
async def get_all_recipe_images():
    result = fetch_all_recipe_images()
    if not result:
        raise HTTPException(status_code=404, detail="No images found")
    return result


@router.get("/{recipe_id}")
async def get_recipe_image_by_id(recipe_id: int):
    result = get_recipe_image(recipe_id)
    if not result:
        raise HTTPException(status_code=404, detail="Image not found")

    # 이미지가 저장된 상대 경로 (예: /static/recipe_images/xxx.jpg)
    image_url_path = result["image_path"]

    # 예: http://localhost:8000/static/recipe_images/파일명.jpg
    # 프론트에서는 이 경로를 <img src="..."> 로 사용하면 됨
    return JSONResponse(
        content={
            "image_name": result["image_name"],
            "image_url": image_url_path
        }
    )
