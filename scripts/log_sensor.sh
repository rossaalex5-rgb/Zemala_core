#!/bin/bash
# ZEMALA-CORE V2.1 — Manual Sensor Input (Safe LinkedIn Tracker)

EVENT_SOURCE=$1
IMPACT_SCORE=$2

if [ -z "$EVENT_SOURCE" ] || [ -z "$IMPACT_SCORE" ]; then
    echo "[-] Syntax: ./scripts/log_sensor.sh [Quelle] [Impact 0.0-1.0]"
    exit 1
fi

TIMESTAMP=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
# Kanonischer Schutz
CLEAN_SOURCE=$(echo "$EVENT_SOURCE" | tr -d ' \n\r')

# JSON-Struktur für den Ledger generieren
JSON_LINE=$(printf '{"timestamp":"%s","event":"linkedin_interaction","source":"%s","impact":%s,"status":"PASS"}' "$TIMESTAMP" "$CLEAN_SOURCE" "$IMPACT_SCORE")

# In die master_history einbrennen
echo "$JSON_LINE" >> logs/master_history.jsonl

echo "[+] SENSOR REGISTERED. Zustand im Ledger fixiert."

# Optionaler Git-Vollzug zur SSoT-Absicherung
git add logs/master_history.jsonl
git commit -m "sensor: log external resonance stream from $CLEAN_SOURCE"
git push origin main
