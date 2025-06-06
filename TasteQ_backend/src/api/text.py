from fastapi import APIRouter
from schema.request import TextRequest
from schema.response import NounsResponse
from service.nlp_service import extract_nouns

router = APIRouter()

@router.post("/text/nouns", response_model=NounsResponse)
def get_nouns(request: TextRequest):
    nouns = extract_nouns(request.text)
    return NounsResponse(nouns=nouns)