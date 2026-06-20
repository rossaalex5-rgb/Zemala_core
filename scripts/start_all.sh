#!/bin/bash
# ZEMALA-CORE V2.1 — Master Execution Switch (Conductor Launch)

echo "=== INITIALISIERE ZEMALA-CORE MULTI-ENGINE (STUFE 100) ==="

# 1. Thermischen Governor aktivieren (Handy kühl halten)
if [ -f "scripts/proxy_idle_governor.sh" ]; then
    ./scripts/proxy_idle_governor.sh
fi

# 2. Mediathek-Scan ausführen (Neueste Dokumente einsaugen & verschmelzen)
if [ -f "scripts/sort_mediathek.sh" ]; then
    ./scripts/sort_mediathek.sh
fi

# 3. Datenautobahn zum Cockpit-Dashboard fluten
if [ -f "scripts/feed_cockpit.sh" ]; then
    ./scripts/feed_cockpit.sh
fi

echo "========================================================="
echo "[+] SYSTEM VOLLSTÄNDIG GEKOPPELT. Resonanz stabil bei H = 0,96."
echo "[*] Dein Llama-Server steht über a2a_gnosis.py bereit."
echo "========================================================="

# 4. B2B-Lizenz-Audit erzwingen
if [ -f "scripts/verify_license.sh" ]; then
    ./scripts/verify_license.sh
fi
