import cv2
from ..config import settings

def detect_motion_from_camera(camera_index=None, max_frames=200):
    idx = camera_index if camera_index is not None else settings.ALLOWED_CAMERA_INDEX
    cap = cv2.VideoCapture(idx)
    # Quick safe check
    if not cap.isOpened():
        return {"error": "camera_unavailable", "message": f"Camera {idx} not accessible"}
    ret, frame1 = cap.read()
    ret, frame2 = cap.read()
    frames_checked = 0
    while ret and frames_checked < max_frames:
        diff = cv2.absdiff(frame1, frame2)
        gray = cv2.cvtColor(diff, cv2.COLOR_BGR2GRAY)
        blur = cv2.GaussianBlur(gray, (5,5), 0)
        _, thresh = cv2.threshold(blur, 20, 255, cv2.THRESH_BINARY)
        dilated = cv2.dilate(thresh, None, iterations=3)
        contours, _ = cv2.findContours(dilated, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
        for c in contours:
            if cv2.contourArea(c) > 2000:
                cap.release()
                return {"motion": True, "message": "Motion detected"}
        frame1 = frame2
        ret, frame2 = cap.read()
        frames_checked += 1
    cap.release()
    return {"motion": False, "message": "No motion detected in sample frames"}

