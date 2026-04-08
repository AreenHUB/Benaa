from fastapi import FastAPI
from app.api.v1 import auth, calculator, weather, admin
from app.core.database import engine, Base

# الاستيراد الصحيح للـ Limiter من الملف المستقل
from app.core.rate_limit import limiter
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Benaa Pro API", version="3.0.0")

# إخبار FastAPI باستخدام الحماية
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

app.include_router(auth.router, prefix="/api/v1/auth", tags=["Auth"])
app.include_router(calculator.router, prefix="/api/v1", tags=["Calculator"])
app.include_router(weather.router, prefix="/api/v1", tags=["Weather"])
app.include_router(admin.router, prefix="/api/v1/admin", tags=["Admin"])


@app.get("/")
def root():
    return {"message": "Benaa Pro API is running securely"}
