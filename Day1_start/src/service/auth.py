 # 비즈니스 로직
from datetime import datetime, timedelta
import bcrypt
from jose import jwt
from fastapi import HTTPException
import os
from dotenv import load_dotenv 

load_dotenv()

class AuthService:
    _encoding: str = "utf-8"
    _secret_key = os.getenv("SECRET_KEY")
    _algorithm: str = "HS256"
    _token_exp_days: int = 1

    # 비밀번호 해싱
    def hash_password(self, plain: str) -> str:
        hashed = bcrypt.hashpw(plain.encode(self._encoding), bcrypt.gensalt())
        return hashed.decode(self._encoding)

    # 비밀번호 검증
    def verify_password(self, plain: str, hashed: str) -> bool:
        return bcrypt.checkpw(plain.encode(self._encoding), hashed.encode(self._encoding))

    # JWT 생성
    def create_access_token(self, username: str) -> str:
        payload = {"sub": username, "exp": datetime.utcnow() + timedelta(days=self._token_exp_days)}
        return jwt.encode(payload, self._secret_key, algorithm=self._algorithm)

    # JWT 디코딩
    def decode_token(self, token: str) -> str:
        try:
            payload = jwt.decode(token, self._secret_key, algorithms=[self._algorithm])
            return payload["sub"]
        except Exception:
            raise HTTPException(status_code=401, detail="토큰이 유효하지 않습니다.")
