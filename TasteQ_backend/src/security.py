# security.py
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi import Depends, HTTPException

_token_scheme = HTTPBearer(auto_error=False)


def get_access_token(
    credentials: HTTPAuthorizationCredentials | None = Depends(_token_scheme),
) -> str:
    if credentials is None:
        raise HTTPException(status_code=401, detail="인증 필요")
    return credentials.credentials
