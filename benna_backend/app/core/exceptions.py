from fastapi import Request
from fastapi.responses import JSONResponse
from .logger import get_logger

logger = get_logger(__name__)


class BenaaException(Exception):
    def __init__(self, message: str, status_code: int = 400):
        self.message = message
        self.status_code = status_code


async def benaa_exception_handler(request: Request, exc: BenaaException):
    logger.error(f"Custom Error: {exc.message} | Path: {request.url.path}")
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "success": False,
            "error": {"code": exc.status_code, "message": exc.message},
        },
    )


async def global_exception_handler(request: Request, exc: Exception):
    logger.critical(f"Unhandled Exception: {str(exc)} | Path: {request.url.path}")
    return JSONResponse(
        status_code=500,
        content={
            "success": False,
            "error": {
                "code": 500,
                "message": "حدث خطأ داخلي في الخادم. تم إبلاغ الإدارة.",
            },
        },
    )
