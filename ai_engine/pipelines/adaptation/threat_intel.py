# threat_intel.py - Pull and integrate live threat feeds (cyber + natural disasters)
import requests
import json
import logging
from datetime import datetime
import os

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class ThreatIntelligenceIntegrator:
    def __init__(self):
        self.vt_api_key = os.getenv("VIRUSTOTAL_API_KEY")
        self.otx_api_key = os.getenv("ALIENVAULT_OTX_KEY")
        self.noaa_key = os.getenv("NOAA_API_KEY", "public")
        
    def fetch_cyber_intel(self):
        """Pull latest indicators from VirusTotal & AlienVault OTX"""
        headers = {"x-apikey": self.vt_api_key}
        
        # Recent malware hashes
        vt_url = "https://www.virustotal.com/api/v3/intelligence/search"
        query = "tag:malware AND positives:>20 AND first_submission_date:2026-01-01"
        try:
            response = requests.get(f"{vt_url}?query={query}", headers=headers)
            new_hashes = [item['id'] for item in response.json()['data'][:50]]
            self.update_malware_signatures(new_hashes)
        except Exception as e:
            logger.error(f"VirusTotal fetch failed: {e}")
        
        # OTX pulses (AI threats, agentic patterns)
        otx_url = f"https://otx.alienvault.com/api/v1/pulses/subscribed?modified_since=2026-01-01"
        otx_headers = {"X-OTX-API-KEY": self.otx_api_key}
        try:
            pulses = requests.get(otx_url, headers=otx_headers).json()
            ai_threat_iocs = [ioc for pulse in pulses['results'] for ioc in pulse['indicators'] if 'agentic' in pulse['tags'] or 'deepfake' in pulse['tags']]
            self.flag_ai_threat_patterns(ai_threat_iocs)
        except Exception as e:
            logger.error(f"OTX fetch failed: {e}")
    
    def fetch_disaster_intel(self):
        """NOAA + USGS real-time alerts"""
        # Severe weather
        noaa_url = "https://api.weather.gov/alerts/active?area=US"
        alerts = requests.get(noaa_url, headers={"User-Agent": "SmartVigilant/1.0"}).json()
        active_events = [f"{a['properties']['event']} in {a['properties']['areaDesc']}" for a in alerts.get('features', [])]
        
        # Earthquakes
        usgs_url = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/significant_month.geojson"
        quakes = requests.get(usgs_url).json()
        recent_quakes = [f"M{q['properties']['mag']} {q['properties']['place']}" for q in quakes['features']]
        
        self.broadcast_disaster_alerts(active_events + recent_quakes)
    
    def update_malware_signatures(self, new_hashes: list):
        with open('../../../data/cyber/threat_signatures_latest.json', 'w') as f:
            json.dump({"malware_hashes": new_hashes, "updated": datetime.utcnow().isoformat()}, f)
        logger.info(f"Updated malware signatures with {len(new_hashes)} new threats")
    
    def flag_ai_threat_patterns(self, iocs: list):
        # Trigger retraining signal for agentic/deepfake models
        logger.warning(f"New AI threat patterns detected: {len(iocs)} IOCs – triggering model adaptation")
    
    def broadcast_disaster_alerts(self, events: list):
        if events:
            with open('../../../data/human/active_disasters.json', 'w') as f:
                json.dump({"alerts": events, "timestamp": datetime.utcnow().isoformat()}, f)
            logger.warning(f"Broadcasting {len(events)} active disaster alerts to clients")

def run_daily_threat_intel_cycle():
    integrator = ThreatIntelligenceIntegrator()
    integrator.fetch_cyber_intel()
    integrator.fetch_disaster_intel()
    logger.info("Threat intelligence cycle completed – SmartVigilant is now smarter")

if __name__ == "__main__":
    run_daily_threat_intel_cycle()
