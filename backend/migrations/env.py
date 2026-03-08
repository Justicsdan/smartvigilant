from app.utils.config import settings
config.set_main_option("sqlalchemy.url", settings.DATABASE_URL)
