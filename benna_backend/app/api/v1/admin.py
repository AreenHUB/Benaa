from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.core.database import get_db
from app.models.models import User, Calculation
from app.core.auth_deps import get_current_admin_user
from app.core.logger import get_logger
from app.core.exceptions import BenaaException

logger = get_logger(__name__)
router = APIRouter()


@router.get("/dashboard-stats", status_code=status.HTTP_200_OK)
def get_app_statistics(
    db: Session = Depends(get_db), admin_user: User = Depends(get_current_admin_user)
):
    """جلب إحصائيات النظام الشاملة (للمديرين فقط)."""

    logger.info(f"المدير {admin_user.email} دخل إلى لوحة الإحصائيات.")

    try:
        total_users = db.query(User).count()
        total_calculations = db.query(Calculation).count()

        total_money_estimated = (
            db.query(func.sum(Calculation.total_cost)).scalar() or 0.0
        )

        logger.info("تم جلب الإحصائيات بنجاح.")

        return {
            "success": True,
            "data": {
                "total_users": total_users,
                "total_calculations": total_calculations,
                "total_money_estimated_aed": round(float(total_money_estimated), 2),
            },
        }
    except Exception as e:
        logger.error(f"خطأ أثناء جلب إحصائيات الإدارة: {str(e)}")
        raise BenaaException(message="فشل في جلب بيانات الإدارة", status_code=500)
