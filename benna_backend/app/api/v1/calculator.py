from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.models import Calculation
from app.schemas.schemas import CalcInput, BlockInput
from app.core.auth_deps import get_current_user
from app.services.calc_service import calculate_block_logic, calculate_structural_logic
from app.core.logger import get_logger
from app.core.exceptions import BenaaException

logger = get_logger(__name__)
router = APIRouter()


@router.post("/calculations/structural")
def compute(
    data: CalcInput,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    """حساب كميات الخرسانة والحديد وحفظها."""

    res = calculate_structural_logic(
        data.element_type, data.count, data.length, data.width, data.height_or_thickness
    )

    try:
        new_calc = Calculation(
            element_type=data.element_type,
            concrete_m3=res["concrete_m3"],
            steel_tons=res["steel_tons"],
            total_cost=res["total_cost"],
            user_id=current_user.id,
        )
        db.add(new_calc)
        db.commit()
        logger.info(f"تم حفظ حساب إنشائي جديد للمستخدم {current_user.email}")
        return {"success": True, "data": res}
    except Exception as e:
        db.rollback()
        logger.error(f"فشل حفظ الحساب في القاعدة: {str(e)}")
        raise BenaaException(
            message="فشل حفظ البيانات في السجل السحابي", status_code=500
        )


@router.get("/calculations/history")
def get_history(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, le=100),
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    """جلب سجل الحسابات للمستخدم الحالي (Pagination)."""
    history_records = (
        db.query(Calculation)
        .filter(Calculation.user_id == current_user.id)
        .order_by(Calculation.id.desc())
        .offset(skip)
        .limit(limit)
        .all()
    )

    return {
        "success": True,
        "data": [
            {
                "id": r.id,
                "element_type": r.element_type,
                "concrete_m3": r.concrete_m3,
                "steel_tons": r.steel_tons,
                "total_cost": r.total_cost,
                "date": "محفوظ سحابياً",
            }
            for r in history_records
        ],
    }


@router.post("/calculations/blocks")
def compute_blocks(
    data: BlockInput,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    """حساب الطابوق وحفظ التكلفة التقديرية."""
    res = calculate_block_logic(data.length, data.height)

    est_cost = res["blocks"] * 3.5

    try:
        new_calc = Calculation(
            element_type="طابوق",
            concrete_m3=0.0,
            steel_tons=0.0,
            total_cost=est_cost,
            user_id=current_user.id,
        )
        db.add(new_calc)
        db.commit()
        return {"success": True, "data": res}
    except Exception as e:
        db.rollback()
        raise BenaaException(message="فشل حفظ حساب الطابوق", status_code=500)
