# SmartVigilant Backend (Starter)

## Quick start (local)
1. Create virtualenv:
   python -m venv .venv
   source .venv/bin/activate

2. Install deps:
   pip install -r requirements.txt

3. (Optional) Set VirusTotal API key:
   export VIRUSTOTAL_API_KEY="your_api_key"

4. Start server:
   uvicorn app.main:app --reload --port 8000

Open: http://127.0.0.1:8000/docs for interactive Swagger UI.

## Notes
- AI anomaly model: `app/ai_engine/anomaly.py` uses IsolationForest.
  Train with `train_and_save(X)` (X = list of feature vectors) and then the `/api/analyze` endpoint will use the model.
- Motion detection uses local camera; running in container may not access your host camera.
- Replace placeholders and extend services (notifier -> Firebase/Twilio, scanner -> YARA, defensive hooks -> OS integrations).

