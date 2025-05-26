from fastapi import APIRouter, HTTPException
from schema.response import SeasoningResponse
import service.seasoning_service as seasoning_service

router = APIRouter()

@router.get("/seasonings", response_model=list[SeasoningResponse])
def get_all_seasonings():
    data = seasoning_service.get_all_seasonings()
    return [SeasoningResponse(**row) for row in data]

@router.get("/seasonings/{seasoning_id}", response_model=SeasoningResponse)
def get_seasoning_by_id(seasoning_id: int):
    seasoning = seasoning_service.get_seasoning_by_id(seasoning_id)
    if seasoning is None:
        raise HTTPException(status_code=404, detail="Seasoning not found")
    return SeasoningResponse(**seasoning)
