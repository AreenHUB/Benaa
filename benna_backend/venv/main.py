from enum import Enum

from fastapi import FastAPI, HTTPException, status
from pydantic import BaseModel, Field
from dotenv import load_dotenv
import httpx
import os
import logging

# تحميل المتغيرات البيئية (الأمان)
load_dotenv()

# إعداد نظام تسجيل الأخطاء الاحترافي (Logging)
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# إنشاء التطبيق مع بيانات الشركة (Documentation)
app = FastAPI(
    title="Benaa Pro API",
    description="Enterprise API for Construction Calculations and Site Management in UAE.",
    version="1.1.0",
)

# جلب المفتاح السري من بيئة النظام
WEATHER_API_KEY = os.getenv("OPENWEATHER_API_KEY")


class ElementType(str, Enum):
    slab = "سقف"
    column = "عمود"
    footing = "قاعدة"


class StructuralInput(BaseModel):
    element_type: ElementType
    count: int = Field(default=1, gt=0, description="عدد العناصر (مثال: 10 أعمدة)")
    length: float = Field(..., gt=0)
    width: float = Field(..., gt=0)
    height_or_thickness: float = Field(..., gt=0)
    steel_ratio: float = Field(default=100, ge=50, le=300)


# متوسط أسعار السوق في الإمارات (يمكن لاحقاً جلبها من قاعدة بيانات)
MARKET_PRICES_AED = {
    "concrete_per_m3": 320.0,  # 320 درهم لمتر الخرسانة الجاهزة
    "steel_per_ton": 2600.0,  # 2600 درهم لطن الحديد
}


# ==========================================
# 1. Models & Validation (أمان المدخلات)
# ==========================================
class SlabInput(BaseModel):
    # Field تمنع المستخدم من إدخال قيم سالبة أو صفر (حماية السيرفر من أخطاء الحسابات)
    length: float = Field(..., gt=0, description="Length in meters")
    width: float = Field(..., gt=0, description="Width in meters")
    thickness: float = Field(
        ..., gt=0, le=2, description="Thickness in meters (max 2m)"
    )
    steel_ratio: float = Field(
        default=100, ge=50, le=300, description="Steel ratio kg/m3"
    )


# ==========================================
# 2. Calculation Endpoint (سريع ومنفصل)
# ==========================================
@app.post("/api/v1/calculations/slab", tags=["Engineering Calculations"])
async def calculate_slab(data: SlabInput):
    """
    حساب كميات الخرسانة والحديد لسقف بناءً على الأبعاد المدخلة.
    """
    try:
        volume = data.length * data.width * data.thickness
        total_concrete = volume * 1.05  # 5% Waste
        steel_tons = (volume * data.steel_ratio) / 1000

        return {
            "success": True,
            "data": {
                "concrete_m3": round(total_concrete, 2),
                "steel_tons": round(steel_tons, 2),
            },
            "message": "Calculated successfully with 5% waste factor.",
        }
    except Exception as e:
        logger.error(f"Calculation Error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Server Error"
        )


@app.post("/api/v1/calculations/structural", tags=["Engineering Calculations"])
async def calculate_element(data: StructuralInput):
    try:
        # حساب الحجم الصافي لجميع العناصر
        single_volume = data.length * data.width * data.height_or_thickness
        total_volume = single_volume * data.count

        # نسبة الهالك تختلف حسب العنصر
        waste_factor = 1.05 if data.element_type == ElementType.slab else 1.03

        total_concrete = total_volume * waste_factor
        steel_tons = (total_volume * data.steel_ratio) / 1000

        # الذكاء المالي: حساب التكلفة
        concrete_cost = total_concrete * MARKET_PRICES_AED["concrete_per_m3"]
        steel_cost = steel_tons * MARKET_PRICES_AED["steel_per_ton"]
        total_cost = concrete_cost + steel_cost

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
    except Exception as e:
        logger.error(f"Calculation Error: {str(e)}")
        raise HTTPException(status_code=500, detail="Server Error")


# ==========================================
# 3. Async Weather API (أداء عالي للشركات)
# ==========================================
@app.get("/api/v1/advisor/weather/{city}", tags=["Site Advisor"])
async def get_pouring_advice(city: str):
    """
    مستشار الصب الذكي: يجلب بيانات الطقس ويعطي نصيحة هندسية للصب.
    نستخدم httpx.AsyncClient لعدم إيقاف السيرفر أثناء انتظار الرد من الطقس.
    """
    if not WEATHER_API_KEY:
        raise HTTPException(
            status_code=500, detail="Weather API Key is missing in server configuration"
        )

    url = f"http://api.openweathermap.org/data/2.5/weather?q={city},AE&appid={WEATHER_API_KEY}&units=metric"

    # استخدام Async لضمان عدم حظر الطلبات الأخرى (Scalability)
    async with httpx.AsyncClient() as client:
        try:
            response = await client.get(
                url, timeout=5.0
            )  # تحديد وقت أقصى لتجنب تعليق السيرفر

            if response.status_code != 200:
                logger.warning(f"City not found or API error: {city}")
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND, detail="City not found"
                )

            data = response.json()
            temp = data["main"]["temp"]
            wind = data["wind"]["speed"]

            is_safe = temp <= 35 and wind <= 10

            # نصيحة هندسية مبنية على الأكواد
            advice_ar = "الطقس ممتاز للصب."
            if temp > 35:
                advice_ar = "تنبيه (الكود الإماراتي): درجة الحرارة تجاوزت 35 مئوية. يجب استخدام ثلج ومبطئات شك، ويفضل الصب ليلاً."
            elif wind > 10:
                advice_ar = "تنبيه: رياح قوية قد تسبب (Plastic Shrinkage). قم بتجهيز الخيش والماء للرش فوراً."

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
            logger.error(f"Weather API Timeout/Error: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Weather service unavailable",
            )
