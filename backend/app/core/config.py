from functools import lru_cache
from pydantic import field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    project_name: str = "Pickleball Platform API"
    version: str = "0.1.0"
    debug: bool = False
    api_v1_prefix: str = "/api/v1"

    SUPABASE_URL: str
    SUPABASE_ANON_KEY: str
    SUPABASE_SERVICE_ROLE_KEY: str | None = None
    DATABASE_URL: str = ""
    STORAGE_BUCKET_NAME: str = "pickleball-assets"

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    @field_validator("debug", mode="before")
    def parse_debug(cls, value):
        if isinstance(value, str):
            truthy = {"1", "true", "yes", "y", "on"}
            falsy = {"0", "false", "no", "n", "off", "release"}
            normalized = value.strip().lower()
            if normalized in truthy:
                return True
            if normalized in falsy:
                return False
        return value

    @property
    def database_url(self) -> str:
        return self.DATABASE_URL


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
