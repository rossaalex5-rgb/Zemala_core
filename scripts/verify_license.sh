#!/bin/bash
# ZEMALA-CORE V2.1 — B2B License Verification Gate

LICENSE_FILE="core/license_vault.json"

if [ ! -f "$LICENSE_FILE" ]; then
    echo "[-] CRITICAL ERROR: License Vault vermisst. System wechselt in den READ-ONLY-AUDIT-MODUS."
    exit 1
fi

# Auslesen der Lizenz-Stufe (Rauschfreie Extraktion)
TIER=$(grep -o '"license_tier": "[^"]*' "$LICENSE_FILE" | cut -d'"' -f4)
HOLDER=$(grep -o '"holder": "[^"]*' "$LICENSE_FILE" | cut -d'"' -f4)

if [ "$TIER" == "PREMIUM" ]; then
    echo "[+] ZEMALA B2B LICENSE: PASS [Tier: $TIER | Holder: $HOLDER]"
    
    # Protokollierung des Lizenz-Audits im Ledger
    TIMESTAMP=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
    echo "{\"timestamp\":\"$TIMESTAMP\",\"event\":\"b2b_license_audit\",\"tier\":\"$TIER\",\"status\":\"PASS\"}" >> logs/master_history.jsonl
    exit 0
else
    echo "[*] ZEMALA B2B LICENSE: TRIAL MODUS. Cloud-Relay gedrosselt."
    exit 2
fi
