# src/database/orm.py
from sqlalchemy import Column, Integer, String, Float, Date, ForeignKey
from sqlalchemy.orm import declarative_base, relationship

Base = declarative_base()


class User(Base):
    __tablename__ = "user"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(256), nullable=False, unique=True) # 회원"이름임"
    email = Column(String(256), nullable=False, unique=True) # 로그인ID (이메일)
    password = Column(String(256), nullable=False)

    @classmethod
    def create(cls, username: str, email:str, hashed_password: str) -> "User":
        return cls(username=username, email=email, password=hashed_password)
    
class PetProfile(Base):
    __tablename__ = "pet_profile"
    
    id = Column(Integer, primary_key=True, index=True)
    owner_id = Column(Integer, ForeignKey("user.id"), nullable=False)  # 사용자 ID (Foreign Key)
    pet_name = Column(String(100), nullable=False)         # 반려동물 이름
    pet_species = Column(String(100), nullable=False)      # 종 (예: 말티즈, 시바견)
    age = Column(Integer, nullable=True)               # 나이
    birth_date = Column(Date, nullable=True)           # 생년월일
    gender = Column(String(10), nullable=True)         # 성별 (예: 남, 여)
    weight = Column(Float, nullable=True)              # 몸무게 (kg)

    owner = relationship("User", backref="pets")