import os
from groq import AsyncGroq
from dotenv import load_dotenv

load_dotenv()


client = AsyncGroq(api_key=os.getenv("GROQ_API_KEY"))

ENGINEERING_PROMPT = """
أنت مستشار هندسي خبير ومحترف في الهندسة المدنية والإنشائية، وتعمل وفق الأكواد العالمية.
مهمتك:
1. أجب على الأسئلة الهندسية بوضوح وإيجاز.
2. اذكر رقم الكود أو المرجع إن أمكن.
3. إذا سُئلت عن شيء خارج الهندسة، اعتذر بلباقة.
4. أجب باللغة العربية فقط.
"""


async def ask_engineering_assistant(question: str) -> str:
    try:
        response = await client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[
                {"role": "system", "content": ENGINEERING_PROMPT},
                {"role": "user", "content": question},
            ],
            temperature=0.3,
        )
        return response.choices[0].message.content
    except Exception as e:
        return f"عذراً، حدث خطأ في الاتصال بالمستشار الذكي: {str(e)}"
