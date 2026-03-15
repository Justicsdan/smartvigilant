# Backend Dockerfile for SmartVigilant
# Using Python 3.12-slim for torch==2.4.1 compatibility (wheels exist for cp312)
# Keeps psycopg2-binary fix in case needed

FROM python:3.12-slim

# System deps for psycopg2-binary (harmless to keep, small overhead)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .

# Upgrade pip (helps with everything)
RUN pip install --upgrade pip

# Install deps — torch 2.4.1 should now install cleanly
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
