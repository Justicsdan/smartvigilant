from fastapi import APIRouter, UploadFile, File, Depends
import tempfile
from ..services.scanner import virustotal_scan_file
from ..database import get_db
from ..crud import create_scanlog
from sqlalchemy.orm import Session

router = APIRouter()

@router.post("/scan/file")
async def scan_file_endpoint(file: UploadFile = File(...), db: Session = Depends(get_db)):
    with tempfile.NamedTemporaryFile(delete=False) as tmp:
        content = await file.read()
        tmp.write(content)
        path = tmp.name
    vt_result = virustotal_scan_file(path)
    # record minimal log
    create_scanlog(db, filename=file.filename, result=str(vt_result.get("status")), details=str(vt_result))
    return {"filename": file.filename, "vt": vt_result}

