from fastapi import File, APIRouter, UploadFile, Form, HTTPException
from fastapi.responses import Response
from service.custom_recipe_image_service import save_custom_recipe_image, get_custom_recipe_image, get_all_custom_recipe_images
from schema.response import CustomRecipeImageResponse

import mimetypes
from urllib.parse import quote

router = APIRouter(prefix="/custom-recipe-image", tags=["Custom_recipe_image"])

@router.post("/upload")
async def upload_custom_recipe_image(
    custom_recipe_id: int = Form(...),
    custom_image_name: str = Form(...),
    custom_image_file: UploadFile = File(...)
):
    image_id = save_custom_recipe_image(custom_recipe_id, custom_image_name, custom_image_file)
    return {"image_id": image_id, "message": "Custom recipe image uploaded successfully"}


@router.get("/all", response_model=list[CustomRecipeImageResponse])
def get_all_custom_recipe_images_endpoint():
    result = get_all_custom_recipe_images()
    if not result:
        raise HTTPException(status_code=404, detail="No custom recipe images found")
    return result


@router.get("/{custom_recipe_id}")
async def get_custom_recipe_image_by_id(custom_recipe_id: int):
    result = get_custom_recipe_image(custom_recipe_id)
    if not result:
        raise HTTPException(status_code=404, detail="Image not found")

    file_name = result["custom_image_name"]
    media_type = mimetypes.guess_type(file_name)[0] or "application/octet-stream"
    safe_ascii_name = "download.jpg"
    utf8_encoded = quote(file_name)

    return Response(
        content=result["custom_image_data"],
        media_type=media_type,
        headers={
            "Content-Disposition": f"inline; filename={safe_ascii_name}; filename*=UTF-8''{utf8_encoded}"
        }
    )
