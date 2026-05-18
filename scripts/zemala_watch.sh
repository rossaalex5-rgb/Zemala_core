#!/bin/bash
INBOX="$HOME/zemala-core/inbox"
ARCHIVE="$HOME/zemala-core/archive"
echo "Zemala Watcher aktiv. Takt: 3,47s"
while true; do
  for f in "$INBOX"/*.json; do
    [ -e "$f" ] || continue
    bash ~/zemala-core/scripts/process_event.sh "$f"
    mv "$f" "$ARCHIVE/"
  done
  sleep 3.47
done
