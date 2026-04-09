from fastapi import APIRouter, Depends
from pydantic import BaseModel
from app.core.auth_deps import get_current_user
from app.services.ai_service import ask_engineering_assistant

router = APIRouter()


class QuestionInput(BaseModel):
    question: str


@router.post("/ask")
async def ask_assistant(data: QuestionInput, current_user=Depends(get_current_user)):
    answer = await ask_engineering_assistant(data.question)
    return {"success": True, "data": {"question": data.question, "answer": answer}}
