from fastapi import Depends, status
from fastapi.security import OAuth2PasswordBearer
from jose import jwt, JWTError
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.models import User
from app.core.config import settings
from app.core.logger import get_logger
from app.core.exceptions import BenaaException

logger = get_logger(__name__)

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="api/v1/auth/login")


def get_current_user(
    token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)
) -> User:
    """التحقق من التوكن وجلب المستخدم الحالي."""
    try:
        payload = jwt.decode(
            token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM]
        )
        email: str = payload.get("sub")
        if email is None:
            logger.warning("فشل فك تشفير التوكن: حقل 'sub' مفقود.")
            raise BenaaException(
                message="توكن غير صالح", status_code=status.HTTP_401_UNAUTHORIZED
            )

    except JWTError as e:
        logger.warning(f"محاولة دخول بتوكن منتهي أو غير صالح: {str(e)}")
        raise BenaaException(
            message="انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً",
            status_code=status.HTTP_401_UNAUTHORIZED,
        )

    user = db.query(User).filter(User.email == email).first()
    if user is None:
        logger.error(f"توكن صحيح لإيميل غير موجود في قاعدة البيانات: {email}")
        raise BenaaException(
            message="المستخدم غير موجود", status_code=status.HTTP_401_UNAUTHORIZED
        )

    return user


def get_current_admin_user(current_user: User = Depends(get_current_user)) -> User:
    """التحقق من صلاحيات المدير."""
    if not current_user.is_admin:
        logger.warning(f"محاولة وصول غير مصرح للمسؤولين من قِبل: {current_user.email}")
        raise BenaaException(
            message="ليس لديك صلاحيات المدير للقيام بهذا الإجراء",
            status_code=status.HTTP_403_FORBIDDEN,
        )
    return current_user
