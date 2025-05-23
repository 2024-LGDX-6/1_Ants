# DB 연결/세션 관련
from sqlalchemy.orm import Session
from sqlalchemy import select
from fastapi import Depends, HTTPException
from .connection import get_db
from .orm import User


class UserRepository:
    def __init__(self, session: Session = Depends(get_db)):
        self.session = session

    # 회원명으로 조회
    def get_by_username(self, username: str) -> User | None:
        return self.session.scalar(select(User).where(User.username == username))

    # 신규 저장
    def save(self, user: User) -> User:
        self.session.add(user)
        self.session.commit()
        self.session.refresh(user)
        return user

    # 중복 시 예외 처리 편의 메서드
    def ensure_unique_username(self, username: str) -> None:
        if self.get_by_username(username):
            raise HTTPException(status_code=409, detail="이미 존재하는 사용자명입니다.")
