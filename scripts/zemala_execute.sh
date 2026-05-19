#!/usr/bin/env bash
set -euo pipefail
INBOX_DIR="$HOME/zemala-core/vault/inbox"
ARCHIVE_DIR="$HOME/zemala-core/vault/archive"
LOCK_EMIT="$HOME/zemala-core/scripts/lock_emit.sh"

shopt -s nullglob
for file in "$INBOX_DIR"/zemala-ledger-*.json; do
  echo "Verarbeite: $file"
  if [ -x "$LOCK_EMIT" ]; then
    bash "$LOCK_EMIT" "$file"
  fi
  mv "$file" "$ARCHIVE_DIR/"
  echo "Erfolgreich archiviert."
done
