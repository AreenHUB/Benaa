from pydantic import BaseModel, Field, EmailStr


class CalcInput(BaseModel):
    element_type: str
    count: int = Field(..., gt=0)
    length: float = Field(..., gt=0)
    width: float = Field(..., gt=0)
    height_or_thickness: float = Field(..., gt=0)


class UserBase(BaseModel):
    email: EmailStr


class UserCreate(UserBase):
    password: str


class UserResponse(UserBase):
    id: int

    class Config:
        from_attributes = True  # لربطها بـ SQLAlchemy


class Token(BaseModel):
    access_token: str
    token_type: str


class BlockInput(BaseModel):
    length: float = Field(..., gt=0)
    height: float = Field(..., gt=0)
    block_type: str = "Standard"
