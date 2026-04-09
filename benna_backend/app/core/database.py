from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker, declarative_base
from app.core.config import settings
from app.core.logger import get_logger

logger = get_logger(__name__)

engine = create_engine(
    settings.DATABASE_URL, pool_pre_ping=True, pool_size=10, max_overflow=20
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


def get_db():
    """توفير جلسة قاعدة بيانات للطلبات."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


try:
    with engine.connect() as connection:
        connection.execute(text("SELECT 1"))
        logger.info("✅ تم الاتصال بقاعدة البيانات PostgreSQL بنجاح.")
except Exception as e:
    logger.critical(f"❌ فشل الاتصال بقاعدة البيانات: {str(e)}")
