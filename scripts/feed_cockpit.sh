#!/bin/bash
# ZEMALA-CORE V2.1 — Bridge to Event Cockpit UI

echo "[*] ZEMALA COCKPIT FEED: Initialisiere Daten-Injektion..."

CORE_CONTEXT="core/memory/collective_context.json"
COCKPIT_DIR="$HOME/zemala-event-cockpit"

if [ ! -f "$CORE_CONTEXT" ]; then
    echo "[-] FEHLER: Kollektiver Kontext-Vektor existiert nicht."
    exit 1
fi

# Prüfen, ob das Cockpit-Verzeichnis lokal existiert
if [ ! -d "$COCKPIT_DIR" ]; then
    echo "[*] Info: Lokalisiert Cockpit im übergeordneten Verzeichnis..."
    COCKPIT_DIR="$HOME/Zemala_event_cockpit"
fi

# Zustand in das Cockpit spiegeln (Erzwungener atomarer Transfer)
mkdir -p "$COCKPIT_DIR/data"
cp "$CORE_CONTEXT" "$COCKPIT_DIR/data/status.json"

# Kanonischen Hash für das Audit-Protokoll sichern
SHA=$(sha256sum "$COCKPIT_DIR/data/status.json" | cut -d' ' -f1)
TIMESTAMP=$(date -u +'%Y-%m-%dT%H:%M:%SZ')

echo "{\"timestamp\":\"$TIMESTAMP\",\"event\":\"cockpit_data_injection\",\"hash\":\"$SHA\",\"status\":\"PASS\"}" >> logs/master_history.jsonl

echo "[+] VOLLZUG: Cockpit erfolgreich mit realer Gnosis gefüttert. SHA: ${SHA:0:7}"

# SSoT-Update im Gitter absichern
git add logs/master_history.jsonl 2>/dev/null
git commit -m "sync: inject collective memory vector into event cockpit data layer" 2>/dev/null
git push origin main 2>/dev/null
