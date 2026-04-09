import os
from pathlib import Path
from pydantic_settings import BaseSettings, SettingsConfigDict


BASE_DIR = Path(__file__).resolve().parent.parent.parent


class Settings(BaseSettings):
    DATABASE_URL: str
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    OPENWEATHER_API_KEY: str

    model_config = SettingsConfigDict(
        env_file=os.path.join(BASE_DIR, ".env"), env_file_encoding="utf-8"
    )


settings = Settings()
