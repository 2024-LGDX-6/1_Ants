from fastapi import APIRouter, HTTPException
from schema.response import SeasoningResponse
import service.seasoning_service as seasoning_service

router = APIRouter()

@router.get("/seasonings", response_model=list[SeasoningResponse])
def get_all_seasonings():
    seasonings = seasoning_service.get_all_seasonings()
    if not seasonings:
        raise HTTPException(status_code=404, detail="No seasonings found")
    return seasonings


@router.get("/seasonings/{seasoning_id}", response_model=SeasoningResponse)
def get_seasoning(seasoning_id: int):
    seasoning = seasoning_service.get_seasoning_by_id(seasoning_id)
    if not seasoning:
        raise HTTPException(status_code=404, detail="Seasoning not found")
    return seasoning