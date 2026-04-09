from sqlalchemy import (
    Column,
    Integer,
    String,
    Float,
    ForeignKey,
    Boolean,
)
from app.core.database import Base


class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    is_admin = Column(Boolean, default=False)
    company_name = Column(String, default="BENAA PRO")


class Calculation(Base):
    __tablename__ = "calculations"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    element_type = Column(String)
    concrete_m3 = Column(Float)
    steel_tons = Column(Float)
    total_cost = Column(Float)
