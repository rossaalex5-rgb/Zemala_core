#!/usr/bin/env bash
set -euo pipefail

# ZEMALA DRIVE SYNC - Die direkte Cloud-Schiene
# Wir gehen davon aus, dass dein rclone-Remote "gdrive" heißt.
# Pfad im Drive: Zemala_Master/KI_Output
REMOTE="gdrive:Zemala_Master/KI_Output"
LOCAL_INBOX="$HOME/zemala-core/vault/inbox"

echo "Prüfe Cloud-Orbit auf neue Resonanz..."

# rclone copy zieht nur neue Dateien und überschreibt nichts lokales
rclone copy "$REMOTE" "$LOCAL_INBOX" --include "fix*.sh"

# Status-Check
COUNT=$(ls -1 "$LOCAL_INBOX"/fix*.sh 2>/dev/null | wc -l)
if [ "$COUNT" -gt 0 ]; then
    echo "Resonanz gefunden: $COUNT neue Datei(en) in der Inbox."
    echo "Starte jetzt: ~/zemala-core/scripts/zemala_execute.sh"
else
    echo "Der Orbit ist ruhig. Keine neuen Instruktionen."
fi
