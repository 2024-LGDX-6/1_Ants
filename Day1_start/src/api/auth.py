# src/api/auth.py  
# 라우터
from fastapi import APIRouter, Depends, HTTPException, status
from schema.request import SignUpRequest, LogInRequest
from schema.response import UserSchema, TokenSchema
from service.auth import AuthService
from database.repository import UserRepository
from database.orm import User

router = APIRouter(prefix="/auth")


@router.post("/signup", response_model=UserSchema, status_code=status.HTTP_201_CREATED)
def signup(
    req: SignUpRequest,
    repo: UserRepository = Depends(),
    auth: AuthService = Depends(),
):
    repo.ensure_unique_username(req.username)
    hashed_pw = auth.hash_password(req.password)
    user = repo.save(User.create(req.username, hashed_pw))
    return user


@router.post("/login", response_model=TokenSchema)
def login(
    req: LogInRequest,
    repo: UserRepository = Depends(),
    auth: AuthService = Depends(),
):
    user = repo.get_by_username(req.username)
    if not user or not auth.verify_password(req.password, user.password):
        raise HTTPException(status_code=401, detail="아이디나 비밀번호가 올바르지 않습니다.")
    token = auth.create_access_token(user.username)
    return TokenSchema(access_token=token)
