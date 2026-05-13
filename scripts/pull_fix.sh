#!/usr/bin/env bash
set -euo pipefail
# ZEMALA PULL - Sicherer Import in den Core
SRC="$HOME/storage/downloads/fix.sh"
TS=$(date -u +%Y%m%dT%H%M%SZ)
DEST_DIR="$HOME/zemala-core/vault/inbox"
DEST="$DEST_DIR/fix_${TS}.sh"

if [ ! -f "$SRC" ]; then
  echo "Warte auf Resonanz im Briefkasten (Downloads)..."
  exit 0
fi

cp "$SRC" "$DEST" && sync "$DEST"
# Meta-Daten für die Integrität erzeugen
sha256sum "$DEST" | awk '{print $1}' > "${DEST}.sha256"
echo "Fix erfolgreich als $(basename "$DEST") importiert."
