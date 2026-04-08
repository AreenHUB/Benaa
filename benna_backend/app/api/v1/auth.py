from fastapi import (
    APIRouter,
    Depends,
    HTTPException,
    status,
    Request,
)  # أضف Request هنا
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.models import User
from app.schemas.schemas import UserCreate, UserResponse
from app.core.security import get_password_hash
from fastapi import Request  # أضف هذا
from app.core.rate_limit import limiter
from fastapi.security import OAuth2PasswordRequestForm
from app.core.security import verify_password, create_access_token
from jose import JWTError, jwt
from app.core.config import settings

router = APIRouter()


@router.post("/register", response_model=UserResponse)
def register(user: UserCreate, db: Session = Depends(get_db)):
    # التحقق هل المستخدم موجود؟
    db_user = db.query(User).filter(User.email == user.email).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")

    hashed_pw = get_password_hash(user.password)
    new_user = User(email=user.email, hashed_password=hashed_pw)

    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user


@router.post("/login")
@limiter.limit("5/minute")
def login(
    request: Request,
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db),
):
    user = db.query(User).filter(User.email == form_data.username).first()
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Invalid email or password")

    access_token = create_access_token(data={"sub": user.email})
    # استخدم الدالة الجديدة هنا:
    from app.core.security import create_refresh_token

    refresh_token = create_refresh_token(data={"sub": user.email})

    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer",
    }


from fastapi import Header


from fastapi import Header, Request  # أضف Request


@router.post("/refresh")
def refresh_token(request: Request, db: Session = Depends(get_db)):
    # نحاول استخراج الهيدر بكل الطرق الممكنة لتجنب مشاكل الشرطة والـ Case
    refresh_token = request.headers.get("refresh-token") or request.headers.get(
        "Refresh-Token"
    )

    if not refresh_token:
        # طباعة الهيدرات المستلمة في التيرمينال للتأكد مما يرسله الفلاتر فعلياً
        print("Headers received:", request.headers)
        raise HTTPException(status_code=400, detail="Refresh token missing")

    try:
        # تأكد أن الـ SECRET_KEY هو نفسه المستخدم في كل مكان
        payload = jwt.decode(
            refresh_token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM]
        )
        email: str = payload.get("sub")
        new_access_token = create_access_token(data={"sub": email})
        return {"access_token": new_access_token, "token_type": "bearer"}
    except Exception as e:
        print("Refresh Error:", e)
        raise HTTPException(status_code=401, detail="Invalid or expired refresh token")
