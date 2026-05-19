#!/data/data/com.termux/files/usr/bin/bash
INBOX_FILE="$HOME/zemala-core/vault/inbox.md"
ARCHIVE_DIR="$HOME/zemala-core/vault/captures"
RAW_PHOTO="/tmp/raw_capture.jpg"
TEMP_OCR="/tmp/sentry_ocr"

mkdir -p "$ARCHIVE_DIR"
TIMESTAMP_FILE=$(date +"%Y%m%d_%H%M%S")
ARCHIVED_PHOTO="$ARCHIVE_DIR/sentry_${TIMESTAMP_FILE}.jpg"

BATTERY_LEVEL=$(termux-battery-status | grep "percentage" | awk -F: '{print $2}' | tr -d ', ')
termux-tts-speak -l de-DE "Sentry-Modus aktiv. Akku $BATTERY_LEVEL Prozent."

if command -v rish &> /dev/null; then
    rish -c "settings put global low_power 1" &> /dev/null
    rish -c "settings put system screen_brightness 1" &> /dev/null
fi

if ! termux-camera-photo -c 0 "$RAW_PHOTO" &> /dev/null; then
    termux-tts-speak -l de-DE "Kamera blockiert."
    exit 1
fi

if command -v ffmpeg &> /dev/null; then
    ffmpeg -i "$RAW_PHOTO" -vf "scale=1080:-1" -q:v 5 "$ARCHIVED_PHOTO" -y &> /dev/null
else
    cp "$RAW_PHOTO" "$ARCHIVED_PHOTO"
fi

SIZE_ARCHIVED=$(du -sh "$ARCHIVED_PHOTO" | cut -f1)
termux-vibrate -d 50

tesseract "$ARCHIVED_PHOTO" "$TEMP_OCR" -l deu+eng &> /dev/null

if [ -f "${TEMP_OCR}.txt" ]; then
    EXTRACTED_TEXT=$(cat "${TEMP_OCR}.txt" | sed '/^[[:space:]]*$/d')
    if [ -n "$EXTRACTED_TEXT" ]; then
        TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
        {
            echo -e "\n---"
            echo -e "### 🔋 FIELD-SENTRY CAPTURE ($TIMESTAMP)"
            echo -e "**Akku-Status:** $BATTERY_LEVEL%"
            echo -e "**Bild:** $ARCHIVED_PHOTO ($SIZE_ARCHIVED)"
            echo -e "\n\`\`\`text"
            echo -e "$EXTRACTED_TEXT"
            echo -e "\`\`\`"
        } >> "$INBOX_FILE"
        PREVIEW_TEXT=$(echo "$EXTRACTED_TEXT" | head -n 3 | tr '\n' ' ')
        termux-tts-speak -l de-DE "Gespeichert. Groesse $SIZE_ARCHIVED. Inhalt: $PREVIEW_TEXT"
    else
        termux-tts-speak -l de-DE "Kein Text erkannt."
    fi
    rm -f "$RAW_PHOTO"
    rm -f "${TEMP_OCR}.txt"
else
    termux-tts-speak -l de-DE "OCR Fehler."
    rm -f "$RAW_PHOTO"
fi

if command -v rish &> /dev/null; then
    rish -c "input keyevent 26" &> /dev/null
fi
