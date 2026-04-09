from fastapi import APIRouter, Depends, Request, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.models import User
from app.schemas.schemas import UserCreate, UserResponse, ProfileUpdate
from app.core.security import (
    verify_password,
    create_access_token,
    create_refresh_token,
    get_password_hash,
)
from app.core.rate_limit import limiter
from app.core.auth_deps import get_current_user
from app.core.logger import get_logger
from app.core.exceptions import BenaaException
from jose import jwt, JWTError
from app.core.config import settings

logger = get_logger(__name__)
router = APIRouter()


@router.post("/register", response_model=UserResponse, status_code=201)
def register(user: UserCreate, db: Session = Depends(get_db)):
    if db.query(User).filter(User.email == user.email).first():
        logger.warning(f"محاولة تسجيل بإيميل موجود مسبقاً: {user.email}")
        raise BenaaException(
            message="هذا البريد الإلكتروني مسجل بالفعل", status_code=400
        )

    new_user = User(email=user.email, hashed_password=get_password_hash(user.password))
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    logger.info(f"مستخدم جديد انضم إلينا: {user.email}")
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
        logger.warning(f"فشل تسجيل دخول للإيميل: {form_data.username}")
        raise BenaaException(
            message="البريد الإلكتروني أو كلمة المرور غير صحيحة", status_code=401
        )

    logger.info(f"دخول ناجح للمستخدم: {user.email}")
    return {
        "access_token": create_access_token(data={"sub": user.email}),
        "refresh_token": create_refresh_token(data={"sub": user.email}),
        "token_type": "bearer",
    }


@router.post("/refresh")
def refresh_access_token(request: Request):
    refresh_token = request.headers.get("refresh-token") or request.headers.get(
        "Refresh-Token"
    )
    if not refresh_token:
        raise BenaaException(message="Refresh Token مفقود", status_code=400)

    try:
        payload = jwt.decode(
            refresh_token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM]
        )
        email: str = payload.get("sub")
        if not email:
            raise JWTError()

        logger.info(f"تجديد جلسة للمستخدم: {email}")
        return {
            "access_token": create_access_token(data={"sub": email}),
            "token_type": "bearer",
        }
    except JWTError:
        logger.warning("محاولة تجديد جلسة بتوكن تالف أو منتهي")
        raise BenaaException(
            message="انتهت صلاحية الجلسة بالكامل، يرجى الدخول مجدداً", status_code=401
        )


@router.get("/profile")
def get_profile(current_user: User = Depends(get_current_user)):
    return {"company_name": current_user.company_name, "email": current_user.email}


@router.put("/profile")
def update_profile(
    profile: ProfileUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    current_user.company_name = profile.company_name
    db.commit()
    logger.info(f"تم تحديث بروفايل المستخدم: {current_user.email}")
    return {"success": True, "company_name": current_user.company_name}
