import requests
import os
from ..config import settings

VT_UPLOAD_URL = "https://www.virustotal.com/api/v3/files"
VT_ANALYSE_URL_TEMPLATE = "https://www.virustotal.com/api/v3/analyses/{}"

def virustotal_scan_file(filepath: str):
    api_key = settings.VIRUSTOTAL_API_KEY
    if not api_key:
        return {"status": "unavailable", "message": "VirusTotal API key not configured"}
    headers = {"x-apikey": api_key}
    with open(filepath, "rb") as f:
        files = {"file": (os.path.basename(filepath), f)}
        r = requests.post(VT_UPLOAD_URL, headers=headers, files=files, timeout=60)
    if r.status_code != 200 and r.status_code != 201:
        return {"status": "error", "message": r.text, "code": r.status_code}
    try:
        data = r.json()
        analysis_id = data.get("data", {}).get("id")
        if analysis_id:
            # try to fetch quick result (best-effort)
            resp = requests.get(VT_ANALYSE_URL_TEMPLATE.format(analysis_id), headers=headers, timeout=20)
            return {"status": "queued", "analysis": resp.json() if resp.status_code==200 else None}
    except Exception as e:
        return {"status": "error", "message": str(e)}
    return {"status": "uploaded", "data": data}

