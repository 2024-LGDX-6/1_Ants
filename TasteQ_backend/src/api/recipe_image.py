from fastapi import File, APIRouter, UploadFile, Form, HTTPException
from fastapi.responses import Response
from service.recipe_image_service import save_recipe_image, get_recipe_image
import mimetypes
from urllib.parse import quote

router = APIRouter(prefix="/recipe-image", tags=["Recipe_image"])

@router.post("/upload")
async def upload_recipe_image(
    recipe_id: int = Form(...),
    image_name: str = Form(...),
    image_file: UploadFile = File(...)
):
    image_id = save_recipe_image(recipe_id, image_name, image_file)
    return {"image_id": image_id, "message": "Image uploaded successfully"}


@router.get("/{recipe_id}")
async def get_recipe_image_by_id(recipe_id: int):
    result = get_recipe_image(recipe_id)
    if not result:
        raise HTTPException(status_code=404, detail="Image not found")

    # MIME 타입 자동 감지
    file_name = result["image_name"]
    media_type = mimetypes.guess_type(file_name)[0] or "application/octet-stream"
    
    safe_ascii_name = "download.jpg"  # 또는 slugify 처리한 이름
    utf8_encoded = quote(file_name)


    return Response(
        content=result["image_data"],
        media_type=media_type,
        headers = {
            "Content-Disposition": f"inline; filename={safe_ascii_name}; filename*=UTF-8''{utf8_encoded}"
        }
    )
