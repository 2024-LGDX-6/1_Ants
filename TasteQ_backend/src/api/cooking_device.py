
# api/cooking_device.py
from fastapi import APIRouter, HTTPException
from schema.response import CookingDeviceResponse
import service.cooking_device_service as service

router = APIRouter()

@router.get("/cooking-devices", response_model=list[CookingDeviceResponse])
def get_all_cooking_devices():
    devices = service.get_all_cooking_devices()
    if not devices:
        raise HTTPException(status_code=404, detail="No cooking devices found")
    return devices


@router.get("/cooking-devices/{device_id}", response_model=CookingDeviceResponse)
def get_device_by_id(device_id: int):
    device = service.get_cooking_device_by_id(device_id)
    if not device:
        raise HTTPException(status_code=404, detail="Device not found")
    return device
