from fastapi import APIRouter, Depends, status
from app.core.auth_deps import get_current_user
from app.services.ai_service import ask_engineering_assistant
from app.schemas.schemas import QuestionInput
from app.core.logger import get_logger
from app.models.models import User

logger = get_logger(__name__)
router = APIRouter()


@router.post("/ask", status_code=status.HTTP_200_OK)
async def ask_assistant(
    data: QuestionInput, current_user: User = Depends(get_current_user)
):
    """استقبال أسئلة المهندسين ومعالجتها عبر الذكاء الاصطناعي."""

    logger.info(f"المستخدم {current_user.email} أرسل استفساراً للمساعد الذكي.")

    answer = await ask_engineering_assistant(data.question)

    logger.info(f"تمت الإجابة على استفسار {current_user.email} بنجاح.")

    return {"success": True, "data": {"question": data.question, "answer": answer}}
