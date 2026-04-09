from app.core.logger import get_logger
from app.core.exceptions import BenaaException


logger = get_logger(__name__)


def calculate_structural_logic(
    element_type: str, count: int, length: float, width: float, height: float
) -> dict:
    """
    حساب كميات الخرسانة والحديد للعناصر الإنشائية وتكلفتها التقديرية.
    """
    logger.info(
        f"بدء حساب الكميات لعدد {count} {element_type} (الأبعاد: {length}x{width}x{height})"
    )

    if length <= 0 or width <= 0 or height <= 0 or count <= 0:
        logger.warning(
            f"محاولة إدخال أبعاد غير صالحة من المستخدم. الأبعاد: {length}x{width}x{height}"
        )
        raise BenaaException(
            message="يجب أن تكون جميع الأبعاد والعدد أكبر من الصفر", status_code=400
        )

    try:
        # 2. العمليات الحسابية
        volume = length * width * height * count
        concrete = volume * 1.05
        steel = (volume * 150) / 1000

        result = {
            "concrete_m3": round(concrete, 2),
            "steel_tons": round(steel, 2),
            "total_cost": round((concrete * 300) + (steel * 2500), 2),
        }

        logger.info(f"تم الحساب بنجاح. التكلفة الإجمالية: {result['total_cost']} AED")
        return result

    except Exception as e:
        logger.error(f"خطأ غير متوقع أثناء الحساب الإنشائي: {str(e)}")
        raise BenaaException(
            message="حدث خطأ داخلي أثناء معالجة الأرقام", status_code=500
        )


def calculate_block_logic(length: float, height: float) -> dict:
    """
    حساب عدد الطابوق وكميات المونة (الأسمنت والرمل) للجدران.
    """
    logger.info(f"بدء حساب الطابوق لجدار بأبعاد: {length}x{height}")

    if length <= 0 or height <= 0:
        logger.warning("تم إدخال أبعاد جدار غير صالحة (صفر أو أقل)")
        raise BenaaException(
            message="أبعاد الجدار يجب أن تكون أكبر من الصفر", status_code=400
        )

    try:
        wall_area = length * height
        blocks_count = wall_area * 12.5 * 1.05
        cement = blocks_count * 0.02
        sand = blocks_count * 0.006

        result = {
            "blocks": round(blocks_count),
            "cement_bags": round(cement, 2),
            "sand_m3": round(sand, 2),
        }

        logger.info(f"تم حساب الطابوق بنجاح. إجمالي الطابوق: {result['blocks']} طابوقة")
        return result

    except Exception as e:
        logger.error(f"خطأ غير متوقع أثناء حساب الطابوق: {str(e)}")
        raise BenaaException(
            message="حدث خطأ داخلي أثناء معالجة حسابات الطابوق", status_code=500
        )
