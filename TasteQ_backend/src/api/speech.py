from fastapi import APIRouter, UploadFile, File
from fastapi.responses import JSONResponse
from service.speech_service import transcribe_audio

router = APIRouter()

@router.post("/speech-to-text/")
async def speech_to_text(file: UploadFile = File(...)):
    audio_bytes = await file.read()
    result = transcribe_audio(audio_bytes)

    if result.startswith("[ERROR]"):
        return JSONResponse(status_code=500, content={"error": result})
    
    return {"transcript": result}
