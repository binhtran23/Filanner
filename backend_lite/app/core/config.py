from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import List # Python cu can cai nay, 3.10+ dung list[str] ok

class Settings(BaseSettings):
    """Application settings loaded from environment variables."""
    
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore"
    )
    
    # Application
    PROJECT_NAME: str = "Filanner API"
    VERSION: str = "1.0.0"
    
    API_STR: str = "/api" 
    
    # Security
    SECRET_KEY: str 
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 8 # 8 days

    # Database
    POSTGRES_SERVER: str = "db"
    POSTGRES_USER: str = "filanner_user"
    POSTGRES_PASSWORD: str = "filanner_password"
    POSTGRES_DB: str = "filanner_db"
    POSTGRES_PORT: int = 5432
        
    @property
    def DATABASE_URL(self) -> str:
        """Construct database URL."""
        # Tu dong ghep chuoi tu cac bien tren
        return (
            f"postgresql://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}"
            f"@{self.POSTGRES_SERVER}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"
        )
    
    # CORS
    BACKEND_CORS_ORIGINS: list[str] = ["*"] 
    
    # Gamification
    POINTS_PER_CHECK_IN: int = 10
    STREAK_BONUS_POINTS: int = 5

# Khoi tao settings
settings = Settings()
