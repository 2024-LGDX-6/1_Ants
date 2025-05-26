
# --- api/cooking_log.py ---
from fastapi import APIRouter, HTTPException
from schema.request import CookingLogCreateRequest
from schema.response import CookingLogResponse
import service.cooking_log_service as service

router = APIRouter()

@router.post("/cooking-logs", response_model=int)
def create_cooking_log(request: CookingLogCreateRequest):
    log_id = service.create_cooking_log(request)
    return log_id

@router.get("/cooking-logs", response_model=list[CookingLogResponse])
def get_all_cooking_logs():
    logs = service.get_all_cooking_logs()
    if not logs:
        raise HTTPException(status_code=404, detail="No cooking logs found")
    return logs

@router.get("/cooking-logs/{log_id}", response_model=CookingLogResponse)
def get_cooking_log_by_id(log_id: int):
    log = service.get_cooking_log_by_id(log_id)
    if not log:
        raise HTTPException(status_code=404, detail="Cooking log not found")
    return log
