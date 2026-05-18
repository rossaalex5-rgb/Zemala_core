#!/usr/bin/env bash
# ZEMALA KI-CONNECTOR v1.9.1 - "Array-Safe Hecht"
set -euo pipefail

ZEMALA_DIR="$HOME/zemala-core"
VAULT_DIR="$ZEMALA_DIR/vault/archive"
INBOX_DIR="$ZEMALA_DIR/vault/inbox"
LOG_FILE="$ZEMALA_DIR/logs/connector.log"

LATEST_LEDGER=$(ls -t "$VAULT_DIR"/zemala-ledger-*.json 2>/dev/null | head -n 1)
[ -z "$LATEST_LEDGER" ] && LATEST_LEDGER=$(ls -t "$INBOX_DIR"/zemala-ledger-*.json 2>/dev/null | head -n 1)

if [ -z "$LATEST_LEDGER" ]; then
    termux-toast -c red "Kein Ledger gefunden."
    exit 1
fi

HASH=$(sha256sum "$LATEST_LEDGER" | awk '{print $1}')
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
FILENAME=$(basename "$LATEST_LEDGER")

# FIX: Wir prüfen erst, ob es ein Array ist. Wenn ja, nimm das erste Element [0].
# Danach suchen wir nach payload, message oder command.
USER_COMMAND=$(jq -r 'if type == "array" then .[0] else . end | .payload // .message // .command // "Kein Befehl gefunden."' "$LATEST_LEDGER")

CONNECTOR_BLOCK="--- [ZEMALA CONTEXT RECONSTRUCTION] ---
STATE_HASH: $HASH
LEDGER_ID: $FILENAME
TIMESTAMP: $TIMESTAMP
SYSTEM_STATUS: IFR-Zelle aktiv

[AKTUELLER BEFEHL AUS HTML-GNOSIS]:
\"$USER_COMMAND\"

[INSTRUKTION]:
Agiere als operative Instanz. Führe den obigen Befehl basierend auf der verifizierten Realität aus.
--------------------------------------------"

echo "$CONNECTOR_BLOCK" | termux-clipboard-set
termux-toast -c gold "Connector bereit (Array-Fix aktiv)"
termux-tts-speak "Kontext rekonstruiert."

echo "$TIMESTAMP | Connector Fix applied | File: $FILENAME" >> "$LOG_FILE"
