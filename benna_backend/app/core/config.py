import os
from pathlib import Path
from pydantic_settings import BaseSettings, SettingsConfigDict

# تحديد مسار المجلد الرئيسي للمشروع (المجلد الذي يحتوي على .env)
BASE_DIR = Path(__file__).resolve().parent.parent.parent


class Settings(BaseSettings):
    DATABASE_URL: str
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    OPENWEATHER_API_KEY: str

    # إخبار Pydantic بمكان الملف باستخدام المسار الكامل
    model_config = SettingsConfigDict(
        env_file=os.path.join(BASE_DIR, ".env"), env_file_encoding="utf-8"
    )


settings = Settings()
