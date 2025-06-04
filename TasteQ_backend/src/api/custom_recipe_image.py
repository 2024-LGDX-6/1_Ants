from fastapi import File, APIRouter, UploadFile, Form, HTTPException
from service.custom_recipe_image_service import (
    save_custom_recipe_image,
    get_custom_recipe_image,
    get_all_custom_recipe_images
)
from schema.response import CustomRecipeImageResponse
from fastapi.responses import JSONResponse

router = APIRouter(prefix="/custom-recipe-image", tags=["Custom_recipe_image"])


@router.post("/upload")
async def upload_custom_recipe_image(
    custom_recipe_id: int = Form(...),
    custom_image_name: str = Form(...),
    image_file: UploadFile = File(...)
):
    image_id = save_custom_recipe_image(custom_recipe_id, custom_image_name, image_file)
    return {"custom_image_id": image_id, "message": "Image uploaded successfully"}


@router.get("/all", response_model=list[CustomRecipeImageResponse])
async def get_all_images():
    result = get_all_custom_recipe_images()
    if not result:
        raise HTTPException(status_code=404, detail="No images found")
    return result


@router.get("/{custom_recipe_id}")
async def get_custom_image_by_recipe_id(custom_recipe_id: int):
    result = get_custom_recipe_image(custom_recipe_id)
    if not result:
        raise HTTPException(status_code=404, detail="Image not found")

    return JSONResponse(
        content={
            "custom_image_name": result["custom_image_name"],
            "custom_image_path": result["custom_image_path"]
        }
    )
