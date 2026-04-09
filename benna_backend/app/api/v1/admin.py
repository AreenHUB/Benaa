from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.core.database import get_db
from app.models.models import User, Calculation
from app.core.auth_deps import get_current_admin_user

router = APIRouter()


@router.get("/dashboard-stats")
def get_app_statistics(
    db: Session = Depends(get_db), admin_user=Depends(get_current_admin_user)
):
    total_users = db.query(User).count()
    total_calculations = db.query(Calculation).count()

    total_money_estimated = db.query(func.sum(Calculation.total_cost)).scalar() or 0.0

    return {
        "success": True,
        "data": {
            "total_users": total_users,
            "total_calculations": total_calculations,
            "total_money_estimated_aed": round(total_money_estimated, 2),
        },
    }
