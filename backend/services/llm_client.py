import time
from langchain_openai import ChatOpenAI
from langchain_anthropic import ChatAnthropic
from pathlib import Path
from ..config import settings

PROMPT_PATH = Path(__file__).parent.parent / "prompts" / "summarise_system_prompt.txt"

with open(PROMPT_PATH, 'r', encoding = "utf-8") as f:
    SYSTEM_PROMPT = f.read()

def build_user_prompt(raw_text: str, length: str, tone: str) -> str:
    return f"""
Summarise the following content:
- Desired Length: {length}
- Tone: {tone}

Follow the structure described in the system prompt exactly

CONTENT START
{raw_text}
CONTENT END
"""

def call_llm(raw_text: str, length: str, tone: str):
    """
    Call LLM through LangChain's ChatOpenAIand return:
    - full_text_output
    - input_tokens
    - output_tokens
    - processing_time_ms
    """

    if length == 'long':
        max_tokens = settings.max_output_tokens_long
    else:
        max_tokens = settings.max_output_tokens_short
    
    # llm = ChatOpenAI(
    #     model = settings.openai_model,
    #     temperature = settings.temperature,
    #     max_tokens = max_tokens,
    #     api_key = settings.openai_api_key,
    #     base_url = settings.openai_base_url,
    # )

    llm = ChatAnthropic(
        model = settings.anthropic_model,
        temperature = settings.temperature,
        max_tokens = max_tokens,
        api_key = settings.anthropic_api_key
    )

    messages = [
        ("system", SYSTEM_PROMPT),
        ("user", build_user_prompt(raw_text, length, tone)),
    ]

    start = time.time()
    ai_msg = llm.invoke(messages)
    end = time.time()

    full_text = ai_msg.content or ""

    usage = getattr(ai_msg, "usage_metadata", None) or {}
    input_tokens = int(usage.get("input_tokens", 0))
    output_tokens = int(usage.get("output_tokens", 0))
    processing_time_ms = int((end - start)*1000)

    return full_text, input_tokens, output_tokens, processing_time_ms

def parse_llm_output(full_text: str):
    """
    Parse the model output markdown into:
    - summary_short (str)
    - summary_long (str)
    - key_points (list[str])

    Expects the heading:
    ### SHORT SUMMARY
    ### LONG SUMMARY
    ### KEY POINTS
    """
    sections = {
        "short": "",
        "long": "",
        "points_raw": "",
    }

    current = None
    lines = full_text.splitlines()

    for line in lines:
        stripped = line.strip()

        if stripped.upper().startswith("### SHORT SUMMARY"):
            current = "short"
            continue

        if stripped.upper().startswith("### LONG SUMMARY"):
            current = "long"
            continue

        if stripped.upper().startswith("### KEY POINTS"):
            current = "points_raw"
            continue

        if current is None:
            continue

        sections[current] += line + '\n'
    
    summary_short = sections["short"].strip()
    summary_long = sections["long"].strip()

    key_points = []
    for line in sections["points_raw"].splitlines():
        stripped = line.strip()
        if not stripped:
            continue
        if stripped.startswith("- "):
            key_points.append(stripped[2:].strip())
        else:
            key_points.append(stripped)
    
    return {
        "summary_short": summary_short,
        "summary_long": summary_long,
        "key_points": key_points,
    }