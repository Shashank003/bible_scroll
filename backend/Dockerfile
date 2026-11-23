# Build context: repository root, not backend/.
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    HOST=0.0.0.0

WORKDIR /app
COPY backend/server.py /app/backend/server.py
COPY BibleScroll/kjv.json BibleScroll/web.json /app/BibleScroll/

USER nobody
CMD ["python", "backend/server.py"]
