#!/bin/bash
BASE_DIR="$HOME/zemala-core"
LEDGER="$BASE_DIR/ledger/master_ledger.jsonl"
LOG="$BASE_DIR/ledger/system.log"

log_event() { echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG"; }

FILE=$1
raw_content=$(cat "$FILE")
# Extraktion zwischen den Markern
content=$(echo "$raw_content" | sed -n '/BEGIN_EVENT/,/END_EVENT/p' | sed '1d;$d')

if [[ -z "$content" ]]; then
    log_event "REJECT: Kein Event-Block in $FILE"
    exit 1
fi

# Validierung & Execution (GPT-Logik)
cmd=$(echo "$content" | jq -r '.cmd // .command // empty')
case "$cmd" in
  "echo")
    msg=$(echo "$content" | jq -r '.payload.msg')
    echo "[EXEC] $msg" ;;
  "update_metadata")
    vid=$(echo "$content" | jq -r '.payload.videoid')
    echo "[EXEC] Metadaten für Video $vid aktualisiert." ;;
  *)
    log_event "REJECT: Unbekannter Befehl '$cmd'"
    exit 3 ;;
esac

echo "$content" >> "$LEDGER"
log_event "SUCCESS: Event in Ledger verewigt."
