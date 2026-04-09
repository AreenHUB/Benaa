from fastapi import APIRouter, status
import httpx
from app.core.config import settings
from app.core.logger import get_logger
from app.core.exceptions import BenaaException

logger = get_logger(__name__)
router = APIRouter()


@router.get("/advisor/weather/{city}")
async def get_pouring_advice(city: str):
    """جلب بيانات الطقس وتقديم نصيحة هندسية للصب."""
    logger.info(f"طلب نصيحة صب لمدينة: {city}")

    if not settings.OPENWEATHER_API_KEY:
        logger.critical("مفتاح OpenWeather API مفقود في الإعدادات!")
        raise BenaaException(message="خدمة الطقس غير مفعلة حالياً", status_code=500)

    url = f"http://api.openweathermap.org/data/2.5/weather?q={city},AE&appid={settings.OPENWEATHER_API_KEY}&units=metric"

    async with httpx.AsyncClient() as client:
        try:
            response = await client.get(url, timeout=5.0)
            if response.status_code == 404:
                logger.warning(f"المدينة غير موجودة: {city}")
                raise BenaaException(
                    message="لم يتم العثور على المدينة المحددة في الإمارات",
                    status_code=404,
                )

            if response.status_code != 200:
                raise BenaaException(
                    message="فشل الاتصال بخدمة الطقس العالمية", status_code=502
                )

            data = response.json()
            temp = data["main"]["temp"]
            wind = data["wind"]["speed"]

            is_safe = temp <= 35 and wind <= 10
            advice_ar = "الطقس ممتاز للصب."
            if temp > 35:
                advice_ar = "تنبيه: الحرارة مرتفعة (>35°). استخدم الثلج ومبطئات الشك ويفضل الصب ليلاً."
            elif wind > 10:
                advice_ar = (
                    "تنبيه: رياح قوية. خطر جفاف السطح السريع، جهز وسائل المعالجة فوراً."
                )

            logger.info(f"تم تقديم النصيحة لمدينة {city}: Safe={is_safe}")
            return {
                "success": True,
                "data": {
                    "city": city,
                    "temperature": temp,
                    "wind_speed": wind,
                    "is_safe": is_safe,
                    "advice": advice_ar,
                },
            }
        except httpx.RequestError as e:
            logger.error(f"خطأ في الاتصال بـ OpenWeather: {str(e)}")
            raise BenaaException(message="خدمة الطقس غير متاحة مؤقتاً", status_code=503)
