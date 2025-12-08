from typing import IO
from pypdf import PdfReader

def extract_text_from_pdf(file_like: IO[bytes]) -> str: #extract text from a pdf-like binary object
    reader = PdfReader(file_like)
    pages_text = []

    for page in reader.pages:
        text = page.extract_text() or ""
        pages_text.append(text)
    
    return "\n\n".join(pages_text).strip()