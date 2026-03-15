# Backend Dockerfile for SmartVigilant
# Using Python 3.12 for torch==2.4.1 compatibility + psycopg2-binary support

FROM python:3.12-slim

# Install build dependencies (for psycopg2-binary if wheel not auto-selected)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .

# Upgrade pip (good practice)
RUN pip install --upgrade pip

# Install dependencies (torch 2.4.1 should now have matching wheels)
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

# Adjust CMD if your FastAPI file is not app.py (e.g., "app.main:app" if in app/main.py)
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
