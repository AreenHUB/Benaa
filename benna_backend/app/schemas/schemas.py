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
        from_attributes = True


class Token(BaseModel):
    access_token: str
    token_type: str


class BlockInput(BaseModel):
    length: float = Field(..., gt=0)
    height: float = Field(..., gt=0)
    block_type: str = "Standard"


class ProfileUpdate(BaseModel):
    company_name: str = Field(
        ..., min_length=3, max_length=100, example="شركة الإنشاءات الحديثة"
    )


class QuestionInput(BaseModel):
    question: str = Field(..., min_length=5, max_length=500)
