# src/api/user_info.py
from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

from service.auth import AuthService          # JWT 디코딩용

router = APIRouter(prefix="/users", tags=["Users"])

bearer_scheme = HTTPBearer(auto_error=False)  # 401 대신 None 반환

@router.get("/me", summary="내 정보 조회")
def read_me(
    creds: HTTPAuthorizationCredentials = Depends(bearer_scheme),
    auth: AuthService = Depends(),
):
    if creds is None:
        raise HTTPException(status_code=401, detail="Not authenticated")

    username = auth.decode_token(creds.credentials)
    return {"username": username}
