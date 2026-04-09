from fastapi import APIRouter, HTTPException, status
import httpx
import os
from dotenv import load_dotenv

load_dotenv()
WEATHER_API_KEY = os.getenv("OPENWEATHER_API_KEY")

router = APIRouter()


@router.get("/advisor/weather/{city}")
async def get_pouring_advice(city: str):
    if not WEATHER_API_KEY:
        raise HTTPException(status_code=500, detail="Weather API Key is missing")

    url = f"http://api.openweathermap.org/data/2.5/weather?q={city},AE&appid={WEATHER_API_KEY}&units=metric"

    async with httpx.AsyncClient() as client:
        try:
            response = await client.get(url, timeout=5.0)
            if response.status_code != 200:
                raise HTTPException(status_code=404, detail="City not found")

            data = response.json()
            temp = data["main"]["temp"]
            wind = data["wind"]["speed"]

            is_safe = temp <= 35 and wind <= 10

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
        except httpx.RequestError:
            raise HTTPException(status_code=503, detail="Weather service unavailable")
