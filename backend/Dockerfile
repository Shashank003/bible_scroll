# Railway Root Directory: /backend
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    HOST=0.0.0.0

WORKDIR /app
COPY server.py /app/server.py
COPY data/ /app/data/

USER nobody
CMD ["python", "server.py"]
