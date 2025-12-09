# SummariseX – AI-Powered Document Summarisation  
**Understanding, Accelerated.**

SummariseX is a full-stack AI summarisation system capable of processing **text**, **URLs**, and **PDF documents**, delivering clear and structured insights.  
Built using **Flutter** (mobile app) and **FastAPI** (backend), SummariseX integrates advanced language models to convert long content into actionable summaries.

---

## 🚀 Features

- **Text, URL, and PDF summarisation**
- **Chat-style interactive interface**
- **Quick + detailed summaries**
- **Key points extraction**
- **Local chat history persistence**
- **Cloud-deployed FastAPI backend**
- **Configurable summary length + tone**

---

![WhatsApp Image 2025-12-08 at 20 40 51_5a930c3e](https://github.com/user-attachments/assets/bd1712d2-2266-4332-b463-f99c3915110e)


## 🛠 Tech Stack

**Frontend (Flutter)**
- Provider state management  
- SharedPreferences persistence  
- File Picker  
- Clean, modular architecture  

**Backend (FastAPI)**
- RESTful summarisation endpoint  
- Multipart PDF handling  
- Uvicorn ASGI server  
- Render deployment-ready  

---

## 📡 API Overview

**POST /summarise**  
Accepts:
```json
{
  "input_type": "text | url | pdf",
  "content": "...",
  "length": "short | medium | long",
  "tone": "neutral | formal | casual"
}
```

Returns:
```json
{
  "summary_short": "...",
  "summary_long": "...",
  "key_points": ["..."],
  "meta": {...},
  "error": null
}
```

---

## 📱 Running Locally

Backend:
```bash
uvicorn backend.main:app --reload
```

Frontend:
```bash
cd frontend
flutter run
```

To use the deployed backend, update:
```
lib/config/app_config.dart
```

---

## 🌐 Deployment

Backend deployed on Render:

```
uvicorn backend.main:app --host 0.0.0.0 --port $PORT
```

Dependencies:
```
backend/requirements.txt
```

---

## 📁 Project Structure

```
SummariseX/
├── backend/        # FastAPI application
├── frontend/       # Flutter mobile application
└── README.md
```

---

## 📌 Author  
**Gotham Kothari**  
AI/ML + Full-Stack Engineering
