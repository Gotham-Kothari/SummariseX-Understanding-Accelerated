from typing import Optional

from fastapi import FastAPI, Request, UploadFile
from fastapi.responses import JSONResponse

from .config import settings
from .models import SummarizeRequest, SummaryResponse
from .utils.pdf_extractor import extract_text_from_pdf
from .services.summariser_service import SummariserService

app = FastAPI(
    title = 'SummariseX API',
    description = "MVP Summarisation API for text, URL and PDF.",
    version = "1.0.0"
)

def error_response(code: str, message: str, status_code: int = 400):
    return JSONResponse(
        status_code = status_code,
        content = {"error" : {"code": code, "message": message}}
    )

@app.post("/summarise", response_model = SummaryResponse)
async def summarise(request: Request):
    """
    Single endpoint that accepts:
    - JSON (application/json) for text/URL inputs
    - multipart/form-data for PDF uploads

    and returns a SummaryResponse or an error object.
    """
    content_type = request.headers.get("content-type", "")

    if "multipart/form-data" in content_type:
        form = await request.form()

        input_type = form.get("input_type")
        length = form.get("length")
        tone = form.get("tone") or "neutral"
        upload: Optional[UploadFile] = form.get("file")

        if input_type != "pdf":
            return error_response(
                "INVALID_INPUT_TYPE",
                "For multipart requests, input_type must be 'pdf'.",
            )
        
        if upload is None:
            return error_response(
                "MISSING_FILE",
                "PDF file is required when input_type is 'pdf'."
            )
        
        contents = await upload.read()
        if len(contents) > settings.max_pdf_size_bytes:
            return error_response(
                "FILE_TOO_LARGE",
                "PDF exceeds maximum allowed size."
            )
        
        from io import BytesIO

        pdf_buffer = BytesIO(contents)

        try:
            raw_text = extract_text_from_pdf(pdf_buffer)
        except Exception:
            return error_response(
                "MODEL_FAILURE",
                "Failed to extract from PDF.",
                status_code = 500
            )
        
        if not raw_text.strip():
            return error_response(
                "MISSING CONTENT",
                "No extractable text found in PDF.",
            )
        
        try:
            parsed, meta = await SummariserService.summarise_text(
                text = raw_text,
                length = length,
                tone = tone
            )
        except ValueError as exc:
            if str(exc) == 'TEXT TOO LONG':
                return error_response(
                    "TEXT_TOO_LONG",
                    "Extracted text seconds allowed length.",
                )
            raise

        return SummaryResponse(
            summary_short = parsed["summary_short"],
            summary_long = parsed["summary_long"],
            key_points = parsed["key_points"],
            meta = meta,
            error = None,
        )
    
    try:
        raw_json = await request.json()
    except Exception:
        return error_response("INALVID_INPUT", "Invalid or missing JSON body")
    
    try:
        body = SummarizeRequest(**raw_json)
    except Exception as exc:
        return error_response("INVALID_INPUT", f"JSON validation failed: {exc}")
    
    if body.input_type not in ("text", "url"):
        return error_response(
            "INVALID_INPUT_TYPE", 
            "For JSON requests, input_type must be 'text' or 'url'."
        )
    
    if not body.content or not body.content.strip():
        return error_response(
            "MISSING_CONTENT",
            "'content' is required for text and url inputs.",
        )

    # Prepare raw text based on input type
    if body.input_type == "text":
        raw_text = body.content
    else:
        # URL case
        try:
            raw_text = await SummariserService.fetch_url_content(body.content)
        except Exception:
            return error_response(
                "URL_FETCH_FAILED",
                "The URL could not be fetched within the allowed time.",
            )

    try:
        parsed, meta = await SummariserService.summarise_text(
            text=raw_text,
            length=body.length,
            tone=body.tone or "neutral",
        )
    except ValueError as exc:
        if str(exc) == "TEXT_TOO_LONG":
            return error_response(
                "TEXT_TOO_LONG",
                "Input text exceeds allowed length.",
            )
        raise

    return SummaryResponse(
        summary_short=parsed["summary_short"],
        summary_long=parsed["summary_long"],
        key_points=parsed["key_points"],
        meta=meta,
        error=None,
    )
