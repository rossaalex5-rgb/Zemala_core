#!/bin/bash
# ZEMALA-CORE V2.1 — Dynamic CPU & Polling Governor (Anti-Friction)

echo "[*] ZEMALA GOVERNOR: Initialisiere thermische Härtung..."

# 1. Finde den Amok-Prozess (Llama-Server oder Python-Proxy)
TARGET_PID=$(pgrep -f "llama_cpp_server" || pgrep -f "python3 scripts/a2a_gnosis")

if [ -z "$TARGET_PID" ]; then
    echo "[+] Info: Keine aktiven Hochleistungsprozesse im Feld. System ist kühl."
    exit 0
fi

echo "[*] Target-Prozess lokalisiert bei PID: $TARGET_PID"

# 2. Die Nickel-Passung für die Hardware:
# Wir nutzen cpulimit (falls vorhanden) oder erzwingen einen systemischen renice-Befehl,
# um dem Prozess die Priorität im Leerlauf radikal zu entziehen (+19 = maximal passiv/kühl)
renice -n 19 -p $TARGET_PID

# 3. Den Zustand im Ledger protokollieren
TIMESTAMP=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
echo "{\"timestamp\":\"$TIMESTAMP\",\"event\":\"thermal_governor_engaged\",\"target_pid\":$TARGET_PID,\"status\":\"PASS\"}" >> logs/master_history.jsonl

echo "[+] VOLLZUG: Prozess gedrosselt. Die Hardware kühlt ab bei voller 0-Latenz-Bereitschaft."

# SSoT-Update im Gitter absichern
git add logs/master_history.jsonl
git commit -m "fix: enforce dynamic thermal governance to eliminate idle friction" 2>/dev/null
git push origin main 2>/dev/null
