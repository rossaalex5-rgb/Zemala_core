#!/usr/bin/env bash
set -e
DOWNLOAD_DIR="/sdcard/Download"
INBOX_DIR="$HOME/zemala-core/vault/inbox"
PROCESSOR="$HOME/zemala-core/scripts/zemala_execute.sh"

shopt -s nullglob
for f in "$DOWNLOAD_DIR"/zemala-ledger-*.json; do
  echo "In Inbox verschoben: $f"
  mv "$f" "$INBOX_DIR/"
done

if [ -x "$PROCESSOR" ]; then
  bash "$PROCESSOR"
fi
