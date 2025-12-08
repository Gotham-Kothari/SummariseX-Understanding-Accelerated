import os
from dotenv import load_dotenv
from pydantic import BaseModel

load_dotenv()

class Settings(BaseModel):
    environment: str = "dev"
    openai_api_key: str = os.getenv("OPENAI_API_KEY", "")
    openai_base_url: str = os.getenv("OPENAI_BASE", "https://api.openai.com/v1")
    openai_model: str = os.getenv("OPENAI_MODEL", 'gpt-4.1-mini')
    anthropic_api_key: str = os.getenv("ANTHROPIC_API_KEY", "")
    anthropic_model: str = os.getenv("ANTHROPIC_MODEL", "claude-3-haiku-20240307")
    temperature: float = 0.2
    max_output_tokens_short: int = 512
    max_output_tokens_long: int = 1024
    url_fetch_timeout_seconds: int = 5
    max_text_length: int = 20000
    max_pdf_size_bytes: int = 5*1024*1024

settings = Settings()

