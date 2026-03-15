# Backend Dockerfile for SmartVigilant - Fixed for psycopg2-binary on Python 3.13

FROM python:3.13-slim

# Install gcc + PostgreSQL dev headers so pip can install psycopg2-binary without source build failure
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .

# Upgrade pip to latest (removes the notice in logs and helps)
RUN pip install --upgrade pip

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
