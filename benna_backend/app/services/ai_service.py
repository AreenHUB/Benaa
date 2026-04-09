import os
from groq import AsyncGroq
from dotenv import load_dotenv
from app.core.logger import get_logger
from app.core.exceptions import BenaaException

load_dotenv()


logger = get_logger(__name__)

client = AsyncGroq(api_key=os.getenv("GROQ_API_KEY"))

ENGINEERING_PROMPT = """
أنت مستشار هندسي خبير ومحترف في الهندسة المدنية والإنشائية، وتعمل وفق الأكواد العالمية والإماراتية.
مهمتك:
1. أجب على الأسئلة الهندسية بوضوح وإيجاز.
2. اذكر رقم الكود أو المرجع إن أمكن.
3. إذا سُئلت عن شيء خارج الهندسة، اعتذر بلباقة وأخبر المستخدم باختصاصك.
4. أجب باللغة العربية الفصحى وبأسلوب احترافي فقط.
"""


async def ask_engineering_assistant(question: str) -> str:
    """
    إرسال استفسار للذكاء الاصطناعي وجلب الإجابة الهندسية.
    """

    logger.info(f"استقبال سؤال جديد للذكاء الاصطناعي: {question[:50]}...")

    if not question or not question.strip():
        logger.warning("محاولة إرسال سؤال فارغ للمستشار الذكي")
        raise BenaaException(
            message="لا يمكن إرسال سؤال فارغ. يرجى كتابة استفسارك.", status_code=400
        )

    try:
        logger.info("جاري الاتصال بخوادم Groq لمعالجة السؤال...")
        response = await client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[
                {"role": "system", "content": ENGINEERING_PROMPT},
                {"role": "user", "content": question},
            ],
            temperature=0.3,
        )

        logger.info("تم استلام الإجابة من الذكاء الاصطناعي بنجاح")
        return response.choices[0].message.content

    except Exception as e:

        logger.critical(f"فشل الاتصال بخدمة الذكاء الاصطناعي (Groq Error): {str(e)}")

        raise BenaaException(
            message="عذراً، المستشار الذكي يواجه ضغطاً حالياً أو غير متاح. يرجى المحاولة بعد قليل.",
            status_code=503,
        )
