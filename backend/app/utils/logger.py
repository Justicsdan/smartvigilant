# logger.py - Structured logging with JSON output for monitoring
import logging
import sys
from loguru import logger as loguru_logger
from pythonjsonlogger import jsonlogger

def setup_logger():
    # Remove default handlers
    loguru_logger.remove()
    
    # JSON formatted logs for ELK/CloudWatch
    json_handler = loguru_logger.add(
        sys.stdout,
        format="<green>{time:YYYY-MM-DD HH:mm:ss}</green> | <level>{level: <8}</level> | <cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> - <level>{message}</level>",
        level="INFO",
        serialize=True  # JSON output
    )
    
    # Also add simple console for local dev
    loguru_logger.add(
        sys.stderr,
        format="<green>{time:YYYY-MM-DD HH:mm:ss}</green> | <level>{level: <8}</level> | <cyan>{name}</cyan>:<cyan>{function}</cyan> - <level>{message}</level>",
        level="DEBUG",
        colorize=True
    )
    
    return loguru_logger

# Global logger
logger = setup_logger()

# Example usage in other modules:
# from app.utils.logger import logger
# logger.info("Threat neutralized", extra={"threat_type": "agentic_ai", "user_id": "123"})
