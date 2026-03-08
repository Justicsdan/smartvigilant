from sqlalchemy.orm import Session
from . import models

def create_scanlog(db: Session, filename: str, result: str, details: str = None):
    log = models.ScanLog(filename=filename, result=result, details=details)
    db.add(log)
    db.commit()
    db.refresh(log)
    return log

def create_alert(db: Session, source: str, level: str, message: str):
    alert = models.Alert(source=source, level=level, message=message)
    db.add(alert)
    db.commit()
    db.refresh(alert)
    return alert

def register_protected_app(db: Session, name: str, token: str, info: str = None):
    app = models.ProtectedApp(name=name, token=token, info=info)
    db.add(app)
    db.commit()
    db.refresh(app)
    return app

