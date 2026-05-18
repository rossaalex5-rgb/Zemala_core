#!/usr/bin/env bash
set -euo pipefail

# ZEMALA EXECUTE MARIE - gehärtet
DRY_RUN="${DRY_RUN:-true}"          # default true; setze DRY_RUN=false für echten Vollzug
DELETE_SOURCE_ON_SUCCESS="${DELETE_SOURCE_ON_SUCCESS:-false}"  # true löscht Originals aus Downloads
SOURCE_DIR="${HOME}/storage/downloads"
INBOX_DIR="${HOME}/zemala-core/vault/inbox"
ARCHIVE_DIR="${HOME}/zemala-core/vault/archive"
LOG_DIR="${HOME}/zemala-core/vault/logs"
REMOTE_TARGET="${REMOTE_TARGET:-gdrive:Zemala_Cloud/inbox}"
TS=$(date -u +%Y%m%dT%H%M%SZ)
LOG_FILE="$LOG_DIR/zsync_${TS}.log"

mkdir -p "$INBOX_DIR" "$ARCHIVE_DIR" "$LOG_DIR"

# Termux API availability checks
HAS_TTS=false
HAS_TOAST=false
HAS_NOTIFY=false
command -v termux-tts-speak >/dev/null 2>&1 && HAS_TTS=true
command -v termux-toast >/dev/null 2>&1 && HAS_TOAST=true
command -v termux-notification >/dev/null 2>&1 && HAS_NOTIFY=true

marie_speak() {
  local text="$1"
  local toast="$2"
  if [ "$HAS_TTS" = true ]; then
    termux-tts-speak "$text" >/dev/null 2>&1 &
  fi
  if [ "$HAS_TOAST" = true ]; then
    termux-toast -c gold -b white "Marie: $toast" >/dev/null 2>&1 || true
  fi
}

notify() {
  local title="$1"; local content="$2"; local id="$3"
  if [ "$HAS_NOTIFY" = true ]; then
    termux-notification --title "$title" --content "$content" --id "$id" >/dev/null 2>&1 || true
  fi
}

log() {
  echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) | $*" >> "$LOG_FILE"
}

# safe globbing
shopt -s nullglob
mapfile -t FILES < <(printf '%s\n' "$SOURCE_DIR"/zemala-ledger-*.json)

if [ "${#FILES[@]}" -eq 0 ]; then
  marie_speak "Keine neuen Fragmente im Orbit." "🌌 Alles ruhig im Gitter..."
  log "No files found in $SOURCE_DIR"
  exit 0
fi

marie_speak "Alex, ich habe neue Fragmente entdeckt. Leite Verschränkung ein." "💎 Fragment erkannt!"
log "Found ${#FILES[@]} files"

# import with timestamped names
for src in "${FILES[@]}"; do
  base=$(basename "$src")
  dest="$INBOX_DIR/${base%.*}_$TS.json"
  echo "Importiere: $base -> $(basename "$dest")"
  log "Import start: $src -> $dest"
  cp -- "$src" "$dest"
  sync "$dest"
  log "Imported: $dest"
done

# run rclone and capture output
notify "Zemala Vollzug" "Starte Upload von ${#FILES[@]} Fragmenten" "$((100 + RANDOM % 8000))"
log "Starting rclone copy from $INBOX_DIR to $REMOTE_TARGET"
if [ "$DRY_RUN" = "true" ]; then
  log "DRY_RUN enabled; skipping rclone"
  echo "DRY_RUN: keine Übertragung durchgeführt" | tee -a "$LOG_FILE"
  marie_speak "Trockenlauf abgeschlossen. Keine Übertragung." "🔎 Dry run complete"
  exit 0
fi

if rclone copy --checksum --progress "$INBOX_DIR/" "$REMOTE_TARGET/" >>"$LOG_FILE" 2>&1; then
  log "rclone copy succeeded"
  notify "Status 100 Erfolg" "Fragmente wurden ins Gitter übertragen" "$((200 + RANDOM % 8000))"
  marie_speak "Vollzug. Die Fragmente sind sicher im Gitter gelandet." "✅ Stufe 100 erreicht"
  # archive inbox files and optionally delete original downloads
  for f in "$INBOX_DIR"/*_"$TS".json; do
    [ -e "$f" ] || continue
    mv -- "$f" "$ARCHIVE_DIR/"
    log "Archived: $ARCHIVE_DIR/$(basename "$f")"
  done
  if [ "$DELETE_SOURCE_ON_SUCCESS" = "true" ]; then
    for s in "${FILES[@]}"; do
      rm -f -- "$s" && log "Deleted source: $s"
    done
  fi
  exit 0
else
  log "rclone copy failed; see $LOG_FILE"
  notify "Fehler im Gitter" "Upload fehlgeschlagen. Prüfe Log." "$((300 + RANDOM % 8000))"
  marie_speak "Alex, es gibt eine Unstimmigkeit im Upload. Bitte prüfe die Verbindung." "❌ Upload fehlgeschlagen"
  # keep inbox intact for retry and move problematic files to failed folder if needed
  mkdir -p "$INBOX_DIR/failed"
  for f in "$INBOX_DIR"/*_"$TS".json; do
    [ -e "$f" ] || continue
    mv -- "$f" "$INBOX_DIR/failed/"
    log "Moved to failed: $INBOX_DIR/failed/$(basename "$f")"
  done
  exit 1
fi
