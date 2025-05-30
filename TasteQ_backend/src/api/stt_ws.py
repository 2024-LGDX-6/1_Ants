from fastapi import APIRouter, WebSocket
from service.stt_service import handle_stt_stream

router = APIRouter()

@router.websocket("/ws/stt")
async def stt_websocket(websocket: WebSocket):
    await handle_stt_stream(websocket)