from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.models import Calculation
from app.schemas.schemas import CalcInput
from app.core.auth_deps import get_current_user
from app.schemas.schemas import BlockInput
from app.services.calc_service import calculate_block_logic

router = APIRouter()


@router.post("/calculations/structural")
def compute(
    data: CalcInput,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):

    single_volume = data.length * data.width * data.height_or_thickness
    total_volume = single_volume * data.count
    waste_factor = 1.05 if data.element_type == "سقف" else 1.03

    total_concrete = total_volume * waste_factor
    steel_tons = (total_volume * 100) / 1000

    concrete_cost = total_concrete * 320.0
    steel_cost = steel_tons * 2600.0
    total_cost = concrete_cost + steel_cost

    new_calc = Calculation(
        element_type=data.element_type,
        concrete_m3=total_concrete,
        steel_tons=steel_tons,
        total_cost=total_cost,
        user_id=current_user.id,
    )
    db.add(new_calc)
    db.commit()

    return {
        "success": True,
        "data": {
            "element_type": data.element_type,
            "count": data.count,
            "concrete_m3": round(total_concrete, 2),
            "steel_tons": round(steel_tons, 2),
            "financials_aed": {
                "concrete_cost": round(concrete_cost, 2),
                "steel_cost": round(steel_cost, 2),
                "total_cost": round(total_cost, 2),
            },
        },
    }


@router.get("/calculations/history")
def get_history(
    skip: int = 0,
    limit: int = 20,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):

    history_records = (
        db.query(Calculation)
        .filter(Calculation.user_id == current_user.id)
        .order_by(Calculation.id.desc())
        .offset(skip)
        .limit(limit)
        .all()
    )

    formatted_data = []
    for record in history_records:
        formatted_data.append(
            {
                "id": record.id,
                "element_type": record.element_type,
                "concrete_m3": record.concrete_m3,
                "steel_tons": record.steel_tons,
                "total_cost": record.total_cost,
                "date": "تم الحفظ سحابياً",
            }
        )

    return {"success": True, "data": formatted_data}


@router.post("/calculations/blocks")
def compute_blocks(
    data: BlockInput,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):

    result = calculate_block_logic(data.length, data.height)

    new_calc = Calculation(
        element_type="طابوق",
        concrete_m3=0.0,
        steel_tons=0.0,
        total_cost=result["cement_bags"] * 15.0 + result["sand_m3"] * 50.0,
        user_id=current_user.id,
    )
    db.add(new_calc)
    db.commit()

    return {"success": True, "data": result}
