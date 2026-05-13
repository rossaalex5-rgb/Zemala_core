#!/usr/bin/env bash
set -euo pipefail
# ZEMALA EXECUTE - Gehärteter Vollzug
VAULT="$HOME/zemala-core/vault"
INBOX="$VAULT/inbox"
FAILED="$VAULT/failed"
ARCHIVE="$VAULT/archive"
LOGS="$VAULT/logs"

for f in "$INBOX"/*.sh; do
  [ -e "$f" ] || continue
  echo "--- PRÜFUNG ZEMALA CORE: $(basename "$f") ---"
  
  # 1. Syntax-Check (Keine Ausführung bei Fehlern)
  bash -n "$f" || { echo "Syntaxfehler erkannt! Schiebe nach failed."; mv "$f" "$FAILED/"; continue; }
  
  # 2. Dangerous Pattern Scan (Einfacher Schutz)
  if grep -E "(rm -rf /|:(){:|forkbomb)" "$f"; then
    echo "GEFAHR: Verdächtiges Muster gefunden! Schiebe nach failed."
    mv "$f" "$FAILED/"
    continue
  fi

  cat "$f"
  echo "-------------------------------------------"
  read -p "Vollzug bestätigen? [y/N]: " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    # Ausführung mit 5 Min Timeout und Logging
    timeout 300 bash "$f" 2>&1 | tee "$LOGS/$(basename "$f")_$(date +%s).log"
    mv "$f" "$ARCHIVE/"
    echo "Vollzug abgeschlossen und archiviert."
  else
    echo "Abgebrochen. Datei bleibt in der Inbox."
  fi
done
