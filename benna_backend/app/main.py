# from fastapi import FastAPI
# from app.api.v1 import auth, calculator, weather, admin
# from app.core.database import engine, Base


# from app.core.rate_limit import limiter
# from app.api.v1 import assistant
# from slowapi import _rate_limit_exceeded_handler
# from slowapi.errors import RateLimitExceeded

# Base.metadata.create_all(bind=engine)

# app = FastAPI(title="Benaa Pro API", version="3.0.0")


# app.state.limiter = limiter
# app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# app.include_router(auth.router, prefix="/api/v1/auth", tags=["Auth"])
# app.include_router(calculator.router, prefix="/api/v1", tags=["Calculator"])
# app.include_router(weather.router, prefix="/api/v1", tags=["Weather"])
# app.include_router(admin.router, prefix="/api/v1/admin", tags=["Admin"])
# app.include_router(assistant.router, prefix="/api/v1/ai", tags=["AI Assistant"])


# @app.get("/")
# def root():
#     return {"message": "Benaa Pro API is running securely"}


import time
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from app.api.v1 import auth, calculator, weather, admin, assistant
from app.core.database import engine, Base
from app.core.rate_limit import limiter
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded


from app.core.logger import get_logger
from app.core.exceptions import (
    BenaaException,
    benaa_exception_handler,
    global_exception_handler,
)

logger = get_logger(__name__)

Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Benaa Pro API",
    version="3.0.0",
    description="Enterprise-grade Construction Management API",
)


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# 3. تسجيل معالجات الأخطاء المركزية (Global Error Handlers)
app.add_exception_handler(BenaaException, benaa_exception_handler)
app.add_exception_handler(Exception, global_exception_handler)


@app.middleware("http")
async def log_requests(request: Request, call_next):
    start_time = time.time()

    response = await call_next(request)

    process_time = (time.time() - start_time) * 1000
    formatted_process_time = "{0:.2f}".format(process_time)

    logger.info(
        f"Method: {request.method} | "
        f"Path: {request.url.path} | "
        f"Status: {response.status_code} | "
        f"Time: {formatted_process_time}ms | "
        f"IP: {request.client.host}"
    )

    response.headers["X-Process-Time-ms"] = formatted_process_time
    return response


app.include_router(auth.router, prefix="/api/v1/auth", tags=["Auth"])
app.include_router(calculator.router, prefix="/api/v1", tags=["Calculator"])
app.include_router(weather.router, prefix="/api/v1", tags=["Weather"])
app.include_router(admin.router, prefix="/api/v1/admin", tags=["Admin"])
app.include_router(assistant.router, prefix="/api/v1/ai", tags=["AI Assistant"])


@app.get("/")
def root():
    logger.info("تم الوصول إلى المسار الرئيسي")
    return {"message": "Benaa Pro API is running securely"}
