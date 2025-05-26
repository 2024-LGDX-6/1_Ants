# src/api/device_connection_log.py
from fastapi import APIRouter, HTTPException
from schema.request import DeviceConnectionLogCreateRequest
from schema.response import DeviceConnectionLogResponse
import service.device_connection_log_service as service

router = APIRouter()

@router.post("/device-connection-logs")
def create_log(log: DeviceConnectionLogCreateRequest):
    log_id = service.create_device_connection_log(
        device_id=log.device_id,
        connection_status=log.connection_status,
        timestamp=log.timestamp
    )
    return {"device_connection_id": log_id}

@router.get("/device-connection-logs", response_model=list[DeviceConnectionLogResponse])
def get_logs():
    logs = service.get_all_device_connection_logs()
    if not logs:
        raise HTTPException(status_code=404, detail="No connection logs found")
    return logs

@router.get("/device-connection-logs/{device_id}", response_model=list[DeviceConnectionLogResponse])
def get_logs_by_device(device_id: int):
    logs = service.get_device_connection_logs_by_device(device_id)
    if not logs:
        raise HTTPException(status_code=404, detail="No logs for this device")
    return logs
