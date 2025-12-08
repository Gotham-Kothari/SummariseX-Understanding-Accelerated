import httpx
from bs4 import BeautifulSoup
from ..config import settings
from ..models import SummaryMeta
from .llm_client import call_llm, parse_llm_output

class SummariserService:
    @staticmethod
    def enforce_limit(text: str):
        if len(text) > settings.max_text_length:
            raise ValueError("TEXT TOO LONG")
    
    # @staticmethod
    # async def fetch_url_content(url: str) -> str: #Fetch raw html or text from a url (GET)
    #     async with httpx.AsyncClient(
    #         timeout = settings.url_fetch_timeout_seconds
    #     ) as client:
    #         resp = await client.get(url)
    #         resp.raise_for_status()
    #         return resp.text
    
    @staticmethod
    async def fetch_url_content(url: str) -> str:
        headers = {
            "User-Agent": (
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
                "AppleWebKit/537.36 (KHTML, like Gecko) "
                "Chrome/120.0.0.0 Safari/537.36"
            )
        }

        timeout = httpx.Timeout(10.0, connect=5.0)

        async with httpx.AsyncClient(follow_redirects=True, headers=headers, timeout=timeout) as client:
            try:
                resp = await client.get(url)
            except Exception:
                raise Exception("URL_FETCH_FAILED")

        if resp.status_code >= 400:
            raise Exception("URL_FETCH_FAILED")

        # Extract TEXT from HTML
        soup = BeautifulSoup(resp.text, "html.parser")

        # Remove scripts + styles
        for tag in soup(["script", "style", "noscript"]):
            tag.extract()

        text = soup.get_text(separator="\n")
        text = "\n".join(line.strip() for line in text.splitlines() if line.strip())

        if not text:
            raise Exception("URL_FETCH_FAILED")

        return text


    @staticmethod
    async def summarise_text(text: str, length: str, tone: str):
        #Summarise text using the LangChain LLM client
        #Return parsed summaries and summary metadata

        SummariserService.enforce_limit(text)

        full_text, in_tokens, out_tokens, time_ms = call_llm(
            raw_text = text,
            length = length,
            tone = tone,
        )

        parsed = parse_llm_output(full_text)

        meta = SummaryMeta(
            input_tokens = in_tokens,
            output_tokens = out_tokens,
            processing_time_ms = time_ms
        )

        return parsed, meta