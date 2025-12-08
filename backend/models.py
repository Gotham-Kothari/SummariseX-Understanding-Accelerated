from typing import Optional, List, Literal
from pydantic import BaseModel

InputType = Literal["text", "pdf", "url"]
SummaryLength = Literal["short", "medium", "long"]
Tone = Literal['neutral', 'formal', 'casual']

class SummarizeRequest(BaseModel):
    input_type: InputType
    content: Optional[str]
    length: SummaryLength
    tone: Optional[Tone] = 'neutral'

class SummaryMeta(BaseModel):
    input_tokens: int
    output_tokens: int
    processing_time_ms: int

class ErroInfo(BaseModel):
    code: str
    message: str

class SummaryResponse(BaseModel):
    summary_short: Optional[str] = None
    summary_long: Optional[str] = None
    key_points: Optional[List[str]] = None
    meta: Optional[SummaryMeta] = None
    error: Optional[ErroInfo] = None