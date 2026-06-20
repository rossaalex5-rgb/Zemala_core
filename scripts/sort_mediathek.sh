#!/bin/bash
# ZEMALA-CORE V2.1 — Mediathek Document Sorting Engine (Internal Storage Bridge)

echo "[*] ZEMALA INGEST: Scanne den internen Speicher (~/storage/shared/)..."

# Pfade zum Android-Dokumenten- und Download-Ordner definieren
ANDROID_DOCS="$HOME/storage/shared/Documents"
ANDROID_DOWNLOADS="$HOME/storage/shared/Download"
TARGET_DIR="core/memory"

FOUND_COUNT=0

# Suchschleife für deine realen Manifeste und Imperiums-Dokumente
for SOURCE_DIR in "$ANDROID_DOCS" "$ANDROID_DOWNLOADS"; do
    if [ -d "$SOURCE_DIR" ]; then
        # Kopiert alle Textdateien, die mit "Zemala" oder "Dezentrales" beginnen
        for FILE in "$SOURCE_DIR"/[Zz]emala*.txt "$SOURCE_DIR"/[Dd]ezentrales*.txt; do
            if [ -f "$FILE" ]; then
                FILENAME=$(basename "$FILE")
                echo "[+] Dokument lokalisiert: $FILENAME"
                cp "$FILE" "$TARGET_DIR/"
                FOUND_COUNT=$((FOUND_COUNT + 1))
            fi
        done
    fi
done

echo "[+] Scan beendet. $FOUND_COUNT neue Dokumente in den Kern-Speicher überführt."

# Wenn neue Fragmente gefunden wurden, direkt das Kollektiv-Gedächtnis neu verschmelzen
if [ $FOUND_COUNT -gt 0 ]; then
    python3 scripts/merge_memory.py
fi

# Audit-Protokollierung im Ledger
TIMESTAMP=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
echo "{\"timestamp\":\"$TIMESTAMP\",\"event\":\"mediathek_ingest_run\",\"files_found\":$FOUND_COUNT,\"status\":\"PASS\"}" >> logs/master_history.jsonl

# SSoT-Update im Gitter absichern
git add core/memory/ logs/master_history.jsonl 2>/dev/null
git commit -m "sync: auto-ingest and sort real documents from internal storage mediathek" 2>/dev/null
git push origin main 2>/dev/null
